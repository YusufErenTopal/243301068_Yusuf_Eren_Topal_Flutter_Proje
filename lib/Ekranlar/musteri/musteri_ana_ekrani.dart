import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drone_detay_ekrani.dart';
import 'musteri_profil_ekrani.dart';

class MusteriAnaEkrani extends StatefulWidget {
  final String uid;
  const MusteriAnaEkrani({super.key, required this.uid});

  @override
  State<MusteriAnaEkrani> createState() => _MusteriAnaEkraniState();
}

class _MusteriAnaEkraniState extends State<MusteriAnaEkrani> {
  int _secilenIndis = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _sayfalar = [
      _DroneListeGorunumu(uid: widget.uid),
      MusteriProfilEkrani(uid: widget.uid),
    ];

    return Scaffold(
      body: _sayfalar[_secilenIndis],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _secilenIndis,
        onTap: (indis) {
          setState(() {
            _secilenIndis = indis;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: "Dronelar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profilim"),
        ],
      ),
    );
  }
}

class _DroneListeGorunumu extends StatelessWidget {
  final String uid;
  const _DroneListeGorunumu({required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kiralık Dronelar"),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              child: Text("Şu anda müsait drone bulunmuyor."),
            );

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final droneDoc = docs[index];
              final drone = droneDoc.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DroneDetayEkrani(
                          droneId: droneDoc.id,
                          droneData: drone,
                          kullaniciUid: uid,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Image.network(
                        drone['foto_url'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.flight, size: 50),
                      ),
                      ListTile(
                        title: Text("${drone['marka']} ${drone['model']}"),
                        trailing: Text(
                          "${drone['gunluk_ucret']} TL / Gün",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
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
    );
  }
}
