# 🎬 Filmora: Yapay Zeka Destekli Sinema Keşif Asistanı

<div align="center">

![Status](https://img.shields.io/badge/Status-OBSS%20Codecamp%20'25-blue?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-iOS%2016.0%2B-black?style=for-the-badge&logo=apple&logoColor=white)
![Language](https://img.shields.io/badge/Language-Swift%205-orange?style=for-the-badge&logo=swift&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-blueviolet?style=for-the-badge)
![AI Engine](https://img.shields.io/badge/AI%20Engine-Gemini%20Pro-4285F4?style=for-the-badge&logo=google&logoColor=white)

</div>

---

## 🚀 Proje Özeti

**Filmora**, OBSS 2025 Codecamp sürecinde geliştirilen, **TMDB** veritabanının geniş arşivini **Google Gemini** yapay zekasının sohbet yetenekleriyle birleştiren modern bir iOS uygulamasıdır.

Uygulama, **MVVM** mimarisi üzerine inşa edilmiş olup, kullanıcıların sadece film bilgilerine ulaşmasını değil, aynı zamanda yapay zeka ile filmler hakkında sohbet etmesini, senaryo analizleri yapmasını ve kişiselleştirilmiş öneriler almasını sağlar.

---

## 🛠️ Teknoloji Yığını

Uygulama geliştirilirken kullanılan temel teknolojiler ve kütüphaneler:

| Kategori | Teknoloji / Kütüphane | Açıklama |
| --- | --- | --- |
| **Dil** | Swift 5 | iOS 16.0+ hedefli geliştirme dili. |
| **Mimari** | MVVM | Temiz kod ve test edilebilirlik için katmanlı yapı. |
| **Networking** | Moya (Alamofire Wrapper) | Tip güvenli (Type-safe) API yönetimi. |
| **Veri Kaynağı** | TMDB API | Film verileri, görseller ve oyuncu bilgileri. |
| **Yapay Zeka** | Google Gemini API | Doğal dil işleme ve film asistanı. |
| **UI / Görsel** | Kingfisher | Asenkron görsel indirme ve önbellekleme. |
| **UX / Yükleme** | SkeletonView | Veri yüklenirken iskelet animasyon gösterimi. |

---

## ✨ Temel Özellikler

### 🏠 Ana Ekran

* **Hero Section:** Günün öne çıkan filmi veya kişiselleştirilmiş öneri.
* **Dinamik Listeler:** Popüler, Trend Olanlar ve En Yüksek Puanlı filmlerin yatay kaydırılabilir listeleri.

### 🎥 Film Detayları

* **Kapsamlı Bilgi:** Bütçe, hasılat, türler, yapımcı şirketler ve orijinal çıkış tarihleri.
* **Görsel Zenginlik:** Yüksek çözünürlüklü posterler ve arka plan görselleri.
* **Benzer Filmler:** İzlediğiniz filme benzer önerilerin bulunduğu kaydırılabilir liste.

### 🤖 Yapay Zeka Film Asistanı

* **İnteraktif Sohbet:** Filmler hakkında sorular sorun, spoiler almadan özet isteyin veya "Bana X tarzında bir film öner" diyerek sohbet edin.
* **Keşfet Modu:** Hazır konu başlıkları ile popüler sinema tartışmalarına katılın.

### 🌟 Kişiselleştirme

* **Favorilerim:** Beğendiğiniz filmleri yerel veritabanına (UserDefaults/CoreData) kaydederek kendi listenizi oluşturun.
* **Oyuncu Kadrosu:** Filmin oyuncularını görüntüleyin ve detaylarına gidin.

---

## 📸 Ekran Görüntüleri

<div align="center">

| **Keşfet & Ana Ekran** | **Detaylı Analiz** | **Yapay Zeka Sohbet** |
| --- | --- | --- |
| <img src="Photos/1.png" width="220" alt="Ana Ekran"> | <img src="Photos/2.png" width="220" alt="Film Detay"> | <img src="Photos/5.png" width="220" alt="AI Asistan"> |
| *Hero & Trendler* | *Detay Sayfası* | *Gemini Entegrasyonu* |

| **Arama & Filtre** | **Favoriler** | **Oyuncu Detay** |
| --- | --- | --- |
| <img src="Photos/7.png" width="220" alt="Arama"> | <img src="Photos/6.png" width="220" alt="Favoriler"> | <img src="Photos/8.png" width="220" alt="Oyuncu"> |
| *Anlık Arama* | *Kullanıcı Kitaplığı* | *Filmografi* |

</div>

---

## ⚙️ Kurulum

Projeyi yerel ortamınızda çalıştırmak için aşağıdaki adımları izleyin:

1. **Depoyu Klonlayın:**
```bash
git clone https://github.com/chyp3r/Filmora.git
cd Filmora

```


2. **Projeyi Açın:**
`Filmora.xcodeproj` dosyasını Xcode ile açın.
3. **API Anahtarları:**
* Projenin düzgün çalışması için `TMDB API Key` ve `Gemini API Key` gereklidir.
* `Constants` veya `Config` dosyanıza kendi API anahtarlarınızı ekleyin.


4. **Çalıştırın:**
`Cmd + R` kısayolu ile simülatörde veya cihazınızda başlatın.

---

<div align="center">
<sub>OBSS Codecamp 2025 kapsamında geliştirilmiştir. ❤️</sub>
</div>
