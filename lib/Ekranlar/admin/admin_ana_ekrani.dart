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
  // Drone Kayıt Girişleri
  final _markaController = TextEditingController();
  final _modelController = TextEditingController();
  final _ucretController = TextEditingController();
  final _fotoController = TextEditingController();
  final _droneGerekenLisansController = TextEditingController();

  // Pilot Kayıt Girişleri
  final _pilotIsimController = TextEditingController();
  final _pilotLisansAdController = TextEditingController();
  final _pilotLisansSeviyeController = TextEditingController();
  final _pilotUcretController = TextEditingController();
  final _pilotFotoController = TextEditingController();
  final _pilotIlController = TextEditingController();
  final _pilotIlceController = TextEditingController();
  final _pilotLisansNoController = TextEditingController();

  // --- CRUD İŞLEMLERİ ---

  void droneEkle() async {
    if (_markaController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _ucretController.text.isEmpty ||
        _droneGerekenLisansController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen zorunlu drone alanlarını doldurun!"),
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
        'gereken_lisans_seviyesi': int.parse(
          _droneGerekenLisansController.text.trim(),
        ),
        'durum': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Drone başarıyla eklendi!"),
          backgroundColor: Colors.green,
        ),
      );
      _markaController.clear();
      _modelController.clear();
      _ucretController.clear();
      _fotoController.clear();
      _droneGerekenLisansController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void pilotEkle() async {
    if (_pilotIsimController.text.isEmpty ||
        _pilotLisansAdController.text.isEmpty ||
        _pilotLisansSeviyeController.text.isEmpty ||
        _pilotUcretController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen temel pilot alanlarını doldurun!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('pilotlar').add({
        'isim': _pilotIsimController.text.trim(),
        'lisans': _pilotLisansAdController.text.trim(),
        'lisans_seviyesi': int.parse(_pilotLisansSeviyeController.text.trim()),
        'gunluk_ucret': int.parse(_pilotUcretController.text.trim()),
        'foto_url': _pilotFotoController.text.trim(),
        'il': _pilotIlController.text.trim().isEmpty
            ? "Konya"
            : _pilotIlController.text.trim(),
        'ilce': _pilotIlceController.text.trim().isEmpty
            ? "Selçuklu"
            : _pilotIlceController.text.trim(),
        'lisans_no': _pilotLisansNoController.text.trim().isEmpty
            ? "TR-PIL-9999"
            : _pilotLisansNoController.text.trim(),
        'durum': true,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilot başarıyla sisteme eklendi!"),
          backgroundColor: Colors.teal,
        ),
      );
      _pilotIsimController.clear();
      _pilotLisansAdController.clear();
      _pilotLisansSeviyeController.clear();
      _pilotUcretController.clear();
      _pilotFotoController.clear();
      _pilotIlController.clear();
      _pilotIlceController.clear();
      _pilotLisansNoController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void veriSil(String koleksiyonAdi, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection(koleksiyonAdi)
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kayıt sistemden silindi!"),
          backgroundColor: Colors.redAccent,
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

  // --- YENİLENEN TAM GÜNCELLEME DİALOGLARI ---

  void droneGuncelleDialog(String docId, Map<String, dynamic> mevcutVeri) {
    final markaEdit = TextEditingController(text: mevcutVeri['marka']);
    final modelEdit = TextEditingController(text: mevcutVeri['model']);
    final ucretEdit = TextEditingController(
      text: mevcutVeri['gunluk_ucret']?.toString(),
    );
    final seviyeEdit = TextEditingController(
      text: mevcutVeri['gereken_lisans_seviyesi']?.toString(),
    );
    final fotoEdit = TextEditingController(text: mevcutVeri['foto_url']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Drone Düzenle",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: markaEdit,
                decoration: const InputDecoration(labelText: "Marka"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: modelEdit,
                decoration: const InputDecoration(labelText: "Model"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ucretEdit,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Günlük Ücret"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: seviyeEdit,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Gereken Yetki Derecesi (1-4)",
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fotoEdit,
                decoration: const InputDecoration(labelText: "Fotoğraf URL"),
              ),
            ],
          ),
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
                    'marka': markaEdit.text.trim(),
                    'model': modelEdit.text.trim(),
                    'gunluk_ucret': int.parse(ucretEdit.text.trim()),
                    'gereken_lisans_seviyesi': int.parse(
                      seviyeEdit.text.trim(),
                    ),
                    'foto_url': fotoEdit.text.trim(),
                  });
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Değişiklikleri Kaydet"),
          ),
        ],
      ),
    );
  }

  void pilotGuncelleDialog(String docId, Map<String, dynamic> mevcutVeri) {
    final isimEdit = TextEditingController(text: mevcutVeri['isim']);
    final lisansAdEdit = TextEditingController(text: mevcutVeri['lisans']);
    final seviyeEdit = TextEditingController(
      text: mevcutVeri['lisans_seviyesi']?.toString(),
    );
    final lisansNoEdit = TextEditingController(text: mevcutVeri['lisans_no']);
    final ilEdit = TextEditingController(text: mevcutVeri['il']);
    final ilceEdit = TextEditingController(text: mevcutVeri['ilce']);
    final ucretEdit = TextEditingController(
      text: mevcutVeri['gunluk_ucret']?.toString(),
    );
    final fotoEdit = TextEditingController(text: mevcutVeri['foto_url']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Pilot Bilgilerini Düzenle",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: isimEdit,
                decoration: const InputDecoration(labelText: "Ad Soyadı"),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: lisansAdEdit,
                      decoration: const InputDecoration(
                        labelText: "Sınıf (Örn: İHA-3)",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: seviyeEdit,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Derece (1-4)",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lisansNoEdit,
                decoration: const InputDecoration(labelText: "Lisans Numarası"),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ilEdit,
                      decoration: const InputDecoration(labelText: "İl"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ilceEdit,
                      decoration: const InputDecoration(labelText: "İlçe"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ucretEdit,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Günlük Ücret"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fotoEdit,
                decoration: const InputDecoration(labelText: "Fotoğraf URL"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('pilotlar')
                  .doc(docId)
                  .update({
                    'isim': isimEdit.text.trim(),
                    'lisans': lisansAdEdit.text.trim(),
                    'lisans_seviyesi': int.parse(seviyeEdit.text.trim()),
                    'lisans_no': lisansNoEdit.text.trim(),
                    'il': ilEdit.text.trim(),
                    'ilce': ilceEdit.text.trim(),
                    'gunluk_ucret': int.parse(ucretEdit.text.trim()),
                    'foto_url': fotoEdit.text.trim(),
                  });
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Değişiklikleri Kaydet"),
          ),
        ],
      ),
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
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    // FORMLAR KISMI
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DRONE FORMU
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
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _modelController,
                                    decoration: InputDecoration(
                                      labelText:
                                          "Drone Modeli (Örn: Matrix 300)",
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
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _droneGerekenLisansController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText:
                                          "Gereken Pilot Yetki Derecesi (1:İHA-0, 4:İHA-3)",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _fotoController,
                                    decoration: InputDecoration(
                                      labelText: "Fotoğraf Linki (URL)",
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
                                      label: const Text("Drone'u Kaydet"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // PİLOT FORMU
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
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _pilotLisansAdController,
                                          decoration: InputDecoration(
                                            labelText: "Sınıf (Örn: İHA-3)",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              _pilotLisansSeviyeController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: "Derece (1-4)",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _pilotLisansNoController,
                                    decoration: InputDecoration(
                                      labelText:
                                          "Lisans Numarası (Örn: TR-PIL-5544)",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _pilotIlController,
                                          decoration: InputDecoration(
                                            labelText: "Şehir (İl)",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _pilotIlceController,
                                          decoration: InputDecoration(
                                            labelText: "İlçe",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _pilotUcretController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: "Günlük Pilot Ücreti (TL)",
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
                                      label: const Text("Pilotu Kaydet"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                    const SizedBox(height: 24),

                    // YÖNETİM LİSTELERİ KISMI
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DRONE LİSTESİ VE DÜZENLEME
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Drone Modelleri ve Yönetimi",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const Divider(),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('dronelar')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return const LinearProgressIndicator();
                                      final docs = snapshot.data!.docs;
                                      if (docs.isEmpty)
                                        return const Text(
                                          "Sistemde drone yok.",
                                        );
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: docs.length,
                                        itemBuilder: (context, index) {
                                          var data =
                                              docs[index].data()
                                                  as Map<String, dynamic>;
                                          String id = docs[index].id;
                                          String seviye =
                                              data['gereken_lisans_seviyesi']
                                                  ?.toString() ??
                                              "null";
                                          return ListTile(
                                            title: Text(
                                              "${data['marka']} ${data['model']}",
                                            ),
                                            subtitle: Text(
                                              "${data['gunluk_ucret']} TL/Gün - (Seviye: $seviye)",
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.orange,
                                                  ),
                                                  onPressed: () =>
                                                      droneGuncelleDialog(
                                                        id,
                                                        data,
                                                      ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      veriSil('dronelar', id),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // PİLOT LİSTESİ VE DÜZENLEME
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Kayıtlı Pilotlar ve Yönetimi",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const Divider(),
                                  StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('pilotlar')
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData)
                                        return const LinearProgressIndicator();
                                      final docs = snapshot.data!.docs;
                                      if (docs.isEmpty)
                                        return const Text(
                                          "Sistemde pilot yok.",
                                        );
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: docs.length,
                                        itemBuilder: (context, index) {
                                          var data =
                                              docs[index].data()
                                                  as Map<String, dynamic>;
                                          String id = docs[index].id;
                                          String lvl =
                                              data['lisans_seviyesi']
                                                  ?.toString() ??
                                              "null";
                                          return ListTile(
                                            title: Text(
                                              data['isim'] ?? "Pilot",
                                            ),
                                            subtitle: Text(
                                              "${data['gunluk_ucret']} TL/Gün - Seviye: $lvl",
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.orange,
                                                  ),
                                                  onPressed: () =>
                                                      pilotGuncelleDialog(
                                                        id,
                                                        data,
                                                      ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      veriSil('pilotlar', id),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // REZERVASYON GEÇMİŞİ
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.history_toggle_off_rounded,
                                  color: Colors.deepOrange,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Genel Kiralama ve Rezervasyon Geçmişi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('rezervasyonlar')
                                  .orderBy('tarih', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData)
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                final docs = snapshot.data!.docs;
                                if (docs.isEmpty)
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Henüz bir kiralama geçmişi bulunmuyor.",
                                      ),
                                    ),
                                  );

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    var veri =
                                        docs[index].data()
                                            as Map<String, dynamic>;
                                    String tur =
                                        veri['kiralanan_tur'] ?? "Hizmet";
                                    String isim = tur == 'Drone'
                                        ? (veri['drone_model'] ?? "Model")
                                        : (veri['pilot_isim'] ?? "Pilot");
                                    int maliyet = veri['toplam_maliyet'] ?? 0;
                                    String durum = veri['durum'] ?? "Beklemede";

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: durum == 'Ödendi'
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,
                                        child: Icon(
                                          tur == 'Drone'
                                              ? Icons.flight
                                              : Icons.person,
                                          color: durum == 'Ödendi'
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      title: Text("$isim ($tur Kiralama)"),
                                      subtitle: Text("Maliyet: $maliyet TL"),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: durum == 'Ödendi'
                                              ? Colors.green
                                              : Colors.orange,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          durum,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
