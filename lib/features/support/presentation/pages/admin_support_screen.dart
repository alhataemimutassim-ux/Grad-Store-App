import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/support_message.dart';
import '../state/support_provider.dart';

/// شاشة المدير لعرض وإدارة رسائل الدعم الفني
class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<SupportProvider>().fetchAll();
    });
  }

  Color _typeColor(String title) {
    if (title.contains('مشكلة')) return const Color(0xFFEF4444);
    if (title.contains('شكوى')) return const Color(0xFFF59E0B);
    if (title.contains('طلب')) return const Color(0xFF8B5CF6);
    return const Color(0xFF3B82F6);
  }

  IconData _typeIcon(String title) {
    if (title.contains('مشكلة')) return Icons.bug_report_rounded;
    if (title.contains('شكوى')) return Icons.feedback_rounded;
    if (title.contains('طلب')) return Icons.star_rounded;
    return Icons.help_outline_rounded;
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return 'تم الحل';
      case 'in_progress': return 'قيد المعالجة';
      default: return 'جديدة';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return const Color(0xFF10B981);
      case 'in_progress': return const Color(0xFFF59E0B);
      default: return const Color(0xFF3B82F6);
    }
  }

  Future<void> _confirmDelete(BuildContext context, SupportMessage msg) async {
    final provider = context.read<SupportProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الرسالة'),
        content: Text('هل تريد حذف رسالة "${msg.userName}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await provider.delete(msg.id);
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(success ? 'تم الحذف بنجاح' : 'فشل الحذف'),
        backgroundColor: success ? const Color(0xFF10B981) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('رسائل الدعم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => context.read<SupportProvider>().fetchAll(),
          ),
        ],
      ),
      body: Consumer<SupportProvider>(
        builder: (_, provider, __) {
          if (provider.status == SupportStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED)));
          }
          if (provider.status == SupportStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 56, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(provider.error, style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: provider.fetchAll, child: const Text('إعادة المحاولة')),
                ],
              ),
            );
          }
          if (provider.messages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mark_email_read_rounded, size: 72, color: Color(0xFF7C3AED)),
                  const SizedBox(height: 16),
                  const Text('لا توجد رسائل دعم حالياً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: provider.fetchAll,
            color: const Color(0xFF7C3AED),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.messages.length,
              itemBuilder: (_, i) {
                final msg = provider.messages[i];
                final color = _typeColor(msg.title);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Icon(_typeIcon(msg.title), color: color, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                msg.title,
                                style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _statusColor(msg.status).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _statusLabel(msg.status),
                                style: TextStyle(fontSize: 11, color: _statusColor(msg.status), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Body
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_rounded, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(msg.userName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const Spacer(),
                                const Icon(Icons.email_rounded, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(msg.email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                            const Divider(height: 16),
                            Text(msg.message, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  '${msg.createdAt.day}/${msg.createdAt.month}/${msg.createdAt.year}  ${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _confirmDelete(context, msg),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.delete_rounded, color: Colors.redAccent, size: 14),
                                        SizedBox(width: 4),
                                        Text('حذف', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
