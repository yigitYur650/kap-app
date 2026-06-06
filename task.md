# Kap-App Proje Görevleri (SSOT)

Bu dosya, projedeki fazların ve görevlerin güncel durumunu takip eden tek doğruluk kaynağıdır (Single Source of Truth - SSOT).

## Mevcut Durum Özeti
- **Faz 1**: Altyapı, Güvenlik ve Kimlik Doğrulama (Authentication) kurulumu başarıyla tamamlandı. E-posta/Şifre ile kimlik doğrulama akışı, hata yönetimi katmanı, RLS veritabanı politikaları ve birim test planı entegre edildi.
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
- [x] **T-08**: E-posta/Şifre ile Kimlik Doğrulama Entegrasyonu (AuthService & SupabaseAuthImpl)
  - `AuthService` soyut arayüzü ve `SupabaseAuthImpl` servisi Service Pattern'e uygun olarak oluşturuldu.
  - `LoginScreen` arayüzü shadcn/ui eşdeğeri ShadForm, ShadInputFormField ve ShadButton bileşenleri kullanılarak, l10n dilleştirme altyapısıyla hazırlandı.
  - `main.dart` içinde `AuthGate` kurularak oturum durumuna göre dinamik yönlendirme yapıldı.
- [x] **T-09**: Dinamik Kullanıcı Oturum Verileri
  - SettingsView üzerindeki statik kullanıcı verileri (Yiğit Kaya, yigit@example.com vb.) kaldırılıp aktif Supabase oturumuyla (`currentUser`) dinamikleştirildi.
  - "Çıkış Yap" (Sign Out) eylemi SettingsView ayarlarına entegre edildi.
- [x] **T-10**: Row Level Security (RLS) Sıkılaştırılması
  - `schema.sql` dosyasındaki tüm anonim okuma/yazma politikaları kaldırıldı.
  - `products` ve `family_members` tabloları için `auth.uid() = created_by` / `auth.uid() = id` politikaları yerleştirildi.
  - Ürün ekleme metoduna (`urunEkle`) `created_by` alanı eklenerek yetkilendirme akışı sağlandı.
- [x] **T-11**: Hata Yönetimi ve Özel Hata Sınıfları (Custom Exception)
  - Merkezi loglama (Sentry vb.) sistemlerine uygun, stack trace barındıran özel hata sınıfları (`InvalidCredentialsException`, `EmailAlreadyInUseException`, vb.) tanımlandı.
- [x] **T-12**: Kimlik Doğrulama Birim Test Senaryolarının Tasarlanması
  - Auth modülü için Mockito ve flutter_test tabanlı detaylı test durumları oluşturuldu.
- [x] **T-13**: Kimlik Doğrulama UX Hatalarının Giderilmesi & Dil Seçici Entegrasyonu
  - Giriş/kayıt başarı veya hata durumlarında düzgün SnackBar bildirimleri eklendi.
  - Asenkron context kaybını engellemek amacıyla `ScaffoldMessengerState` ve yerelleştirilmiş metinler async çağrı öncesinde yakalandı.
  - Arayüze `LocaleProvider` kullanılarak dinamik TR/EN dil seçici eklendi ve tüm metinler dilleştirildi.

### Faz 2: UI Etkileşimleri & Veri Katmanı Güncellemeleri
- [x] **T-05**: UI Silme & Geri Al (Undo) Özelliği (UI Deletion)
  - Ürün listesi elemanlarına çöp kutusu (silme) ikonu yerleştirildi.
  - İkona tıklandığında veya öğe kaydırıldığında soft delete tetiklenerek Supabase/Mock veritabanında `is_deleted = true` olarak güncelleniyor.
  - Shadcn Toast (`ShadToaster`) bildiriminde yerelleştirilmiş "Geri Al" (Undo) butonu sunularak silme işleminin geri alınması (`is_deleted = false`) sağlandı.
- [ ] **T-08**: Hızlı Yeniden Ekleme (Quick Re-add)
  - [x] **Moved to Backlog (YAGNI)**: Ürün Sahibi kararıyla bu özellik şimdilik atlandı.
- [x] **T-09**: Miktar ve Birim Alanlarının Gösterilmesi (Display Quantity)
  - Hem ana alışveriş listesinde (Pending) hem de alınanlar/geçmiş listesinde (Paid) ürünlerin miktar ve birim değerleri (örn: "Fırın · 2 adet" veya "Elma · 3 kg") nokta ayırıcı biçiminde görünür hale getirildi.
- **Sonraki Hedef / Sonraki Adım**: Faz 2 - Adım 2: Ürün Düzenleme Arayüzü & Akıllı Kategorizasyon İyileştirmeleri.

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
