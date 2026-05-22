import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MusteriProfilEkrani extends StatelessWidget {
  final String uid;
  const MusteriProfilEkrani({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ÜST KISIM: PROFİL ÖZETİ KARTI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Profilim",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Müşteri Hesabı",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID: ${uid.substring(0, 8)}...",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ALT KISIM: KİRALAMA GEÇMİŞİ LİSTESİ
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_toggle_off_rounded,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Kiralama Geçmişi & Maliyet Özeti",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // FIRESTORE CANLI VERİ AKIŞI
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rezervasyonlar')
                        .where('kullanici_id', isEqualTo: uid)
                        .where('durum', isEqualTo: 'Ödendi')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      if (docs.isEmpty) {
                        return const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                "Henüz onaylanmış bir kiralama geçmişiniz yok.",
                              ),
                            ),
                          ),
                        );
                      }

                      // Sıralama işlemini Firebase yerine cihazın içinde (Dart ile) yapıyoruz (Index hatasını çözer)
                      final sortedDocs = List.from(docs);
                      sortedDocs.sort((a, b) {
                        final aTimestamp =
                            (a.data() as Map<String, dynamic>)['tarih']
                                as Timestamp?;
                        final bTimestamp =
                            (b.data() as Map<String, dynamic>)['tarih']
                                as Timestamp?;
                        if (aTimestamp == null || bTimestamp == null) return 0;
                        return bTimestamp.compareTo(
                          aTimestamp,
                        ); // Yeniden eskiye sıralama
                      });

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedDocs.length,
                        itemBuilder: (context, index) {
                          final veri =
                              sortedDocs[index].data() as Map<String, dynamic>;

                          // Tür kontrolü yapılıyor
                          final String tur = veri['kiralanan_tur'] ?? "Drone";

                          // Eğer tür pilotsa 'pilot_isim' alanını, dronesu 'drone_model' alanını okur
                          final String baslik = tur == 'Pilot'
                              ? (veri['pilot_isim'] ?? "Uzman Pilot")
                              : (veri['drone_model'] ?? "Drone Modeli");

                          final int maliyet = veri['toplam_maliyet'] ?? 0;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade50,
                                child: Icon(
                                  tur == 'Pilot'
                                      ? Icons.badge_outlined
                                      : Icons.flight_takeoff_rounded,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                baslik,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                "$tur - Kiralama Onaylandı",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                "$maliyet TL",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // OTURUMU KAPAT BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        "Oturumu Kapat",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
  }
}
