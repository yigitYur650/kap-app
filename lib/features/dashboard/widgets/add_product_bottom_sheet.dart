import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:kap/l10n/app_localizations.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/database_service.dart';

class AddProductBottomSheet extends StatefulWidget {
  const AddProductBottomSheet({super.key});

  @override
  State<AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends State<AddProductBottomSheet> {
  final _formKey = GlobalKey<ShadFormState>();
  String _selectedCategory = 'Süt Ürünleri';
  String _selectedUnit = 'Adet';

  Widget _buildCategoryChips() {
    final categories = ['Süt Ürünleri', 'Manav', 'Temizlik', 'Fırın', 'Diğer'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            color: KapColors.slateDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? KapColors.slateDark : KapColors.backgroundLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? KapColors.slateDark : KapColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? KapColors.pureWhite : KapColors.slateDark.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUnitChips() {
    final units = ['Adet', 'Kg', 'Litre', 'Paket'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Birim',
          style: TextStyle(
            color: KapColors.slateDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: units.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final unit = units[index];
              final isSelected = _selectedUnit == unit;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedUnit = unit;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? KapColors.slateDark : KapColors.backgroundLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? KapColors.slateDark : KapColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      unit,
                      style: TextStyle(
                        color: isSelected ? KapColors.pureWhite : KapColors.slateDark.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dbService = context.read<DatabaseService>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: KapColors.pureWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle/indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: KapColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.addProduct,
                style: const TextStyle(
                  color: KapColors.slateDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 20),
              ShadForm(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name Field
                    ShadInputFormField(
                      id: 'productName',
                      label: Text(
                        l10n.productName,
                        style: const TextStyle(
                          color: KapColors.slateDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      placeholder: Text(
                        l10n.enterProductName,
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      validator: (v) {
                        if (v.trim().isEmpty) {
                          return l10n.productNameRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Category Selector
                    _buildCategoryChips(),
                    const SizedBox(height: 16),
                    // Quantity and Unit Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShadInputFormField(
                                id: 'quantity',
                                label: const Text(
                                  'Miktar',
                                  style: TextStyle(
                                    color: KapColors.slateDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                placeholder: Text(
                                  'Örn: 2',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (v) {
                                  if (v.isNotEmpty) {
                                    final parsed = double.tryParse(v);
                                    if (parsed == null) {
                                      return 'Geçersiz sayı';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: _buildUnitChips(),
                        ),
                      ],
                    ),
                    // Smart UX Description Note
                    const Padding(
                      padding: EdgeInsets.only(top: 6.0),
                      child: Text(
                        'Miktar belirtmezseniz, ürün tipine göre otomatik olarak 1 adet veya 1 kg olarak ekleriz.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Price Field
                    ShadInputFormField(
                      id: 'price',
                      label: Text(
                        l10n.price,
                        style: const TextStyle(
                          color: KapColors.slateDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      placeholder: Text(
                        l10n.enterPrice,
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v.isNotEmpty) {
                          final parsed = double.tryParse(v);
                          if (parsed == null) {
                            return 'Invalid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Market Name Field (Simple TextField)
                    ShadInputFormField(
                      id: 'marketName',
                      label: Text(
                        l10n.marketName,
                        style: const TextStyle(
                          color: KapColors.slateDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      placeholder: Text(
                        l10n.enterMarketName,
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Actions Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ShadButton.outline(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.cancel,
                            style: const TextStyle(color: KapColors.slateDark),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ShadButton(
                          backgroundColor: KapColors.slateDark,
                          hoverBackgroundColor: KapColors.slateDark.withValues(alpha: 0.8),
                          onPressed: () async {
                            if (_formKey.currentState!.saveAndValidate()) {
                              final values = _formKey.currentState!.value;
                              final String name = (values['productName'] as String).trim();
                              final String? priceRaw = values['price'] as String?;
                              final String? market = (values['marketName'] as String?)?.trim();
                              final String? qtyRaw = values['quantity'] as String?;

                              final double? price = priceRaw != null && priceRaw.isNotEmpty
                                  ? double.tryParse(priceRaw)
                                  : null;

                              final double? miktar = qtyRaw != null && qtyRaw.isNotEmpty
                                  ? double.tryParse(qtyRaw)
                                  : null;

                              await dbService.urunEkle(
                                urunAdi: name,
                                fiyat: price,
                                marketAdi: market,
                                kategori: _selectedCategory,
                                miktar: miktar,
                                birim: _selectedUnit,
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Text(
                            l10n.add,
                            style: const TextStyle(color: KapColors.pureWhite),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
