import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';

class SupabaseDatabaseImpl implements DatabaseService {
  final _supabase = Supabase.instance.client;
  final Map<String, String> _categoryCache = {};
  final Map<String, String> _marketCache = {};
  
  final _itemsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  List<Map<String, dynamic>> _lastProducts = [];

  final _marketsController = StreamController<List<String>>.broadcast();

  final _familyController = StreamController<List<Map<String, dynamic>>>.broadcast();
  List<Map<String, dynamic>> _lastFamilyMembers = [];

  SupabaseDatabaseImpl() {
    _initRealtimeListeners();
  }

  void _emitFamilyMembers() {
    if (_familyController.isClosed) return;
    _familyController.add(List.from(_lastFamilyMembers));
  }

  void _initRealtimeListeners() {
    // 1. Categories Stream Listener
    _supabase
        .from('categories')
        .stream(primaryKey: ['id'])
        .listen((categoryData) {
          _categoryCache.clear();
          for (var row in categoryData) {
            final id = row['id'] as String;
            final name = row['name'] as String;
            _categoryCache[id] = name;
          }
          _emitMappedItems();
        }, onError: (err) {
          debugPrint('Supabase categories stream error: $err');
        });

    // 2. Markets Stream Listener
    _supabase
        .from('markets')
        .stream(primaryKey: ['id'])
        .listen((marketsData) {
          _marketCache.clear();
          for (var row in marketsData) {
            final id = row['id'] as String;
            final name = row['name'] as String;
            _marketCache[id] = name;
          }
          if (!_marketsController.isClosed) {
            _marketsController.add(_marketCache.values.toList());
          }
          _emitMappedItems();
        }, onError: (err) {
          debugPrint('Supabase markets stream error: $err');
        });

    // 3. Products Stream Listener
    _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .listen((productsData) {
          _lastProducts = productsData;
          _emitMappedItems();
        }, onError: (err) {
          debugPrint('Supabase products stream error: $err');
        });

    // 4. Family Members Stream Listener
    _supabase
        .from('family_members')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .listen((familyData) {
          _lastFamilyMembers = familyData.map((row) {
            return {
              'id': row['id'] as String,
              'isim': row['name'] as String,
            };
          }).toList();
          _emitFamilyMembers();
        }, onError: (err) {
          debugPrint('Supabase family_members stream error: $err');
        });
  }

  List<Map<String, dynamic>> _getMappedItems() {
    return _lastProducts.map((map) {
      final categoryId = map['category_id'] as String?;
      final categoryName = categoryId != null ? (_categoryCache[categoryId] ?? 'Diğer') : 'Diğer';
      
      final marketId = map['market_id'] as String?;
      final marketName = marketId != null ? _marketCache[marketId] : null;
      
      return {
        'id': map['id'],
        'urunAdi': map['name'],
        'fiyat': map['price'] != null ? (map['price'] as num).toDouble() : null,
        'alindiMi': map['is_bought'] ?? false,
        'kategori': categoryName,
        'miktar': map['quantity'] != null ? (map['quantity'] as num).toDouble() : null,
        'birim': map['unit'],
        'marketAdi': marketName,
      };
    }).toList();
  }

  void _emitMappedItems() {
    if (_itemsController.isClosed) return;
    _itemsController.add(_getMappedItems());
  }

  @override
  Stream<List<Map<String, dynamic>>> getAlinacaklarListesi() async* {
    yield _getMappedItems().where((item) => !(item['alindiMi'] as bool? ?? false)).toList();
    yield* _itemsController.stream.map((list) {
      return list.where((item) => !(item['alindiMi'] as bool? ?? false)).toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getAlinanlarListesi() async* {
    yield _getMappedItems().where((item) => item['alindiMi'] as bool? ?? false).toList();
    yield* _itemsController.stream.map((list) {
      return list.where((item) => item['alindiMi'] as bool? ?? false).toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getTumUrunler() async* {
    yield _getMappedItems();
    yield* _itemsController.stream;
  }

  String? _getCategoryIdByName(String name) {
    for (var entry in _categoryCache.entries) {
      if (entry.value.toLowerCase() == name.toLowerCase()) {
        return entry.key;
      }
    }
    return null;
  }

  Future<String> _getOrCreateCategoryId(String categoryName) async {
    final existingId = _getCategoryIdByName(categoryName);
    if (existingId != null) return existingId;

    try {
      // Timeout eklendi
      final response = await _supabase
          .from('categories')
          .insert({'name': categoryName})
          .select('id')
          .single()
          .timeout(const Duration(seconds: 10)); 
      return response['id'] as String;
    } catch (e) {
      debugPrint('Kategori insert hatası, select deneniyor: $e');
      try {
        // Timeout eklendi
        final res = await _supabase
            .from('categories')
            .select('id')
            .eq('name', categoryName)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));
            
        if (res != null) {
          return res['id'] as String;
        }
        throw Exception('Kategori bulunamadı ve oluşturulamadı. RLS kuralını kontrol edin.');
      } catch (innerErr) {
        throw Exception('Kategori işlemi zaman aşımına uğradı veya reddedildi: $innerErr');
      }
    }
  }

  String? _getMarketIdByName(String name) {
    for (var entry in _marketCache.entries) {
      if (entry.value.toLowerCase() == name.toLowerCase()) {
        return entry.key;
      }
    }
    return null;
  }

  Future<String> _getOrCreateMarketId(String marketName) async {
    final existingId = _getMarketIdByName(marketName);
    if (existingId != null) return existingId;

    try {
      final response = await _supabase
          .from('markets')
          .insert({'name': marketName})
          .select('id')
          .single()
          .timeout(const Duration(seconds: 10));
      return response['id'] as String;
    } catch (e) {
      debugPrint('Market insert hatası, select deneniyor: $e');
      try {
        final res = await _supabase
            .from('markets')
            .select('id')
            .eq('name', marketName)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));
            
        if (res != null) {
          return res['id'] as String;
        }
        throw Exception('Market bulunamadı ve oluşturulamadı. RLS kuralını kontrol edin.');
      } catch (innerErr) {
        throw Exception('Market işlemi zaman aşımına uğradı veya reddedildi: $innerErr');
      }
    }
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
    try {
      String? categoryId;
      if (kategori != null && kategori.isNotEmpty) {
        categoryId = await _getOrCreateCategoryId(kategori);
      }

      String? marketId;
      if (marketAdi != null && marketAdi.isNotEmpty) {
        marketId = await _getOrCreateMarketId(marketAdi);
      }

      // Timeout ve is_deleted eklendi
      await _supabase.from('products').insert({
        'name': urunAdi,
        'price': fiyat,
        'category_id': categoryId,
        'market_id': marketId,
        'quantity': miktar ?? 1.0,
        'unit': birim,
        'is_bought': false,
        'is_deleted': false,
        'created_by': _supabase.auth.currentUser?.id,
      }).timeout(const Duration(seconds: 10));
      
    } catch (e) {
      debugPrint('SupabaseDatabaseImpl urunEkle Hata: $e');
      rethrow; // Bu rethrow sayesinde hatayı UI yakalayıp ekrana basacak!
    }
  }

  @override
  Future<void> urunDurumGuncelle({
    required String urunId,
    required bool alindiMi,
  }) async {
    try {
      await _supabase
          .from('products')
          .update({'is_bought': alindiMi})
          .eq('id', urunId)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('SupabaseDatabaseImpl urunDurumGuncelle Hata: $e');
    }
  }

  @override
  Stream<List<String>> getMarketler() async* {
    yield _marketCache.values.toList();
    yield* _marketsController.stream;
  }

  @override
  Future<void> marketEkle(String marketAdi) async {
    final cleanName = marketAdi.trim();
    if (cleanName.isNotEmpty) {
      await _getOrCreateMarketId(cleanName);
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getAileUyeleri() async* {
    yield List.from(_lastFamilyMembers);
    yield* _familyController.stream;
  }

  @override
  Future<void> aileUyesiEkle(String isim) async {
    try {
      await _supabase.from('family_members').insert({
        'name': isim,
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('SupabaseDatabaseImpl aileUyesiEkle Hata: $e');
    }
  }

  @override
  Future<void> urunSil(String urunId) async {
    try {
      await _supabase
          .from('products')
          .update({'is_deleted': true})
          .eq('id', urunId)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('SupabaseDatabaseImpl urunSil Hata: $e');
    }
  }

  @override
  Future<void> urunGeriAl(String urunId) async {
    try {
      await _supabase
          .from('products')
          .update({'is_deleted': false})
          .eq('id', urunId)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('SupabaseDatabaseImpl urunGeriAl Hata: $e');
    }
  }
}
