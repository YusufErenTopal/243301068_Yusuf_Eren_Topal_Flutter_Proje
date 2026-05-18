import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  String _secilenRol = 'Müşteri'; // [cite: 14]

  void kayitOl() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _sifreController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(userCredential.user!.uid)
          .set({
            'email': _emailController.text.trim(),
            'rol': _secilenRol,
            'kayit_tarihi': FieldValue.serverTimestamp(),
          });

      await FirebaseFirestore.instance.collection('loglar').add({
        'kullanici_id': userCredential.user!.uid,
        'islem': 'Yeni Kullanıcı Kayıt Oldu ($_secilenRol)',
        'tarih': FieldValue.serverTimestamp(),
      }); // [cite: 22]

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Kayıt Hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kayıt Ol")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "E-posta"),
            ),
            TextField(
              controller: _sifreController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Şifre"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _secilenRol,
              items: <String>['Müşteri', 'Firma Yetkilisi'].map((String value) {
                // [cite: 14]
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _secilenRol = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: kayitOl,
              child: const Text("Kayıt Ol ve Tamamla"),
            ),
          ],
        ),
      ),
    );
  }
}
