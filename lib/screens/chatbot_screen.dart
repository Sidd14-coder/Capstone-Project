import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../data/user_finance_data.dart';
import '../services/user_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController controller = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
void initState() {
  super.initState();
  loadWelcomeMessage();
}

void loadWelcomeMessage() async {
  var user = getUserFromHive();

  String name = "User";

  if (user != null && user['name'] != null) {
    name = user['name'].toString().split(" ")[0]; // first name
  }

  setState(() {
    messages.add({
      "role": "bot",
      "text":
          "Hello $name 👋\nI'm your BudgetBee assistant.\n\n1️⃣ Analyze my spending\n2️⃣ Saving tips\n3️⃣ Investment ideas\n4️⃣ Budget advice"
    });
  });
}

  void sendMessage(String text) async {
  setState(() {
    messages.add({"role": "user", "text": text});
    messages.add({"role": "bot", "text": "Typing..."}); // 🔥 loading
  });

  final data = await getUserFinanceData();

  String reply = await GeminiService.getAIResponse(
    userMessage: text,
    userData: data,
  );

  setState(() {
    messages.removeLast(); // remove "Typing..."
    messages.add({"role": "bot", "text": reply});
  });

  controller.clear();
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
              padding: const EdgeInsets.all(10),
              children: messages.map((msg) {
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
          Text(msg["text"]!),

          // 🔥 ONLY FIRST MESSAGE → SHOW OPTIONS
          if (msg == messages.first && msg["role"] == "bot")
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