import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MusteriOdemeEkrani extends StatefulWidget {
  final String uid;
  const MusteriOdemeEkrani({super.key, required this.uid});

  @override
  State<MusteriOdemeEkrani> createState() => _MusteriOdemeEkraniState();
}

class _MusteriOdemeEkraniState extends State<MusteriOdemeEkrani> {
  final _kartNoController = TextEditingController();
  final _sktController = TextEditingController();
  final _cvvController = TextEditingController();

  // YENİ: Sepetten Ürün Çıkarma Fonksiyonu
  void sepettenCikar(String docId, String urunIsim) async {
    try {
      await FirebaseFirestore.instance
          .collection('rezervasyonlar')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$urunIsim sepetinizden kaldırıldı."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void odemeYap(int toplamTutar, List<String> docIds) async {
    if (_kartNoController.text.isEmpty ||
        _sktController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen kart bilgilerini eksiksiz giriniz!"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      for (String id in docIds) {
        await FirebaseFirestore.instance
            .collection('rezervasyonlar')
            .doc(id)
            .update({'durum': 'Ödendi'});
      }

      await FirebaseFirestore.instance.collection('loglar').add({
        'kullanici_id': widget.uid,
        'islem':
            'Yemeksepeti Modülü Üzerinden Ödeme Tamamlandı ($toplamTutar TL)',
        'tarih': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        _kartNoController.clear();
        _sktController.clear();
        _cvvController.clear();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "🎉 Ödeme Başarılı",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Toplam $toplamTutar TL tutarındaki kiralama işleminiz başarıyla onaylanmıştır. Keyifli uçuşlar dileriz!",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Harika"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ödeme Hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rezervasyonlar')
          .where('kullanici_id', isEqualTo: widget.uid)
          .where('durum', isEqualTo: 'Beklemede')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        int toplamSepetTutari = 0;
        List<String> sepetDokumanIds = [];

        for (var doc in docs) {
          final veri = doc.data() as Map<String, dynamic>;
          toplamSepetTutari += (veri['toplam_maliyet'] as int? ?? 0);
          sepetDokumanIds.add(doc.id);
        }

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_basket_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  "Sepetiniz şu an boş.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Text(
                  "Dronelar veya Pilotlar sekmesinden ekleme yapın.",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sepetteki Hizmetler",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // SEPETTEKİ ÖGELERİN LİSTESİ (GÜNCELLENEN KISIM)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final veri = docs[index].data() as Map<String, dynamic>;
                  final String id = docs[index].id;
                  final String isim =
                      veri['drone_model'] ?? veri['pilot_isim'] ?? "Hizmet";
                  final String tur = veri['kiralanan_tur'] ?? "Kiralama";
                  final int maliyet = veri['toplam_maliyet'] ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        tur == 'Drone' ? Icons.flight : Icons.person,
                        color: Colors.blue,
                      ),
                      title: Text(
                        isim,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text("Tür: $tur"),
                      // SAĞ TARAF: FİYAT BİLGİSİ VE SİLME BUTONU
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "$maliyet TL",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => sepettenCikar(
                              id,
                              isim,
                            ), // Çöp kutusuna basınca silecek
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Divider(height: 32),

              // KART GİRİŞ ALANI
              Card(
                color: Colors.blue.shade50,
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
                          Icon(Icons.credit_card, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "Güvenli Kart Ödemesi (Simülasyon)",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _kartNoController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Kart Numarası",
                          hintText: "1234 5678 1234 5678",
                          filled: true,
                          fillColor: Colors.white,
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
                              controller: _sktController,
                              decoration: InputDecoration(
                                labelText: "Son Kul. Tarihi",
                                hintText: "AA/YY",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _cvvController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "CVV",
                                hintText: "123",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // TOPLAM TUTAR BARI VE ÖDEME BUTONU
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ödenecek Toplam Tutar:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$toplamSepetTutari TL",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => odemeYap(toplamSepetTutari, sepetDokumanIds),
                  icon: const Icon(Icons.payment_rounded),
                  label: const Text(
                    "Ödemeyi Tamamla ve Kirala",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
