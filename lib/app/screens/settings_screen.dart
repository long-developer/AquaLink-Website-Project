import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:project_aqualink/app/providers/app_data_provider.dart';

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

class UserDirectoryScreen extends StatefulWidget {
  const UserDirectoryScreen({super.key});

  @override
  State<UserDirectoryScreen> createState() => _UserDirectoryScreenState();
}

class _UserDirectoryScreenState extends State<UserDirectoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts({String query = ''}) async {
    final appData = context.read<AppDataProvider>();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = query.trim().isEmpty
          ? await appData.fetchContacts()
          : await appData.searchUsers(query);
      if (!mounted) return;
      setState(() {
        _users = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final t = appData.translate;

    return Scaffold(
      appBar: AppBar(title: Text(t('user_directory'))),
      body: Column(
        children: [
          if (appData.latestNotificationText.isNotEmpty) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF007C89).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF007C89).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF007C89),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        appData.clearLatestNotification();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserChatScreen(
                              targetUsername: appData.latestNotificationFrom,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Tin nhắn mới từ ${appData.latestNotificationFrom}: ${appData.latestNotificationText}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: appData.clearLatestNotification,
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) => _loadContacts(query: value),
              decoration: InputDecoration(
                hintText: 'Tìm tên / username / email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadContacts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!, textAlign: TextAlign.center))
                : _users.isEmpty
                ? Center(
                    child: Text(
                      t('no_users_found'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _users.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      final username =
                          (user['username'] ?? user['partnerId'] ?? '')
                              .toString();
                      final name = (user['name'] ?? username).toString();
                      final location = (user['location'] ?? 'Việt Nam')
                          .toString();
                      final lastMessage = (user['lastMessage'] ?? '')
                          .toString();
                      final isOnline = appData.isUserOnline(username);

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
                            child: Text(
                              name.isNotEmpty
                                  ? name.substring(0, 1).toUpperCase()
                                  : 'U',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(child: Text(name)),
                              if (isOnline)
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              else
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(left: 8),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            lastMessage.isNotEmpty
                                ? lastMessage
                                : '${t('user_address')}: $location',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (appData.getUnreadCount(username) > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00A7B5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      appData.getUnreadCount(username) > 99
                                          ? '99+'
                                          : appData
                                                .getUnreadCount(username)
                                                .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    appData.clearUnreadCount(username);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => UserChatScreen(
                                          targetUsername: username,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.message_rounded,
                                    color: Color(0xFF007C89),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UserProfileScreen(username: username),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
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
  bool _loadingHistory = true;

  @override
  void initState() {
    super.initState();
    final appData = context.read<AppDataProvider>();
    appData.clearUnreadCount(widget.targetUsername);
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    final appData = context.read<AppDataProvider>();
    try {
      await appData.fetchConversationHistory(widget.targetUsername);
    } catch (_) {
      // fallback to local data if server is unavailable
    } finally {
      if (mounted) {
        setState(() {
          _loadingHistory = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;
      if (!mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _attachedImage = bytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  void _sendMessage(AppDataProvider appData) {
    final text = _messageController.text.trim();
    if ((text.isEmpty && _attachedImage == null) ||
        appData.currentUserId.isEmpty) {
      return;
    }

    if (text.isNotEmpty) {
      appData.sendPrivateMessage(widget.targetUsername, text);
      _messageController.clear();
    }

    setState(() {
      _attachedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppDataProvider>();
    final messages = appData.getPrivateChatThread(widget.targetUsername);
    final targetName = appData.getUserDisplayName(widget.targetUsername);
    final t = appData.translate;

    return Scaffold(
      appBar: AppBar(title: Text('${t('chat_with')} $targetName')),
      body: Column(
        children: [
          Expanded(
            child: _loadingHistory
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
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
                      onSubmitted: (_) => _sendMessage(appData),
                      textInputAction: TextInputAction.send,
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
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;
      if (!mounted) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      context.read<AppDataProvider>().setCurrentUserAvatar(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
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
