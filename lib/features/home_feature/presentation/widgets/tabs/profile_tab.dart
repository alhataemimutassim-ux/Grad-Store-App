import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/utils/check_theme_status.dart';
import 'package:grad_store_app/core/constants/api_constants.dart';
import '../../../../../core/theme/dimens.dart';
import '../../../../auth/presentation/state/auth_provider.dart';
import '../../bloc/theme_cubit.dart';
import '../../../../profile/presentation/state/profile_provider.dart';
import '../../../../profile/domain/entities/user_profile.dart';
import '../../../../profile/presentation/screens/edit_profile_screen.dart';
import '../../../../../core/utils/app_navigator.dart';
import '../../../../support/presentation/pages/support_screen.dart';
import '../../../../support/presentation/pages/admin_support_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ProfileProvider>().fetchProfile();
      }
    });
  }

  // ─── Role Helpers ───────────────────────────────────────────────────────────
  String _getRoleName(int roleId) {
    if (roleId == 1) return 'بائع';
    if (roleId == 3) return 'مدير';
    return 'طالب';
  }

  Color _getRoleColor(int roleId, AppColors appColors) {
    if (roleId == 1) return const Color(0xFFFF6B35);   // orange for seller
    if (roleId == 3) return const Color(0xFF7C3AED);   // purple for admin
    return appColors.primary;                           // teal for student
  }

  IconData _getRoleIcon(int roleId) {
    if (roleId == 1) return Icons.store_rounded;
    if (roleId == 3) return Icons.shield_rounded;
    return Icons.school_rounded;
  }

  // ─── Initial Avatar (fallback when no image) ─────────────────────────────────
  Widget _buildInitialAvatar(UserProfile profile, Color roleColor) {
    final initial = profile.name.isNotEmpty
        ? profile.name.trim()[0].toUpperCase()
        : '؟';
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.25),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─── Header Card ────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, UserProfile profile) {
    final appColors = context.theme.appColors;
    final roleColor = _getRoleColor(profile.roleId, appColors);
    final _ = checkDarkMode(context); // used implicitly via roleColor

    String imageUrl = '';
    if (profile.profileImage != null && profile.profileImage!.isNotEmpty) {
      imageUrl = profile.profileImage!.startsWith('http')
          ? profile.profileImage!
          : '${ApiConstants.baseUrl}${profile.profileImage}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            roleColor,
            roleColor.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: roleColor.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 3),
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: imageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                imageUrl,
                                width: 78,
                                height: 78,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildInitialAvatar(profile, roleColor),
                              ),
                            )
                          : _buildInitialAvatar(profile, roleColor),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getRoleIcon(profile.roleId), size: 14, color: roleColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Name & Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.isNotEmpty ? profile.name : 'مستخدم',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getRoleIcon(profile.roleId), size: 12, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              _getRoleName(profile.roleId),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit button
                GestureDetector(
                  onTap: () => appPush(context, EditProfileScreen(profile: profile)),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            if (profile.phone.isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(color: Colors.white.withValues(alpha: 0.25), thickness: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(width: 6),
                  Text(
                    profile.phone,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Info Row Widget ─────────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String? value, Color roleColor) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: roleColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Role-Specific Details ────────────────────────────────────────────────────
  Widget _buildRoleSection(BuildContext context, UserProfile profile) {
    final appColors = context.theme.appColors;
    final roleColor = _getRoleColor(profile.roleId, appColors);
    final isDark = checkDarkMode(context);

    String sectionTitle = '';
    List<Widget> rows = [];

    if (profile is SellerProfileEntity) {
      sectionTitle = '🏪  معلومات المتجر';
      rows = [
        _infoRow(Icons.store_mall_directory_rounded, 'اسم المتجر', profile.shopName, roleColor),
        _infoRow(Icons.location_on_rounded, 'الموقع', profile.location, roleColor),
        _infoRow(Icons.phone_rounded, 'واتساب', profile.whatsApp, roleColor),
        _infoRow(Icons.facebook_rounded, 'فيسبوك', profile.facebook, roleColor),
        _infoRow(Icons.camera_alt_rounded, 'انستقرام', profile.instagram, roleColor),
      ];
    } else if (profile is AdminProfileEntity) {
      sectionTitle = '🛡️  معلومات الإدارة';
      rows = [
        _infoRow(Icons.badge_rounded, 'اسم المدير', profile.adminName, roleColor),
        _infoRow(Icons.folder_special_rounded, 'اسم المشروع', profile.projectName, roleColor),
        _infoRow(Icons.description_rounded, 'وصف المشروع', profile.projectDescription, roleColor),
        _infoRow(Icons.language_rounded, 'اسم الموقع', profile.siteName, roleColor),
        _infoRow(Icons.location_on_rounded, 'الموقع', profile.location, roleColor),
      ];
    } else if (profile is StudentProfileEntity) {
      sectionTitle = '🎓  المعلومات الجامعية';
      rows = [
        _infoRow(Icons.account_balance_rounded, 'الجامعة', profile.university, roleColor),
        _infoRow(Icons.menu_book_rounded, 'التخصص', profile.major, roleColor),
      ];
    }

    final hasData = rows.any((w) => w is! SizedBox);
    if (sectionTitle.isEmpty || !hasData) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(sectionTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  // ─── Settings Section ─────────────────────────────────────────────────────────
  Widget _buildSettingsSection(BuildContext context) {
    final appColors = context.theme.appColors;
    final isDark = checkDarkMode(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 4),
            child: Text('الإعدادات العامة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _settingsTile(
                  context,
                  icon: Icons.credit_card_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  label: 'طرق الدفع',
                  onTap: () {},
                ),
                _divider(),
                _settingsTile(
                  context,
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFFEF4444),
                  label: 'العناوين',
                  onTap: () {},
                ),
                _divider(),
                _settingsTile(
                  context,
                  icon: Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  label: 'الوضع الليلي',
                  trailing: Transform.scale(
                    scale: 0.75,
                    child: CupertinoSwitch(
                      value: isDark,
                      onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                      activeTrackColor: appColors.primary,
                    ),
                  ),
                  onTap: () => context.read<ThemeCubit>().toggleTheme(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDashboardOption(BuildContext context, UserProfile profile) {
    if (profile.roleId != 1 && profile.roleId != 3) {
      return const SizedBox.shrink();
    }

    final isDark = checkDarkMode(context);
    final url = profile.roleId == 1
        ? 'https://trindhodhod.somee.com/Seller/Dashboard'
        : 'https://trindhodhod.somee.com/Admin/Dashboard';

    return Padding(
      padding: const EdgeInsets.only(
          left: Dimens.largePadding, right: Dimens.largePadding, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 4),
            child: Text('إدارة النظام',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87)),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _settingsTile(
              context,
              icon: Icons.dashboard_customize_rounded,
              iconColor: const Color(0xFF10B981),
              label: 'لوحة التحكم',
              onTap: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSupportSection(BuildContext context) {
    final isDark = checkDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 4),
            child: Text('الدعم والمساعدة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _settingsTile(
              context,
              icon: Icons.support_agent_rounded,
              iconColor: const Color(0xFF10B981),
              label: 'راسلنا',
              onTap: () {
                final roleId = context.read<ProfileProvider>().profile?.roleId;
                if (roleId == 3) {
                  // Admin
                  appPush(context, const AdminSupportScreen());
                } else {
                  // User / Seller
                  appPush(context, const SupportScreen());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    indent: 54,
    endIndent: 16,
    color: Colors.grey.withValues(alpha: 0.15),
  );

  // ─── Logout Button ────────────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      child: GestureDetector(
        onTap: () => context.read<AuthProvider>().logout(),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              const Text('تسجيل الخروج', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Guest Card ────────────────────────────────────────────────────────────
  Widget _buildGuestCard(BuildContext context) {
    final appColors = context.theme.appColors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimens.largePadding),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appColors.primary.withValues(alpha: 0.8), appColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_off_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text(
            'أنت تتصفح كضيف',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'سجّل الدخول لعرض وتعديل ملفك الشخصي',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: checkDarkMode(context) ? const Color(0xFF111827) : const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            if (provider.status == ProfileStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = provider.profile;

            return RefreshIndicator(
              onRefresh: () async => provider.fetchProfile(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // Page Header Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Dimens.largePadding, 20, Dimens.largePadding, 16),
                    child: Row(
                      children: [
                        const Text('ملفي الشخصي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (profile != null)
                          GestureDetector(
                            onTap: () => appPush(context, EditProfileScreen(profile: profile)),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: context.theme.appColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.edit_rounded, size: 18, color: context.theme.appColors.primary),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Profile Header
                  if (profile != null) _buildHeader(context, profile),
                  if (profile == null) _buildGuestCard(context),
                  
                  const SizedBox(height: 16),

                  // Role-specific details
                  if (profile != null) _buildRoleSection(context, profile),

                  const SizedBox(height: 16),

                  // Dashboard (Admin & Seller only)
                  if (profile != null) _buildDashboardOption(context, profile),

                  // Settings
                  _buildSettingsSection(context),
                  const SizedBox(height: 16),
                  _buildSupportSection(context),
                  const SizedBox(height: 16),

                  // Logout
                  _buildLogoutButton(context),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
