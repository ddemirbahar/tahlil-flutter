import 'package:flutter/material.dart';
import 'login_screen.dart'; // Giriş ekranı bağlantısı

// Animasyonlar için artık StatefulWidget kullanıyoruz
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

// TickerProviderStateMixin, animasyon kontrolcüleri için gereklidir
class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  // Animasyon Kontrolcüleri
  late final AnimationController _breathingController; // Kan damlası için
  late final AnimationController _floatingController;  // Baloncuklar için

  // Renk Paleti (Sabitler)
  static const orangeColor = Color(0xFFEE6C4D);
  static const darkBlueColor = Color(0xFF293241);
  // İsteğin üzerine güncellenen soğuk/modern beyaz arka plan
  static const coolBg = Color(0xFFF5F7FA); 

  @override
  void initState() {
    super.initState();

    // 1. Nefes Alma Animasyonu (Kan Damlası İçin)
    // 1.5 saniyede bir büyüyüp küçülecek
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0.95, // Normal boyuttan biraz küçük başla
      upperBound: 1.05, // Normal boyuttan biraz büyük bitir
    )..repeat(reverse: true); // Sürekli tekrarla ve geri sar

    // 2. Yüzme Animasyonu (Baloncuklar İçin)
    // 6 saniyede bir yavaşça yukarı aşağı gidecek
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Sayfadan çıkınca animasyonları durdur (Hafıza sızıntısını önler)
    _breathingController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double w = size.width;
    double h = size.height;

    return Scaffold(
      backgroundColor: coolBg,
      body: Stack(
        children: [
          // --- 1. ARKA PLAN DEKORASYONLARI ---
          
          // Sağ Üst Köşe Dalgası
          Positioned(
            top: 0,
            right: 0,
            child: ClipPath(
              clipper: TopRightWaveClipper(),
              child: Container(
                width: w * 0.5,
                height: h * 0.7,
                color: orangeColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          // Sol Alt Köşe Dalgası
          Positioned(
            bottom: 0,
            left: 0,
            child: ClipPath(
              clipper: BottomLeftWaveClipper(),
              child: Container(
                width: w * 0.45,
                height: h * 0.5,
                color: orangeColor.withValues(alpha: 0.1),
              ),
            ),
          ),

          // --- HAREKETLİ BALONCUKLAR ---
          // Artık sabit değiller, _buildAnimatedBubble kullanıyoruz
          _buildAnimatedBubble(
            controller: _floatingController,
            topBase: h * 0.1, leftBase: w * 0.8, size: 50, 
            color: orangeColor.withValues(alpha: 0.1),
            movementRange: 20.0 // 20 piksel yukarı aşağı oynasın
          ),
           _buildAnimatedBubble(
            controller: _floatingController,
            topBase: h * 0.25, leftBase: w * 0.6, size: 30, 
            color: orangeColor.withValues(alpha: 0.08),
            movementRange: -15.0 // Ters yöne 15 piksel oynasın
          ),
           _buildAnimatedBubble(
            controller: _floatingController,
            bottomBase: h * 0.2, leftBase: w * 0.15, size: 70, 
            color: orangeColor.withValues(alpha: 0.05),
            movementRange: 25.0
          ),

          // --- 2. ADAM GÖRSELİ (Arkası Yuvarlaklı) ---
          Positioned(
            right: w * 0.02,
            top: h * 0.05,
            child: Container(
              padding: EdgeInsets.all(h * 0.04), 
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Arka plan rengiyle uyumlu hafif bir ton
                color: orangeColor.withValues(alpha: 0.08), 
              ),
              child: Image.asset(
                'assets/main_illustration.png',
                height: h * 0.43,
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) => Icon(Icons.person, size: 200, color: Colors.grey),
              ),
            ),
          ),

          // --- 3. ANA İÇERİK ---
          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A) LOGO
                Row(
                  children: [
                    Image.asset(
                      'assets/app_logo.png',
                      height: h * 0.22, 
                      errorBuilder: (c, o, s) => Icon(Icons.medical_services, size: 50, color: darkBlueColor),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tahlil Takip",
                          style: TextStyle(fontSize: h * 0.045, fontWeight: FontWeight.bold, color: darkBlueColor, height: 1.0),
                        ),
                        Text(
                          "Sistemi",
                          style: TextStyle(fontSize: h * 0.045, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 246, 151, 67), height: 1.0),
                        ),
                      ],
                    )
                  ],
                ),

                SizedBox(height: h * 0.06),

                // B) YAZILAR (Gradient Başlık Eklendi)
                SizedBox(
                  width: w * 0.60, // Biraz daha yer açtım
                  child: Padding(
                    padding: EdgeInsets.only(left: w * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- GRADIENT (RENK GEÇİŞLİ) BAŞLIK ---
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color.fromARGB(255, 246, 151, 67), Color(0xFFFF4757)], // Turuncudan kırmızıya geçiş
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            "Kan Tahlilleriniz,\nKarmaşadan Netliğe!",
                            style: TextStyle(
                              fontSize: h * 0.050,
                              fontWeight: FontWeight.w900,
                              // Gradient'in görünmesi için rengi beyaz yapıyoruz (Maske boyayacak)
                              color: Colors.white, 
                              height: 1.1,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: h * 0.03),
                        
                        Text(
                          "Dağınık e-Nabız PDF'leri unutun. Tüm sonuçlarınızı tek, anlaşılır bir ekranda profesyonelce analiz edin.",
                          style: TextStyle(fontSize: h * 0.025, color: darkBlueColor, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: h * 0.11),

                // C) KARTLAR (Tıklanınca Zıplayan)
                // Artık _buildInfoCard yerine BouncingCard widget'ını kullanıyoruz
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BouncingCard(child: _buildStaticCardContent(icon: Icons.cloud_upload_outlined, title: "Kolay Yükleme", desc: "Tek tıkla yükle", h: h, w: w)),
                    SizedBox(width: w * 0.03),
                    BouncingCard(child: _buildStaticCardContent(icon: Icons.analytics_outlined, title: "Akıllı Analiz", desc: "Referans kontrolü", h: h, w: w)),
                    SizedBox(width: w * 0.03),
                    BouncingCard(child: _buildStaticCardContent(icon: Icons.history_edu_outlined, title: "Geçmiş Takibi", desc: "Değişim grafiği", h: h, w: w)),
                  ],
                ),

                const Spacer(),

                // D) CTA BUTONU
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const GirisEkrani()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 246, 151, 67),
                      padding: EdgeInsets.symmetric(horizontal: w * 0.08, vertical: h * 0.025),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      elevation: 15, // Gölgelendirmeyi artırdım
                      shadowColor: orangeColor.withValues(alpha: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "PDF'lerini Yükle & Başla",
                          style: TextStyle(fontSize: h * 0.025, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        // Hareket hissi veren ok ikonu
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: h * 0.03),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: h * 0.05),
              ],
            ),
          ),

          // --- 4. NEFES ALAN KAN DAMLASI (SOL ALT) ---
          Positioned(
            left: w * 0.01,
            bottom: h * 0.04,
            // AnimatedBuilder ile sarmalayarak kontrolcüye bağlıyoruz
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                // Transform.scale ile büyütüp küçültüyoruz
                return Transform.scale(
                  scale: _breathingController.value, // 0.95 ile 1.05 arası değişen değer
                  alignment: Alignment.bottomCenter, // Alt taraftan büyüsün
                  child: child,
                );
              },
              // Sabit kalacak görsel kısım
              child: Image.asset(
                'assets/running_blood_drop.png',
                height: h * 0.45,
                errorBuilder: (c, o, s) => const Icon(Icons.water_drop, color: Colors.red, size: 100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR ve FONKSİYONLAR ---

  // Hareketli Baloncuk Oluşturucu
  Widget _buildAnimatedBubble({
    required AnimationController controller,
    double? topBase, double? bottomBase, double? leftBase, double? rightBase,
    required double size,
    required Color color,
    required double movementRange, // Ne kadar hareket edeceği
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Sinüs dalgası kullanarak yumuşak bir git-gel hareketi oluşturuyoruz
        double offset = Colors.blue.computeLuminance() * movementRange * controller.value; // Basit bir hareket hesabı
        
        // Eğer üstten pozisyon verilmişse oraya ekle, alttan verilmişse oraya
        double? currentTop = topBase != null ? topBase + offset : null;
        double? currentBottom = bottomBase != null ? bottomBase + offset : null;

        return Positioned(
          top: currentTop,
          bottom: currentBottom,
          left: leftBase,
          right: rightBase,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      },
    );
  }

  // Kartın Statik İçeriği (Eski _buildInfoCard'ın içi)
  Widget _buildStaticCardContent({required IconData icon, required String title, required String desc, required double h, required double w}) {
    return Container(
      width: w * 0.22, // Biraz genişlettim
      height: h * 0.20,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // Köşeleri daha yuvarlak yaptım
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEE6C4D).withValues(alpha: 0.15),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8), // Gölgeyi biraz daha aşağı aldım
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // İkona hafif bir degrade efekti verelim
          ShaderMask(
             shaderCallback: (bounds) => const LinearGradient(
                colors: [orangeColor, Color(0xFFFF8E53)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
            child: Icon(icon, size: h * 0.045, color: Colors.white)
          ),
          SizedBox(height: h * 0.015),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: h * 0.026, fontWeight: FontWeight.bold, color: const Color(0xFF293241)),
          ),
          SizedBox(height: h * 0.008),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: h * 0.022, color: Colors.grey[600]),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// --- YENİ: ZIPLAYAN KART WIDGET'I ---
// Karta tıklandığında küçülüp bırakınca büyüyen efekt
class BouncingCard extends StatefulWidget {
  final Widget child;
  const BouncingCard({super.key, required this.child});

  @override
  State<BouncingCard> createState() => _BouncingCardState();
}

class _BouncingCardState extends State<BouncingCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Basılınca küçült
      onTapDown: (_) => setState(() => _isPressed = true),
      // Bırakılınca veya iptal edilince eski haline getir
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      
      // Animasyonlu ölçeklendirme
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0, // Basılıyken %92 boyutuna in
        duration: const Duration(milliseconds: 150), // Hızlı ve keskin bir geçiş
        curve: Curves.easeInOutBack, // Hafif yaylanma efekti
        child: widget.child,
      ),
    );
  }
}

// --- DALGA ÇİZİCİLER (Aynı kaldı) ---

class TopRightWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0); 
    path.lineTo(size.width, size.height * 0.85);
    var firstControlPoint = Offset(size.width * 0.90, size.height * 0.85);
    var firstEndPoint = Offset(size.width * 0.80, size.height * 0.60);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.70, size.height * 0.30);
    var secondEndPoint = Offset(size.width * 0.45, size.height * 0.35);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    var thirdControlPoint = Offset(size.width * 0.20, size.height * 0.40);
    var thirdEndPoint = Offset(size.width * 0.25, 0); 
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy, thirdEndPoint.dx, thirdEndPoint.dy);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BottomLeftWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height); 
    path.lineTo(0, size.height * 0.25);
    var firstControlPoint = Offset(size.width * 0.10, size.height * 0.25);
    var firstEndPoint = Offset(size.width * 0.20, size.height * 0.50);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.35, size.height * 0.85);
    var secondEndPoint = Offset(size.width * 0.60, size.height * 0.70);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    var thirdControlPoint = Offset(size.width * 0.85, size.height * 0.60);
    var thirdEndPoint = Offset(size.width * 0.75, size.height);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy, thirdEndPoint.dx, thirdEndPoint.dy);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}