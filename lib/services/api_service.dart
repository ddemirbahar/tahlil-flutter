import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ApiServisi {
  static var logger = Logger(printer: PrettyPrinter(methodCount: 0));

  // --- CANLI SUNUCU ADRESİ ---
  static String get baseUrl {
    return "https://tahlil-backend.onrender.com";
  }

  static String? aktifKullanici;

  // --- HASTALIK LİSTESİNİ ÇEK ---
  static Future<List<String>> hastaliklariGetir() async {
    try {
      var url = Uri.parse("$baseUrl/diseases");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      }
    } catch (e) {
      logger.e("Hastalık listesi çekilemedi: $e");
    }
    return ["Diyabet", "Tansiyon", "Kolesterol"]; 
  }

  // --- KAYIT OL ---
  static Future<Map<String, dynamic>> kayitOl({
    required String username, 
    required String password,
    String? email,
    int? dogumYili,
    String? cinsiyet,
    String? hastaliklar
  }) async {
    try {
      var url = Uri.parse("$baseUrl/register");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username, 
          "password": password,
          "email": email,
          "dogum_yili": dogumYili,
          "cinsiyet": cinsiyet,
          "hastaliklar": hastaliklar
        }),
      );

      if (response.statusCode == 201) {
        return {'basarili': true, 'mesaj': 'Kayıt Başarılı'};
      } else {
        var body = jsonDecode(response.body);
        return {'basarili': false, 'mesaj': body['hata'] ?? 'Kayıt başarısız'};
      }
    } catch (e) {
      return {'basarili': false, 'mesaj': 'Hata: $e'};
    }
  }

  // --- GİRİŞ YAP ---
  static Future<Map<String, dynamic>> girisYap(String username, String password) async {
    try {
      var url = Uri.parse("$baseUrl/login");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        aktifKullanici = data['username'];
        return {'basarili': true, 'mesaj': 'Giriş Başarılı'};
      } else {
        return {'basarili': false, 'mesaj': 'Hatalı giriş'};
      }
    } catch (e) {
      return {'basarili': false, 'mesaj': 'Sunucu hatası: $e'};
    }
  }

  // --- PDF YÜKLE ---
  static Future<String> pdfYukle(PlatformFile file) async {
    if (aktifKullanici == null) return "Giriş yapılmamış";
    try {
      var uri = Uri.parse("$baseUrl/upload");
      var request = http.MultipartRequest("POST", uri);
      request.fields['username'] = aktifKullanici!;

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));
      } else {
        if (file.path != null) request.files.add(await http.MultipartFile.fromPath('file', file.path!));
      }

      var response = await request.send();
      return response.statusCode == 201 ? "Başarılı" : "Hata: ${response.statusCode}";
    } catch (e) { 
      return "Hata: $e"; 
    }
  }

  // --- KARŞILAŞTIRMA MATRİSİ ---
  static Future<Map<String, dynamic>> karsilastirmaMatrisiniGetir() async {
    if (aktifKullanici == null) return {};
    try {
      var url = Uri.parse("$baseUrl/comparison_matrix?username=$aktifKullanici");
      var response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { logger.e("Matris hatası: $e"); }
    return {};
  }

  // --- PARAMETRE GEÇMİŞİ ---
  static Future<List<TahlilDetayi>> parametreGecmisiniGetir(String parametreAdi) async {
    if (aktifKullanici == null) return [];
    try {
      String guvenliParametreAdi = Uri.encodeComponent(parametreAdi);
      var url = Uri.parse("$baseUrl/results/$guvenliParametreAdi?username=$aktifKullanici");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => TahlilDetayi.fromJson(e)).toList();
      }
    } catch (e) { logger.e("Geçmiş hatası: $e"); }
    return [];
  }

  // --- KULLANICI DETAYLARINI GETİR ---
  static Future<Map<String, dynamic>?> kullaniciBilgileriniGetir() async {
    if (aktifKullanici == null) return null;
    try {
      var url = Uri.parse("$baseUrl/user_info?username=$aktifKullanici");
      var response = await http.get(url);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) { logger.e("Profil bilgisi hatası: $e"); }
    return null;
  }

  // --- VERİ SİLME ---
  static Future<String> pdfVeVeriSil(String tarih) async {
    if (aktifKullanici == null) return "Giriş yapılmamış";
    try {
      var url = Uri.parse("$baseUrl/delete_date?username=$aktifKullanici&date=$tarih");
      var response = await http.delete(url);
      return response.statusCode == 200 ? "Silindi" : "Hata";
    } catch (e) { return "Hata: $e"; }
  }

  // ########################################################
  // --- YENİ EKLENEN KISIM: YAPAY ZEKA SOHBET (RAG) ---
  // ########################################################
  static Future<String> sohbetEt(String soru) async {
    if (aktifKullanici == null) return "Lütfen önce giriş yapın.";
    try {
      var url = Uri.parse("$baseUrl/chat");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": aktifKullanici,
          "soru": soru
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['yanit']; // api.py'den gelen Qwen cevabı
      } else {
        return "Üzgünüm, şu an tahlillerini analiz edemiyorum. (Hata: ${response.statusCode})";
      }
    } catch (e) {
      logger.e("Chat bağlantı hatası: $e");
      return "Sunucuya bağlanılamadı. Lütfen internetinizi kontrol edin.";
    }
  }
}

// --- VERİ MODELİ ---
class TahlilDetayi {
  final DateTime tarih;
  final double deger;
  final String birim;
  final String referans;

  TahlilDetayi({required this.tarih, required this.deger, required this.birim, required this.referans});

  factory TahlilDetayi.fromJson(Map<String, dynamic> json) {
    return TahlilDetayi(
      tarih: DateFormat('dd.MM.yyyy').parse(json['tarih']),
      deger: json['deger'] is double ? json['deger'] : (json['deger'] as int).toDouble(),
      birim: json['birim'],
      referans: json['referans'],
    );
  }
}