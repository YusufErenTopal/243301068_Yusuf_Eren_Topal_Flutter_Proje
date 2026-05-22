import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'musteri_profil_ekrani.dart';
import 'musteri_pilot_ekrani.dart';
import 'musteri_odeme_ekrani.dart'; // Yeni ekranı bağladık

class MusteriAnaEkrani extends StatefulWidget {
  final String uid;
  const MusteriAnaEkrani({super.key, required this.uid});

  @override
  State<MusteriAnaEkrani> createState() => _MusteriAnaEkraniState();
}

class _MusteriAnaEkraniState extends State<MusteriAnaEkrani> {
  int _secilenSekme = 0; // 0: Dronelar, 1: Pilotlar, 2: Sepetim, 3: Profilim

  void droneKirala(String droneModel, int gunlukUcret) async {
    try {
      await FirebaseFirestore.instance.collection('rezervasyonlar').add({
        'kullanici_id': widget.uid,
        'kiralanan_tur': 'Drone',
        'drone_model': droneModel,
        'toplam_maliyet': gunlukUcret,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'Beklemede', // Ödeme ekranına düşmesi için Beklemede kalıyor
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

  @override
  Widget build(BuildContext context) {
    // 4 SEKMELİ YENİ LİSTE DÜZENİ
    final List<Widget> _sayfalar = [
      // SEKME 0: DRONELAR LİSTESİ
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
            return const Center(child: Text("Müsait drone bulunmuyor."));

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final drone = docs[index].data() as Map<String, dynamic>;
              final String marka = drone['marka'] ?? "";
              final String model = drone['model'] ?? "";
              final int ucret = drone['gunluk_ucret'] ?? 0;
              final String fotoUrl = drone['foto_url'] ?? "";

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
                              onPressed: () =>
                                  droneKirala("$marka $model", ucret),
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

      // SEKME 1: PİLOTLAR SAYFASI
      MusteriPilotEkrani(uid: widget.uid),

      // SEKME 2: YENİ ÖDEME VE SEPET SAYFASI (Profilin Solu)
      MusteriOdemeEkrani(uid: widget.uid),

      MusteriProfilEkrani(uid: widget.uid),
    ];

    final List<String> _basliklar = [
      "Kiralık Dronelar",
      "Uzman Pilotlarımız",
      "Yemeksepeti Ödeme Sistemi",
      "Profil Özeti",
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _basliklar[_secilenSekme],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
        elevation: 0,
      ),
      body: _sayfalar[_secilenSekme],

      // 4 SEKMELİ BOTTOM NAV BAR
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
          // YENİ ÖDEME İKONU (Profilin solunda)
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
