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
  static const coolBg = Color(0xFFF5F7FA); 

  @override
  void initState() {
    super.initState();

    // 1. Nefes Alma Animasyonu
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0.95, 
      upperBound: 1.05, 
    )..repeat(reverse: true); 

    // 2. Yüzme Animasyonu
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double w = size.width;
    double h = size.height;

    // EKRAN KONTROLÜ: 800 pikselden darsa MOBİL kabul ediyoruz
    bool isMobile = w < 800;

    return Scaffold(
      backgroundColor: coolBg,
      body: Stack(
        children: [
          // --- 1. ARKA PLAN DEKORASYONLARI (Aynı Kaldı) ---
          
          // Sağ Üst Köşe Dalgası
          Positioned(
            top: 0, right: 0,
            child: ClipPath(
              clipper: TopRightWaveClipper(),
              child: Container(
                width: w * 0.5, height: h * 0.7,
                color: orangeColor.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          // Sol Alt Köşe Dalgası
          Positioned(
            bottom: 0, left: 0,
            child: ClipPath(
              clipper: BottomLeftWaveClipper(),
              child: Container(
                width: w * 0.45, height: h * 0.5,
                color: orangeColor.withValues(alpha: 0.1),
              ),
            ),
          ),

          // --- HAREKETLİ BALONCUKLAR ---
          _buildAnimatedBubble(
            controller: _floatingController,
            topBase: h * 0.1, leftBase: w * 0.8, size: 50, 
            color: orangeColor.withValues(alpha: 0.1), movementRange: 20.0
          ),
           _buildAnimatedBubble(
            controller: _floatingController,
            topBase: h * 0.25, leftBase: w * 0.6, size: 30, 
            color: orangeColor.withValues(alpha: 0.08), movementRange: -15.0
          ),
           _buildAnimatedBubble(
            controller: _floatingController,
            bottomBase: h * 0.2, leftBase: w * 0.15, size: 70, 
            color: orangeColor.withValues(alpha: 0.05), movementRange: 25.0
          ),

          // --- 2. ADAM GÖRSELİ (Masaüstü için Sağda Sabit) ---
          // Mobildeyken buradaki görseli GİZLİYORUZ (Yazıların içine alacağız)
          if (!isMobile)
            Positioned(
              right: w * 0.02,
              top: h * 0.05,
              child: Container(
                padding: EdgeInsets.all(h * 0.04), 
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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

          // --- 3. ANA İÇERİK (Responsive Yapı) ---
          SafeArea(
            child: SingleChildScrollView( // Mobilde kaydırma özelliği eklendi
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A) LOGO KISMI
                    Row(
                      children: [
                        Image.asset(
                          'assets/app_logo.png',
                          height: isMobile ? 60 : h * 0.15, // Mobilde logo boyutu sabitlendi
                          errorBuilder: (c, o, s) => Icon(Icons.medical_services, size: 50, color: darkBlueColor),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tahlil Takip",
                              style: TextStyle(fontSize: isMobile ? 24 : h * 0.045, fontWeight: FontWeight.bold, color: darkBlueColor, height: 1.0),
                            ),
                            Text(
                              "Sistemi",
                              style: TextStyle(fontSize: isMobile ? 24 : h * 0.045, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 246, 151, 67), height: 1.0),
                            ),
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: isMobile ? 30 : h * 0.06),

                    // B) YAZILAR
                    SizedBox(
                      // Mobilde genişlik %95, Masaüstünde %60
                      width: isMobile ? w * 0.95 : w * 0.60, 
                      child: Padding(
                        padding: EdgeInsets.only(left: isMobile ? 0 : w * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // BAŞLIK
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color.fromARGB(255, 246, 151, 67), Color(0xFFFF4757)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                "Kan Tahlilleriniz,\nKarmaşadan Netliğe!",
                                style: TextStyle(
                                  fontSize: isMobile ? 32 : h * 0.050, // Mobilde font küçültüldü
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white, 
                                  height: 1.1,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: h * 0.03),
                            
                            // AÇIKLAMA
                            Text(
                              "Dağınık e-Nabız PDF'leri unutun. Tüm sonuçlarınızı tek, anlaşılır bir ekranda profesyonelce analiz edin.",
                              style: TextStyle(fontSize: isMobile ? 16 : h * 0.025, color: darkBlueColor, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: isMobile ? 30 : h * 0.05),

                    // ** MOBİL İÇİN RESİM **
                    // Masaüstünde sağda duran resim, mobilde buraya (araya) gelir
                    if (isMobile)
                      Center(
                        child: Container(
                          height: 250,
                          margin: const EdgeInsets.only(bottom: 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: orangeColor.withValues(alpha: 0.08),
                          ),
                          child: Image.asset(
                            'assets/main_illustration.png',
                            fit: BoxFit.contain,
                            errorBuilder: (c, o, s) => const Icon(Icons.person, size: 100, color: Colors.grey),
                          ),
                        ),
                      ),

                    // C) KARTLAR (Responsive)
                    // Mobilde Column (Alt alta), Masaüstünde Row (Yan yana)
                    if (isMobile)
                      Column(
                        children: [
                          _buildCardWrapper(child: _buildStaticCardContent(icon: Icons.cloud_upload_outlined, title: "Kolay Yükleme", desc: "Tek tıkla yükle", fontSize: 14)),
                          const SizedBox(height: 15),
                          _buildCardWrapper(child: _buildStaticCardContent(icon: Icons.analytics_outlined, title: "Akıllı Analiz", desc: "Referans kontrolü", fontSize: 14)),
                          const SizedBox(height: 15),
                          _buildCardWrapper(child: _buildStaticCardContent(icon: Icons.history_edu_outlined, title: "Geçmiş Takibi", desc: "Değişim grafiği", fontSize: 14)),
                        ],
                      )
                    else
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

                    SizedBox(height: isMobile ? 40 : h * 0.11),

                    // D) CTA BUTONU
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const GirisEkrani()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 246, 151, 67),
                          padding: EdgeInsets.symmetric(horizontal: isMobile ? 40 : w * 0.08, vertical: isMobile ? 15 : h * 0.025),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          elevation: 15,
                          shadowColor: orangeColor.withValues(alpha: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "PDF'lerini Yükle & Başla",
                              style: TextStyle(fontSize: isMobile ? 16 : h * 0.025, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: isMobile ? 20 : h * 0.03),
                          ],
                        ),
                      ),
                    ),
                    
                    // Alt tarafta boşluk bırakalım ki mobilde rahat kaydırılsın
                    SizedBox(height: h * 0.1), 
                  ],
                ),
              ),
            ),
          ),

          // --- 4. NEFES ALAN KAN DAMLASI (SOL ALT) ---
          Positioned(
            left: w * 0.01,
            bottom: h * 0.04,
            child: AnimatedBuilder(
              animation: _breathingController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _breathingController.value, 
                  alignment: Alignment.bottomCenter, 
                  child: child,
                );
              },
              child: Image.asset(
                'assets/running_blood_drop.png',
                height: isMobile ? 120 : h * 0.45, // Mobilde boyutunu küçülttük
                errorBuilder: (c, o, s) => const Icon(Icons.water_drop, color: Colors.red, size: 100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR ve FONKSİYONLAR ---

  // Mobilde kartları sarmalamak için yardımcı (Genişlik ayarı)
  Widget _buildCardWrapper({required Widget child}) {
    return SizedBox(
      width: double.infinity, // Mobilde tam genişlik
      child: BouncingCard(child: child),
    );
  }

  Widget _buildAnimatedBubble({
    required AnimationController controller,
    double? topBase, double? bottomBase, double? leftBase, double? rightBase,
    required double size,
    required Color color,
    required double movementRange, 
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double offset = Colors.blue.computeLuminance() * movementRange * controller.value; 
        
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

  // Kart İçeriği (Responsive boyutlandırma eklendi)
  Widget _buildStaticCardContent({
      required IconData icon, 
      required String title, 
      required String desc, 
      double? h, double? w,
      double fontSize = 0 // Font boyutu opsiyonel
    }) {
    
    // Varsayılan boyutlar (Masaüstü için)
    double iconSize = h != null ? h * 0.045 : 30;
    double titleSize = h != null ? h * 0.026 : 18;
    double descSize = h != null ? h * 0.022 : 14;

    return Container(
      width: w != null ? w * 0.22 : null, 
      height: h != null ? h * 0.20 : 120, // Mobilde sabit yükseklik
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), 
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEE6C4D).withValues(alpha: 0.15),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8), 
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
             shaderCallback: (bounds) => const LinearGradient(
                colors: [orangeColor, Color(0xFFFF8E53)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
            child: Icon(icon, size: iconSize, color: Colors.white)
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: const Color(0xFF293241)),
          ),
          const SizedBox(height: 5),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: descSize, color: Colors.grey[600]),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// --- ZIPLAYAN KART ---
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
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0, 
        duration: const Duration(milliseconds: 150), 
        curve: Curves.easeInOutBack, 
        child: widget.child,
      ),
    );
  }
}

// --- DALGA ÇİZİCİLER (Değişmedi) ---
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