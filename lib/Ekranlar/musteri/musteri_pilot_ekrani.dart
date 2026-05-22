import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusteriPilotEkrani extends StatelessWidget {
  final String uid;
  const MusteriPilotEkrani({super.key, required this.uid});

  void pilotKirala(
    BuildContext context,
    String pilotIsim,
    int ucret,
    int pilotLisansSeviyesi,
    String pilotIl,
  ) async {
    try {
      // 1. KONTROL: Kullanıcının sepetinde duran (Beklemede olan) drone'ları çekiyoruz
      var sepetSnapshot = await FirebaseFirestore.instance
          .collection('rezervasyonlar')
          .where('kullanici_id', isEqualTo: uid)
          .where('durum', isEqualTo: 'Beklemede')
          .where('kiralanan_tur', isEqualTo: 'Drone')
          .get();

      // Sepetteki her bir drone'un gereksinim seviyesini tek tek inceliyoruz
      for (var doc in sepetSnapshot.docs) {
        final droneVeri = doc.data();

        // GÜVENLİ TÜR DÖNÜŞÜMÜ: Gelen veri ne olursa olsun sağlama alıyoruz
        int gerekenSeviye = 2; // Varsayılan değer
        if (droneVeri['gereken_lisans_seviyesi'] != null) {
          gerekenSeviye = int.parse(
            droneVeri['gereken_lisans_seviyesi'].toString(),
          );
        }

        // EĞER PİLOTUN LİSANSI DRONE İÇİN YETERSİZSE ENGELE TAKILSIN
        if (pilotLisansSeviyesi < gerekenSeviye) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: const [
                    Icon(Icons.gpp_bad_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Yetersiz Yetki Seviyesi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  "$pilotIsim adlı pilotun lisans seviyesi bu drone sınıfını uçurmaya yetmiyor. "
                  "Lütfen sepetinizdeki drone'a uygun, daha üst düzey bir pilot seçiniz.",
                  style: const TextStyle(fontSize: 15),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Anladım",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return; // Kontrolden geçemediği için fonksiyonu burada kırıyoruz, veritabanına eklemiyoruz!
        }
      }

      // 2. KONTROLDEN GEÇERSE SEPETE EKLEME İŞLEMİ YAPILIR
      await FirebaseFirestore.instance.collection('rezervasyonlar').add({
        'kullanici_id': uid,
        'kiralanan_tur': 'Pilot',
        'pilot_isim': pilotIsim,
        'toplam_maliyet': ucret,
        'pilot_il': pilotIl,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'Beklemede',
      });

      // Loglama
      await FirebaseFirestore.instance.collection('loglar').add({
        'kullanici_id': uid,
        'islem':
            'Pilot Sepete Eklendi ($pilotIsim - Lisans Seviyesi: $pilotLisansSeviyesi)',
        'tarih': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$pilotIsim sepetinize eklendi!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pilotlar').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("Sistemde aktif pilot bulunmuyor."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final pilot = docs[index].data() as Map<String, dynamic>;
            final String isim = pilot['isim'] ?? "Bilinmeyen Pilot";
            final String lisansAd = pilot['lisans'] ?? "İHA-1";
            final int lisansSeviye = pilot['lisans_seviyesi'] ?? 2;
            final int ucret = pilot['gunluk_ucret'] ?? 0;
            final String fotoUrl = pilot['foto_url'] ?? "";
            final String il = pilot['il'] ?? "Konya";
            final String ilce = pilot['ilce'] ?? "Selçuklu";
            final String lisansNo = pilot['lisans_no'] ?? "TR-PIL-2026X";

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: fotoUrl.isNotEmpty
                            ? Image.network(
                                fotoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isim,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Sınıf: $lisansAd (No: $lisansNo)",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                "$il / $ilce",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$ucret TL / Günlük",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () => pilotKirala(
                                context,
                                isim,
                                ucret,
                                lisansSeviye,
                                il,
                              ),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                              ),
                              label: const Text(
                                "Seç",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
