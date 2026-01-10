import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'screens/login_screen.dart'; 
import 'screens/landing_page.dart'; 

void main() {
  // Bu satır, uygulama çalışmadan önce Flutter motorunun ve 
  // widget bağlayıcılarının hazır olduğundan emin olur.
  WidgetsFlutterBinding.ensureInitialized(); 

  runApp(const TahlilUygulamasi());
}

class TahlilUygulamasi extends StatelessWidget {
  const TahlilUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Tahlil Takip Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Web ise LandingPage, Emülatör (Mobil) ise Giriş Ekranı açılır.
      home: kIsWeb ? const LandingPage() : const GirisEkrani(),
    );
  }
}