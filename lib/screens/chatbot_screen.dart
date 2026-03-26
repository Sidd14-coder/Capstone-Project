import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart'; // 🔥 url_launcher ADDED
import '../services/gemini_service.dart';
import '../data/user_finance_data.dart';
import '../services/user_service.dart';
import '../globals.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (globalChatMessages.isEmpty) {
      loadWelcomeMessage();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void loadWelcomeMessage() async {
    var user = getUserFromHive();
    String name = "User";

    if (user != null && user['name'] != null) {
      name = user['name'].toString().split(" ")[0]; // first name
    }

    setState(() {
      globalChatMessages.add({
        "role": "bot",
        "text":
            "Hello $name 👋\nI'm your BudgetBee assistant.\n\n1️⃣ Analyze my spending\n2️⃣ Saving tips\n3️⃣ Investment ideas\n4️⃣ Budget advice"
      });
    });
  }

  void sendMessage(String text) async {
    setState(() {
      globalChatMessages.add({"role": "user", "text": text});
      globalChatMessages.add({"role": "bot", "text": "Typing..."}); // 🔥 loading
      controller.clear(); // CRITICAL: Clear immediately
    });
    scrollToBottom();

    final data = await getUserFinanceData();

    String reply = await GeminiService.getAIResponse(
      userMessage: text,
      userData: data,
      chatHistory: globalChatMessages, // 🔥 Passed chat history
    );

    if (mounted) {
      setState(() {
        globalChatMessages.removeLast(); // remove "Typing..."
        globalChatMessages.add({"role": "bot", "text": reply});
      });
      scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F7D5B),
      appBar: AppBar(
        title: const Text("BudgetBee Assistant"),
        backgroundColor: const Color(0xFF2F7D5B),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              children: globalChatMessages.map((msg) {
  return Align(
    alignment: msg["role"] == "user"
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: msg["role"] == "user"
            ? Colors.green
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          msg["role"] == "user"
              ? Text(
                  msg["text"]!,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                )
                : MarkdownBody(
                    data: msg["text"]!,
                    // 🔥 LINK CLICK HANDLER
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        try {
                          await launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
                        } catch (e) {
                          debugPrint("Could not launch $href: $e");
                        }
                      }
                    },
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 16, height: 1.4, color: Colors.black87),
                      a: const TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline), // 🔥 Links made visually clickable
                      strong: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E6F5C)),
                      listBullet: const TextStyle(fontSize: 18, color: Color(0xFF1E6F5C)),
                      h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0D47A1)),
                      h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                      h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
                    ),
                  ),

          // 🔥 ONLY FIRST MESSAGE → SHOW OPTIONS
          if (msg == globalChatMessages.first && msg["role"] == "bot")
            Wrap(
              spacing: 8,
              children: [
                optionButton("Analyze my spending"),
                optionButton("Saving tips"),
                optionButton("Investment ideas"),
                optionButton("Budget advice"),
              ],
            )
        ],
      ),
    ),
  );
}).toList(),
            ),
          ),

          Padding(
  padding: const EdgeInsets.all(10),
  child: Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Ask anything...",
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      CircleAvatar(
        backgroundColor: Colors.green,
        child: IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              sendMessage(controller.text.trim());
            }
          },
        ),
      )
    ],
  ),
)
        ],
      ),
    );
  }

  Widget optionButton(String text) {
  return ElevatedButton(
    onPressed: () {
        sendMessage(text); // 👈 button ka text bhejna hai
},
    child: Text(text),
  );
}

}