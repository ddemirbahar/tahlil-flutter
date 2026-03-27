import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatEkrani extends StatefulWidget {
  const ChatEkrani({super.key});
  @override
  State<ChatEkrani> createState() => _ChatEkraniState();
}

class _ChatEkraniState extends State<ChatEkrani> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _mesajlar = [
    {"isUser": false, "text": "Merhaba! Ben yapay zeka tahlil asistanın. Sonuçların veya genel sağlık durumun hakkında ne sormak istersin?"}
  ];
  bool _yukleniyor = false;

  static const orangeColor = Color(0xFFEE6C4D);
  static const darkBlueColor = Color(0xFF293241);
  static const coolBg = Color(0xFFF5F7FA);

  void _mesajGonder() async {
    if (_controller.text.trim().isEmpty) return;
    String soru = _controller.text.trim();
    
    setState(() {
      _mesajlar.add({"isUser": true, "text": soru});
      _yukleniyor = true;
      _controller.clear();
    });
    _scrollToBottom();

    String cevap = await ApiServisi.sohbetEt(soru);

    setState(() {
      _mesajlar.add({"isUser": false, "text": cevap});
      _yukleniyor = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: coolBg,
      appBar: AppBar(
        title: const Text("AI Tahlil Danışmanı", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: darkBlueColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mesajlar.length,
              itemBuilder: (context, index) {
                bool isUser = _mesajlar[index]['isUser'];
                return _buildMessageBubble(isUser, _mesajlar[index]['text']);
              },
            ),
          ),
          if (_yukleniyor) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: orangeColor)),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isUser, String text) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? orangeColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15), topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(isUser ? 15 : 0), bottomRight: Radius.circular(isUser ? 0 : 15),
          ),
          // GÜNCELLEME: withValues kullanıldı
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
        ),
        child: Text(text, style: TextStyle(color: isUser ? Colors.white : darkBlueColor, fontSize: 15)),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      // GÜNCELLEME: withValues kullanıldı
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))]
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _mesajGonder(),
                decoration: InputDecoration(
                  hintText: "Tahlillerini sor...",
                  filled: true, fillColor: coolBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _yukleniyor ? null : _mesajGonder,
              child: CircleAvatar(backgroundColor: orangeColor, child: const Icon(Icons.send, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}