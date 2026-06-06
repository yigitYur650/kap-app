import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:provider/provider.dart';
import 'package:kap/l10n/app_localizations.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/database_service.dart';

class ProductListItem extends StatefulWidget {
  final Map<String, dynamic> item;

  const ProductListItem({
    super.key,
    required this.item,
  });

  @override
  State<ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  bool _isAnimatingOut = false;

  Widget _buildDismissBackground({required bool isSwipeRight}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: KapColors.mutedRed,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: isSwipeRight ? Alignment.centerLeft : Alignment.centerRight,
      child: const Icon(
        LucideIcons.trash2,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = context.read<DatabaseService>();
    final String id = widget.item['id'] as String? ?? '';
    final String urunAdi = widget.item['urunAdi'] as String? ?? '';
    final double? miktar = widget.item['miktar'] != null
        ? (widget.item['miktar'] is num
            ? (widget.item['miktar'] as num).toDouble()
            : double.tryParse(widget.item['miktar'].toString()))
        : null;
    final String? birim = widget.item['birim'] as String?;
    final double? fiyat = widget.item['fiyat'] != null
        ? (widget.item['fiyat'] is num
            ? (widget.item['fiyat'] as num).toDouble()
            : double.tryParse(widget.item['fiyat'].toString()))
        : null;
    final String? marketAdi = widget.item['marketAdi'] as String?;
    final bool alindiMi = widget.item['alindiMi'] as bool? ?? false;

    String displayName = urunAdi;
    String quantityInfo = '';
    if (miktar != null) {
      final miktarStr = miktar.toString().replaceAll(RegExp(r'\.0$'), '');
      if (birim != null && birim.trim().isNotEmpty) {
        quantityInfo = '$miktarStr $birim';
      } else {
        quantityInfo = miktarStr;
      }
    } else if (birim != null && birim.trim().isNotEmpty) {
      quantityInfo = birim;
    }

    if (quantityInfo.isNotEmpty) {
      displayName = '$urunAdi · $quantityInfo';
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _isAnimatingOut ? 0.0 : 1.0,
      curve: Curves.easeOut,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: _isAnimatingOut
            ? const SizedBox(height: 0, width: double.infinity)
            : Dismissible(
                key: ValueKey(id),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  try {
                    await dbService.urunSil(id);
                    return true;
                  } catch (e) {
                    if (context.mounted) {
                      ShadToaster.of(context).show(
                        ShadToast.destructive(
                          title: const Text("Hata"),
                          description: const Text("Silme işlemi başarısız oldu"),
                        ),
                      );
                    }
                    return false;
                  }
                },
                onDismissed: (direction) {
                  if (context.mounted) {
                    final l10n = AppLocalizations.of(context)!;
                    ShadToaster.of(context).show(
                      ShadToast(
                        description: Text(l10n.productDeleted),
                        action: ShadButton.outline(
                          size: ShadButtonSize.sm,
                          onPressed: () async {
                            try {
                              await dbService.urunGeriAl(id);
                            } catch (e) {
                              if (context.mounted) {
                                ShadToaster.of(context).show(
                                  ShadToast.destructive(
                                    title: const Text("Hata"),
                                    description: const Text("Geri alma işlemi başarısız oldu"),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(l10n.undo),
                        ),
                      ),
                    );
                  }
                },
                background: _buildDismissBackground(isSwipeRight: true),
                secondaryBackground: _buildDismissBackground(isSwipeRight: false),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: KapColors.pureWhite,
                    borderRadius: BorderRadius.circular(16), // Zen: Organik yumuşak kavis
                    border: Border.all(
                      color: KapColors.borderLight,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04), // Zen: Geniş ve çok hafif gölge
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            if (id.isNotEmpty && !_isAnimatingOut) {
                              setState(() {
                                _isAnimatingOut = true;
                              });
                              // Wait for fade/shrink animation to complete
                              await Future.delayed(const Duration(milliseconds: 250));
                              dbService.urunDurumGuncelle(urunId: id, alindiMi: !alindiMi);
                            }
                          },
                          child: Row(
                            children: [
                              IgnorePointer(
                                child: ShadCheckbox(
                                  value: alindiMi,
                                  onChanged: (_) {},
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: TextStyle(
                                        color: alindiMi ? Colors.grey.shade400 : KapColors.slateDark,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        decoration: alindiMi ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    if (marketAdi != null && marketAdi.trim().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        marketAdi,
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (fiyat != null) ...[
                                Text(
                                  '₺${fiyat.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: alindiMi ? Colors.grey.shade400 : KapColors.slateDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    decoration: alindiMi ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Zarif Düzenle (Edit/Pencil) ikonu
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          // ignore: avoid_print
                          print('Düzenle tıklandı');
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (context) => _EditProductDummyBottomSheet(urunAdi: urunAdi),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                          child: Icon(
                            LucideIcons.pencil,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      // Zarif Sil (Delete/Trash) ikonu
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          if (id.isNotEmpty && !_isAnimatingOut) {
                            final toaster = ShadToaster.of(context);
                            final l10n = AppLocalizations.of(context)!;
                            
                            try {
                              setState(() {
                                _isAnimatingOut = true;
                              });
                              // Animasyonun bitmesini bekle
                              await Future.delayed(const Duration(milliseconds: 250));
                              await dbService.urunSil(id);
                              
                              if (context.mounted) {
                                toaster.show(
                                  ShadToast(
                                    description: Text(l10n.productDeleted),
                                    action: ShadButton.outline(
                                      size: ShadButtonSize.sm,
                                      onPressed: () async {
                                        try {
                                          await dbService.urunGeriAl(id);
                                        } catch (e) {
                                          if (context.mounted) {
                                            ShadToaster.of(context).show(
                                              ShadToast.destructive(
                                                title: const Text("Hata"),
                                                description: const Text("Geri alma işlemi başarısız oldu"),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: Text(l10n.undo),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Hata durumunda animasyonu geri al
                              setState(() {
                                _isAnimatingOut = false;
                              });
                              if (context.mounted) {
                                toaster.show(
                                  ShadToast.destructive(
                                    title: const Text("Hata"),
                                    description: const Text("Silme işlemi başarısız oldu"),
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Tooltip(
                          message: AppLocalizations.of(context)!.deleteTooltip,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                            child: Icon(
                              LucideIcons.trash2,
                              size: 18,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _EditProductDummyBottomSheet extends StatelessWidget {
  final String urunAdi;

  const _EditProductDummyBottomSheet({required this.urunAdi});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KapColors.pureWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            'Ürün Düzenle: $urunAdi',
            style: const TextStyle(
              color: KapColors.slateDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KapColors.primaryAccent.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.pencil,
              color: KapColors.primaryAccent,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bu ürün çok yakında düzenlenebilecek!',
            style: TextStyle(
              color: KapColors.slateDark,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
