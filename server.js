require('dotenv').config();

const express = require('express');
const http = require('http');
const crypto = require('crypto');
const { Server } = require('socket.io');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');
const { GoogleGenAI } = require('@google/genai');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

app.use(cors());
app.use(express.json());

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/aqualink';
let mongoClient = null;
let mongoDb = null;

async function connectMongo() {
    if (mongoClient && mongoDb) {
        return mongoClient;
    }

    try {
        mongoClient = new MongoClient(MONGODB_URI, {
            serverSelectionTimeoutMS: 5000,
            maxPoolSize: 10,
        });

        await mongoClient.connect();
        mongoDb = mongoClient.db();
        console.log(`✅ MongoDB connected: ${mongoDb.databaseName}`);
        return mongoClient;
    } catch (error) {
        console.error('❌ MongoDB connection failed:', error.message);
        mongoClient = null;
        mongoDb = null;
        return null;
    }
}

async function getCollection(collectionName) {
    const client = await connectMongo();
    if (!client || !mongoDb) {
        throw new Error('MongoDB chưa được kết nối. Hãy kiểm tra MONGODB_URI trong file .env.');
    }

    return mongoDb.collection(collectionName);
}

function hashPassword(password) {
    return crypto.createHash('sha256').update(`aqualink_${String(password)}_salt`).digest('hex');
}

function createAuthToken() {
    return crypto.randomBytes(32).toString('hex');
}

function sanitizeUser(user) {
    if (!user) return null;
    const { passwordHash, ...safeUser } = user;
    return safeUser;
}

async function ensureMongoIndexes() {
    try {
        const users = await getCollection('users');
        await users.createIndex({ email: 1 }, { unique: true, sparse: true });
        await users.createIndex({ username: 1 }, { unique: true, sparse: true });
        await users.createIndex({ token: 1 }, { unique: true, sparse: true });
        console.log('✅ MongoDB indexes prepared for users collection');
    } catch (error) {
        console.warn('⚠️ Cannot ensure MongoDB indexes:', error.message);
    }
}

const userSockets = new Map();
const socketUsers = new Map();

function normalizeUserId(value) {
    if (typeof value !== 'string') return null;
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
}

function buildConversationId(userA, userB) {
    return [String(userA), String(userB)].sort().join('_');
}

async function saveChatMessage({ fromUserId, toUserId, message, conversationId }) {
    const collection = await getCollection('chat_messages');
    const payload = {
        fromUserId: String(fromUserId),
        toUserId: String(toUserId),
        conversationId: String(conversationId || buildConversationId(fromUserId, toUserId)),
        message: String(message || '').trim(),
        createdAt: new Date(),
        updatedAt: new Date(),
    };

    const result = await collection.insertOne(payload);
    return { ...payload, _id: result.insertedId };
}

async function getConversationMessages(userA, userB) {
    const collection = await getCollection('chat_messages');
    const conversationId = buildConversationId(userA, userB);

    return collection
        .find({ conversationId })
        .sort({ createdAt: 1 })
        .toArray();
}

async function getUserConversations(userId) {
    const collection = await getCollection('chat_messages');
    const query = {
        $or: [{ fromUserId: String(userId) }, { toUserId: String(userId) }],
    };

    const items = await collection
        .find(query)
        .sort({ createdAt: -1 })
        .toArray();

    const map = new Map();
    for (const item of items) {
        const partnerId = item.fromUserId === String(userId) ? item.toUserId : item.fromUserId;
        if (!map.has(partnerId)) {
            map.set(partnerId, item);
        }
    }

    return Array.from(map.entries()).map(([partnerId, lastMessage]) => ({
        partnerId,
        conversationId: lastMessage.conversationId,
        lastMessage: lastMessage.message,
        lastUpdated: lastMessage.createdAt,
    }));
}

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

app.get('/api/health', async (req, res) => {
    try {
        const connected = !!mongoDb;
        res.json({
            status: connected ? 'ok' : 'degraded',
            message: connected ? 'MongoDB connected' : 'MongoDB disconnected',
            mongo: connected,
            dbName: mongoDb?.databaseName || null,
            timestamp: new Date().toISOString(),
        });
    } catch (error) {
        res.status(500).json({ error: 'Health check failed', details: error.message });
    }
});

app.get('/api/chat', (req, res) => {
    res.status(405).json({
        error: 'Phương thức GET không được hỗ trợ cho endpoint chat.',
        details: 'Hãy gửi request bằng POST với body { "message": "..." }.'
    });
});

app.post('/api/auth/register', async (req, res) => {
    try {
        const { name, username, email, password } = req.body || {};
        const safeName = String(name || '').trim();
        const safeUsername = String(username || '').trim();
        const safeEmail = String(email || '').trim().toLowerCase();
        const safePassword = String(password || '');

        if (!safeName || !safeUsername || !safeEmail || safePassword.length < 6) {
            return res.status(400).json({
                error: 'Thiếu thông tin hoặc mật khẩu tối thiểu 6 ký tự.',
            });
        }

        const users = await getCollection('users');
        const exists = await users.findOne({
            $or: [{ email: safeEmail }, { username: safeUsername }],
        });

        if (exists) {
            return res.status(409).json({
                error: 'Email hoặc username đã tồn tại.',
            });
        }

        const token = createAuthToken();
        const user = {
            name: safeName,
            username: safeUsername,
            email: safeEmail,
            passwordHash: hashPassword(safePassword),
            token,
            avatar: '',
            createdAt: new Date(),
            updatedAt: new Date(),
            lastLoginAt: new Date(),
        };

        const result = await users.insertOne(user);
        res.status(201).json({
            success: true,
            user: sanitizeUser({ ...user, _id: result.insertedId }),
            token,
        });
    } catch (error) {
        console.error('❌ Register failed:', error.message);
        res.status(500).json({
            error: 'Không thể đăng ký tài khoản.',
            details: error.message,
        });
    }
});

app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, username, password } = req.body || {};
        const identifier = String(email || username || '').trim().toLowerCase();
        const safePassword = String(password || '');

        if (!identifier || !safePassword) {
            return res.status(400).json({ error: 'Email/username và mật khẩu là bắt buộc.' });
        }

        const users = await getCollection('users');
        const user = await users.findOne({
            $or: [{ email: identifier }, { username: identifier }],
        });

        if (!user || user.passwordHash !== hashPassword(safePassword)) {
            return res.status(401).json({ error: 'Thông tin đăng nhập không đúng.' });
        }

        const token = createAuthToken();
        await users.updateOne(
            { _id: user._id },
            {
                $set: {
                    token,
                    lastLoginAt: new Date(),
                    updatedAt: new Date(),
                },
            },
        );

        const updatedUser = await users.findOne({ _id: user._id });
        res.json({
            success: true,
            user: sanitizeUser(updatedUser),
            token,
        });
    } catch (error) {
        console.error('❌ Login failed:', error.message);
        res.status(500).json({
            error: 'Không thể đăng nhập.',
            details: error.message,
        });
    }
});

app.get('/api/auth/me', async (req, res) => {
    try {
        const authHeader = req.headers.authorization || '';
        const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : authHeader;

        if (!token) {
            return res.status(401).json({ error: 'Token không tồn tại.' });
        }

        const users = await getCollection('users');
        const user = await users.findOne({ token });

        if (!user) {
            return res.status(401).json({ error: 'Token không hợp lệ.' });
        }

        res.json({ success: true, user: sanitizeUser(user) });
    } catch (error) {
        res.status(500).json({ error: 'Không thể xác thực người dùng.', details: error.message });
    }
});

app.get('/api/users', async (req, res) => {
    try {
        const users = await getCollection('users');
        const list = await users
            .find({}, { projection: { passwordHash: 0 } })
            .sort({ createdAt: -1 })
            .limit(100)
            .toArray();

        res.json({ success: true, users: list });
    } catch (error) {
        res.status(500).json({ error: 'Không thể lấy danh sách người dùng.', details: error.message });
    }
});

app.get('/api/chat/search-users', async (req, res) => {
    try {
        const query = String(req.query.query || '').trim();
        const currentUserId = String(req.query.currentUserId || '').trim();

        if (!query && !currentUserId) {
            return res.status(400).json({ error: 'Thiếu query hoặc currentUserId' });
        }

        const users = await getCollection('users');
        const filter = currentUserId
            ? { username: { $ne: currentUserId }, $or: [
                { username: { $regex: query || '', $options: 'i' } },
                { name: { $regex: query || '', $options: 'i' } },
                { email: { $regex: query || '', $options: 'i' } },
            ] }
            : { $or: [
                { username: { $regex: query || '', $options: 'i' } },
                { name: { $regex: query || '', $options: 'i' } },
                { email: { $regex: query || '', $options: 'i' } },
            ] };

        const list = await users
            .find(filter, { projection: { passwordHash: 0 } })
            .limit(20)
            .toArray();

        res.json({
            success: true,
            users: list.map((user) => ({
                ...sanitizeUser(user),
                online: userSockets.has(String(user._id || user.username || user.email)),
            })),
        });
    } catch (error) {
        res.status(500).json({ error: 'Không thể tìm người dùng', details: error.message });
    }
});

app.get('/api/chat/online-users', async (req, res) => {
    try {
        const onlineUsers = Array.from(userSockets.entries()).map(([userId, socketId]) => ({
            userId,
            socketId,
            online: true,
        }));

        res.json({ success: true, users: onlineUsers });
    } catch (error) {
        res.status(500).json({ error: 'Không thể lấy danh sách online', details: error.message });
    }
});

app.get('/api/aqua-data', async (req, res) => {
    try {
        const collection = await getCollection('aqua_data');
        const items = await collection
            .find({})
            .sort({ createdAt: -1 })
            .limit(50)
            .toArray();

        res.json({
            success: true,
            count: items.length,
            data: items,
        });
    } catch (error) {
        res.status(503).json({
            error: 'Không thể truy vấn MongoDB',
            details: error.message,
        });
    }
});

app.post('/api/aqua-data', async (req, res) => {
    try {
        const { type = 'sensor', data = {}, source = 'app' } = req.body || {};
        const collection = await getCollection('aqua_data');

        const payload = {
            type,
            source,
            data,
            createdAt: new Date(),
            updatedAt: new Date(),
        };

        const result = await collection.insertOne(payload);

        res.status(201).json({
            success: true,
            id: result.insertedId,
            data: {
                ...payload,
                _id: result.insertedId,
            },
        });
    } catch (error) {
        res.status(503).json({
            error: 'Không thể lưu dữ liệu vào MongoDB',
            details: error.message,
        });
    }
});

app.get('/api/aqua-data/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const collection = await getCollection('aqua_data');
        const item = await collection.findOne({ _id: new ObjectId(id) });

        if (!item) {
            return res.status(404).json({ error: 'Không tìm thấy dữ liệu' });
        }

        res.json({ success: true, data: item });
    } catch (error) {
        res.status(400).json({
            error: 'Định dạng ID không hợp lệ hoặc MongoDB lỗi',
            details: error.message,
        });
    }
});

app.get('/api/chat/users/:userId/conversations', async (req, res) => {
    try {
        const { userId } = req.params;
        if (!normalizeUserId(userId)) {
            return res.status(400).json({ error: 'Thiếu userId hợp lệ' });
        }

        const conversations = await getUserConversations(userId);
        res.json({ success: true, conversations });
    } catch (error) {
        res.status(500).json({ error: 'Không thể lấy cuộc trò chuyện', details: error.message });
    }
});

app.get('/api/chat/contacts/:userId', async (req, res) => {
    try {
        const { userId } = req.params;
        if (!normalizeUserId(userId)) {
            return res.status(400).json({ error: 'Thiếu userId hợp lệ' });
        }

        const conversations = await getUserConversations(userId);
        const users = await getCollection('users');
        const userList = await users.find({}, { projection: { passwordHash: 0 } }).toArray();

        const contacts = userList
            .filter((user) => String(user.username || user.email) !== String(userId))
            .map((user) => {
                const partnerId = String(user.username || user.email || user._id);
                const conversation = conversations.find((item) => item.partnerId === partnerId);
                return {
                    ...sanitizeUser(user),
                    partnerId,
                    lastMessage: conversation?.lastMessage || '',
                    lastUpdated: conversation?.lastUpdated || null,
                    online: userSockets.has(partnerId),
                };
            });

        res.json({ success: true, contacts });
    } catch (error) {
        res.status(500).json({ error: 'Không thể lấy danh sách liên hệ', details: error.message });
    }
});

app.get('/api/chat/messages', async (req, res) => {
    try {
        const { userA, userB } = req.query;
        const a = normalizeUserId(userA);
        const b = normalizeUserId(userB);

        if (!a || !b) {
            return res.status(400).json({ error: 'Cần truyền userA và userB' });
        }

        const messages = await getConversationMessages(a, b);
        res.json({ success: true, messages, conversationId: buildConversationId(a, b) });
    } catch (error) {
        res.status(500).json({ error: 'Không thể lấy tin nhắn', details: error.message });
    }
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

    socket.on('register_user', ({ userId, username }) => {
        const normalizedUserId = normalizeUserId(userId);
        if (!normalizedUserId) {
            return socket.emit('error_message', { message: 'userId không hợp lệ' });
        }

        userSockets.set(normalizedUserId, socket.id);
        socketUsers.set(socket.id, { userId: normalizedUserId, username: username || normalizedUserId });

        socket.join(`user:${normalizedUserId}`);
        io.emit('user_online', {
            userId: normalizedUserId,
            username: username || normalizedUserId,
            online: true,
        });

        console.log(`✅ Người dùng đăng ký socket: ${normalizedUserId} (${socket.id})`);
    });

    socket.on('join_conversation', ({ userId, targetUserId }) => {
        const currentUserId = normalizeUserId(userId) || socketUsers.get(socket.id)?.userId;
        const otherUserId = normalizeUserId(targetUserId);

        if (!currentUserId || !otherUserId) {
            return socket.emit('error_message', { message: 'Thông tin cuộc trò chuyện không hợp lệ' });
        }

        const conversationId = buildConversationId(currentUserId, otherUserId);
        socket.join(conversationId);
        socket.emit('joined_conversation', { conversationId, withUserId: otherUserId });
    });

    socket.on('send_private_message', async ({ fromUserId, toUserId, message, conversationId }) => {
        const senderId = normalizeUserId(fromUserId) || socketUsers.get(socket.id)?.userId;
        const receiverId = normalizeUserId(toUserId);
        const text = String(message || '').trim();

        if (!senderId || !receiverId || !text) {
            return socket.emit('error_message', { message: 'Tin nhắn không hợp lệ' });
        }

        try {
            const finalConversationId = conversationId || buildConversationId(senderId, receiverId);
            const savedMessage = await saveChatMessage({
                fromUserId: senderId,
                toUserId: receiverId,
                message: text,
                conversationId: finalConversationId,
            });

            const payload = {
                ...savedMessage,
                conversationId: finalConversationId,
                fromUserId: senderId,
                toUserId: receiverId,
                message: text,
                createdAt: savedMessage.createdAt,
            };

            io.to(`user:${receiverId}`).emit('receive_private_message', payload);
            io.to(`user:${senderId}`).emit('receive_private_message', payload);
            io.to(finalConversationId).emit('conversation_message', payload);

            socket.emit('message_sent', payload);
        } catch (error) {
            console.error('❌ Lỗi gửi private message:', error.message);
            socket.emit('error_message', { message: 'Không thể gửi tin nhắn, vui lòng thử lại.' });
        }
    });

    socket.on('get_conversation_history', async ({ userA, userB }) => {
        const a = normalizeUserId(userA) || socketUsers.get(socket.id)?.userId;
        const b = normalizeUserId(userB);

        if (!a || !b) {
            return socket.emit('error_message', { message: 'Thiếu thông tin người nhận' });
        }

        try {
            const messages = await getConversationMessages(a, b);
            socket.emit('conversation_history', {
                conversationId: buildConversationId(a, b),
                messages,
            });
        } catch (error) {
            socket.emit('error_message', { message: 'Không thể tải lịch sử chat' });
        }
    });

    socket.on('send_data', (data) => {
        socket.broadcast.emit('receive_data', data);
    });

    socket.on('disconnect', () => {
        const userInfo = socketUsers.get(socket.id);
        if (userInfo) {
            userSockets.delete(userInfo.userId);
            socketUsers.delete(socket.id);
            io.emit('user_online', {
                userId: userInfo.userId,
                username: userInfo.username,
                online: false,
            });
            console.log(`❌ Người dùng ngắt kết nối: ${userInfo.userId} (${socket.id})`);
        } else {
            console.log(`❌ Thiết bị ngắt kết nối: ${socket.id}`);
        }
    });
});

// Health Check & Monitoring
app.get('/health', async (req, res) => {
    try {
        const client = await connectMongo();
        const isMongoConnected = !!(client && mongoDb);
        const uptime = process.uptime();
        const connectedUsers = userSockets.size;
        const connectedSockets = socketUsers.size;

        res.json({
            status: isMongoConnected ? 'healthy' : 'degraded',
            mongodb: isMongoConnected ? 'connected' : 'disconnected',
            uptime: Math.floor(uptime),
            connectedUsers,
            connectedSockets,
            timestamp: new Date().toISOString(),
        });
    } catch (error) {
        res.status(503).json({
            status: 'unhealthy',
            error: error.message,
            timestamp: new Date().toISOString(),
        });
    }
});

// Error Handler Middleware
app.use((err, req, res, next) => {
    console.error('❌ Unhandled error:', err);
    res.status(err.status || 500).json({
        error: 'Internal server error',
        message: process.env.NODE_ENV === 'development' ? err.message : 'An error occurred',
        timestamp: new Date().toISOString(),
    });
});

const PORT = process.env.PORT || 5000;

async function startServer() {
    await connectMongo();
    await ensureMongoIndexes();
    server.listen(PORT, () => {
        console.log(`🚀 SERVER ONLINE TẠI PORT: ${PORT}`);
    });
}

startServer();