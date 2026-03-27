import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart'; // YENİ: Chat ekranı bağlantısı eklendi

// --- YARDIMCI FONKSİYON ---
String referansBol(String text) {
  if (text.length > 10) {
    return "${text.substring(0, 10)}\n${text.substring(10)}";
  }
  return text;
}

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});
  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  static const coolBg = Color(0xFFF5F7FA); 

  Future<Map<String, dynamic>> _matrisFuture = ApiServisi.karsilastirmaMatrisiniGetir();
  Map<String, dynamic>? _kullaniciBilgileri;
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    _profilBilgileriniYukle();
  }

  Future<void> _profilBilgileriniYukle() async {
    var bilgi = await ApiServisi.kullaniciBilgileriniGetir();
    if (mounted) {
      setState(() {
        _kullaniciBilgileri = bilgi;
      });
    }
  }

  void _yenile() {
    setState(() {
      _matrisFuture = ApiServisi.karsilastirmaMatrisiniGetir();
    });
    _profilBilgileriniYukle();
  }

  Future<void> _pdfYukle() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() { _yukleniyor = true; });
      final mesaj = await ApiServisi.pdfYukle(result.files.first);
      setState(() { _yukleniyor = false; });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mesaj),
          backgroundColor: mesaj.startsWith("Hata") ? Colors.red : Colors.green,
        ),
      );
      if (!mesaj.startsWith("Hata")) _yenile();
    }
  }

  Future<void> _tarihSil(String tarih) async {
    bool? onay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Silinsin mi?"),
        content: Text("$tarih tarihli veriyi kaldırmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("SİL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (onay == true) {
      setState(() { _yukleniyor = true; });
      String mesaj = await ApiServisi.pdfVeVeriSil(tarih);
      setState(() { _yukleniyor = false; });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mesaj), backgroundColor: Colors.orange),
      );
      _yenile();
    }
  }

  @override
  Widget build(BuildContext context) {
    double ekranGenisligi = MediaQuery.of(context).size.width;
    bool isWeb = ekranGenisligi > 800;

    String username = _kullaniciBilgileri?['username'] ?? "Kullanıcı";
    String cinsiyet = _kullaniciBilgileri?['cinsiyet'] ?? "-";
    int? dogumYili = _kullaniciBilgileri?['dogum_yili'];
    String yas = dogumYili != null ? (DateTime.now().year - dogumYili).toString() : "-";
    
    String hastalikString = _kullaniciBilgileri?['hastaliklar'] ?? "";
    List<String> hastaliklar = hastalikString.isNotEmpty 
        ? hastalikString.split(',').map((e) => e.trim()).toList() 
        : [];

    return Scaffold(
      backgroundColor: coolBg,
      
      appBar: AppBar(
        toolbarHeight: isWeb ? 100 : 130, 
        backgroundColor: coolBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : "U",
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Merhaba, $username", 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$cinsiyet, $yas Yaşında", 
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])
                  ),
                  if (hastaliklar.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: hastaliklar.map((hastalik) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.1))
                            ),
                            child: Text(
                              hastalik, 
                              style: TextStyle(color: Colors.red[300], fontSize: 11, fontWeight: FontWeight.w500)
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
        
        actions: [
          // ########################################################
          // --- YENİ EKLENEN: YAPAY ZEKA SOHBET BUTONU ---
          // ########################################################
          IconButton(
            icon: const Icon(Icons.psychology_alt_rounded, color: Color(0xFFEE6C4D), size: 30),
            tooltip: "AI Tahlil Danışmanı",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatEkrani()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.grey),
              tooltip: "Çıkış Yap",
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GirisEkrani()),
              ),
            ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_yukleniyor) const LinearProgressIndicator(),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              children: [
                Icon(Icons.analytics_outlined, color: Color(0xFF448AFF)),
                const SizedBox(width: 8),
                const Text(
                  "Tahlillerim",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _matrisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("Henüz veri yok. + butonuna basıp PDF yükleyin.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final List<dynamic> tarihler = snapshot.data!['sutunlar'];
                final List<dynamic> satirlar = snapshot.data!['satirlar'];

                List<DataColumn> tabloSutunlari = [
                  DataColumn(label: Text("Parametre", style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWeb ? 15 : 13))),
                  DataColumn(label: Text("Referans", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: isWeb ? 14 : 12))),
                ];

                for (var t in tarihler) {
                  String hamTarih = t.toString();
                  String formatliTarih = hamTarih;
                  try {
                    DateTime tarihObj = DateTime.parse(hamTarih);
                    formatliTarih = DateFormat('dd.MM\nyyyy').format(tarihObj);
                  } catch (e) {
                    if (hamTarih.contains('.')) {
                      List<String> parcalar = hamTarih.split('.');
                      if (parcalar.length >= 3) {
                         formatliTarih = "${parcalar[0]}.${parcalar[1]}\n${parcalar[2]}";
                      }
                    }
                  }

                  tabloSutunlari.add(DataColumn(
                    label: Tooltip(
                      message: "Silmek için basılı tutun",
                      child: InkWell(
                        onLongPress: () => _tarihSil(hamTarih),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(formatliTarih, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWeb ? 15 : 13)),
                              const SizedBox(width: 4),
                              Icon(Icons.close, size: 10, color: Colors.red.withValues(alpha: 0.3))
                            ],
                          ),
                        ),
                      ),
                    )
                  ));
                }

                List<DataRow> tabloSatirlari = satirlar.map<DataRow>((satir) {
                  return DataRow(
                    onSelectChanged: (selected) => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetaySayfasi(parametreAdi: satir['isim'])),
                    ),
                    cells: [
                      DataCell(Text(satir['isim'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: isWeb ? 14 : 13))),
                      DataCell(Text(referansBol(satir['referans']), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isWeb ? 13 : 11, color: Colors.grey))),
                      ...satir['hucreler'].map<DataCell>((h) => DataCell(
                        Text(
                          h['deger'],
                          style: TextStyle(
                            fontSize: isWeb ? 15 : 13,
                            color: h['riskli'] ? Colors.red : Colors.black,
                            fontWeight: h['riskli'] ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      )).toList()
                    ],
                  );
                }).toList();

                Widget tablo = DataTable(
                  columnSpacing: isWeb ? 40.0 : 12.0,
                  horizontalMargin: isWeb ? 20.0 : 5.0,
                  showCheckboxColumn: false,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 70,
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                  border: isWeb ? TableBorder.all(color: Colors.grey.shade200, width: 0.5) : null,
                  columns: tabloSutunlari,
                  rows: tabloSatirlari,
                );

                if (isWeb) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200)
                        ),
                        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: tablo),
                      ),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: tablo),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pdfYukle,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- DETAY SAYFASI ---
class DetaySayfasi extends StatefulWidget {
  final String parametreAdi;
  const DetaySayfasi({super.key, required this.parametreAdi});
  @override
  State<DetaySayfasi> createState() => _DetaySayfasiState();
}

class _DetaySayfasiState extends State<DetaySayfasi> {
  static const coolBg = Color(0xFFF5F7FA);
  late Future<List<TahlilDetayi>> _gecmisFuture;

  @override
  void initState() {
    super.initState();
    _gecmisFuture = ApiServisi.parametreGecmisiniGetir(widget.parametreAdi);
  }

  (double, double)? _getRefMinMax(String referans) {
    try {
      if (referans.contains('-')) {
        final parts = referans.split('-');
        return (double.parse(parts[0].trim()), double.parse(parts[1].trim()));
      }
    } catch (_) {}
    return null;
  }

  Color _getRiskColor(double deger, String referans) {
    try {
      if (referans.contains('-')) {
        final parts = referans.split('-');
        double min = double.parse(parts[0].trim());
        double max = double.parse(parts[1].trim());
        if (deger < min || deger > max) return Colors.red;
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: coolBg, 
      appBar: AppBar(
        title: Text(widget.parametreAdi),
        backgroundColor: coolBg, 
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: FutureBuilder<List<TahlilDetayi>>(
            future: _gecmisFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final veriler = snapshot.data!;
              if (veriler.isEmpty) return const Center(child: Text("Veri yok"));
              
              double? refMin, refMax;
              for (var v in veriler) {
                var range = _getRefMinMax(v.referans);
                if (range != null) {
                  refMin = range.$1;
                  refMax = range.$2;
                  break; 
                }
              }

              double enYuksekDeger = veriler.map((e) => e.deger).reduce((a, b) => a > b ? a : b);
              double enDusukDeger = veriler.map((e) => e.deger).reduce((a, b) => a < b ? a : b);
              
              double chartMaxY = enYuksekDeger;
              if (refMax != null && refMax > chartMaxY) chartMaxY = refMax;
              chartMaxY = chartMaxY * 1.2;
              
              double chartMinY = enDusukDeger;
              if (refMin != null && refMin < chartMinY) chartMinY = refMin;
              chartMinY = chartMinY * 0.8; 

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                    ),
                    child: Column(
                      children: [
                        const Text("Zaman Grafiği", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        if (refMin != null) 
                          Row(
                            children: [
                              Container(width: 12, height: 12, color: Colors.green.withValues(alpha: 0.2)),
                              const SizedBox(width: 5),
                              Text("Güvenli Aralık ($refMin - $refMax)", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        const SizedBox(height: 10),
                        Container(
                          height: 300,
                          padding: const EdgeInsets.only(right: 20, top: 10),
                          child: LineChart(
                            LineChartData(
                              rangeAnnotations: (refMin != null && refMax != null) ? RangeAnnotations(
                                horizontalRangeAnnotations: [
                                  HorizontalRangeAnnotation(y1: refMin, y2: refMax, color: Colors.green.withValues(alpha: 0.1)),
                                ],
                              ) : null,
                              extraLinesData: (refMin != null && refMax != null) ? ExtraLinesData(
                                horizontalLines: [
                                  HorizontalLine(y: refMin, color: Colors.green.withValues(alpha: 0.6), strokeWidth: 1, dashArray: [5, 5]),
                                  HorizontalLine(y: refMax, color: Colors.green.withValues(alpha: 0.6), strokeWidth: 1, dashArray: [5, 5]),
                                ]
                              ) : null,
                              gridData: FlGridData(show: true, drawVerticalLine: true, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1), getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35, interval: 1, getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index >= 0 && index < veriler.length) {
                                        return SideTitleWidget(meta: meta, space: 8, child: Text(DateFormat('dd/MM').format(veriler[index].tarih), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)));
                                      }
                                      return const SizedBox();
                                    })),
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10, color: Colors.grey)))),
                              ),
                              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                              minX: 0, maxX: (veriler.length - 1).toDouble(), minY: chartMinY > 0 ? 0 : chartMinY, maxY: chartMaxY,
                              lineTouchData: LineTouchData(touchTooltipData: LineTouchTooltipData(getTooltipColor: (touchedSpot) => Colors.blueAccent, getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                    return touchedBarSpots.map((barSpot) {
                                      final veri = veriler[barSpot.x.toInt()];
                                      return LineTooltipItem("${DateFormat('dd.MM.yyyy').format(veri.tarih)}\n", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), children: [
                                          TextSpan(text: "${veri.deger} ${veri.birim}\n", style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.w900, fontSize: 14)),
                                          TextSpan(text: "Ref: ${veri.referans}", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                        ]);
                                    }).toList();
                                  })),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: veriler.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.deger)).toList(),
                                  isCurved: true, color: Colors.blueAccent, barWidth: 4, isStrokeCapRound: true, belowBarData: BarAreaData(show: false),
                                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                                      final veri = veriler[index];
                                      bool riskli = _getRiskColor(veri.deger, veri.referans) == Colors.red;
                                      return FlDotCirclePainter(radius: 6, color: riskli ? Colors.red : Colors.blue, strokeWidth: 2, strokeColor: Colors.white);
                                    }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text("Geçmiş Sonuçlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        DataTable(
                          dataRowMinHeight: 40, dataRowMaxHeight: 70,
                          columns: const [DataColumn(label: Text("Tarih")), DataColumn(label: Text("Değer")), DataColumn(label: Text("Ref"))],
                          rows: veriler.map((v) {
                            bool riskli = _getRiskColor(v.deger, v.referans) == Colors.red;
                            return DataRow(cells: [
                              DataCell(Text(DateFormat('dd.MM\nyyyy').format(v.tarih), textAlign: TextAlign.center)),
                              DataCell(Text(v.deger.toString(), style: TextStyle(color: riskli ? Colors.red : Colors.black, fontWeight: riskli ? FontWeight.bold : FontWeight.normal))),
                              DataCell(Text(referansBol(v.referans), style: const TextStyle(fontSize: 12, color: Colors.grey))),
                            ]);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}