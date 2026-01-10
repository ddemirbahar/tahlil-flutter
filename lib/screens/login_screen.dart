import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _formKey = GlobalKey<FormState>();

  // --- RENK VE TEMA AYARLARI (BURADAN DEĞİŞTİRİLİR) ---
  static const coolBg = Color(0xFFF5F7FA); // Arka plan
  static const darkText = Color(0xFF293241); // Yazılar
  
  // >>> RENGİ BURADAN DEĞİŞTİRİYORSUN <<<
  // Şu anki: Yumuşak Su Yeşili
  static const anaRenk = Color.fromARGB(255, 246, 151, 67); 

  // Controllerlar
  final TextEditingController _kullaniciAdiController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dogumYiliController = TextEditingController();

  bool _girisModu = true;
  bool _yukleniyor = false;

  // Cinsiyet
  String? _secilenCinsiyet;
  final List<String> _cinsiyetler = ['Erkek', 'Kadın'];

  // Dinamik Hastalık Listesi
  List<String> _hastalikListesi = [];
  final List<String> _secilenHastaliklar = [];
  
  bool _hastaliklarYukleniyor = true; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hastaliklariYukle();
    });
  }

  Future<void> _hastaliklariYukle() async {
    try {
      var liste = await ApiServisi.hastaliklariGetir();
      if (mounted) {
        setState(() {
          _hastalikListesi = liste;
          _hastaliklarYukleniyor = false;
        });
      }
    } catch (e) {
      debugPrint("Hastalık yükleme hatası: $e");
      if (mounted) {
        setState(() {
          _hastaliklarYukleniyor = false;
        });
      }
    }
  }

  void _islemYap() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _yukleniyor = true; });

      if (_girisModu) {
        // --- GİRİŞ YAP ---
        var sonuc = await ApiServisi.girisYap(
          _kullaniciAdiController.text,
          _sifreController.text
        );

        setState(() { _yukleniyor = false; });

        if (!mounted) return;
        if (sonuc['basarili']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AnaSayfa())
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(sonuc['mesaj']), backgroundColor: Colors.red),
          );
        }
      } else {
        // --- KAYIT OL ---
        String hastalikString = _secilenHastaliklar.join(',');

        var sonuc = await ApiServisi.kayitOl(
          username: _kullaniciAdiController.text,
          password: _sifreController.text,
          email: _emailController.text.isEmpty ? null : _emailController.text,
          dogumYili: _dogumYiliController.text.isEmpty ? null : int.tryParse(_dogumYiliController.text),
          cinsiyet: _secilenCinsiyet,
          hastaliklar: hastalikString.isEmpty ? null : hastalikString,
        );

        setState(() { _yukleniyor = false; });

        if (!mounted) return;
        if (sonuc['basarili']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kayıt Başarılı! Giriş yapabilirsiniz."), backgroundColor: Colors.green),
          );
          setState(() {
            _girisModu = true;
            _temizle();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(sonuc['mesaj']), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _temizle() {
    _kullaniciAdiController.clear();
    _sifreController.clear();
    _emailController.clear();
    _dogumYiliController.clear();
    _secilenHastaliklar.clear();
    _secilenCinsiyet = null;
  }

  // Tasarım İçin Ortak Input Stili
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: anaRenk), // İkon rengi anaRenk oldu
      filled: true,
      fillColor: Colors.white, 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
         borderRadius: BorderRadius.circular(12),
         borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: anaRenk, width: 2), // Odak rengi anaRenk oldu
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: coolBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Container(
                decoration: isWeb 
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ]
                    )
                  : null, 
                
                padding: isWeb ? const EdgeInsets.all(40) : EdgeInsets.zero,
                
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- LOGO KISMI ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                             BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0,5))
                          ]
                        ),
                        child: Icon(
                          _girisModu ? Icons.login_rounded : Icons.app_registration_rounded,
                          size: 60,
                          color: anaRenk, // Logo rengi anaRenk oldu
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Text(
                        _girisModu ? "Hoş Geldiniz" : "Hesap Oluştur",
                        style: const TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold, 
                          color: darkText
                        ),
                      ),
                      Text(
                        _girisModu ? "Devam etmek için giriş yapın" : "Tahlil analizi için bilgilerinizi girin",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 30),

                      // --- KULLANICI ADI ---
                      TextFormField(
                        controller: _kullaniciAdiController,
                        decoration: _inputStyle("Kullanıcı Adı", Icons.person),
                        validator: (value) => value!.isEmpty ? "Kullanıcı adı gerekli" : null,
                      ),
                      const SizedBox(height: 16),

                      // --- ŞİFRE ---
                      TextFormField(
                        controller: _sifreController,
                        decoration: _inputStyle("Şifre", Icons.lock),
                        obscureText: true,
                        validator: (value) => value!.isEmpty ? "Şifre gerekli" : null,
                      ),

                      // --- KAYIT MODU İÇİN EK ALANLAR ---
                      if (!_girisModu) ...[
                        const SizedBox(height: 16),
                        // E-posta
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputStyle("E-posta (Opsiyonel)", Icons.email),
                        ),
                        const SizedBox(height: 16),

                        // Doğum Yılı ve Cinsiyet
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dogumYiliController,
                                keyboardType: TextInputType.number,
                                decoration: _inputStyle("D. Yılı", Icons.calendar_today),
                                validator: (val) {
                                  if (val != null && val.isNotEmpty) {
                                    if (int.tryParse(val) == null || val.length != 4) {
                                      return "Hatalı";
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                key: ValueKey(_secilenCinsiyet),
                                initialValue: _secilenCinsiyet,
                                decoration: _inputStyle("Cinsiyet", Icons.people),
                                items: _cinsiyetler.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                onChanged: (val) => setState(() => _secilenCinsiyet = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Hastalıklar
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Hastalıklar",
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.grey[800]
                            )
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _hastaliklarYukleniyor
                              ? const Center(child: CircularProgressIndicator(color: anaRenk))
                              : Scrollbar(
                                  thumbVisibility: true,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: _hastalikListesi.length,
                                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final hastalik = _hastalikListesi[index];
                                      final seciliMi = _secilenHastaliklar.contains(hastalik);
                                      return CheckboxListTile(
                                        title: Text(hastalik, style: const TextStyle(fontSize: 14)),
                                        value: seciliMi,
                                        activeColor: anaRenk, // Checkbox rengi
                                        controlAffinity: ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            if (value == true) {
                                              _secilenHastaliklar.add(hastalik);
                                            } else {
                                              _secilenHastaliklar.remove(hastalik);
                                            }
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // --- BUTON ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _yukleniyor ? null : _islemYap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: anaRenk, // Buton rengi
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shadowColor: anaRenk.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _yukleniyor
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  _girisModu ? "Giriş Yap" : "Kayıt Ol",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // --- GEÇİŞ ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _girisModu ? "Hesabınız yok mu?" : "Zaten hesabınız var mı?",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _girisModu = !_girisModu;
                                _temizle();
                              });
                            },
                            child: Text(
                              _girisModu ? "Kayıt Olun" : "Giriş Yapın",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: anaRenk), // Link rengi
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}