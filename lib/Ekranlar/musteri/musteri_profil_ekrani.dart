import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MusteriProfilEkrani extends StatelessWidget {
  final String uid;
  const MusteriProfilEkrani({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profilim ve Taleplerim"),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kiralama Geçmişiniz ve Maliyet Özeti",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ), //
            const SizedBox(height: 15),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                // Sadece bu kullanıcının kiralama taleplerini çekiyoruz
                stream: FirebaseFirestore.instance
                    .collection('rezervasyonlar')
                    .where('kullanici_id', isEqualTo: uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty)
                    return const Text(
                      "Henüz bir drone kiralama talebiniz bulunmuyor.",
                    );

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final talep = docs[index].data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        color: Colors.green.shade50,
                        child: ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(talep['drone_model'] ?? "Drone"),
                          subtitle: Text(
                            "Maliyet: ${talep['toplam_maliyet']} TL",
                          ), //
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout),
              label: const Text("Oturumu Kapat"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
