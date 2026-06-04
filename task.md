# Kap-App Proje Görevleri (SSOT)

Bu dosya, projedeki fazların ve görevlerin güncel durumunu takip eden tek doğruluk kaynağıdır (Single Source of Truth - SSOT).

## Mevcut Durum Özeti
- **Faz 1**: Altyapı ve Güvenlik kurulumu başarıyla tamamlandı. Firebase bağımlılıkları tamamen kaldırıldı ve Supabase tek backend servisi haline getirildi. Çevresel güvenlik sıkılaştırıldı.
- **Faz 5**: Supabase entegrasyonu tamamlandı. Ev halkı real-time güncelleme sorunu çözüldü, ürün listeleri veritabanına bağlandı ve soft delete mekanizması uygulandı.

---

## Proje Görev Listesi

### Faz 1: Altyapı Güvenliği & Backend Çakışmalarının Giderilmesi
- [x] **T-01**: Firebase Bağımlılıklarının Kaldırılması
  - `firebase_core`, `firebase_auth`, `cloud_firestore` paketleri `pubspec.yaml` dosyasından temizlendi.
  - `flutter pub get` çalıştırılarak bağımlılıklar ve ilgili otomatik platform dosyaları güncellendi.
- [x] **T-04**: Çevresel Güvenlik ve Gizlilik Yapılandırması
  - `.env` dosyasının `.gitignore` içinde yer aldığı doğrulandı.
  - `.env.example` dosyası örnek placeholder anahtarlar ile oluşturuldu.
  - Kod içinde hiçbir API Key'in hardcoded kalmadığından emin olundu, `flutter_dotenv` kullanımı standartlaştırıldı.

### Faz 5: Supabase Veritabanı Entegrasyonu & Akıllı Özellikler
- [x] **T-02**: Ana Listelerin Dinlenmesi (StreamBuilder)
  - `PendingListView` ve `PaidListView` `StreamBuilder` ile sarmalandı.
  - Filtrelenmiş veri akışları Supabase'e bağlandı.
- [x] **T-03**: Akıllı Form Bağlantısı
  - Ürün ekleme formu `databaseService.urunEkle()` metoduna bağlandı.
  - Boş bırakılan opsiyonel alanların (Miktar/Birim) yönetimi yapıldı.
- [x] **T-05**: Ev Halkı Real-time Güncellenmeme Hatasının Giderilmesi
  - `family_members` için tekil bir `StreamController` yayını kurularak sayfa yenilenmeden dinamik güncelleme yapılması sağlandı.
- [x] **T-06**: Soft Delete (Geçici Silme) Altyapısının Kurulması
  - Ürün silme işlemleri veritabanından kalıcı silme yerine `is_deleted = true` olarak güncellenecek şekilde soft delete standardına geçirildi.
  - Okuma akışları sadece `is_deleted = false` olan kayıtları getirecek şekilde güncellendi.
