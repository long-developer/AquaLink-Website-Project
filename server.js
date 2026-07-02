const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

// Đọc chuỗi kiểm tra khi vào trình duyệt
app.get('/', (req, res) => {
    res.send('Server AquaLink đang chạy ngon lành!');
});

// Logic kết nối Người dùng - Người dùng
io.on('connection', (socket) => {
    console.log(`👤 Thiết bị kết nối: ${socket.id}`);

    // Lắng nghe dữ liệu/tin nhắn từ một máy gửi lên
    socket.on('send_data', (data) => {
        console.log('📩 Nhận dữ liệu:', data);
        // Phát ngay lập tức cho TẤT CẢ các máy khác đang kết nối
        socket.broadcast.emit('receive_data', data);
    });

    socket.on('disconnect', () => {
        console.log(`❌ Thiết bị ngắt kết nối: ${socket.id}`);
    });
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`🚀 SERVER ONLINE TẠI PORT: ${PORT}`);
});