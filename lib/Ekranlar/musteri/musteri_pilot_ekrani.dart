import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusteriPilotEkrani extends StatelessWidget {
  final String uid;
  const MusteriPilotEkrani({super.key, required this.uid});

  void pilotKirala(BuildContext context, String pilotIsim, int ucret) async {
    try {
      // Rezervasyonlar tablosuna pilot kiralama kaydı atıyoruz
      await FirebaseFirestore.instance.collection('rezervasyonlar').add({
        'kullanici_id': uid,
        'kiralanan_tur': 'Pilot',
        'pilot_isim': pilotIsim,
        'toplam_maliyet': ucret,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'Beklemede',
      });

      // Loglama
      await FirebaseFirestore.instance.collection('loglar').add({
        'kullanici_id': uid,
        'islem': 'Pilot Kiralama Talebi Oluşturuldu ($pilotIsim)',
        'tarih': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$pilotIsim için kiralama talebi iletildi!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Firestore'daki 'pilotlar' koleksiyonunu canlı dinliyoruz
      stream: FirebaseFirestore.instance.collection('pilotlar').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text(
              "Sistemde şu an müsait pilot bulunmuyor.",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final pilot = docs[index].data() as Map<String, dynamic>;
            final String isim = pilot['isim'] ?? "Bilinmeyen Pilot";
            final String lisans = pilot['lisans'] ?? "Klasik Lisans";
            final int ucret = pilot['gunluk_ucret'] ?? 0;
            final String fotoUrl = pilot['foto_url'] ?? "";

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                  12.0,
                ), // İçerik ile kart arası temiz boşluk
                child: Row(
                  // Resim solda, içerikler sağda olacak şekilde Row düzeni
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // SOL TARAF: PİLOT FOTOĞRAFI (KARE EBATINDA)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 100, // Drone kartı ile birebir aynı ebat
                        height: 100,
                        color: Colors.grey.shade200,
                        child: fotoUrl.isNotEmpty
                            ? Image.network(
                                fotoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
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

                    const SizedBox(
                      width: 16,
                    ), // Resim ile metinler arası boşluk
                    // SAĞ TARAF: DETAYLAR VE ALTINDA DURAN BUTON
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Her şeyi sola yaslıyoruz
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
                            "Sınıfı: $lisans",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
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

                          // İŞTE SEÇ BUTONU (BİLGİLERİN TAM ALTINDA)
                          Align(
                            alignment: Alignment
                                .centerLeft, // Butonu sola yanaştırıyoruz
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
                              onPressed: () =>
                                  pilotKirala(context, isim, ucret),
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
