import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kayit_ekrani.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  bool _yukleniyor = false;

  void girisYap() async {
    if (_emailController.text.isEmpty || _sifreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen tüm alanları doldurun."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _yukleniyor = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _sifreController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('loglar').add({
          'kullanici_id': user.uid,
          'islem': 'Kullanıcı Giriş Yaptı',
          'tarih': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Giriş Hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted)
        setState(() {
          _yukleniyor = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Resmin klavye açılınca yukarı kayıp bozulmasını engelliyor
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                //Giriş ekranının arka plan resminin internet üzerinden çekilmesi
                image: NetworkImage(
                  'https://png.pngtree.com/thumb_back/fh260/background/20210129/pngtree-blue-sky-and-sunshine-image_548401.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    // Kartı hafif şeffaf yaparak arkadaki resmin biraz görünür hale getiriyor
                    color: Colors.white.withOpacity(0.92),
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(
                              Icons.flight_takeoff,
                              size: 40,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Dronium",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Devam etmek için giriş yapın",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // E-POSTA ALANI
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "E-posta",
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ŞİFRE ALANI
                          TextField(
                            controller: _sifreController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: "Şifre",
                              prefixIcon: const Icon(Icons.lock_outline),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // GİRİŞ BUTONU
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _yukleniyor ? null : girisYap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                              ),
                              child: _yukleniyor
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Giriş Yap",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // KAYIT OLMAYA YÖNLENDİRME
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const KayitEkrani(),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                                children: const [
                                  TextSpan(text: "Hesabın yok mu? "),
                                  TextSpan(
                                    text: "Kayıt Ol",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
