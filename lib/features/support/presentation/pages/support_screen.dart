import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/support_provider.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  // Message types for quick selection
  static const _types = [
    ('استفسار عام', Icons.help_outline_rounded, Color(0xFF3B82F6)),
    ('مشكلة تقنية', Icons.bug_report_rounded, Color(0xFFEF4444)),
    ('شكوى', Icons.feedback_rounded, Color(0xFFF59E0B)),
    ('طلب خاص', Icons.star_rounded, Color(0xFF8B5CF6)),
  ];
  int _selectedType = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<SupportProvider>();

    // Prefix the title with the selected message type
    final typeLabel = _types[_selectedType].$1;
    final fullTitle = '[$typeLabel] ${_titleController.text.trim()}';

    final success = await provider.send(
      title: fullTitle,
      message: _messageController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _titleController.clear();
      _messageController.clear();
      setState(() => _selectedType = 0);
      _showSuccessSheet();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${provider.error}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFD1FAE5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'تم إرسال رسالتك بنجاح!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'سيقوم فريق الدعم بالرد عليك في أقرب وقت ممكن.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('حسناً', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<SupportProvider>().status == SupportStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(
        slivers: [
          // ─ Animated App Bar ─
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF0F766E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('الدعم والمساعدة',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.support_agent_rounded, color: Colors.white30, size: 80),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ─ Info Card ─
                    _InfoCard(),
                    const SizedBox(height: 20),

                    // ─ Message Type Selection ─
                    _sectionLabel('نوع الرسالة'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _types.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final selected = _selectedType == i;
                          final type = _types[i];
                          return GestureDetector(
                            onTap: () => setState(() => _selectedType = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected ? type.$3 : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: selected ? type.$3 : Colors.grey.shade300,
                                ),
                                boxShadow: selected
                                    ? [BoxShadow(color: type.$3.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
                                    : [],
                              ),
                              child: Row(
                                children: [
                                  Icon(type.$2, color: selected ? Colors.white : type.$3, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    type.$1,
                                    style: TextStyle(
                                      color: selected ? Colors.white : Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─ Title Field ─
                    _sectionLabel('موضوع الرسالة'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _titleController,
                      hint: 'أدخل موضوعاً مختصراً',
                      icon: Icons.title_rounded,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'الموضوع مطلوب' : null,
                    ),

                    const SizedBox(height: 16),

                    // ─ Message Field ─
                    _sectionLabel('تفاصيل رسالتك'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _messageController,
                      hint: 'اكتب رسالتك بالتفصيل هنا...',
                      icon: Icons.message_rounded,
                      maxLines: 6,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'الرسالة مطلوبة';
                        if (v.trim().length < 10) return 'الرسالة قصيرة جداً';
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // ─ Submit Button ─
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F766E)))
                          : ElevatedButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.send_rounded, color: Colors.white),
                              label: const Text(
                                'إرسال الرسالة',
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: const Color(0xFF0F766E).withValues(alpha: 0.4),
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF374151)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 60.0 : 0.0),
          child: Icon(icon, color: const Color(0xFF0F766E), size: 20),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}


// ─── Info Card Widget ───────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6EE7B7)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF059669), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('نحن هنا لمساعدتك!',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46), fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  'فريق الدعم يعمل 9 صباحاً — 5 مساءً. سنرد خلال 24 ساعة عمل.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
