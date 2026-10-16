# ☕️ Caffeine for macOS

<div align="center">

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-000000?style=for-the-badge&logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift&logoColor=white)
![Architecture](https://img.shields.io/badge/Arch-Apple%20Silicon%20%7C%20Intel-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A lightweight, native macOS menu bar & window application to prevent your Mac from going to sleep or dimming its display.**

[Türkçe Açıklama](#-türkçe-açıklama) • [Features](#-features) • [Installation & Run](#-quick-start) • [How It Works](#-how-it-works)

</div>

---

## 📖 Overview / Genel Bakış

**Caffeine**, macOS sisteminizin güç ayarlarını kalıcı olarak değiştirmeden; arka planda kod derleme, dosya indirme/yükleme, render alma veya veri işleme gibi uzun süren işler yaparken ekranın kararmasını ve sistemin uykuya geçmesini tek tıkla engelleyen yerel bir macOS uygulamasıdır.

Çekirdek macOS `IOKit.pwr_mgt` API'lerini kullanarak çalışır. Uygulama kapatıldığında ya da belirlenen süre dolduğunda, sistem otomatik olarak standart uyku ayarlarına geri döner.

---

## ✨ Features / Özellikler

- **⏱ Quick Presets (Hazır Süreler):**
  - ⚡️ **30 Dakika** (Kısa işlemler)
  - ⏳ **1 Saat** (Standart odaklanma)
  - 🕒 **2 Saat** (Toplantı & kod derleme)
  - 🔥 **5 Saat** (Uzun işlemler & render)
  - 💼 **8 Saat** (Tam mesai)
  - ♾ **Süresiz / Indefinite** (Siz durdurana kadar sistemi uyanık tutar)

- **🎛 Custom Duration (Özel Süre):**
  - İstediğiniz saat (0-48) ve dakika (0-59) değerini serbestçe belirleyebilme.
  - Çalışırken dahi süreyi uzatmak için hızlı **`+15 dk`**, **`+30 dk`**, **`+1 sa`** ekleme butonları.

- **🍏 Menu Bar Integration (Menü Çubuğu):**
  - macOS menü çubuğunun sağ üst köşesinde zarif bir kahve fincanı simgesi (☕️).
  - Sayaç çalışırken menü çubuğunda simgenin solunda kalan süre anlık olarak akar (`45dk ☕️` veya `23s ☕️`).
  - Simgeden açılır etkileşimli popover kontrol paneli.

- **🪟 Dual Mode (Menü Çubuğu + Bağımsız Pencere):**
  - İster menü çubuğundan kompakt açılır menü olarak kullanın.
  - İsterseniz "Ayrı Pencerede Aç" butonuyla masaüstünüzde bağımsız pencere olarak tutun.
  - Pencereyi kapattığınızda uygulama sonlanmaz, menü çubuğunda sessizce çalışmayı sürdürür.

- **🛡 Power & Display Modes (Akıllı Güç Yönetimi):**
  - **Ekranı da Açık Tut:** Ekranın kararmasını, ekran koruyucuyu ve uyku modunu tamamen engeller.
  - **Yalnızca Sistemi Açık Tut:** Ekranın pil tasarrufu için kararmasına izin verir ancak arka plan işlemlerinin (CPU/ağ/disk) kesintisiz devam etmesini sağlar.

- **🔔 Audio & Notifications (Ses ve Bildirimler):**
  - Süre dolduğunda hoş bir macOS sistem sesi (`Glass`) çalar ve bildirim gönderir.

- **⚡️ 100% Native & Lightweight (%100 Yerel ve Hafif):**
  - Saf Swift & SwiftUI ile yazılmıştır.
  - Electron veya Node.js gerektirmez, toplam binary boyutu yalnızca ~600 KB'tır.
  - CPU ve RAM tüketimi neredeyse sıfırdır.

---

## 🚀 Quick Start / Hızlı Başlangıç

### 1. Klonlama ve Çalıştırma
```bash
git clone https://github.com/yunusemre-cagan/Caffeine.git
cd Caffeine
make run
```
*(Bu komut uygulamayı derler, yüksek çözünürlüklü ikonlarını oluşturur ve `Caffeine.app` olarak hemen başlatır).*

### 2. Uygulamalar (Applications) Klasörüne Kurma
Uygulamayı Spotlight veya Launchpad'den doğrudan açabilmek için:
```bash
make install
```

### 3. Kaynak Koddan Yeniden Derleme
```bash
make build
# veya
./build.sh
```

---

## 📂 Project Architecture / Proje Yapısı

```
Caffeine/
├── Package.swift                     # Swift Package Manager manifest
├── Makefile                          # Kolay terminal komutları (build, run, install)
├── build.sh                          # Otomatik derleme, imzalama ve paketleme betiği
├── README.md                         # Dokümantasyon
├── LICENSE                           # MIT Lisansı
├── Scripts/
│   └── generate_icons.swift          # Vektörel kahve uygulama ikonu üretici
└── Sources/
    └── Caffeine/
        ├── CaffeineApp.swift         # Ana SwiftUI giriş noktası & AppDelegate
        ├── CaffeineManager.swift     # IOKit güç yönetimi & geri sayım mantığı
        └── Views/
            ├── MainContentView.swift        # Birleşik arayüz görünümü
            ├── StatusHeroView.swift         # Kahve fincanı, durum & geri sayım kartı
            ├── PresetGridView.swift         # 30dk, 1sa, 2sa, 5sa, 8sa hazır süreler
            ├── CustomDurationView.swift     # Özel süre seçici ve hızlı ekleme butonları
            └── SettingsView.swift           # Ekran modu, bildirim ve Dock tercihleri
```

---

## 💡 How It Works / Nasıl Çalışır?

macOS işletim sisteminde `IOKit.pwr_mgt` çekirdek güç yönetim API'si bulunmaktadır:
- `kIOPMAssertionTypePreventUserIdleDisplaySleep`: Ekranın kapanmasını ve sistemin uyumasını engeller.
- `kIOPMAssertionTypePreventUserIdleSystemSleep`: CPU ve arka plan işlemlerini uyanık tutar.

Terminal üzerinden aktif durumu doğrulamak için:
```bash
pmset -g assertions
```
komutunu çalıştırdığınızda, Caffeine aktifken `PreventUserIdleDisplaySleep` kaydını görebilirsiniz.

---

## 📄 License / Lisans

Bu proje [MIT Lisansı](LICENSE) kapsamında açık kaynak olarak yayınlanmıştır.
