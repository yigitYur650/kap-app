abstract class DatabaseService {
  /// Stream to fetch the shopping list (alinacaklar listesi).
  Stream<List<Map<String, dynamic>>> getAlinacaklarListesi();

  /// Stream to fetch the bought list (alinanlar listesi).
  Stream<List<Map<String, dynamic>>> getAlinanlarListesi();

  /// Stream to fetch all products (hem alınacaklar hem alınanlar).
  Stream<List<Map<String, dynamic>>> getTumUrunler();

  /// Adds a new product to the shopping list.
  Future<void> urunEkle({
    required String urunAdi,
    double? fiyat,
    String? marketAdi,
    String? kategori,
    double? miktar,
    String? birim,
  });

  /// Updates the status (checked/unchecked) of a product in the list.
  Future<void> urunDurumGuncelle({
    required String urunId,
    required bool alindiMi,
  });

  /// Stream to fetch all markets.
  Stream<List<String>> getMarketler();

  /// Adds a new market.
  Future<void> marketEkle(String marketAdi);

  /// Stream to fetch all family members.
  Stream<List<Map<String, dynamic>>> getAileUyeleri();

  /// Adds a new family member.
  Future<void> aileUyesiEkle(String isim);

  /// Removes a product from the list.
  Future<void> urunSil(String urunId);
}
