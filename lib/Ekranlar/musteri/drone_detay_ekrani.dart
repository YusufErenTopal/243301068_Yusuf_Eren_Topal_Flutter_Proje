import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DroneDetayEkrani extends StatelessWidget {
  final String droneId;
  final Map<String, dynamic> droneData;
  final String kullaniciUid;

  const DroneDetayEkrani({
    super.key,
    required this.droneId,
    required this.droneData,
    required this.kullaniciUid,
  });

  void droneKiralala(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('dronelar')
          .doc(droneId)
          .update({'durum': false});

      await FirebaseFirestore.instance.collection('rezervasyonlar').add({
        'drone_id': droneId,
        'kullanici_id': kullaniciUid,
        'drone_model': "${droneData['marka']} ${droneData['model']}",
        'toplam_maliyet': droneData['gunluk_ucret'],
        'tarih': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('loglar').add({
        'kullanici_id': kullaniciUid,
        'islem':
            'Drone Kiralandı (Model: ${droneData['marka']} ${droneData['model']})',
        'tarih': FieldValue.serverTimestamp(),
      }); // [cite: 22]

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kiralama talebi başarıyla oluşturuldu! 🎉"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${droneData['marka']} Detayı")),
      body: Column(
        children: [
          Image.network(
            droneData['foto_url'],
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Icon(Icons.flight, size: 100),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${droneData['marka']} - ${droneData['model']}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Günlük Ücret: ${droneData['gunluk_ucret']} TL",
                  style: const TextStyle(fontSize: 18, color: Colors.blue),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => droneKiralala(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Hemen Kirala"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
