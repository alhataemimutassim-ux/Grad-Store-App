import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../domain/entities/user_profile.dart';
import '../state/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common Fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  // Student
  late TextEditingController _majorController;
  late TextEditingController _universityController;

  // Seller
  late TextEditingController _shopNameController;
  late TextEditingController _locationController;
  late TextEditingController _facebookController;
  late TextEditingController _whatsappController;
  late TextEditingController _instagramController;
  File? _selectedImage;

  // Admin
  late TextEditingController _adminNameController;
  late TextEditingController _projectNameController;
  late TextEditingController _projectDescController;
  late TextEditingController _siteNameController;

  // Role helpers
  Color get _roleColor {
    if (widget.profile.roleId == 1) return const Color(0xFFFF6B35);
    if (widget.profile.roleId == 3) return const Color(0xFF7C3AED);
    return const Color(0xFF0F766E);
  }


  IconData get _roleIcon {
    if (widget.profile.roleId == 1) return Icons.store_rounded;
    if (widget.profile.roleId == 3) return Icons.shield_rounded;
    return Icons.school_rounded;
  }

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.name);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);

    _majorController = TextEditingController();
    _universityController = TextEditingController();
    _shopNameController = TextEditingController();
    _locationController = TextEditingController();
    _facebookController = TextEditingController();
    _whatsappController = TextEditingController();
    _instagramController = TextEditingController();
    _adminNameController = TextEditingController();
    _projectNameController = TextEditingController();
    _projectDescController = TextEditingController();
    _siteNameController = TextEditingController();

    if (p is StudentProfileEntity) {
      _majorController.text = p.major ?? '';
      _universityController.text = p.university ?? '';
    } else if (p is SellerProfileEntity) {
      _shopNameController.text = p.shopName ?? '';
      _locationController.text = p.location ?? '';
      _facebookController.text = p.facebook ?? '';
      _whatsappController.text = p.whatsApp ?? '';
      _instagramController.text = p.instagram ?? '';
    } else if (p is AdminProfileEntity) {
      _adminNameController.text = p.adminName ?? '';
      _projectNameController.text = p.projectName ?? '';
      _projectDescController.text = p.projectDescription ?? '';
      _siteNameController.text = p.siteName ?? '';
      _locationController.text = p.location ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _majorController.dispose();
    _universityController.dispose();
    _shopNameController.dispose();
    _locationController.dispose();
    _facebookController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    _adminNameController.dispose();
    _projectNameController.dispose();
    _projectDescController.dispose();
    _siteNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final p = widget.profile;
    UserProfile updatedProfile;

    if (p is StudentProfileEntity) {
      updatedProfile = StudentProfileEntity(
        idUser: p.idUser, roleId: p.roleId,
        name: _nameController.text, email: _emailController.text,
        phone: _phoneController.text, major: _majorController.text,
        university: _universityController.text,
      );
    } else if (p is SellerProfileEntity) {
      updatedProfile = SellerProfileEntity(
        idUser: p.idUser, roleId: p.roleId,
        name: _nameController.text, email: _emailController.text,
        phone: _phoneController.text, shopName: _shopNameController.text,
        location: _locationController.text, facebook: _facebookController.text,
        whatsApp: _whatsappController.text, instagram: _instagramController.text,
        latitude: p.latitude, longitude: p.longitude,
      );
    } else if (p is AdminProfileEntity) {
      updatedProfile = AdminProfileEntity(
        idUser: p.idUser, roleId: p.roleId,
        name: _nameController.text, email: _emailController.text,
        phone: _phoneController.text, adminName: _adminNameController.text,
        projectName: _projectNameController.text, projectDescription: _projectDescController.text,
        siteName: _siteNameController.text, location: _locationController.text,
      );
    } else {
      return;
    }

    final provider = context.read<ProfileProvider>();
    final success = await provider.updateProfile(updatedProfile, imageFile: _selectedImage);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('تم تحديث البيانات بنجاح'),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ─── Custom Input Field ────────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: isRequired
          ? (val) => (val == null || val.trim().isEmpty) ? '$label مطلوب' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _roleColor, size: 20),
        filled: true,
        fillColor: _roleColor.withValues(alpha: 0.04),
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
          borderSide: BorderSide(color: _roleColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  // ─── Section Title ─────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _roleColor, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _roleColor)),
      ],
    );
  }

  // ─── Avatar Picker (for Seller) ─────────────────────────────────────────────
  Widget _buildAvatarPicker() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _roleColor.withValues(alpha: 0.1),
                border: Border.all(color: _roleColor, width: 2.5),
                image: _selectedImage != null
                    ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                    : null,
              ),
              child: _selectedImage == null
                  ? Icon(Icons.camera_alt_rounded, color: _roleColor, size: 36)
                  : null,
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: _roleColor, shape: BoxShape.circle),
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().status == ProfileStatus.loading;

    return AppScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: _roleColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'تعديل البيانات',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_roleColor, _roleColor.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 40),
                    child: Row(
                      children: [
                        Icon(_roleIcon, color: Colors.white.withValues(alpha: 0.3), size: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Avatar Picker for Seller
                if (widget.profile is SellerProfileEntity) ...[
                  _buildAvatarPicker(),
                  const SizedBox(height: 20),
                ],

                // ── Personal Info
                _sectionTitle('البيانات الشخصية', Icons.person_rounded),
                const SizedBox(height: 12),
                _field(controller: _nameController, label: 'الاسم الكامل', icon: Icons.badge_rounded, isRequired: true),
                const SizedBox(height: 12),
                _field(controller: _emailController, label: 'البريد الإلكتروني', icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _field(controller: _phoneController, label: 'رقم الهاتف', icon: Icons.phone_rounded, keyboardType: TextInputType.phone),

                const SizedBox(height: 24),
                Divider(height: 1, color: _roleColor.withValues(alpha: 0.2)),
                const SizedBox(height: 20),

                // ── Student Fields
                if (widget.profile is StudentProfileEntity) ...[
                  _sectionTitle('المعلومات الجامعية', Icons.school_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _universityController, label: 'اسم الجامعة', icon: Icons.account_balance_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _majorController, label: 'التخصص الدراسي', icon: Icons.menu_book_rounded),
                ],

                // ── Seller Fields
                if (widget.profile is SellerProfileEntity) ...[
                  _sectionTitle('معلومات المتجر', Icons.store_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _shopNameController, label: 'اسم المتجر', icon: Icons.store_mall_directory_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _locationController, label: 'الموقع', icon: Icons.location_on_rounded),
                  const SizedBox(height: 20),
                  _sectionTitle('وسائل التواصل', Icons.share_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _whatsappController, label: 'رقم الواتساب', icon: Icons.chat_rounded, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _field(controller: _facebookController, label: 'رابط فيسبوك', icon: Icons.facebook_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _instagramController, label: 'رابط انستقرام', icon: Icons.camera_alt_rounded),
                ],

                // ── Admin Fields
                if (widget.profile is AdminProfileEntity) ...[
                  _sectionTitle('معلومات الإدارة', Icons.shield_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _adminNameController, label: 'اسم المدير', icon: Icons.badge_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _projectNameController, label: 'اسم المشروع', icon: Icons.folder_special_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _projectDescController, label: 'وصف المشروع', icon: Icons.description_rounded, maxLines: 3),
                  const SizedBox(height: 12),
                  _field(controller: _siteNameController, label: 'اسم الموقع', icon: Icons.language_rounded),
                  const SizedBox(height: 12),
                  _field(controller: _locationController, label: 'الموقع', icon: Icons.location_on_rounded),
                ],

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: _roleColor),
                        )
                      : ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save_rounded, color: Colors.white),
                          label: const Text(
                            'حفظ التعديلات',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _roleColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            shadowColor: _roleColor.withValues(alpha: 0.4),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
