import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'broadcast_channel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AquaLinkApp());
}

class AquaLinkApp extends StatelessWidget {
  const AquaLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppDataProvider(),
      child: Consumer<AppDataProvider>(
        builder: (context, appData, _) {
          return MaterialApp(
            title: 'AquaLink',
            debugShowCheckedModeBanner: false,
            themeMode: appData.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Roboto',
              scaffoldBackgroundColor: const Color(0xFFEAF8FA),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF007C89),
                primary: const Color(0xFF007C89),
                secondary: const Color(0xFF00A7B5),
                surface: Colors.white,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Colors.transparent,
                foregroundColor: Color(0xFF073B4C),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF090909),
              cardColor: const Color(0xFF151515),
              dialogTheme: const DialogThemeData(
                backgroundColor: Color(0xFF121212),
              ),
              canvasColor: const Color(0xFF0D0D0D),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00B2CA),
                onPrimary: Colors.white,
                secondary: Color(0xFF80D7EA),
                onSecondary: Colors.white,
                surface: Color(0xFF141414),
                onSurface: Colors.white,
                error: Color(0xFFCF6679),
                onError: Colors.white,
                brightness: Brightness.dark,
              ),
              textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
              iconTheme: const IconThemeData(color: Colors.white70),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
            ),
            home: appData.isLoggedIn ? const MainShell() : const AuthScreen(),
          );
        },
      ),
    );
  }
}

// Khu vực quản lí chung của app
class AppDataProvider extends ChangeNotifier {
  late final BroadcastSyncChannel _syncChannel;

  AppDataProvider() {
    _syncChannel = createBroadcastSyncChannel(_handleSyncEvent);
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
          'Xin lỗi, mình chưa hiểu bạn hỏi gì :( Bạn có thể hỏi về giá tôm hôm nay hoặc cách vệ sinh ao nuôi...! Câu hỏi của bạn đã được ghi nhận, tương lai đội ngũ AquaLink sẽ cập nhật.',
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
          'Sorry, I did not understand. You can ask about today’s shrimp prices or pond hygiene... Your question is recorded and AquaLink may update soon.',
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
    _syncChannel.dispose();
    super.dispose();
  }

  void _handleSyncEvent(String type, Map<String, dynamic> payload) {
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
      notifyListeners();
      return;
    }

    if (type == 'user_message') {
      final fromUsername = payload['fromUsername'] as String?;
      final toUsername = payload['toUsername'] as String?;
      if (fromUsername == null || toUsername == null) return;
      if (_loggedInUsername != fromUsername && _loggedInUsername != toUsername)
        return;

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
      responseThread.add({
        'sender': targetUsername,
        'text':
            'Tin nhắn của bạn đã được gửi đến ${getUserDisplayName(targetUsername)}. Họ sẽ trả lời sớm.',
        'imageBytes': null,
        'timestamp': DateTime.now(),
      });
      notifyListeners();
    });
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

  // Ảnh chọn tạm thời
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

  // 1. Quản lý danh sách bài viết (Bản tin)
  final List<Map<String, dynamic>> _posts = [];

  List<Map<String, dynamic>> get posts => List.unmodifiable(_posts);

  List<Map<String, dynamic>> get savedPosts =>
      _posts.where((post) => post['isSaved'] as bool).toList();

  void addPost(String content) {
    // Không cho đăng nếu không có cả chữ lẫn ảnh
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

    _syncChannel.sendMessage('new_post', {
      'id': postId,
      'author': author,
      'time': 'Vừa xong',
      'content': content,
      'imageBase64': _selectedImageBytes != null
          ? base64Encode(_selectedImageBytes!)
          : null,
    });

    _selectedImageBytes = null; // Reset ảnh sau khi đăng
    _index = 0; // Đăng xong quay về trang chủ
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

  // 2. Quản lý cuộc trò chuyện với AquaBot
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

      // detect ranges like "132.000 - 145.000 đ" or singles like "132.000 đ"
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

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _messages.add({'isBot': false, 'text': text});
    _isBotTyping = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 1500), () async {
      final t = translate;
      String reply = t('assistant_default');
      String input = text.toLowerCase();

      if (input.contains('chào') || input.contains('hello')) {
        reply = t('assistant_greeting');
      } else if (input.contains('giá tôm') || input.contains('shrimp price')) {
        reply = t('assistant_price');
      } else if (input.contains('bệnh') ||
          input.contains('chết') ||
          input.contains('disease')) {
        reply = t('assistant_disease');
      } else if (input.contains('vệ sinh') || input.contains('hygiene')) {
        reply = t('assistant_hygiene');
      } else {
        reply = t('assistant_unknown');
      }

      _isBotTyping = false;
      _messages.add({'isBot': true, 'text': reply});
      notifyListeners();
    });
  }
}

// ĐIỀU HƯỚNG CHÍNH APP
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _pages = <Widget>[
    FeedScreen(),
    PostScreen(),
    SearchScreen(),
    SettingsScreen(),
    AssistantScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppDataProvider>();

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(animation);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        child: SizedBox(key: ValueKey(nav.index), child: _pages[nav.index]),
      ),
      bottomNavigationBar: const GlassBottomNav(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isRegisterMode = false;
  bool _showPassword = false;
  String? _errorText;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _usernameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _locationController.clear();
    _contactController.clear();
    _ageController.clear();
    _errorText = null;
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _clearFields();
    });
  }

  void _handleSubmit() {
    final appData = context.read<AppDataProvider>();
    if (_isRegisterMode) {
      final error = appData.signUp(
        location: _locationController.text,
        username: _usernameController.text,
        contact: _contactController.text,
        age: _ageController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appData.translate('registration_success'))),
      );
    } else {
      final error = appData.logIn(
        _usernameController.text,
        _passwordController.text,
      );
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
      _clearFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appData.translate('login_success'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final theme = Theme.of(context);
    final t = appData.translate;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? t('signup_title') : t('login_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isRegisterMode ? t('signup_title') : t('login_title'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_isRegisterMode) ...[
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: t('location_label'),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: t('username_label'),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 12),
            if (_isRegisterMode) ...[
              TextField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: t('contact_label'),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t('age_label'),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: t('password_label'),
                filled: true,
                fillColor: theme.colorScheme.surface,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
            ),
            if (_isRegisterMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: t('confirm_password_label'),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ],
            if (_errorText != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorText!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                child: Text(
                  _isRegisterMode ? t('signup_button') : t('login_button'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _toggleMode,
              child: Text(
                _isRegisterMode ? t('have_account') : t('no_account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({super.key});

  static const _items = [
    _NavItem('feed_title', Icons.feed_rounded),
    _NavItem('post_feed', Icons.add_circle_outline_rounded),
    _NavItem('search_title', Icons.search_rounded),
    _NavItem('settings_title', Icons.settings_rounded),
    _NavItem('assistant_title', Icons.smart_toy_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<AppDataProvider>();
    final appData = context.watch<AppDataProvider>();

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF005F73).withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _items.length;
                return Stack(
                  children: [
                    AnimatedAlign(
                      alignment: Alignment(-1 + nav.targetIndex * 0.5, 0),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        width: itemWidth - 8,
                        height: 56,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF007C89,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_items.length, (index) {
                        final item = _items[index];
                        final selected = nav.targetIndex == index;

                        return Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => nav.setIndex(index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 24,
                                    color: selected
                                        ? const Color(0xFF007C89)
                                        : const Color(0xFF5D7A83),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    appData.translate(item.labelKey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected
                                          ? const Color(0xFF007C89)
                                          : const Color(0xFF5D7A83),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.labelKey, this.icon);
  final String labelKey;
  final IconData icon;
}

// 1. MÀN HÌNH BẢN TIN (DỮ LIỆU ĐỘNG)
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appData.translate('feed_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100, top: 10),
        itemCount: appData.posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: InkWell(
                onTap: () {
                  // Xóa async/await để tránh bị Chrome chặn Pop-up
                  print('Đã click mở link giá tôm đồng bộ!');

                  launchUrl(
                    Uri.parse(
                      'https://tepbac.com/gia-thuy-san/gia-loai/tom-the-chan-trang',
                    ),
                    mode: LaunchMode.platformDefault,
                    webOnlyWindowName: '_blank',
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appData.translate('feed_price_update_title'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              appData.translate('feed_price_update_subtitle'),
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.launch, color: Color(0xFF007C89)),
                    ],
                  ),
                ),
              ),
            );
          }

          final post = appData.posts[index - 1];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            color: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.16),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade200,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['author']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            post['time']!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (post['content']!.isNotEmpty)
                    Text(
                      post['content']!,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.85,
                        ),
                      ),
                    ),

                  // Hiển thị ảnh nếu bài viết có đính kèm ảnh
                  if (post['imageBytes'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: double.infinity,
                          height: 220,
                          child: Image.memory(
                            post['imageBytes'] as Uint8List,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        (post['isSaved'] as bool)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.teal,
                      ),
                      onPressed: () =>
                          appData.toggleSavedPost(post['id'] as int),
                      tooltip: (post['isSaved'] as bool)
                          ? appData.translate('unsave_post')
                          : appData.translate('save_post'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 2. MÀN HÌNH ĐĂNG BÀI (XỬ LÝ LỆNH ĐĂNG & CHỌN ẢNH)

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _handlePickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();
    if (!mounted) return;
    context.read<AppDataProvider>().pickImageBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appData.translate('create_post_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: appData.translate('create_post_hint'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // Khu vực hiển thị ảnh đã chọn trước khi đăng
            if (appData.selectedImageBytes != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: MemoryImage(appData.selectedImageBytes!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () =>
                        context.read<AppDataProvider>().clearSelectedImage(),
                  ),
                ],
              ),

            Row(
              children: [
                // Nút chọn ảnh
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary),
                  ),
                  child: IconButton(
                    onPressed: _handlePickImage,
                    icon: Icon(
                      Icons.add_photo_alternate,
                      color: theme.colorScheme.primary,
                    ),
                    tooltip: appData.translate('choose_image'),
                  ),
                ),
                const SizedBox(width: 12),

                // Nút đăng bài
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      appData.addPost(_controller.text);
                      _controller.clear();
                      FocusScope.of(
                        context,
                      ).unfocus(); // Ẩn bàn phím đi cho mượt
                    },
                    icon: const Icon(Icons.send),
                    label: Text(appData.translate('post_now_button')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 3. MÀN HÌNH TÌM KIẾM
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final theme = Theme.of(context);
    final results = appData.searchPosts(_searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appData.translate('search_title'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: appData.translate('search_hint'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 16),
            if (_searchController.text.trim().isEmpty) ...[
              Text(
                appData.translate('popular_keywords'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildSearchChip(appData.translate('search_chip_price')),
                  _buildSearchChip(appData.translate('search_chip_dealer')),
                  _buildSearchChip(appData.translate('search_chip_disease')),
                ],
              ),
            ] else ...[
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                          appData.translate('not_found_posts'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : ListView.separated(
                        itemCount: results.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final post = results[index];
                          return Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: theme.dividerColor.withValues(
                                  alpha: 0.16,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['author']!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    post['content']!,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(String label) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.12),
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      onPressed: () {
        _searchController.text = label;
        setState(() {});
      },
    );
  }
}

// 4. MÀN HÌNH CÀI ĐẶT (ĐÃ NÂNG CẤP)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final theme = Theme.of(context);
    final t = appData.translate;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t('settings_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          bottom: 100,
          left: 16,
          right: 16,
          top: 8,
        ),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Builder(
                      builder: (context) {
                        final currentAvatar = appData.getUserAvatar(
                          appData.username,
                        );
                        final displayName = appData.username.isNotEmpty
                            ? appData.getUserDisplayName(appData.username)
                            : 'LD';
                        final initials = displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'LD';

                        return CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF007C89),
                          backgroundImage: currentAvatar != null
                              ? MemoryImage(currentAvatar)
                              : null,
                          child: currentAvatar == null
                              ? Text(
                                  initials,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A7B5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  appData.username.isNotEmpty
                      ? appData.username
                      : appData.translate('default_user_label'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF073B4C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appData.userContact.isNotEmpty
                      ? appData.userContact
                      : 'support@aqualink.vn',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text(
            t('account_section'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              _buildListTile(
                context,
                icon: Icons.person_outline_rounded,
                title: t('profile_personal'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
              _buildDivider(context),
              _buildListTile(
                context,
                icon: Icons.lock_outline_rounded,
                title: t('change_password'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(context),
              _buildListTile(
                context,
                icon: Icons.bookmark_border_rounded,
                title: t('saved_posts'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedPostsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            t('app_section'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              _buildSwitchTile(
                context,
                icon: Icons.notifications_active_outlined,
                title: t('push_notifications'),
                value: appData.pushNotifications,
                onChanged: appData.setPushNotifications,
              ),
              _buildDivider(context),
              _buildSwitchTile(
                context,
                icon: Icons.trending_up_rounded,
                title: t('market_alerts'),
                value: appData.marketAlerts,
                onChanged: appData.setMarketAlerts,
              ),
              _buildDivider(context),
              _buildSwitchTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: t('dark_theme'),
                value: appData.isDarkMode,
                onChanged: appData.setDarkMode,
              ),
              _buildDivider(context),
              _buildListTile(
                context,
                icon: Icons.people_outline,
                title: t('user_directory'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserDirectoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            t('other_section'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsCard(
            context,
            children: [
              _buildListTile(
                context,
                icon: Icons.help_outline_rounded,
                title: t('support_center'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SupportCenterScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(context),
              _buildListTile(
                context,
                icon: Icons.security_rounded,
                title: t('terms_policy'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  );
                },
              ),
              _buildDivider(context),
              _buildListTile(
                context,
                icon: Icons.info_outline_rounded,
                title: t('app_version'),
                trailingText: 'v1.0.0',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Nút Đăng xuất
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<AppDataProvider>().logOut();
              },
              icon: const Icon(Icons.logout_rounded),
              label: Text(
                t('logout'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Khung Card bo góc dùng chung cho các cụm cài đặt để UI sạch sẽ
  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.16),
          width: 1.5,
        ),
      ),
      child: Column(children: children),
    );
  }

  // Hàm tạo dòng ListTile cơ bản
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.bold,
              ),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
      onTap: onTap,
    );
  }

  // Hàm tạo dòng ListTile có nút gạt Switch

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: theme.colorScheme.primary,
        activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.35),
        inactiveThumbColor: theme.colorScheme.onSurface.withValues(alpha: 0.75),
        inactiveTrackColor: theme.colorScheme.onSurface.withValues(alpha: 0.24),
      ),
    );
  }

  // Đường kẻ mỏng ngăn cách giữa các item trong Card
  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor.withValues(alpha: 0.3),
      indent: 56,
      endIndent: 16,
    );
  }
}

class UserDirectoryScreen extends StatelessWidget {
  const UserDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final users = appData.userDirectory;
    final t = appData.translate;

    return Scaffold(
      appBar: AppBar(title: Text(t('user_directory'))),
      body: users.isEmpty
          ? Center(
              child: Text(
                t('no_users_found'),
                style: const TextStyle(fontSize: 16),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF007C89),
                      backgroundImage:
                          appData.getUserAvatar(user['username'] as String) !=
                              null
                          ? MemoryImage(
                              appData.getUserAvatar(
                                user['username'] as String,
                              )!,
                            )
                          : null,
                      child:
                          appData.getUserAvatar(user['username'] as String) ==
                              null
                          ? Text(
                              (user['name'] as String).substring(0, 1),
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    title: Text(user['name'] as String),
                    subtitle: Text(
                      '${t('user_address')}: ${user['location'] as String}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserProfileScreen(
                            username: user['username'] as String,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final String username;

  const UserProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final name = appData.getUserDisplayName(username);
    final location = appData.getUserLocation(username);
    final avatarBytes = appData.getUserAvatar(username);
    final t = appData.translate;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF007C89),
                backgroundImage: avatarBytes != null
                    ? MemoryImage(avatarBytes)
                    : null,
                child: avatarBytes == null
                    ? Text(
                        name.isNotEmpty ? name[0] : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '${t('user_address')}: $location',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserChatScreen(targetUsername: username),
                  ),
                );
              },
              icon: const Icon(Icons.message_outlined),
              label: Text('${t('chat_with')} $name'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007C89),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserChatScreen extends StatefulWidget {
  final String targetUsername;

  const UserChatScreen({super.key, required this.targetUsername});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _attachedImage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _attachedImage = bytes;
    });
  }

  void _sendMessage(AppDataProvider appData) {
    if (_messageController.text.trim().isEmpty && _attachedImage == null)
      return;
    appData.sendUserMessage(
      widget.targetUsername,
      text: _messageController.text,
      imageBytes: _attachedImage,
    );
    _messageController.clear();
    setState(() {
      _attachedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final messages = appData.getChatThread(widget.targetUsername);
    final targetName = appData.getUserDisplayName(widget.targetUsername);
    final t = appData.translate;

    return Scaffold(
      appBar: AppBar(title: Text('${t('chat_with')} $targetName')),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      t('no_messages'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message['sender'] == 'me';
                      final imageBytes = message['imageBytes'] as Uint8List?;
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 300),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF007C89)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (imageBytes != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.memory(imageBytes),
                                ),
                                const SizedBox(height: 10),
                              ],
                              if ((message['text'] as String).isNotEmpty)
                                Text(
                                  message['text'] as String,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black87,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_attachedImage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t('attach_image'),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _attachedImage = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: t('type_message'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _sendMessage(appData),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: Text(t('send')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    context.read<AppDataProvider>().setCurrentUserAvatar(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final avatarBytes = appData.getUserAvatar(appData.username);
    final displayName = appData.getUserDisplayName(appData.username);
    final initials = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(title: Text(appData.translate('profile_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF007C89),
                backgroundImage: avatarBytes != null
                    ? MemoryImage(avatarBytes)
                    : null,
                child: avatarBytes == null
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickAvatar,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(appData.translate('change_avatar')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              appData.translate('personal_info'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              appData.translate('username_label'),
              appData.username,
            ),
            _buildInfoTile(
              appData.translate('location_label'),
              appData.userLocation,
            ),
            _buildInfoTile(
              appData.translate('contact_label'),
              appData.userContact,
            ),
            _buildInfoTile(
              appData.translate('age_label'),
              appData.userAge.toString(),
            ),
            const SizedBox(height: 24),
            Text(
              appData.translate('bio_title'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              appData.userBio,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showEditBioDialog(context, appData),
              icon: const Icon(Icons.edit),
              label: Text(appData.translate('edit_bio')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 14),
      ],
    );
  }

  Future<void> _showEditBioDialog(
    BuildContext context,
    AppDataProvider appData,
  ) async {
    final controller = TextEditingController(text: appData.userBio);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(appData.translate('edit_bio_dialog_title')),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: appData.translate('bio_hint'),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(appData.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AppDataProvider>().setUserBio(
                  controller.text.trim(),
                );
                Navigator.of(context).pop();
              },
              child: Text(appData.translate('save')),
            ),
          ],
        );
      },
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(appData.translate('change_password_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _currentController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: appData.translate('current_password'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: appData.translate('new_password'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: appData.translate('confirm_new_password'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final appData = context.read<AppDataProvider>();
                  final error = appData.changePassword(
                    currentPassword: _currentController.text,
                    newPassword: _newController.text,
                    confirmPassword: _confirmController.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error ?? appData.translate('password_saved'),
                      ),
                    ),
                  );

                  if (error == null) {
                    _currentController.clear();
                    _newController.clear();
                    _confirmController.clear();
                  }
                },
                child: Text(appData.translate('change_password_button')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appData = context.watch<AppDataProvider>();
    final savedPosts = appData.savedPosts;

    return Scaffold(
      appBar: AppBar(title: Text(appData.translate('saved_posts_title'))),
      body: savedPosts.isEmpty
          ? Center(
              child: Text(
                appData.translate('saved_posts_empty'),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedPosts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final post = savedPosts[index];
                return Card(
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['author']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post['content']!,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                appData.toggleSavedPost(post['id'] as int);
                              },
                              icon: const Icon(Icons.bookmark_remove_outlined),
                              label: Text(appData.translate('unsave')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(appData.translate('support_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appData.translate('help_title'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(appData.translate('support_text')),
          ],
        ),
      ),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(appData.translate('policy_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(appData.translate('terms_content')),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(appData.translate('about_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appData.translate('about_name'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(appData.translate('about_version')),
            const SizedBox(height: 8),
            Text(appData.translate('about_updated')),
          ],
        ),
      ),
    );
  }
}

// 5. MÀN HÌNH TRỢ LÝ AquaBot
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen>
    with SingleTickerProviderStateMixin {
  final _msgController = TextEditingController();
  late final AnimationController _typingController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _typingController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage(AppDataProvider appData) {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    appData.sendMessage(text);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            const Text(
              'AquaBot Assistant',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appData.messages.length,
              itemBuilder: (context, index) {
                final msg = appData.messages[index];
                final isBot = msg['isBot'] as bool;

                return Align(
                  alignment: isBot
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isBot
                          ? theme.colorScheme.surface
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomLeft: isBot
                            ? const Radius.circular(0)
                            : const Radius.circular(16),
                        bottomRight: isBot
                            ? const Radius.circular(16)
                            : const Radius.circular(0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Text(
                      msg['text'] as String,
                      style: TextStyle(
                        color: isBot
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (appData.isBotTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    height: 18,
                    child: AnimatedBuilder(
                      animation: _typingController,
                      builder: (context, child) {
                        final value = _typingController.value;
                        final offset = (value * 2 - 1) * 3;
                        return Transform.translate(
                          offset: Offset(0, -offset),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(3, (dotIndex) {
                              final dotValue =
                                  ((value + dotIndex * 0.2) % 1.0) * 2;
                              final scale =
                                  0.6 + 0.4 * (1 - (dotValue - 1).abs());
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                child: Transform.scale(
                                  scale: scale,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    appData.translate('assistant_thinking'),
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(appData),
                    decoration: InputDecoration(
                      hintText: appData.translate('assistant_hint'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: Icon(Icons.send, color: theme.colorScheme.onPrimary),
                    onPressed: () {
                      appData.sendMessage(_msgController.text);
                      _msgController.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
