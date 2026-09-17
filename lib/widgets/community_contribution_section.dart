import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/community_contribution.dart';
import '../providers/auth_provider.dart';
import '../services/community_contribution_service.dart';
import '../services/firebase_service.dart';
import '../utils/theme.dart';

class CommunityContributionSection extends StatefulWidget {
  final String itemType;
  final String itemId;
  final Color accentColor;

  const CommunityContributionSection({
    super.key,
    required this.itemType,
    required this.itemId,
    required this.accentColor,
  });

  @override
  State<CommunityContributionSection> createState() =>
      _CommunityContributionSectionState();
}

class _CommunityContributionSectionState
    extends State<CommunityContributionSection> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<CommunityContribution>> _future;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<CommunityContribution>> _load() {
    return CommunityContributionService.instance.fetchContributions(
      itemType: widget.itemType,
      itemId: widget.itemId,
    );
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();
    if (message.isEmpty || _isSubmitting) return;

    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    setState(() => _isSubmitting = true);
    try {
      await CommunityContributionService.instance.submitContribution(
        itemType: widget.itemType,
        itemId: widget.itemId,
        userId: user?.uid ?? 'guest',
        userName: user?.displayName ?? 'Học viên NihonGo',
        message: message,
      );
      _controller.clear();
      if (!mounted) return;
      setState(() => _future = _load());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đóng góp của bạn. Cảm ơn nhé! 💛')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _future = _load());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu góp ý trên thiết bị. Khi có đồng bộ, nội dung sẽ được cập nhật.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phút trước';
    if (diff.inDays < 1) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.accentColor.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.forum_rounded, color: widget.accentColor),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Góc đóng góp cộng đồng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            FirebaseService.isEnabled
                ? 'Mọi người có thể bổ sung mẹo nhớ, ví dụ hay hoặc góp ý chỉnh nghĩa ngay tại đây.'
                : 'Bạn vẫn có thể để lại góp ý. Hiện nội dung sẽ được lưu trên thiết bị này cho đến khi đồng bộ đám mây khả dụng.',
            style: const TextStyle(
              color: AppTheme.textMedium,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Từ này còn nghĩa là..., hoặc mình hay nhớ theo cách...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: widget.accentColor.withOpacity(0.18)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: widget.accentColor.withOpacity(0.18)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.accentColor,
                foregroundColor: Colors.white,
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_isSubmitting ? 'Đang gửi...' : 'Gửi đóng góp'),
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<CommunityContribution>>(
            future: _future,
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <CommunityContribution>[];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (items.isEmpty) {
                return const Text(
                  'Chưa có đóng góp nào. Hãy trở thành người đầu tiên chia sẻ mẹo học của bạn nhé!',
                  style: TextStyle(color: AppTheme.textMedium),
                );
              }
              return Column(
                children: items.take(5).map((item) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: widget.accentColor.withOpacity(0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: widget.accentColor.withOpacity(0.14),
                              child: Text(
                                item.userName.trim().isEmpty ? 'N' : item.userName.trim().substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: widget.accentColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.userName,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            Text(
                              _formatDate(item.createdAt),
                              style: const TextStyle(
                                color: AppTheme.textMedium,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.message,
                          style: const TextStyle(height: 1.45),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
