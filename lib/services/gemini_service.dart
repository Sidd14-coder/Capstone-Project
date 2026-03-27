import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = "AIzaSyBewUXvu02itnnUM-Llur2uUSATzEffmuU";

  static Future<String> getAIResponse({
    required String userMessage,
    required Map<String, dynamic> userData,
    required List<Map<String, String>> chatHistory,
  }) async {
    try {
      final String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

      String systemInstruction = """
You are BudgetBee Assistant, an expert AI financial advisor inside the BudgetBee app.
Rules:
1. Provide accurate, descriptive financial advice tailored to the user's data.
2. STRICTLY NO TABLES. NEVER create markdown tables. Your response MUST be formatted using only Bold text (**) for headings and Bullet points (-, *) for details.
3. If asked for ideas (saving/investing), provide at least 5 distinct and practical options.
4. ONLY provide real, verified website links (e.g., [Groww](https://groww.in/), [Zerodha](https://zerodha.com/), [Upstox](https://upstox.com/), [SBI](https://www.sbi.co.in/)). NEVER hallucinate or invent fake URLs. If you don't know the exact real homepage link, do NOT provide a link.
5. DO NOT provide generic definitions. Focus purely on actionable advice based on their data.

[User Financial Context]
Balance: ₹${userData['balance']} | Income: ₹${userData['income']} | Expenses: ₹${userData['expenses']} | Savings: ₹${userData['savings']}
Recent Transactions: ${userData['transactions']}
""";

      List<Map<String, dynamic>> contents = [];

      int startIdx = chatHistory.length > 4 ? chatHistory.length - 4 : 0;
      for (int i = startIdx; i < chatHistory.length - 1; i++) {
        if (chatHistory[i]["text"] != "Typing...") {
          contents.add({
            "role": chatHistory[i]["role"] == "bot" ? "model" : "user",
            "parts": [{"text": chatHistory[i]["text"] ?? ""}],
          });
        }
      }

      contents.add({
        "role": "user",
        "parts": [{"text": "System Instructions:\n$systemInstruction\n\nHere is the user's question:\n$userMessage"}],
      });

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": contents,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        return "I am unable to provide a response at this time.";
      } else {
        return "Failed to get AI response. Status: ${response.statusCode}";
      }
    } catch (e) {
      return "❌ Error: $e";
    }
  }
}