import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        _ucretController.text.isEmpty) {
      return;
    }
    try {
      DocumentReference yeniDrone = await FirebaseFirestore.instance
          .collection('dronelar')
          .add({
            'marka': _markaController.text.trim(),
            'model': _modelController.text.trim(),
            'gunluk_ucret': double.parse(_ucretController.text.trim()),
            'foto_url': _fotoController.text.trim().isEmpty
                ? 'https://via.placeholder.com/150'
                : _fotoController.text.trim(),
            'durum': true,
            'ekleyen_admin': widget.uid,
            'eklenme_tarihi': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance.collection('loglar').add({
        'kullanici_id': widget.uid,
        'islem':
            'Yeni Drone Eklendi (${_markaController.text} ${_modelController.text})',
        'tarih': FieldValue.serverTimestamp(),
      }); // [cite: 22]

      _markaController.clear();
      _modelController.clear();
      _ucretController.clear();
      _fotoController.clear();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yönetici Paneli"),
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
          children: [
            TextField(
              controller: _markaController,
              decoration: const InputDecoration(labelText: "Marka"),
            ),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: "Model"),
            ),
            TextField(
              controller: _ucretController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Ücret"),
            ),
            TextField(
              controller: _fotoController,
              decoration: const InputDecoration(labelText: "Fotoğraf URL"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: droneEkle,
              child: const Text("Drone Kaydet"),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              "Gelen Kiralama Talepleri (Müşterilerden)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rezervasyonlar')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final talep = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text("Talep: ${talep['drone_model']}"),
                      subtitle: Text("Kullanıcı ID: ${talep['kullanici_id']}"),
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
