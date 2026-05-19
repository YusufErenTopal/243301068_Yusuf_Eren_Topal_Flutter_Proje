import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAnaEkrani extends StatefulWidget {
  final String uid;
  const AdminAnaEkrani({super.key, required this.uid});

  @override
  State<AdminAnaEkrani> createState() => _AdminAnaEkraniState();
}

class _AdminAnaEkraniState extends State<AdminAnaEkrani> {
  final _markaController = TextEditingController();
  final _modelController = TextEditingController();
  final _ucretController = TextEditingController();
  final _fotoController = TextEditingController();

  void droneEkle() async {
    if (_markaController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _ucretController.text.isEmpty ||
        _fotoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurun!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('dronelar').add({
        'marka': _markaController.text.trim(),
        'model': _modelController.text.trim(),
        'gunluk_ucret': int.parse(_ucretController.text.trim()),
        'foto_url': _fotoController.text.trim(),
        'durum': true,
      });

      // Loglama Sistemi
      await FirebaseFirestore.instance.collection('loglar').add({
        'kullanici_id': widget.uid,
        'islem':
            'Yeni Drone Eklendi (${_markaController.text} ${_modelController.text})',
        'tarih': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Drone başarıyla sisteme eklendi!"),
          backgroundColor: Colors.green,
        ),
      );

      _markaController.clear();
      _modelController.clear();
      _ucretController.clear();
      _fotoController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ekleme Hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Yöneticinin gelen talebi silebilmesine yarayan fonksiyon
  void talebiSil(String docId, String droneModel) async {
    try {
      await FirebaseFirestore.instance
          .collection('rezervasyonlar')
          .doc(docId)
          .delete();

      // Silme işlemininde loglanmasına yarayan fonksiyon
      await FirebaseFirestore.instance.collection('loglar').add({
        'kullanici_id': widget.uid,
        'islem': 'Kiralama Talebi Silindi/Reddedildi ($droneModel)',
        'tarih': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kiralama talebi başarıyla kaldırıldı."),
          backgroundColor: Colors.blueGrey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Silme Hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Firma Yetkili Paneli",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drone ekleme kısmı
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.add_box_rounded,
                              color: Colors.blue,
                              size: 28,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Yeni Drone Kayıt Formu",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 25),

                        TextField(
                          controller: _markaController,
                          decoration: InputDecoration(
                            labelText: "Drone Markası (Örn: DJI)",
                            prefixIcon: const Icon(
                              Icons.branding_watermark_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _modelController,
                          decoration: InputDecoration(
                            labelText: "Drone Modeli (Örn: Air 3)",
                            prefixIcon: const Icon(Icons.flight),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _ucretController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Günlük Kiralama Ücreti (TL)",
                            prefixIcon: const Icon(Icons.payments_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _fotoController,
                          decoration: InputDecoration(
                            labelText: "Fotoğraf İnternet Linki (URL)",
                            prefixIcon: const Icon(Icons.image_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: droneEkle,
                            icon: const Icon(Icons.cloud_upload),
                            label: const Text(
                              "Drone'u Sisteme Kaydet",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: const [
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.blueGrey,
                ),
                SizedBox(width: 8),
                Text(
                  "Müşterilerden Gelen Kiralama Talepleri",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rezervasyonlar')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      "Henüz aktif bir kiralama talebi bulunmuyor.",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final talep = doc.data() as Map<String, dynamic>;
                    final String droneModel =
                        talep['drone_model'] ?? "Bilinmeyen Drone";
                    final String musteriId = talep['kullanici_id'] ?? "ID Yok";

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.shade50,
                          child: const Icon(
                            Icons.hourglass_empty_rounded,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(
                          droneModel,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            "Müşteri ID: ${musteriId.length > 12 ? musteriId.substring(0, 12) + '...' : musteriId}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),

                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          tooltip: "Talebi Kaldır",
                          onPressed: () => talebiSil(doc.id, droneModel),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
