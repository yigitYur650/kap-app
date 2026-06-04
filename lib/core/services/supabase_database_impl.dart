import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';

class SupabaseDatabaseImpl implements DatabaseService {
  final _supabase = Supabase.instance.client;
  final Map<String, String> _categoryCache = {};
  
  final _itemsController = StreamController<List<Map<String, dynamic>>>.broadcast();
  List<Map<String, dynamic>> _lastProducts = [];

  final List<String> _markets = ['Migros', 'Şok', 'BİM', 'A101', 'Fırın'];
  final _marketsController = StreamController<List<String>>.broadcast();

  final _familyController = StreamController<List<Map<String, dynamic>>>.broadcast();
  List<Map<String, dynamic>> _lastFamilyMembers = [];

  SupabaseDatabaseImpl() {
    _initRealtimeListeners();
    
    Timer.run(() {
      if (!_marketsController.isClosed) {
        _marketsController.add(List.from(_markets));
      }
    });
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

    // 2. Products Stream Listener
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

    // 3. Family Members Stream Listener
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

  void _emitMappedItems() {
    if (_itemsController.isClosed) return;
    
    final mapped = _lastProducts.map((map) {
      final categoryId = map['category_id'] as String?;
      final categoryName = categoryId != null ? (_categoryCache[categoryId] ?? 'Diğer') : 'Diğer';
      
      return {
        'id': map['id'],
        'urunAdi': map['name'],
        'fiyat': map['price'] != null ? (map['price'] as num).toDouble() : null,
        'alindiMi': map['is_bought'] ?? false,
        'kategori': categoryName,
        'miktar': map['quantity'] != null ? (map['quantity'] as num).toDouble() : null,
        'birim': map['unit'],
        'marketAdi': null, // markets table isn't in database, default null
      };
    }).toList();

    _itemsController.add(mapped);
  }

  @override
  Stream<List<Map<String, dynamic>>> getAlinacaklarListesi() {
    Timer.run(() => _emitMappedItems());
    return _itemsController.stream.map((list) {
      return list.where((item) => !(item['alindiMi'] as bool? ?? false)).toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getAlinanlarListesi() {
    Timer.run(() => _emitMappedItems());
    return _itemsController.stream.map((list) {
      return list.where((item) => item['alindiMi'] as bool? ?? false).toList();
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> getTumUrunler() {
    Timer.run(() => _emitMappedItems());
    return _itemsController.stream;
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
      final response = await _supabase
          .from('categories')
          .insert({'name': categoryName})
          .select('id')
          .single();
      return response['id'] as String;
    } catch (e) {
      final res = await _supabase
          .from('categories')
          .select('id')
          .eq('name', categoryName)
          .maybeSingle();
      if (res != null) {
        return res['id'] as String;
      }
      throw Exception('Kategori oluşturulamadı.');
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

      await _supabase.from('products').insert({
        'name': urunAdi,
        'price': fiyat,
        'category_id': categoryId,
        'quantity': miktar ?? 1.0,
        'unit': birim,
        'is_bought': false,
        'created_by': _supabase.auth.currentUser?.id,
      });
    } catch (e) {
      debugPrint('SupabaseDatabaseImpl urunEkle Hata: $e');
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
          .eq('id', urunId);
    } catch (e) {
      debugPrint('SupabaseDatabaseImpl urunDurumGuncelle Hata: $e');
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
    Timer.run(() => _emitFamilyMembers());
    return _familyController.stream;
  }

  @override
  Future<void> aileUyesiEkle(String isim) async {
    try {
      await _supabase.from('family_members').insert({
        'name': isim,
      });
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
          .eq('id', urunId);
    } catch (e) {
      debugPrint('SupabaseDatabaseImpl urunSil Hata: $e');
    }
  }
}
