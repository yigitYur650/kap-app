import 'package:flutter/material.dart';
import 'package:kap/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/database_service.dart';
import '../widgets/add_product_bottom_sheet.dart';
import '../widgets/product_list_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: KapColors.backgroundLight,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: const [
            HomeView(),
            PendingListView(),
            PaidListView(),
            SettingsView(),
          ],
        ),
      ),
      floatingActionButton: _currentIndex != 3
          ? FloatingActionButton(
              backgroundColor: KapColors.primaryAccent, // Terracotta orange
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Rounded rectangle form
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => const AddProductBottomSheet(),
                );
              },
              child: const Icon(
                Icons.add,
                color: KapColors.pureWhite,
                size: 28,
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: KapColors.primaryAccent,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: KapColors.pureWhite,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.homeTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag_outlined),
            activeIcon: const Icon(Icons.shopping_bag),
            label: l10n.pending,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_circle_outline),
            activeIcon: const Icon(Icons.check_circle),
            label: l10n.paid,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: l10n.settingsTab,
          ),
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  const PageHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: KapColors.slateDark,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Color _getAvatarColor(int index) {
    final List<Color> avatarColors = [
      const Color(0xFFC05A22), // Terracotta
      const Color(0xFF2C5E8A), // Steel Blue
      const Color(0xFF2E6F40), // Sage Green
      const Color(0xFF8C3B68), // Plum/Mulberry
      const Color(0xFFD35C4E), // Muted Red
      const Color(0xFFD9A036), // Mustard/Gold
    ];
    return avatarColors[index % avatarColors.length];
  }

  Widget _buildFamilyHub(BuildContext context, AppLocalizations l10n, DatabaseService dbService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Ev Halkı',
            style: TextStyle(
              color: Color(0xFF2C2C2E), // Modern Kömür Grisi
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: dbService.getAileUyeleri(),
            builder: (context, snapshot) {
              final members = snapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: members.length + 1,
                itemBuilder: (context, index) {
                  if (index == members.length) {
                    // Ekle (+) butonu
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => const _AddMemberBottomSheet(),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.grey.shade100,
                              child: Icon(
                                Icons.add,
                                color: Colors.grey.shade600,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.add,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final member = members[index];
                  final String name = member['isim'] as String? ?? '';
                  final String initials = _getInitials(name);
                  final Color avatarColor = _getAvatarColor(index);

                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: avatarColor.withValues(alpha: 0.1),
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: avatarColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name.split(' ')[0], // Sadece ilk adı gösteriyoruz taşmasın diye
                          style: const TextStyle(
                            color: KapColors.slateDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = context.watch<DatabaseService>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'KAP',
                style: TextStyle(
                  color: KapColors.slateDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: KapColors.primaryAccent.withValues(alpha: 0.1),
                child: const Text(
                  'K',
                  style: TextStyle(
                    color: KapColors.primaryAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Family Hub
        _buildFamilyHub(context, l10n, dbService),
        const SizedBox(height: 24),
        // Short List title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Yaklaşanlar',
            style: TextStyle(
              color: Color(0xFF2C2C2E), // Modern Kömür Grisi
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Short List body
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: dbService.getAlinacaklarListesi(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: KapColors.primaryAccent,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final items = snapshot.data ?? [];
              // Filter pending, newest first
              final pendingItems = items
                  .where((item) => !(item['alindiMi'] as bool? ?? false))
                  .toList();
              final shortList = pendingItems.reversed.take(3).toList();

              if (shortList.isEmpty) {
                return Center(
                  child: Text(
                    l10n.noPendingItems,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                physics: const BouncingScrollPhysics(),
                itemCount: shortList.length,
                itemBuilder: (context, index) {
                  final item = shortList[index];
                  final urunId = item['id'] as String? ?? '';
                  return _MinimalProductListItem(
                    key: ValueKey(urunId),
                    item: item,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MinimalProductListItem extends StatefulWidget {
  final Map<String, dynamic> item;

  const _MinimalProductListItem({
    super.key,
    required this.item,
  });

  @override
  State<_MinimalProductListItem> createState() => _MinimalProductListItemState();
}

class _MinimalProductListItemState extends State<_MinimalProductListItem> {
  bool _isAnimatingOut = false;

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
            : GestureDetector(
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
                  decoration: const BoxDecoration(
                    color: Colors.transparent, // Arka plansız
                    border: Border(
                      bottom: BorderSide(
                        color: KapColors.borderLight, // Sadece alt çizgi
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            color: KapColors.slateDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (fiyat != null)
                        Text(
                          '₺${fiyat.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: KapColors.slateDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
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

class _AddMemberBottomSheet extends StatefulWidget {
  const _AddMemberBottomSheet();

  @override
  State<_AddMemberBottomSheet> createState() => _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends State<_AddMemberBottomSheet> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
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
            const Text(
              'Ev Halkı Ekle',
              style: TextStyle(
                color: KapColors.slateDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Üye Adı',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: KapColors.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: KapColors.primaryAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen geçerli bir isim girin';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: KapColors.slateDark,
                      elevation: 0,
                      side: const BorderSide(color: KapColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('İptal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final isim = _controller.text.trim();
                        await dbService.aileUyesiEkle(isim);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KapColors.primaryAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Ekle'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildListStatsCard({required String title, required double amount}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
    decoration: BoxDecoration(
      color: const Color(0xFFFCFAF7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: KapColors.primaryAccent.withValues(alpha: 0.15),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: KapColors.primaryAccent.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3.5,
              height: 24,
              decoration: BoxDecoration(
                color: KapColors.primaryAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                color: KapColors.slateDark.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Text(
          '₺${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: KapColors.primaryAccent,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    ),
  );
}

class PendingListView extends StatefulWidget {
  const PendingListView({super.key});

  @override
  State<PendingListView> createState() => _PendingListViewState();
}

class _PendingListViewState extends State<PendingListView> {
  String _selectedCategory = 'Tümü';

  Widget _buildFilterBar() {
    final categories = ['Tümü', 'Süt Ürünleri', 'Manav', 'Temizlik', 'Fırın', 'Diğer'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
                color: isSelected ? KapColors.slateDark : KapColors.pureWhite,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = context.watch<DatabaseService>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: l10n.pending),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: dbService.getAlinacaklarListesi(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: KapColors.primaryAccent,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final items = snapshot.data ?? [];
              var pendingItems = items
                  .where((item) => !(item['alindiMi'] as bool? ?? false))
                  .toList()
                  .reversed
                  .toList(); // Newest first

              // Calculate pending spending
              double pendingSpending = 0.0;
              for (var item in pendingItems) {
                final fiyat = item['fiyat'];
                if (fiyat != null) {
                  if (fiyat is num) {
                    pendingSpending += fiyat.toDouble();
                  } else if (fiyat is String) {
                    pendingSpending += double.tryParse(fiyat) ?? 0.0;
                  }
                }
              }

              // Filter items by category
              if (_selectedCategory != 'Tümü') {
                pendingItems = pendingItems.where((item) {
                  final String cat = item['kategori'] as String? ?? 'Diğer';
                  return cat == _selectedCategory;
                }).toList();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildListStatsCard(
                      title: l10n.pendingSpending,
                      amount: pendingSpending,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterBar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: pendingItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Icon(
                                  Icons.shopping_basket_outlined,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedCategory == 'Tümü'
                                      ? l10n.noPendingItems
                                      : 'Bu kategoride bekleyen ürün bulunmuyor.',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            physics: const BouncingScrollPhysics(),
                            itemCount: pendingItems.length,
                            itemBuilder: (context, index) {
                              final item = pendingItems[index];
                              final urunId = item['id'] as String? ?? '';
                              return ProductListItem(
                                key: ValueKey(urunId),
                                item: item,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class PaidListView extends StatefulWidget {
  const PaidListView({super.key});

  @override
  State<PaidListView> createState() => _PaidListViewState();
}

class _PaidListViewState extends State<PaidListView> {
  String _selectedCategory = 'Tümü';

  Widget _buildFilterBar() {
    final categories = ['Tümü', 'Süt Ürünleri', 'Manav', 'Temizlik', 'Fırın', 'Diğer'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
                color: isSelected ? KapColors.slateDark : KapColors.pureWhite,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = context.watch<DatabaseService>();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: l10n.paid),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: dbService.getAlinanlarListesi(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: KapColors.primaryAccent,
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final items = snapshot.data ?? [];
              var paidItems = items
                  .where((item) => item['alindiMi'] as bool? ?? false)
                  .toList()
                  .reversed
                  .toList(); // Newest first

              // Calculate total spending
              double totalSpent = 0.0;
              for (var item in paidItems) {
                final fiyat = item['fiyat'];
                if (fiyat != null) {
                  if (fiyat is num) {
                    totalSpent += fiyat.toDouble();
                  } else if (fiyat is String) {
                    totalSpent += double.tryParse(fiyat) ?? 0.0;
                  }
                }
              }

              // Filter items by category
              if (_selectedCategory != 'Tümü') {
                paidItems = paidItems.where((item) {
                  final String cat = item['kategori'] as String? ?? 'Diğer';
                  return cat == _selectedCategory;
                }).toList();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildListStatsCard(
                      title: l10n.totalSpending,
                      amount: totalSpent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFilterBar(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: paidItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedCategory == 'Tümü'
                                      ? l10n.noPaidItems
                                      : 'Bu kategoride alınan ürün bulunmuyor.',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            physics: const BouncingScrollPhysics(),
                            itemCount: paidItems.length,
                            itemBuilder: (context, index) {
                              final item = paidItems[index];
                              final urunId = item['id'] as String? ?? '';
                              return ProductListItem(
                                key: ValueKey(urunId),
                                item: item,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final String userEmail = user?.email ?? '';
    final String userName = user?.userMetadata?['name'] as String? ?? 'Kullanıcı';
    final String userInitials = _getInitials(userName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(title: l10n.settingsTab),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            physics: const BouncingScrollPhysics(),
            children: [
              // Settings Group 1 (Profil)
              _buildGroupTitle('Profil'),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: KapColors.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: KapColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: KapColors.primaryAccent.withValues(alpha: 0.1),
                      child: Text(
                        userInitials.isNotEmpty ? userInitials : 'U',
                        style: const TextStyle(
                          color: KapColors.primaryAccent,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: KapColors.slateDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userEmail,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Settings Group 2 (Genel)
              _buildGroupTitle('Genel'),
              _buildSettingsCard([
                _buildSettingsItem(
                  icon: Icons.language,
                  iconBgColor: Colors.blue.shade600,
                  title: 'Dil / Language',
                  subtitle: 'Türkçe',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.dark_mode_outlined,
                  iconBgColor: Colors.purple.shade600,
                  title: 'Tema',
                  subtitle: 'Aydınlık Tema',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),
              // Settings Group 3 (Uygulama)
              _buildGroupTitle('Uygulama'),
              _buildSettingsCard([
                _buildSettingsItem(
                  icon: Icons.info_outline,
                  iconBgColor: Colors.teal.shade600,
                  title: 'Hakkında',
                  subtitle: 'KAP v1.0.0',
                  onTap: () {},
                ),
                _buildSettingsItem(
                  icon: Icons.help_outline,
                  iconBgColor: Colors.orange.shade600,
                  title: 'Destek',
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 20),
              // Settings Group 4 (Oturum)
              _buildGroupTitle('Oturum'),
              _buildSettingsCard([
                _buildSettingsItem(
                  icon: Icons.logout,
                  iconBgColor: KapColors.mutedRed,
                  title: l10n.signOut,
                  onTap: () {
                    authService.signOut();
                  },
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: KapColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KapColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) {
            return children[index];
          }
          return Column(
            children: [
              children[index],
              const Divider(height: 1, color: KapColors.borderLight),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconBgColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconBgColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: KapColors.slateDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }
}
