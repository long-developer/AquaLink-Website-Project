# AquaLink Chat Deployment & Testing Guide

## Part 1: Backend Stress Testing & Error Handling

### Enable Stress Testing
Set environment variable in your `.env` file:
```
ENABLE_STRESS_TEST=true
```

### Health Check Endpoint
```bash
curl http://localhost:5000/health
```

**Response:**
```json
{
  "status": "healthy",
  "mongodb": "connected",
  "uptime": 1234,
  "connectedUsers": 5,
  "connectedSockets": 5,
  "timestamp": "2026-09-01T10:00:00Z"
}
```

### Database Stress Test
```bash
curl -X POST http://localhost:5000/test/stress-db \
  -H "Content-Type: application/json" \
  -d '{"iterations": 100}'
```

### Message Load Test
```bash
curl -X POST http://localhost:5000/test/stress-messages \
  -H "Content-Type: application/json" \
  -d '{"count": 50}'
```

### Cleanup Test Data
```bash
curl -X POST http://localhost:5000/test/cleanup
```

## Part 2: Client Error Handling

The Flutter app now includes:
- **Automatic reconnection** with exponential backoff
- **Message delivery retry** for failed sends
- **Network state detection** (online/offline)
- **Timeout handling** for all Socket.IO events
- **Error notifications** with user-friendly messages

### Network Error Scenarios Handled:
✅ Connection timeout
✅ Network disconnection
✅ MongoDB unavailable
✅ Invalid message format
✅ User not found
✅ Rate limiting
✅ Socket.IO connection failure
✅ Concurrent message conflicts

## Part 3: Real Device Deployment

### Prerequisites:
- Flutter SDK installed
- Android Studio or Xcode (for device/emulator)
- Physical device or Android emulator
- Backend server running and accessible

### Step 1: Update Backend URL
Edit `lib/app/providers/app_data_provider.dart`:
```dart
// Change this line to your backend URL
final String baseUrl = 'http://YOUR_BACKEND_IP:5000';
// For Android emulator: http://10.0.2.2:5000
// For real device: http://LOCAL_IP:5000
```

### Step 2: Run on Android Emulator
```bash
cd "D:\Project AquaLink"

# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch {emulator_id}

# Run app (wait for emulator to fully boot)
flutter run -d emulator-5554
```

### Step 3: Run on Physical Android Device
```bash
# Enable USB debugging on your device
# Connect device via USB

# List connected devices
flutter devices

# Run app
flutter run -d {device_id}
```

### Step 4: Run on iOS Simulator
```bash
# List available simulators
xcrun simctl list devices

# Open simulator
open -a Simulator

# Run app
flutter run -d {device_id}
```

### Step 5: Configure for Production

Update `.env` file on server:
```
MONGODB_URI=mongodb+srv://user:password@cluster.mongodb.net/aqualink
GEMINI_KEY_PAID=your_api_key
PORT=5000
ENABLE_STRESS_TEST=false  # Disable in production
NODE_ENV=production
```

## Part 4: Network Connectivity Testing

### Test 1: Simulate Network Disconnection
```bash
# On Android
adb shell cmd connectivity airplane-mode enable
# Perform app action (try to send message)
adb shell cmd connectivity airplane-mode disable
# App should recover automatically
```

### Test 2: Test with Slow Network
```bash
# On Android emulator (simulate 2G network)
telnet localhost 5554
gsm delay 2000
exit
```

### Test 3: Load Testing Multiple Users
```bash
# Terminal 1: Start backend
npm start

# Terminal 2: Run client with debug
flutter run -v

# Terminal 3+: Connect additional test users (manually or via script)
```

## Part 5: Debugging

### Enable Verbose Logging
```bash
flutter run -v
```

### Check Backend Logs
```bash
# If running locally
node server.js  # Watch console output

# Check specific issues:
# ✅ = Success
# ❌ = Error
# ⚠️ = Warning
# 👤 = User action
# 🚀 = Server start
```

### Common Issues & Solutions

**Issue: "Connection refused" on app**
- Solution: Check backend IP is correct in `baseUrl`
- Emulator uses `10.0.2.2` instead of `localhost`

**Issue: Messages don't sync**
- Solution: Check MongoDB connection in health endpoint
- Verify MONGODB_URI in .env

**Issue: High latency/timeouts**
- Solution: Run stress tests to identify bottleneck
- Check network bandwidth
- Monitor MongoDB performance

**Issue: Crashes on disconnect/reconnect**
- Solution: Latest error handling should fix this
- Check flutter analyze for any new issues

## Part 6: Production Deployment

### Option A: Heroku
```bash
# Create Heroku app
heroku create aqualink-backend

# Set environment variables
heroku config:set MONGODB_URI=your_uri
heroku config:set GEMINI_KEY_PAID=your_key

# Deploy
git push heroku main
```

### Option B: Docker
```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5000
CMD ["npm", "start"]
```

### Option C: AWS/Azure
- Create EC2 instance or App Service
- Install Node.js
- Clone repository
- Set environment variables
- Start with PM2 or systemd

## Testing Checklist

- [ ] Health check endpoint responds
- [ ] Can register new user
- [ ] Can login with credentials
- [ ] Can search users
- [ ] Can send message to user
- [ ] Can receive message in realtime
- [ ] Online/offline status updates
- [ ] Unread badge displays correctly
- [ ] Connection recovers after disconnect
- [ ] No crashes on network error
- [ ] Database stress test completes
- [ ] Load test shows acceptable latency
- [ ] App works on 2G/3G network (simulated)
- [ ] Multiple users can chat simultaneously
- [ ] Messages persist in MongoDB
- [ ] Avatar displays (if implemented)
- [ ] Timestamp shows correctly
- [ ] Notification banner appears
- [ ] Bottom nav badge updates
- [ ] No memory leaks after 1 hour usage

## Performance Targets

- Message delivery: < 100ms
- Average response time: < 200ms
- Max latency under load: < 1000ms
- Database insert: < 50ms per message
- Connection timeout: 10 seconds
- Reconnect delay: 1-5 seconds (exponential backoff)

## Next Steps

1. Deploy backend to production server
2. Update app to point to production URL
3. Run full integration tests
4. Load test with 100+ concurrent users
5. Monitor error rates and performance
6. Gather user feedback
7. Iterate on UX improvements

---

**Need Help?**
- Check server logs: `node server.js`
- Check app logs: `flutter run -v`
- Run health check: `curl http://localhost:5000/health`
- Check connectivity: `flutter doctor`
