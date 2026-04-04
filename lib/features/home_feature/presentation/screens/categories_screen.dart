import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_store_app/core/theme/dimens.dart';
import 'package:grad_store_app/core/theme/theme.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/general_app_bar.dart';
import 'package:grad_store_app/features/categories/presentation/state/categories_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final prov = Provider.of<CategoriesProvider>(context, listen: false);
      prov.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<CategoriesProvider>(context);

    return AppScaffold(
      appBar: GeneralAppBar(title: 'الفئات'),
      padding: EdgeInsets.zero,
      body: Builder(builder: (context) {
        if (prov.status == CategoriesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (prov.status == CategoriesStatus.error) {
          return Center(child: Text(prov.error));
        }
        if (prov.items.isEmpty) {
          return const Center(child: Text('لا توجد فئات'));
        }

        return ListView.separated(
          itemCount: prov.items.length,
          itemBuilder: (context, index) {
            final cat = prov.items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.largePadding, vertical: Dimens.smallPadding),
              child: Card(
                child: ListTile(
                  leading: cat.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(cat.imageUrl!, width: 56, height: 56, fit: BoxFit.cover),
                        )
                      : SizedBox(width: 56, height: 56, child: Icon(Icons.category, color: context.theme.appColors.gray4)),
                  title: Text(cat.name),
                  subtitle: cat.description != null ? Text(cat.description!) : null,
                  onTap: () {
                    // TODO: navigate to category products page
                  },
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: Dimens.largePadding),
        );
      }),
    );
  }
}
