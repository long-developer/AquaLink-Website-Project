require('dotenv').config();

const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const { GoogleGenAI } = require('@google/genai');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

app.use(cors());
app.use(express.json());

const rateLimitWindowMs = 60 * 1000;
const rateLimitMaxRequests = 30;
const requestCounts = new Map();

setInterval(() => {
    const now = Date.now();
    for (const [ip, entry] of requestCounts) {
        if (entry.resetAt <= now) {
            requestCounts.delete(ip);
        }
    }
}, rateLimitWindowMs).unref();

function chatRateLimit(req, res, next) {
    const now = Date.now();
    const ip = req.ip;
    let entry = requestCounts.get(ip);

    if (!entry || entry.resetAt <= now) {
        entry = { count: 0, resetAt: now + rateLimitWindowMs };
        requestCounts.set(ip, entry);
    }

    entry.count += 1;
    const remaining = Math.max(0, rateLimitMaxRequests - entry.count);
    res.set('X-RateLimit-Limit', rateLimitMaxRequests);
    res.set('X-RateLimit-Remaining', remaining);
    res.set('X-RateLimit-Reset', Math.ceil(entry.resetAt / 1000));

    if (entry.count > rateLimitMaxRequests) {
        const retryAfter = Math.ceil((entry.resetAt - now) / 1000);
        res.set('Retry-After', retryAfter);
        return res.status(429).json({
            error: 'Quá nhiều yêu cầu. Vui lòng thử lại sau.',
        });
    }

    next();
}

// Kiểm tra API Key đã được nạp từ file .env chưa
const apiKey = process.env.GEMINI_KEY_FREE || process.env.GEMINI_KEY_PAID;
if (!apiKey) {
    console.error("❌ CHƯA CÓ API KEY! Hãy kiểm tra lại file .env hoặc biến môi trường Render.");
} else {
    console.log("🔑 Đã nhận API Key thành công.");
}

const ai = apiKey ? new GoogleGenAI({ apiKey }) : null;

// Route test server
app.get('/', (req, res) => {
    res.send('Server AquaLink đang chạy ngon lành!');
});

// Endpoint Chat AI
app.post('/api/chat', chatRateLimit, async (req, res) => {
    try {
        const { message } = req.body;

        if (!message) {
            return res.status(400).json({ error: 'Nội dung tin nhắn không được để trống' });
        }

        if (!ai) {
            return res.status(500).json({
                error: 'Gemini API chưa được cấu hình',
                details: 'Vui lòng khai báo GEMINI_KEY_FREE hoặc GEMINI_KEY_PAID trong biến môi trường Render.'
            });
        }

        console.log(`📩 [Client gửi]: ${message}`);

        // Dùng một model ổn định cho mỗi request, tránh việc retry làm cạn quota.
        const response = await ai.models.generateContent({
            model: 'gemini-3.6-flash',
            contents: message,
            config: {
                systemInstruction: [
                    'Bạn là AquaBot, trợ lý AquaLink chuyên về nuôi tôm, cá và thủy sản.',
                    'Trả lời bằng tiếng Việt, ngắn gọn, đúng trọng tâm; ưu tiên gạch đầu dòng và hướng dẫn thực tế.',
                    'Chỉ nêu thông tin chắc chắn. Không bịa số liệu, giá cả, nguồn hoặc kết quả chẩn đoán; thiếu dữ kiện thì hỏi lại hoặc nói rõ chưa đủ thông tin.',
                    'Khi tư vấn bệnh, hóa chất hoặc thuốc, luôn nhắc người dùng kiểm tra nhãn, liều lượng và hỏi chuyên gia địa phương trước khi sử dụng.',
                    'Nếu câu hỏi ngoài phạm vi, từ chối ngắn gọn và hướng người dùng về chủ đề thủy sản.'
                ].join(' '),
            }
        });

        // Kiểm tra response structure
        console.log('📦 Response structure:', JSON.stringify(response, null, 2).substring(0, 500));

        let replyText = null;

        // Cách 1: Nếu response.text tồn tại
        if (response && typeof response.text === 'string') {
            replyText = response.text;
        }
        // Cách 2: Nếu response có candidates
        else if (response && Array.isArray(response.candidates) && response.candidates[0]) {
            const content = response.candidates[0].content;
            if (content && Array.isArray(content.parts) && content.parts[0]) {
                replyText = content.parts[0].text;
            }
        }

        if (replyText && replyText.trim()) {
            console.log('🤖 [AquaBot trả lời thành công]');
            res.json({ reply: replyText });
        } else {
            console.error('❌ Không thể trích xuất text từ response');
            res.status(500).json({
                error: 'Lỗi: AI không trả lời được',
                details: 'Response format không expected'
            });
        }

    } catch (error) {
        console.error('❌ Lỗi không mong muốn:', error.message);
        console.error('Stack:', error.stack);
        const upstreamStatus = Number(error?.error?.code);
        const statusCode = [400, 401, 403, 404, 429, 500, 502, 503].includes(
            upstreamStatus,
        )
            ? upstreamStatus
            : 500;
        const details =
            statusCode === 503
                ? 'Gemini đang quá tải. Vui lòng thử lại sau ít phút.'
                : error.message || 'Không xác định được lỗi từ Gemini';

        res.status(statusCode).json({
            error: 'Không thể xử lý yêu cầu AquaBot',
            details,
        });
    }
});

// Realtime Socket.io
io.on('connection', (socket) => {
    console.log(`👤 Thiết bị kết nối Socket: ${socket.id}`);

    socket.on('send_data', (data) => {
        socket.broadcast.emit('receive_data', data);
    });

    socket.on('disconnect', () => {
        console.log(`❌ Thiết bị ngắt kết nối: ${socket.id}`);
    });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
    console.log(`🚀 SERVER ONLINE TẠI PORT: ${PORT}`);
});