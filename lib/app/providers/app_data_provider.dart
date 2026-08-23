import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:project_aqualink/broadcast_channel.dart';

class AppDataProvider extends ChangeNotifier {
  late final BroadcastSyncChannel _syncChannel;
  Timer? _remoteStateTimer;
  final String _instanceId =
      '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(0x7FFFFFFF)}';

  AppDataProvider() {
    _syncChannel = createBroadcastSyncChannel(_handleSyncEvent);
    _loadPersistedState();
    _initializeDefaultAccounts();
    _remoteStateTimer = Timer(
      const Duration(milliseconds: 150),
      _requestRemoteState,
    );
  }

  int _index = 0;
  int get index => _index;

  int _targetIndex = 0;
  int get targetIndex => _targetIndex;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _pushNotifications = true;
  bool get pushNotifications => _pushNotifications;

  bool _marketAlerts = true;
  bool get marketAlerts => _marketAlerts;

  static const Map<String, Map<String, String>> _localizedStrings = {
    'vi': {
      'app_title': 'AquaLink',
      'login_title': 'Đăng nhập',
      'signup_title': 'Đăng ký tài khoản',
      'location_label': 'Nơi ở',
      'username_label': 'Tên tài khoản',
      'contact_label': 'Email / Số điện thoại',
      'age_label': 'Tuổi',
      'password_label': 'Mật khẩu',
      'confirm_password_label': 'Nhập lại mật khẩu',
      'login_button': 'Đăng nhập',
      'signup_button': 'Đăng ký',
      'have_account': 'Bạn đã có tài khoản? Đăng nhập',
      'no_account': 'Chưa có tài khoản? Đăng ký',
      'registration_success': 'Đăng ký thành công, đã đăng nhập tự động.',
      'login_success': 'Đăng nhập thành công.',
      'error_missing_fields': 'Vui lòng điền đầy đủ thông tin.',
      'error_login_fields': 'Vui lòng nhập tên tài khoản và mật khẩu.',
      'error_user_not_found': 'Tên tài khoản không tồn tại.',
      'error_wrong_password': 'Mật khẩu không đúng.',
      'error_username_exists':
          'Tên tài khoản đã tồn tại. Vui lòng chọn tên khác.',
      'error_password_length': 'Mật khẩu phải có ít nhất 8 ký tự.',
      'error_password_mismatch': 'Mật khẩu và nhập lại mật khẩu không khớp.',
      'error_invalid_age': 'Vui lòng nhập tuổi hợp lệ.',
      'error_login_required': 'Vui lòng đăng nhập lại để đổi mật khẩu.',
      'error_current_password_wrong': 'Mật khẩu hiện tại không đúng.',
      'error_new_password_length': 'Mật khẩu mới phải có ít nhất 8 ký tự.',
      'error_new_password_mismatch': 'Mật khẩu mới và xác nhận không khớp.',
      'feed_title': 'Bản tin AquaLink',
      'post_feed': 'Bài viết',
      'my_post_button': 'Đăng bài ngay',
      'search_title': 'Tìm kiếm',
      'search_hint': 'Tìm kiếm giá tôm, đại lý...',
      'popular_keywords': 'Từ khóa phổ biến',
      'not_found_posts': 'Không tìm thấy bài viết phù hợp.',
      'feed_price_update_title': 'Cập nhật giá tôm thẻ chân trắng',
      'feed_price_update_subtitle': 'Nhấn để xem giá realtime từ tờ TePbac.',
      'create_post_title': 'Tạo bài viết mới',
      'create_post_hint':
          'Nhập giá tôm hôm nay hoặc chia sẻ tình hình ao nuôi...',
      'search_chip_price': 'Giá tôm thẻ',
      'search_chip_dealer': 'Đại lý thức ăn',
      'search_chip_disease': 'Bệnh đốm trắng',
      'settings_title': 'Cài đặt',
      'account_section': 'Tài khoản',
      'profile_personal': 'Hồ sơ cá nhân',
      'change_password': 'Đổi mật khẩu',
      'saved_posts': 'Bài viết đã lưu',
      'app_section': 'Ứng dụng',
      'user_directory': 'Danh sách người dùng',
      'user_address': 'Địa chỉ',
      'chat_with': 'Nhắn tin với',
      'type_message': 'Nhập tin nhắn...',
      'attach_image': 'Đính kèm ảnh',
      'send': 'Gửi',
      'no_messages': 'Chưa có tin nhắn. Bắt đầu cuộc trò chuyện nhé!',
      'no_users_found': 'Chưa có người dùng nào để hiển thị.',
      'push_notifications': 'Thông báo đẩy',
      'market_alerts': 'Cảnh báo biến động giá tôm',
      'dark_theme': 'Giao diện tối (Dark Mode)',
      'language': 'Ngôn ngữ',
      'other_section': 'Khác',
      'support_center': 'Trung tâm hỗ trợ',
      'terms_policy': 'Điều khoản & Bảo mật',
      'app_version': 'Phiên bản ứng dụng',
      'logout': 'Đăng xuất',
      'language_dialog_title': 'Chọn ngôn ngữ',
      'language_vn': 'Việt Nam',
      'language_en': 'English',
      'cancel': 'Huỷ',
      'profile_title': 'Hồ sơ cá nhân',
      'personal_info': 'Thông tin cá nhân',
      'bio_title': 'Mô tả',
      'change_avatar': 'Thay đổi Avatar',
      'edit_bio': 'Chỉnh sửa tiểu sử',
      'edit_bio_dialog_title': 'Chỉnh sửa tiểu sử',
      'bio_hint': 'Nhập tiểu sử của bạn...',
      'save': 'Lưu',
      'current_password': 'Mật khẩu hiện tại',
      'new_password': 'Mật khẩu mới',
      'confirm_new_password': 'Xác nhận mật khẩu',
      'password_saved': 'Đã lưu thay đổi mật khẩu.',
      'change_password_title': 'Đổi mật khẩu',
      'saved_posts_title': 'Bài viết đã lưu',
      'unsave': 'Bỏ lưu',
      'support_title': 'Trung tâm hỗ trợ',
      'support_text':
          'Nếu bạn cần hỗ trợ, vui lòng liên hệ đội ngũ AquaLink để được giúp đỡ.',
      'help_title': 'Hỗ trợ AquaLink',
      'policy_title': 'Điều khoản & Bảo mật',
      'policy_text':
          'Nội dung điều khoản và chính sách bảo mật sẽ được cập nhật sớm.',
      'about_title': 'Phiên bản ứng dụng',
      'about_name': 'AquaLink',
      'about_version': 'Phiên bản: v1.0.0',
      'about_updated': 'Cập nhật gần nhất: 28/05/2026',
      'assistant_title': 'AquaBot Assistant',
      'assistant_hint': 'Hỏi trợ lý về giá tôm, bệnh về tôm...',
      'assistant_thinking': 'AquaBot đang suy nghĩ...',
      'assistant_default':
          'Xin chào! Mình là AquaBot. Bạn cần hỗ trợ gì về tôm hay tra cứu giá cả hôm nay không?',
      'assistant_greeting':
          'Xin chào! Mình là AquaBot, trợ lý ảo của AquaLink. Bạn cần hỗ trợ gì trong quá trình dùng ứng dụng?',
      'assistant_price':
          'Theo dữ liệu thị trường hôm nay, giá tôm thẻ chân trắng tại ĐBSCL dao động từ 132,000đ đến 145,000đ/kg tùy size.',
      'assistant_disease':
          'Nếu tôm có dấu hiệu lờ đờ hoặc đốm trắng, bạn cần kiểm tra ngay hàm lượng khí độc (H2S, NH3) và báo cho kỹ sư khu vực nhé!',
      'assistant_hygiene':
          'Để giữ vệ sinh ao nuôi, bạn nên rải vôi nông nghiệp định kỳ và đảm bảo hệ thống lọc nước hoạt động tốt.',
      'assistant_unknown':
          'Không thể kết nối tới server AquaBot. Bạn hãy đảm bảo đã chạy "node server.js" nhé!',
      'bio_empty':
          'Chưa có tiểu sử. Nhấn nút chỉnh sửa để cập nhật thông tin của bạn.',
      'delete_message': 'Xoá tin nhắn',
      'unknown_location': 'Chưa rõ',
      'default_user_label': 'Người dùng AquaLink',
      'choose_image': 'Chọn ảnh từ thư viện',
      'post_now_button': 'Đăng bài ngay',
      'logout_button': 'Đăng xuất',
      'support_help_text':
          'Nếu bạn cần giúp đỡ, vui lòng liên hệ qua email support@aqualink.vn hoặc gọi 1900-1234.',
      'terms_content':
          'AquaLink cam kết bảo vệ dữ liệu của bạn. Nội dung này chỉ là ví dụ, thay đổi theo chính sách thực tế của ứng dụng.',
      'saved_posts_empty': 'Chưa có bài viết nào được lưu.',
      'save_post': 'Lưu bài viết',
      'unsave_post': 'Bỏ lưu bài viết',
      'change_password_button': 'Lưu thay đổi',
    },
    'en': {
      'app_title': 'AquaLink',
      'login_title': 'Sign In',
      'signup_title': 'Create Account',
      'location_label': 'Location',
      'username_label': 'Username',
      'contact_label': 'Email / Phone',
      'age_label': 'Age',
      'password_label': 'Password',
      'confirm_password_label': 'Confirm Password',
      'login_button': 'Sign In',
      'signup_button': 'Sign Up',
      'have_account': 'Already have an account? Sign In',
      'no_account': 'No account yet? Sign Up',
      'registration_success':
          'Registration successful, logged in automatically.',
      'login_success': 'Login successful.',
      'error_missing_fields': 'Please fill in all required fields.',
      'error_login_fields': 'Please enter username and password.',
      'error_user_not_found': 'Username does not exist.',
      'error_wrong_password': 'Incorrect password.',
      'error_username_exists':
          'Username already exists. Please choose another.',
      'error_password_length': 'Password must be at least 8 characters.',
      'error_password_mismatch': 'Password and confirmation do not match.',
      'error_invalid_age': 'Please enter a valid age.',
      'error_login_required': 'Please log in again to change password.',
      'error_current_password_wrong': 'Current password is incorrect.',
      'error_new_password_length':
          'New password must be at least 8 characters.',
      'error_new_password_mismatch':
          'New password and confirmation do not match.',
      'feed_title': 'AquaLink Feed',
      'post_feed': 'Posts',
      'my_post_button': 'Post Now',
      'search_title': 'Search',
      'search_hint': 'Search shrimp prices, dealers...',
      'popular_keywords': 'Popular keywords',
      'not_found_posts': 'No matching posts found.',
      'feed_price_update_title': 'Whiteleg shrimp price update',
      'feed_price_update_subtitle': 'Tap to view realtime prices from TePbac.',
      'create_post_title': 'Create a new post',
      'create_post_hint':
          'Enter today’s shrimp prices or share pond conditions...',
      'search_chip_price': 'Shrimp prices',
      'search_chip_dealer': 'Feed dealers',
      'search_chip_disease': 'White spot disease',
      'settings_title': 'Settings',
      'account_section': 'Account',
      'profile_personal': 'Profile',
      'change_password': 'Change Password',
      'saved_posts': 'Saved Posts',
      'app_section': 'App',
      'user_directory': 'Users',
      'user_address': 'Address',
      'chat_with': 'Chat with',
      'type_message': 'Type a message...',
      'attach_image': 'Attach Image',
      'send': 'Send',
      'no_messages': 'No messages yet. Start the conversation!',
      'no_users_found': 'No users available to show.',
      'push_notifications': 'Push Notifications',
      'market_alerts': 'Market Alerts',
      'dark_theme': 'Dark Theme',
      'language': 'Language',
      'other_section': 'Others',
      'support_center': 'Support Center',
      'terms_policy': 'Terms & Privacy',
      'app_version': 'App Version',
      'logout': 'Log Out',
      'language_dialog_title': 'Choose language',
      'language_vn': 'Vietnamese',
      'language_en': 'English',
      'cancel': 'Cancel',
      'profile_title': 'Profile',
      'personal_info': 'Personal Information',
      'bio_title': 'Bio',
      'change_avatar': 'Change Avatar',
      'edit_bio': 'Edit Bio',
      'edit_bio_dialog_title': 'Edit Bio',
      'bio_hint': 'Enter your bio...',
      'save': 'Save',
      'current_password': 'Current Password',
      'new_password': 'New Password',
      'confirm_new_password': 'Confirm Password',
      'password_saved': 'Password changes saved.',
      'change_password_title': 'Change Password',
      'saved_posts_title': 'Saved Posts',
      'unsave': 'Unsave',
      'support_title': 'Support Center',
      'support_text':
          'If you need help, please reach out to AquaLink support team.',
      'help_title': 'AquaLink Support',
      'policy_title': 'Terms & Privacy',
      'policy_text': 'Terms and privacy content will be updated soon.',
      'about_title': 'App Version',
      'about_name': 'AquaLink',
      'about_version': 'Version: v1.0.0',
      'about_updated': 'Last updated: 28/05/2026',
      'assistant_title': 'AquaBot Assistant',
      'assistant_hint': 'Ask about shrimp prices, diseases...',
      'assistant_thinking': 'AquaBot is thinking...',
      'assistant_default':
          'Hello! I am AquaBot. Need help with shrimp or market price lookup today?',
      'assistant_greeting':
          'Hello! I am AquaBot, AquaLink virtual assistant. What can I help you with in the app?',
      'assistant_price':
          'According to today’s market data, whiteleg shrimp prices in the Mekong Delta range from 132,000đ to 145,000đ/kg depending on size.',
      'assistant_disease':
          'If shrimp appear lethargic or have white spots, check toxic gas levels (H2S, NH3) and notify your local engineer.',
      'assistant_hygiene':
          'To keep the pond clean, apply agricultural lime regularly and ensure filtration works properly.',
      'assistant_unknown':
          'Could not connect to AquaBot server. Please ensure "node server.js" is running!',
      'bio_empty': 'No bio yet. Tap edit to update your profile.',
      'delete_message': 'Delete message',
      'unknown_location': 'Unknown',
      'default_user_label': 'AquaLink User',
      'choose_image': 'Choose image from gallery',
      'post_now_button': 'Post Now',
      'logout_button': 'Log Out',
      'support_help_text':
          'If you need help, please reach out to AquaLink support team at support@aqualink.vn or call 1900-1234.',
      'terms_content':
          'AquaLink is committed to protecting your data. This is sample content and should be replaced by the actual app policy.',
      'saved_posts_empty': 'No saved posts yet.',
      'save_post': 'Save post',
      'unsave_post': 'Unsave post',
      'change_password_button': 'Save Changes',
    },
  };
  //Khu đang fix
  String translate(String key) {
    return _localizedStrings['vi']?[key] ?? key;
  }

  void setIndex(int value) {
    if (_targetIndex == value) return;

    _targetIndex = value;
    _index = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
  }

  void setPushNotifications(bool value) {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    notifyListeners();
  }

  void setMarketAlerts(bool value) {
    if (_marketAlerts == value) return;
    _marketAlerts = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _remoteStateTimer?.cancel();
    _syncChannel.dispose();
    super.dispose();
  }

  void _requestRemoteState() {
    _syncChannel.sendMessage('request_state', {
      'instanceId': _instanceId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Map<String, dynamic> _serializeUserForState(Map<String, dynamic> user) {
    return {
      'name': user['name'],
      'password': user['password'],
      'location': user['location'],
      'contact': user['contact'],
      'age': user['age'],
      'bio': user['bio'],
      'avatarBase64': user['avatarBytes'] != null
          ? base64Encode(user['avatarBytes'] as Uint8List)
          : null,
    };
  }

  Map<String, dynamic> _serializePostForState(Map<String, dynamic> post) {
    return {
      'id': post['id'],
      'author': post['author'],
      'time': post['time'],
      'content': post['content'],
      'imageBase64': post['imageBytes'] != null
          ? base64Encode(post['imageBytes'] as Uint8List)
          : null,
      'isSaved': post['isSaved'],
    };
  }

  Map<String, dynamic> _deserializeUserFromState(Map<String, dynamic> raw) {
    return {
      'name': raw['name'],
      'password': raw['password'],
      'location': raw['location'],
      'contact': raw['contact'],
      'age': raw['age'],
      'bio': raw['bio'],
      'avatarBytes': raw['avatarBase64'] != null
          ? base64Decode(raw['avatarBase64'] as String)
          : null,
    };
  }

  Map<String, dynamic> _deserializePostFromState(Map<String, dynamic> raw) {
    return {
      'id': raw['id'],
      'author': raw['author'],
      'time': raw['time'],
      'content': raw['content'],
      'imageBytes': raw['imageBase64'] != null
          ? base64Decode(raw['imageBase64'] as String)
          : null,
      'isSaved': raw['isSaved'] ?? false,
    };
  }

  void _loadPersistedState() {
    final persisted = _syncChannel.loadPersistedState();
    if (persisted == null) return;

    final loadedUsers = persisted['users'] as Map<String, dynamic>?;
    if (loadedUsers != null) {
      for (final entry in loadedUsers.entries) {
        if (!_users.containsKey(entry.key) &&
            entry.value is Map<String, dynamic>) {
          _users[entry.key] = _deserializeUserFromState(
            Map<String, dynamic>.from(entry.value as Map<String, dynamic>),
          );
        }
      }
    }

    final loadedPosts = persisted['posts'] as List<dynamic>?;
    if (loadedPosts != null) {
      for (final rawPost in loadedPosts) {
        if (rawPost is Map<String, dynamic>) {
          final postId = rawPost['id'] as int?;
          if (postId != null && !_posts.any((post) => post['id'] == postId)) {
            _posts.add(_deserializePostFromState(rawPost));
          }
        }
      }
    }

    if (loadedUsers != null || loadedPosts != null) {
      if (_posts.isNotEmpty) {
        _posts.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
      }
      notifyListeners();
    }
  }

  void _persistState() {
    _syncChannel.savePersistedState({
      'users': _users.map(
        (key, user) => MapEntry(key, _serializeUserForState(user)),
      ),
      'posts': _posts.map(_serializePostForState).toList(),
    });
  }

  void _handleSyncEvent(String type, Map<String, dynamic> payload) {
    if (type == 'request_state') {
      final requesterId = payload['instanceId'] as String?;
      if (requesterId == null || requesterId == _instanceId) return;
      _syncChannel.sendMessage('sync_state', {
        'instanceId': _instanceId,
        'users': _users.map(
          (key, user) => MapEntry(key, _serializeUserForState(user)),
        ),
        'posts': _posts.map(_serializePostForState).toList(),
      });
      return;
    }

    if (type == 'sync_state') {
      final senderId = payload['instanceId'] as String?;
      if (senderId == null || senderId == _instanceId) return;

      final loadedUsers = payload['users'] as Map<String, dynamic>?;
      if (loadedUsers != null) {
        for (final entry in loadedUsers.entries) {
          if (!_users.containsKey(entry.key)) {
            _users[entry.key] = Map<String, dynamic>.from(entry.value);
          }
        }
      }

      final loadedPosts = payload['posts'] as List<dynamic>?;
      if (loadedPosts != null) {
        for (final rawPost in loadedPosts) {
          if (rawPost is Map<String, dynamic>) {
            final postId = rawPost['id'] as int?;
            if (postId != null && !_posts.any((post) => post['id'] == postId)) {
              _posts.add(Map<String, dynamic>.from(rawPost));
            }
          }
        }
      }

      if (loadedUsers != null || loadedPosts != null) {
        if (_posts.isNotEmpty) {
          _posts.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
        }
        _persistState();
        notifyListeners();
      }
      return;
    }

    if (type == 'new_user') {
      final username = payload['username'] as String?;
      if (username == null || _users.containsKey(username)) return;
      _users[username] = {
        'name': payload['name'] as String? ?? username,
        'password': payload['password'] as String? ?? '',
        'location': payload['location'] as String? ?? '',
        'contact': payload['contact'] as String? ?? '',
        'age': payload['age'] as int? ?? 0,
        'bio': payload['bio'] as String? ?? '',
        'avatarBytes': payload['avatarBase64'] != null
            ? base64Decode(payload['avatarBase64'] as String)
            : null,
      };
      _persistState();
      notifyListeners();
      return;
    }

    if (type == 'new_post') {
      final postId = payload['id'] as int?;
      if (postId == null) return;
      if (_posts.any((post) => post['id'] == postId)) return;
      _posts.insert(0, {
        'id': postId,
        'author': payload['author'] as String? ?? 'Người dùng',
        'time': payload['time'] as String? ?? 'Vừa xong',
        'content': payload['content'] as String? ?? '',
        'imageBytes': payload['imageBase64'] != null
            ? base64Decode(payload['imageBase64'] as String)
            : null,
        'isSaved': false,
      });
      _persistState();
      notifyListeners();
      return;
    }

    if (type == 'user_message') {
      final fromUsername = payload['fromUsername'] as String?;
      final toUsername = payload['toUsername'] as String?;
      if (fromUsername == null || toUsername == null) return;
      if (_loggedInUsername != fromUsername &&
          _loggedInUsername != toUsername) {
        return;
      }

      final text = payload['text'] as String? ?? '';
      final imageBytes = payload['imageBase64'] != null
          ? base64Decode(payload['imageBase64'] as String)
          : null;
      final threadKey = _loggedInUsername == fromUsername
          ? toUsername
          : fromUsername;
      final sender = _loggedInUsername == fromUsername ? 'me' : fromUsername;
      final thread = _chatThreads.putIfAbsent(threadKey, () => []);
      thread.add({
        'sender': sender,
        'text': text,
        'imageBytes': imageBytes,
        'timestamp': DateTime.now(),
      });
      notifyListeners();
    }
  }

  void _initializeDefaultAccounts() {
    const defaultUsername = 'mongtiengdev';
    if (!_users.containsKey(defaultUsername)) {
      _users[defaultUsername] = {
        'name': 'mongtiengdev',
        'password': 'mt2026',
        'location': 'Việt Nam',
        'contact': 'admin@aqualink.vn',
        'age': 25,
        'bio': 'Tài khoản quản trị viên hệ thống',
        'avatarBytes': null,
      };
      _persistState();
    }

    const virtualUsername = 'nguyenthuantom';
    if (!_users.containsKey(virtualUsername)) {
      _users[virtualUsername] = {
        'name': 'Nguyễn Thuận - Tôm',
        'password': 'tmt2026',
        'location': 'Phường 2, TP.Trà Vinh, Trà Vinh',
        'contact': 'nguyenthuantom@gmail.com',
        'age': 30,
        'bio': 'Tài khoản ảo để trao đổi về tôm và nuôi trồng.',
        'avatarBytes': null,
      };
      _persistState();
    }
  }

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String _loggedInUsername = '';
  String get username => _loggedInUsername;

  String get userLocation =>
      _users[_loggedInUsername]?['location'] as String? ??
      translate('unknown_location');
  String get userContact =>
      _users[_loggedInUsername]?['contact'] as String? ?? '';
  int get userAge => _users[_loggedInUsername]?['age'] as int? ?? 0;

  String get userBio {
    final bio = _users[_loggedInUsername]?['bio'] as String?;
    return bio != null && bio.isNotEmpty ? bio : translate('bio_empty');
  }

  final Map<String, Map<String, dynamic>> _users = {};
  final Map<String, List<Map<String, dynamic>>> _chatThreads = {};

  List<Map<String, dynamic>> get userDirectory {
    return _users.entries
        .where((entry) => entry.key != _loggedInUsername)
        .map(
          (entry) => {
            'username': entry.key,
            'name': entry.value['name'] as String? ?? entry.key,
            'location': entry.value['location'] as String? ?? '',
          },
        )
        .toList(growable: false);
  }

  String getUserDisplayName(String username) {
    return _users[username]?['name'] as String? ?? username;
  }

  String getUserLocation(String username) {
    return _users[username]?['location'] as String? ?? '';
  }

  Uint8List? getUserAvatar(String username) {
    return _users[username]?['avatarBytes'] as Uint8List?;
  }

  void setCurrentUserAvatar(Uint8List? bytes) {
    if (_loggedInUsername.isEmpty) return;
    _users[_loggedInUsername]!['avatarBytes'] = bytes;
    _persistState();
    notifyListeners();
  }

  List<Map<String, dynamic>> getChatThread(String username) {
    return List.unmodifiable(_chatThreads[username] ?? []);
  }

  void sendUserMessage(
    String targetUsername, {
    String? text,
    Uint8List? imageBytes,
  }) {
    if ((text?.trim().isEmpty ?? true) && imageBytes == null) return;

    final thread = _chatThreads.putIfAbsent(targetUsername, () => []);
    thread.add({
      'sender': 'me',
      'text': text?.trim() ?? '',
      'imageBytes': imageBytes,
      'timestamp': DateTime.now(),
    });
    notifyListeners();

    _syncChannel.sendMessage('user_message', {
      'fromUsername': _loggedInUsername,
      'toUsername': targetUsername,
      'text': text?.trim() ?? '',
      'imageBase64': imageBytes != null ? base64Encode(imageBytes) : null,
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      final responseThread = _chatThreads.putIfAbsent(targetUsername, () => []);
      final responseText = _buildAutoReply(targetUsername, text?.trim() ?? '');
      responseThread.add({
        'sender': targetUsername,
        'text': responseText,
        'imageBytes': null,
        'timestamp': DateTime.now(),
      });
      notifyListeners();
    });
  }

  String _buildAutoReply(String targetUsername, String message) {
    final displayName = getUserDisplayName(targetUsername);
    final lowered = message.toLowerCase();

    if (targetUsername.toLowerCase() == 'nguyenthuantom') {
      if (lowered.contains('chào') || lowered.contains('hello')) {
        return 'Chào bạn! Mình là $displayName. Mình có thể giúp bạn trao đổi về tôm, giá cả, hoặc kỹ thuật nuôi trồng.';
      }
      if (lowered.contains('giá') || lowered.contains('price')) {
        return 'Giá tôm hôm nay đang biến động nhẹ, bạn nên theo dõi thường xuyên để quyết định bán đúng thời điểm.';
      }
      if (lowered.contains('bệnh') || lowered.contains('disease')) {
        return 'Nếu tôm có dấu hiệu lờ đờ hoặc đốm trắng, hãy kiểm tra nước và liên hệ kỹ thuật viên sớm nhé.';
      }
      if (lowered.contains('nuôi') || lowered.contains('ao')) {
        return 'Với ao nuôi, việc thay nước đều đặn và giữ môi trường ổn định là rất quan trọng.';
      }
      return 'Cảm ơn bạn đã nhắn cho mình. Mình có thể trao đổi về giá tôm, bệnh tôm hoặc cách nuôi khỏe.';
    }

    return 'Tin nhắn của bạn đã được gửi đến $displayName. Họ sẽ trả lời sớm.';
  }

  String? logIn(String username, String password) {
    if (username.trim().isEmpty || password.isEmpty) {
      return translate('error_login_fields');
    }

    final normalizedUsername = username.trim().toLowerCase();
    final account = _users[normalizedUsername];
    if (account == null) {
      return translate('error_user_not_found');
    }
    if (account['password'] != password) {
      return translate('error_wrong_password');
    }

    _isLoggedIn = true;
    _loggedInUsername = normalizedUsername;
    notifyListeners();
    return null;
  }

  String? signUp({
    required String location,
    required String username,
    required String contact,
    required String age,
    required String password,
    required String confirmPassword,
  }) {
    final normalizedUsername = username.trim().toLowerCase();

    if (location.trim().isEmpty ||
        username.trim().isEmpty ||
        contact.trim().isEmpty ||
        age.trim().isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return translate('error_missing_fields');
    }

    if (_users.containsKey(normalizedUsername)) {
      return translate('error_username_exists');
    }

    if (password.length < 8) {
      return translate('error_password_length');
    }

    if (password != confirmPassword) {
      return translate('error_password_mismatch');
    }

    final parsedAge = int.tryParse(age.trim());
    if (parsedAge == null || parsedAge <= 0) {
      return translate('error_invalid_age');
    }

    _users[normalizedUsername] = {
      'name': username.trim(),
      'password': password,
      'location': location.trim(),
      'contact': contact.trim(),
      'age': parsedAge,
      'bio': '',
      'avatarBytes': null,
    };

    _persistState();

    _syncChannel.sendMessage('new_user', {
      'username': normalizedUsername,
      'name': username.trim(),
      'password': password,
      'location': location.trim(),
      'contact': contact.trim(),
      'age': parsedAge,
      'bio': '',
      'avatarBase64': null,
    });

    _isLoggedIn = true;
    _loggedInUsername = normalizedUsername;
    notifyListeners();
    return null;
  }

  void logOut() {
    _isLoggedIn = false;
    _loggedInUsername = '';
    notifyListeners();
  }

  void setUserBio(String bio) {
    if (_users[_loggedInUsername] == null) return;
    _users[_loggedInUsername]!['bio'] = bio;
    notifyListeners();
  }

  String? changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    if (!_isLoggedIn || _loggedInUsername.isEmpty) {
      return translate('error_login_required');
    }

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return translate('error_missing_fields');
    }

    final account = _users[_loggedInUsername];
    if (account == null || account['password'] != currentPassword) {
      return translate('error_current_password_wrong');
    }

    if (newPassword.length < 8) {
      return translate('error_new_password_length');
    }

    if (newPassword != confirmPassword) {
      return translate('error_new_password_mismatch');
    }

    account['password'] = newPassword;
    notifyListeners();
    return null;
  }

  Uint8List? _selectedImageBytes;
  Uint8List? get selectedImageBytes => _selectedImageBytes;

  void pickImageBytes(Uint8List? bytes) {
    _selectedImageBytes = bytes;
    notifyListeners();
  }

  void clearSelectedImage() {
    _selectedImageBytes = null;
    notifyListeners();
  }

  final List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> get posts => List.unmodifiable(_posts);

  List<Map<String, dynamic>> get savedPosts =>
      _posts.where((post) => post['isSaved'] as bool).toList();

  void addPost(String content) {
    if (content.trim().isEmpty && _selectedImageBytes == null) return;

    final author = _loggedInUsername.isNotEmpty
        ? _loggedInUsername
        : 'Tôi (Long-Developer)';

    final postId = DateTime.now().millisecondsSinceEpoch;
    _posts.insert(0, {
      'id': postId,
      'author': author,
      'time': 'Vừa xong',
      'content': content,
      'imageBytes': _selectedImageBytes,
      'isSaved': false,
    });

    _persistState();

    _syncChannel.sendMessage('new_post', {
      'id': postId,
      'author': author,
      'time': 'Vừa xong',
      'content': content,
      'imageBase64': _selectedImageBytes != null
          ? base64Encode(_selectedImageBytes!)
          : null,
    });

    _selectedImageBytes = null;
    _index = 0;
    notifyListeners();
  }

  void toggleSavedPost(int id) {
    final index = _posts.indexWhere((post) => post['id'] == id);
    if (index == -1) return;
    _posts[index]['isSaved'] = !(_posts[index]['isSaved'] as bool);
    notifyListeners();
  }

  List<Map<String, dynamic>> searchPosts(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return _posts;
    return _posts.where((post) {
      final content = (post['content'] as String).toLowerCase();
      final author = (post['author'] as String).toLowerCase();
      return content.contains(trimmed) || author.contains(trimmed);
    }).toList();
  }

  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text':
          'Xin chào! Mình là AquaBot. Bạn cần hỗ trợ gì về tôm hay tra cứu giá cả hôm nay không?',
    },
  ];

  String _latestMarketPriceText = '';
  String get latestMarketPriceText => _latestMarketPriceText;

  Future<String> fetchLatestMarketPrice() async {
    const sourceUrl =
        'https://tepbac.com/gia-thuy-san/gia-loai/tom-the-chan-trang';
    try {
      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0 Safari/537.36',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      };

      http.Response? resp;
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          resp = await http
              .get(Uri.parse(sourceUrl), headers: headers)
              .timeout(const Duration(seconds: 8));
          if (resp.statusCode == 200) break;
        } catch (_) {
          // retry once
        }
      }
      if (resp == null || resp.statusCode != 200) {
        throw Exception('HTTP ${resp?.statusCode ?? 'ERR'}');
      }

      final doc = html_parser.parse(resp.body);
      final text = doc.body?.text ?? resp.body;

      final rangeReg = RegExp(
        r"(\d{1,3}(?:[.,]\d{3})+|\d{4,7})\s*(?:-|–|\bđến\b|\bden\b|to)\s*(\d{1,3}(?:[.,]\d{3})+|\d{4,7})\s*(?:đ|vnd|vnđ)?",
        caseSensitive: false,
      );
      final singleReg = RegExp(
        r"(\d{1,3}(?:[.,]\d{3})+|\d{4,7})\s*(?:đ|vnd|vnđ)",
        caseSensitive: false,
      );

      final prices = <int>[];

      final rangeMatch = rangeReg.firstMatch(text);
      if (rangeMatch != null) {
        String a = rangeMatch.group(1)!;
        String b = rangeMatch.group(2)!;
        int? ai = int.tryParse(a.replaceAll('.', '').replaceAll(',', ''));
        int? bi = int.tryParse(b.replaceAll('.', '').replaceAll(',', ''));
        if (ai != null && bi != null) prices.addAll([ai, bi]);
      }

      for (final m in singleReg.allMatches(text)) {
        final s = m.group(1)!;
        final normalized = s.replaceAll('.', '').replaceAll(',', '').trim();
        final v = int.tryParse(normalized);
        if (v != null) prices.add(v);
      }

      final filtered = prices.where((v) => v >= 10000 && v <= 2000000).toList();
      if (filtered.isEmpty) {
        if (_latestMarketPriceText.isNotEmpty) {
          return 'Không thể lấy giá realtime. Dùng dữ liệu gần nhất: $_latestMarketPriceText';
        }
        return 'Theo dữ liệu thị trường hôm nay, hiện chưa lấy được giá chính xác. Mở nguồn dữ liệu để xem chi tiết: $sourceUrl';
      }

      final min = filtered.reduce((a, b) => a < b ? a : b);
      final max = filtered.reduce((a, b) => a > b ? a : b);

      String fmt(int v) => v.toString().replaceAllMapped(
        RegExp(r"(\d)(?=(\d{3})+(?!\d))"),
        (m) => '${m[1]},',
      );

      _latestMarketPriceText =
          'Theo dữ liệu thị trường hôm nay, giá tôm thẻ chân trắng tại ĐBSCL dao động từ ${fmt(min)}đ đến ${fmt(max)}đ/kg tùy size.';
      return _latestMarketPriceText;
    } catch (e) {
      if (_latestMarketPriceText.isNotEmpty) {
        return 'Không thể lấy giá realtime. Dùng dữ liệu gần nhất: $_latestMarketPriceText';
      }
      return 'Theo dữ liệu thị trường hôm nay, không thể lấy giá realtime. Vui lòng thử lại sau.';
    }
  }

  List<Map<String, dynamic>> get messages => _messages;

  bool _isBotTyping = false;
  bool get isBotTyping => _isBotTyping;

  // Xác định Server URL theo platform
  String get _backendUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/chat';
    } else {
      return defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:5000/api/chat'
          : 'http://localhost:5000/api/chat';
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Thêm tin nhắn của user vào UI ngay
    _messages.add({'isBot': false, 'text': text});
    _isBotTyping = true;
    notifyListeners();

    try {
      // Gọi HTTP POST tới Node.js Backend
      final response = await http
          .post(
            Uri.parse(_backendUrl),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'message': text}),
          )
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () {
              throw TimeoutException('Timeout after 90 seconds');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // Cập nhật câu trả lời từ Gemini API
        if (data is Map && data['reply'] is String) {
          _messages.add({'isBot': true, 'text': data['reply']});
        } else {
          _messages.add({
            'isBot': true,
            'text': 'Format response không hợp lệ',
          });
        }
      } else {
        _messages.add({'isBot': true, 'text': 'Lỗi ${response.statusCode}'});
      }
    } on TimeoutException {
      _messages.add({
        'isBot': true,
        'text':
            '⏱️ Server không phản hồi. Hãy chạy: node server.js trên port 5000',
      });
    } catch (e) {
      _messages.add({'isBot': true, 'text': 'Lỗi: ${e.toString()}'});
    } finally {
      _isBotTyping = false;
      notifyListeners();
    }
  }
}
