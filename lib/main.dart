import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Ekran importları (Klasörlerden çekiyoruz)
import 'Ekranlar/auth/giris_ekrani.dart';
import 'Ekranlar/musteri/musteri_ana_ekrani.dart';
import 'Ekranlar/admin/admin_ana_ekrani.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drone Kiralama Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthKontrol(), // [cite: 17]
    );
  }
}

class AuthKontrol extends StatelessWidget {
  const AuthKontrol({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // [cite: 17]
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return RolYonlendirici(uid: snapshot.data!.uid);
        }
        return const GirisEkrani();
      },
    );
  }
}

class RolYonlendirici extends StatelessWidget {
  final String uid;
  const RolYonlendirici({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('kullanicilar')
          .doc(uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String rol = data['rol'] ?? 'Müşteri'; // [cite: 14]

          if (rol == 'Firma Yetkilisi') {
            return AdminAnaEkrani(uid: uid);
          } else {
            return MusteriAnaEkrani(uid: uid);
          }
        }
        return const GirisEkrani();
      },
    );
  }
}
