import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/study_history_provider.dart';
import '../../utils/theme.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<SettingsProvider, ProgressProvider, AuthProvider, StudyHistoryProvider>(
      builder: (context, settings, progress, auth, history, _) {
        final user = auth.currentUser;
        return Scaffold(
          appBar: AppBar(title: const Text('⚙️ Cài đặt')),
          body: ListView(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFE63946), Color(0xFF1D3557)]),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                      child: user?.photoUrl == null
                          ? Text((user?.displayName ?? 'N').substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 30, color: AppTheme.primaryRed, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(user?.displayName ?? 'Khách', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user?.email ?? 'Chưa đăng nhập', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text('XP: ${progress.progress.totalXP} • Streak: ${progress.progress.currentStreak}', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              _Section(
                title: 'Giao diện & học tập',
                children: [
                  _SwitchTile(icon: Icons.dark_mode_outlined, title: 'Chế độ tối', value: settings.isDarkMode, onChanged: (_) => settings.toggleDarkMode()),
                  _SwitchTile(icon: Icons.translate_outlined, title: 'Hiển thị Romaji', value: settings.showRomaji, onChanged: (_) => settings.toggleRomaji()),
                  _SwitchTile(icon: Icons.text_fields_outlined, title: 'Hiển thị tiếng Việt', value: settings.showVietnamese, onChanged: (_) => settings.toggleVietnamese()),
                ],
              ),
              _Section(
                title: 'Tích hợp hệ điều hành',
                children: [
                  _SwitchTile(icon: Icons.volume_up_outlined, title: 'Âm thanh/TTS & nhạc nền', value: settings.soundEnabled, onChanged: (_) => settings.toggleSound()),
                  _SwitchTile(icon: Icons.notifications_active_outlined, title: 'Nhắc học lúc 20:00', value: settings.notificationsEnabled, onChanged: (_) => settings.toggleNotifications()),
                ],
              ),
              _Section(
                title: 'Tài khoản',
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_done_outlined, color: AppTheme.primaryRed),
                    title: const Text('Đồng bộ dữ liệu'),
                    subtitle: Text(user == null ? 'Đăng nhập để đồng bộ Firebase/Cloud' : 'Tiến độ sẽ được lưu local + cloud nếu Firebase được cấu hình'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppTheme.primaryRed),
                    title: const Text('Đăng xuất'),
                    subtitle: const Text('Thoát tài khoản hiện tại'),
                    onTap: () async {
                      await auth.signOut();
                      await progress.useGuestState();
                      await history.init(userId: 'guest');
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                    },
                  ),
                ],
              ),
              _Section(
                title: 'Dữ liệu',
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_forever_outlined, color: AppTheme.primaryRed),
                    title: const Text('Đặt lại tiến độ'),
                    subtitle: const Text('Xóa XP, streak, bài test và thành tích cục bộ'),
                    onTap: () => _showResetDialog(context, progress),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetDialog(BuildContext context, ProgressProvider progress) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đặt lại tiến độ'),
        content: const Text('Bạn chắc chắn muốn xóa tiến độ hiện tại?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              progress.resetProgress();
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(title, style: const TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryRed),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
