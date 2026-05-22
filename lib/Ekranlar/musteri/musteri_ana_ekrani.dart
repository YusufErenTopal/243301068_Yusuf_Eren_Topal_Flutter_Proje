import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'musteri_profil_ekrani.dart';
import 'musteri_pilot_ekrani.dart';
import 'musteri_odeme_ekrani.dart';

class MusteriAnaEkrani extends StatefulWidget {
  final String uid;
  const MusteriAnaEkrani({super.key, required this.uid});

  @override
  State<MusteriAnaEkrani> createState() => _MusteriAnaEkraniState();
}

class _MusteriAnaEkraniState extends State<MusteriAnaEkrani> {
  int _secilenSekme = 0;

  void droneKirala(
    String droneModel,
    int gunlukUcret,
    int gerekenLisans,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('rezervasyonlar').add({
        'kullanici_id': widget.uid,
        'kiralanan_tur': 'Drone',
        'drone_model': droneModel,
        'toplam_maliyet': gunlukUcret,
        'gereken_lisans_seviyesi': gerekenLisans,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'Beklemede',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$droneModel sepetinize eklendi! Ödeme sekmesinden tamamlayabilirsiniz.",
            ),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    }
  }

  String lisansMetniGetir(int? seviye) {
    if (seviye == 1) return "İHA-0 ";
    if (seviye == 2) return "İHA-1 ";
    if (seviye == 3) return "İHA-2 ";
    if (seviye == 4) return "İHA-3 ";
    return "Belirtilmemiş (İHA-1)";
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _sayfalar = [
      // SEKME 0: GÜNCELLENEN DRONELAR LİSTESİ
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('dronelar')
            .where('durum', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(
              child: Text(
                "Müsait drone bulunmuyor.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final drone = docs[index].data() as Map<String, dynamic>;
              final String marka = drone['marka'] ?? "";
              final String model = drone['model'] ?? "";
              final int ucret = drone['gunluk_ucret'] ?? 0;
              final String fotoUrl = drone['foto_url'] ?? "";
              final int gerekenLisans = drone['gereken_lisans_seviyesi'] ?? 2;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
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
                                    Icons.flight,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(Icons.flight, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$marka $model",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Gereken Lisans: ${lisansMetniGetir(gerekenLisans)}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "$ucret TL / Günlük",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => droneKirala(
                                "$marka $model",
                                ucret,
                                gerekenLisans,
                              ),
                              child: const Text("Sepete Ekle"),
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
      ),

      MusteriPilotEkrani(uid: widget.uid),
      MusteriOdemeEkrani(uid: widget.uid),
      MusteriProfilEkrani(uid: widget.uid),
    ];

    final List<String> _basliklar = [
      "Kiralık Dronelar",
      "Uzman Pilotlarımız",
      "Ödeme Yeri",
      "Profil Özeti",
    ];

    return Scaffold(
      // Arka plan resminin tam oturması için Scaffold'un kendi rengini transparan yapıyoruz
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          _basliklar[_secilenSekme],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // AppBar'ı hafif şeffaf yaparak arkadaki resimle bütünleştiriyoruz
        backgroundColor: Colors.blue.shade100.withOpacity(0.85),
        elevation: 0,
      ),
      // ENTEGRESYON NOKTASI: İnternetten resmi çeken ve sayfaları üzerine basan Container
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            // İSTEDİĞİN GİBİ: İnternet üzerinden dinamik çekilen resim URL'si
            image: NetworkImage(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTtZEf5wGLkLSRs7R9Oo6yTM1TDtylTcEgUIA&s",
            ),
            fit: BoxFit.cover,
            opacity:
                0.25, // Kartlardaki yazıların rahat okunması için resmi arkada %25 opaklıkta tutuyoruz
          ),
        ),
        child: _sayfalar[_secilenSekme],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _secilenSekme,
        onTap: (index) {
          setState(() {
            _secilenSekme = index;
          });
        },
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation_outlined),
            activeIcon: Icon(Icons.navigation),
            label: "Dronelar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervisor_account_outlined),
            activeIcon: Icon(Icons.supervisor_account),
            label: "Pilotlar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: "Sepetim",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profilim",
          ),
        ],
      ),
    );
  }
}
