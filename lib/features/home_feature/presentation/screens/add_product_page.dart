import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grad_store_app/core/theme/theme.dart';
import 'package:grad_store_app/core/widgets/app_scaffold.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();

  File? _mainImage;
  final List<File> _additionalImages = [];
  final ImagePicker _picker = ImagePicker();

  String _selectedCategory = ' جرافكس ';
  final List<String> _categories = ['جرافكس ', 'هندسة ', 'طب عام ', 'Ai'];

  Future<void> _pickMainImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _mainImage = File(pickedFile.path));
    }
  }

  Future<void> _pickAdditionalImage() async {
    if (_additionalImages.length >= 3) return;
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _additionalImages.add(File(pickedFile.path)));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.appColors;

    return AppScaffold(
      appBar: AppBar(
        title: const Text(
          "إضافة منتج جديد",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "صور المنتج",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),

            GestureDetector(
              onTap: _pickMainImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  image:
                      _mainImage != null
                          ? DecorationImage(
                            image: FileImage(_mainImage!),
                            fit: BoxFit.cover,
                          )
                          : null,
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child:
                    _mainImage == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: colors.primary,
                              size: 45,
                            ),
                            const Text(
                              "الصورة الرئيسية",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                        : null,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSmallImageCard(0, colors),
                _buildSmallImageCard(1, colors),
                _buildSmallImageCard(2, colors),
                GestureDetector(
                  onTap: _pickAdditionalImage,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: (colors.primary as Color).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colors.primary),
                    ),
                    child: Icon(Icons.add_rounded, color: colors.primary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            _buildFieldLabel("اسم المنتج"),
            _buildCustomInput(
              _nameController,
              "اسم المنتج...",
              Icons.inventory_2_outlined,
              colors,
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel("السعر (\$)"),
                      _buildCustomInput(
                        _priceController,
                        "0.00",
                        Icons.payments_outlined,
                        colors,
                        type: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel("الفئة"),
                      _buildModernDropdown(colors),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildFieldLabel("وصف المنتج"),
            _buildCustomInput(
              _descController,
              "وصف المنتج...",
              Icons.edit_note_rounded,
              colors,
              maxLines: 4,
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("تم نشر المنتج في قسم $_selectedCategory"),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  "نشر المنتج الآن",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallImageCard(int index, dynamic colors) {
    bool hasImage = _additionalImages.length > index;
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        image:
            hasImage
                ? DecorationImage(
                  image: FileImage(_additionalImages[index]),
                  fit: BoxFit.cover,
                )
                : null,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child:
          !hasImage
              ? Icon(Icons.image_outlined, color: Colors.grey[300])
              : null,
    );
  }

  Widget _buildFieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  );

  Widget _buildCustomInput(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    dynamic colors, {
    TextInputType? type,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: colors.primary),
        filled: true,
        fillColor: (colors.primary as Color).withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildModernDropdown(dynamic colors) {
    return GestureDetector(
      onTap: () => _showCategoriesPicker(colors),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: (colors.primary as Color).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedCategory,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: colors.primary),
          ],
        ),
      ),
    );
  }

  void _showCategoriesPicker(dynamic colors) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              ..._categories.map(
                (cat) => ListTile(
                  title: Text(cat),
                  trailing:
                      _selectedCategory == cat
                          ? Icon(Icons.check_circle, color: colors.primary)
                          : null,
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
