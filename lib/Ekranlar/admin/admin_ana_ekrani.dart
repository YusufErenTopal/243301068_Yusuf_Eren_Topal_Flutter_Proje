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
  // Drone Controller'ları
  final _markaController = TextEditingController();
  final _modelController = TextEditingController();
  final _ucretController = TextEditingController();
  final _fotoController = TextEditingController();

  // YENİ: Pilot Controller'ları
  final _pilotIsimController = TextEditingController();
  final _pilotLisansController = TextEditingController();
  final _pilotUcretController = TextEditingController();
  final _pilotFotoController = TextEditingController();

  void droneEkle() async {
    if (_markaController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _ucretController.text.isEmpty ||
        _fotoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm drone alanlarını doldurun!"),
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

  // YENİ: PİLOT EKLEME FONKSİYONU
  void pilotEkle() async {
    if (_pilotIsimController.text.isEmpty ||
        _pilotLisansController.text.isEmpty ||
        _pilotUcretController.text.isEmpty ||
        _pilotFotoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm pilot alanlarını doldurun!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('pilotlar').add({
        'isim': _pilotIsimController.text.trim(),
        'lisans': _pilotLisansController.text.trim(),
        'gunluk_ucret': int.parse(_pilotUcretController.text.trim()),
        'foto_url': _pilotFotoController.text.trim(),
        'durum': true,
      });
      await FirebaseFirestore.instance.collection('loglar').add({
        'kullanici_id': widget.uid,
        'islem': 'Yeni Pilot Eklendi (${_pilotIsimController.text})',
        'tarih': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilot başarıyla sisteme eklendi!"),
          backgroundColor: Colors.blue,
        ),
      );
      _pilotIsimController.clear();
      _pilotLisansController.clear();
      _pilotUcretController.clear();
      _pilotFotoController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pilot Ekleme Hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void talebiSil(String docId, String droneModel) async {
    try {
      await FirebaseFirestore.instance
          .collection('rezervasyonlar')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Talep başarıyla kaldırıldı."),
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

  void droneSil(String docId, String droneIsim) async {
    try {
      await FirebaseFirestore.instance
          .collection('dronelar')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$droneIsim silindi."),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void droneDuzenleDialog(String docId, Map<String, dynamic> mevcutVeri) {
    final markaEditController = TextEditingController(
      text: mevcutVeri['marka'],
    );
    final modelEditController = TextEditingController(
      text: mevcutVeri['model'],
    );
    final ucretEditController = TextEditingController(
      text: mevcutVeri['gunluk_ucret'].toString(),
    );
    final fotoEditController = TextEditingController(
      text: mevcutVeri['foto_url'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Drone Düzenle"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: markaEditController,
                decoration: const InputDecoration(labelText: "Marka"),
              ),
              TextField(
                controller: modelEditController,
                decoration: const InputDecoration(labelText: "Model"),
              ),
              TextField(
                controller: ucretEditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Ücret"),
              ),
              TextField(
                controller: fotoEditController,
                decoration: const InputDecoration(labelText: "Fotoğraf URL"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('dronelar')
                    .doc(docId)
                    .update({
                      'marka': markaEditController.text.trim(),
                      'model': modelEditController.text.trim(),
                      'gunluk_ucret': int.parse(
                        ucretEditController.text.trim(),
                      ),
                      'foto_url': fotoEditController.text.trim(),
                    });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Güncelle"),
            ),
          ],
        );
      },
    );
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
        elevation: 0,
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
            // YENİ SİMETRİK İKİLİ FORM DÜZENİ (YAN YANA)
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SOL TARAF: DRONE KAYIT FORMU
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.add_box_rounded,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Yeni Drone Kayıt Formu",
                                    style: TextStyle(
                                      fontSize: 16,
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
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _ucretController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Günlük Kiralama Ücreti (TL)",
                                  prefixIcon: const Icon(
                                    Icons.payments_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton.icon(
                                  onPressed: droneEkle,
                                  icon: const Icon(Icons.cloud_upload),
                                  label: const Text(
                                    "Drone'u Kaydet",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16), // İki form arasındaki boşluk
                    // SAĞ TARAF: YENİ PİLOT KAYIT FORMU (Birebir Simetrik)
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: Colors.teal,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Yeni Pilot Kayıt Formu",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 25),
                              TextField(
                                controller: _pilotIsimController,
                                decoration: InputDecoration(
                                  labelText: "Pilot Adı Soyadı",
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _pilotLisansController,
                                decoration: InputDecoration(
                                  labelText: "Lisans Sınıfı (Örn: IHA-0)",
                                  prefixIcon: const Icon(
                                    Icons.card_membership_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _pilotUcretController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Günlük Pilot Ücreti (TL)",
                                  prefixIcon: const Icon(
                                    Icons.monetization_on_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _pilotFotoController,
                                decoration: InputDecoration(
                                  labelText: "Pilot Fotoğraf Linki (URL)",
                                  prefixIcon: const Icon(
                                    Icons.portrait_outlined,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton.icon(
                                  onPressed: pilotEkle,
                                  icon: const Icon(Icons.badge_outlined),
                                  label: const Text(
                                    "Pilotu Kaydet",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // MÜŞTERİ TALEPLERİ
            Row(
              children: const [
                Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.blueGrey,
                ),
                SizedBox(width: 8),
                Text(
                  "Müşterilerden Gelen Kiralama Talepleri",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                if (docs.isEmpty)
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Henüz aktif bir kiralama talebi bulunmuyor."),
                  );
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final talep = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(
                            Icons.hourglass_empty,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(
                          talep['drone_model'] ??
                              talep['pilot_isim'] ??
                              "Kiralama",
                        ),
                        subtitle: Text(
                          "Tür: ${talep['kiralanan_tur'] ?? 'Belirtilmemiş'}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => talebiSil(doc.id, ""),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // SİSTEMDEKİ DRONELAR
            Row(
              children: const [
                Icon(Icons.inventory_2_outlined, color: Colors.blueGrey),
                SizedBox(width: 8),
                Text(
                  "Sistemdeki Mevcut Dronelar",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('dronelar')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final drone = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          drone['foto_url'] ?? "",
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.flight),
                        ),
                        title: Text("${drone['marka']} ${drone['model']}"),
                        subtitle: Text("${drone['gunluk_ucret']} TL / Gün"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_note,
                                color: Colors.blue,
                              ),
                              onPressed: () =>
                                  droneDuzenleDialog(doc.id, drone),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              onPressed: () => droneSil(doc.id, drone['model']),
                            ),
                          ],
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
