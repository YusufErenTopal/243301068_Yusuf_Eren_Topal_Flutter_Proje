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
  String _secilenRol = 'Müşteri'; // Varsayılan rolümüz
  bool _yukleniyor = false;

  void kayitOl() async {
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
      // Senin mevcut kayıt kodun (createUserWithEmailAndPassword...)
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _sifreController.text.trim(),
          );

      // ... Firestore kayıt ve loglama işlemlerin aynen devam ediyor ...
    } on FirebaseAuthException catch (e) {
      // Varsayılan genel bir kayıt hata mesajı belirliyoruz
      String mesaj = "Kayıt oluşturulurken bir hata oluştu.";

      // Eğer bu e-posta adresi zaten sistemde kayıtlıysa:
      if (e.code == 'email-already-in-use') {
        mesaj =
            "Bu e-posta adresi zaten başka bir hesap tarafından kullanılıyor.";
      }
      // Şifre 6 karakterden kısa girildiyse (Firebase alt sınırıdır):
      else if (e.code == 'weak-password') {
        mesaj = "Girdiğiniz şifre çok zayıf. En az 6 karakter olmalıdır.";
      }
      // E-posta formatı tamamen hatalıysa (Örn: sadece "abc" yazdıysa):
      else if (e.code == 'invalid-email') {
        mesaj = "Lütfen geçerli bir e-posta adresi biçimi giriniz.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mesaj),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior
              .floating, // Giriş ekranıyla aynı şık yapıda dursun
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sistem Hatası: $e"),
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // KATMAN 1: ARKA PLAN
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                //yine aynı şekilde internet üzerinden arka planın fotoğrafının aktarıldığı bölüm
                image: NetworkImage(
                  'https://png.pngtree.com/thumb_back/fh260/background/20230716/pngtree-realistic-3d-rendering-of-speeding-clouds-against-a-blue-sky-background-image_3870197.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.35)),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
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
                              Icons.person_add_alt_1_outlined,
                              size: 40,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Yeni Hesap Oluştur",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),

                          //E-posta kısmı
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

                          // Şifre kısmı
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

                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<String>(
                              segments: const <ButtonSegment<String>>[
                                ButtonSegment<String>(
                                  value: 'Müşteri',
                                  label: Text('Müşteri'),
                                  icon: Icon(Icons.person_outline),
                                ),
                                ButtonSegment<String>(
                                  value: 'Firma Yetkilisi',
                                  label: Text('Yetkili'),
                                  icon: Icon(
                                    Icons.admin_panel_settings_outlined,
                                  ),
                                ),
                              ],
                              selected: <String>{_secilenRol},
                              onSelectionChanged: (Set<String> yeniSecim) {
                                setState(() {
                                  _secilenRol = yeniSecim.first;
                                });
                              },
                              style: SegmentedButton.styleFrom(
                                backgroundColor: Colors.white,
                                selectedBackgroundColor: Colors.blue.shade600,
                                selectedForegroundColor: Colors.white,
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Kayıt olma butonu
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _yukleniyor ? null : kayitOl,
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
                                      "Kayıt Ol ve Tamamla",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          //Ana ekrana hesabım var diyerek dönmemizi sağlayam kısım
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Zaten hesabım var? Giriş Yap",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
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

          //sol üstteki geri dön butonu yerine < butonuna dönüştüğü kısım
          Positioned(
            top: 20,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
