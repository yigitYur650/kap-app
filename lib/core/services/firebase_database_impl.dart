import 'dart:async';
import 'database_service.dart';

class FirebaseDatabaseImpl implements DatabaseService {
  // In-memory mock database items
  final List<Map<String, dynamic>> _items = [
    {
      'id': '1',
      'urunAdi': 'Süt',
      'fiyat': 34.50,
      'marketAdi': 'Migros',
      'alindiMi': false,
      'kategori': 'Süt Ürünleri',
    },
    {
      'id': '2',
      'urunAdi': 'Yumurta 10\'lu',
      'fiyat': 48.00,
      'marketAdi': 'BİM',
      'alindiMi': false,
      'kategori': 'Süt Ürünleri',
    },
    {
      'id': '3',
      'urunAdi': 'Ekmek',
      'fiyat': 12.00,
      'marketAdi': 'Fırın',
      'alindiMi': true,
      'kategori': 'Fırın',
    },
    {
      'id': '4',
      'urunAdi': 'Elma',
      'fiyat': 24.00,
      'marketAdi': 'Migros',
      'alindiMi': false,
      'kategori': 'Manav',
    },
    {
      'id': '5',
      'urunAdi': 'Deterjan',
      'fiyat': 89.90,
      'marketAdi': 'Şok',
      'alindiMi': false,
      'kategori': 'Temizlik',
    },
  ];

  // In-memory mock markets
  final List<String> _markets = ['Migros', 'Şok', 'BİM', 'A101', 'Fırın'];

  // In-memory mock family members
  final List<Map<String, dynamic>> _familyMembers = [
    {
      'id': '1',
      'isim': 'Yiğit',
    },
    {
      'id': '2',
      'isim': 'Zeynep',
    },
    {
      'id': '3',
      'isim': 'Can',
    },
  ];

  final _streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _marketsController = StreamController<List<String>>.broadcast();
  final _familyController = StreamController<List<Map<String, dynamic>>>.broadcast();

  FirebaseDatabaseImpl() {
    // Push the initial mock data
    _streamController.add(List.from(_items));
    _marketsController.add(List.from(_markets));
    _familyController.add(List.from(_familyMembers));
  }

  @override
  Stream<List<Map<String, dynamic>>> getAlinacaklarListesi() {
    Timer.run(() {
      if (!_streamController.isClosed) {
        _streamController.add(List.from(_items));
      }
    });
    return _streamController.stream.map((list) {
      return list
          .where((item) => !(item['is_deleted'] as bool? ?? false))
          .where((item) => !(item['alindiMi'] as bool? ?? false))
          .toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getAlinanlarListesi() {
    Timer.run(() {
      if (!_streamController.isClosed) {
        _streamController.add(List.from(_items));
      }
    });
    return _streamController.stream.map((list) {
      return list
          .where((item) => !(item['is_deleted'] as bool? ?? false))
          .where((item) => item['alindiMi'] as bool? ?? false)
          .toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getTumUrunler() {
    Timer.run(() {
      if (!_streamController.isClosed) {
        _streamController.add(List.from(_items));
      }
    });
    return _streamController.stream.map((list) {
      return list.where((item) => !(item['is_deleted'] as bool? ?? false)).toList();
    });
  }

  @override
  Future<void> urunEkle({
    required String urunAdi,
    double? fiyat,
    String? marketAdi,
    String? kategori,
    double? miktar,
    String? birim,
  }) async {
    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'urunAdi': urunAdi,
      'fiyat': fiyat,
      'marketAdi': marketAdi,
      'alindiMi': false,
      'kategori': kategori ?? 'Diğer',
      'miktar': miktar,
      'birim': birim,
    };
    _items.add(newItem);
    _streamController.add(List.from(_items));
  }

  @override
  Future<void> urunDurumGuncelle({
    required String urunId,
    required bool alindiMi,
  }) async {
    final index = _items.indexWhere((element) => element['id'] == urunId);
    if (index != -1) {
      _items[index]['alindiMi'] = alindiMi;
      _streamController.add(List.from(_items));
    }
  }

  @override
  Stream<List<String>> getMarketler() {
    Timer.run(() {
      if (!_marketsController.isClosed) {
        _marketsController.add(List.from(_markets));
      }
    });
    return _marketsController.stream;
  }

  @override
  Future<void> marketEkle(String marketAdi) async {
    final cleanName = marketAdi.trim();
    if (cleanName.isNotEmpty && !_markets.contains(cleanName)) {
      _markets.add(cleanName);
      _marketsController.add(List.from(_markets));
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getAileUyeleri() {
    Timer.run(() {
      if (!_familyController.isClosed) {
        _familyController.add(List.from(_familyMembers));
      }
    });
    return _familyController.stream;
  }

  @override
  Future<void> aileUyesiEkle(String isim) async {
    final cleanName = isim.trim();
    if (cleanName.isNotEmpty) {
      final newMember = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'isim': cleanName,
      };
      _familyMembers.add(newMember);
      _familyController.add(List.from(_familyMembers));
    }
  }

  @override
  Future<void> urunSil(String urunId) async {
    final index = _items.indexWhere((element) => element['id'] == urunId);
    if (index != -1) {
      _items[index]['is_deleted'] = true;
      _streamController.add(List.from(_items));
    }
  }

  @override
  Future<void> urunGeriAl(String urunId) async {
    final index = _items.indexWhere((element) => element['id'] == urunId);
    if (index != -1) {
      _items[index]['is_deleted'] = false;
      _streamController.add(List.from(_items));
    }
  }
}
