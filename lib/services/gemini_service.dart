import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = "AIzaSyA4bk6ldx1e1e0-NMfykDun6L8c4c6t58E";

  static Future<String> getAIResponse({
    required String userMessage,
    required Map<String, dynamic> userData,
    required List<Map<String, String>> chatHistory,
  }) async {
    try {
      final url = "https://text.pollinations.ai/";

      String prompt = """
You are BudgetBee Assistant, an expert AI financial advisor inside the BudgetBee app.
Rules:
1. Provide accurate, descriptive financial advice tailored to the user's data.
2. Always present information in a highly readable, structured Markdown format (use bullet points, bold text).
3. If asked for ideas (saving/investing), provide at least 5 distinct and practical options with realistic links (e.g., [Groww](https://groww.in/)).
4. DO NOT provide generic definitions. Focus purely on actionable advice based on their data.

[User Financial Context]
Balance: ₹${userData['balance']} | Income: ₹${userData['income']} | Expenses: ₹${userData['expenses']} | Savings: ₹${userData['savings']}
Recent Transactions: ${userData['transactions']}

Here is the user's question:
$userMessage
""";

      List<Map<String, dynamic>> messages = [
        {"role": "system", "content": "You are BudgetBee Assistant, a precise, descriptive, and fast financial advisor."},
      ];

      // Keep only last 4 messages to save context limit and increase speed
      int startIdx = chatHistory.length > 4 ? chatHistory.length - 4 : 0;
      for (int i = startIdx; i < chatHistory.length - 1; i++) {
        if (chatHistory[i]["text"] != "Typing...") {
          messages.add({
            "role": chatHistory[i]["role"] == "bot" ? "assistant" : "user",
            "content": chatHistory[i]["text"],
          });
        }
      }

      messages.add({"role": "user", "content": prompt});

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "messages": messages,
          "model": "searchgpt" // searchgpt often yields longer descriptive but fast results on Pollinations
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        // Pollinations returns raw text, no json parsing needed
        String reply = response.body;
        
        // 🔥 Remove Pollinations advertisement if present
        int adIndex = reply.indexOf("Support Pollinations");
        if (adIndex != -1) {
          reply = reply.substring(0, adIndex).trim();
        }
        adIndex = reply.indexOf("🌸 Ad 🌸");
        if (adIndex != -1) {
          reply = reply.substring(0, adIndex).trim();
        }
        adIndex = reply.indexOf("Powered by Pollinations");
        if (adIndex != -1) {
          reply = reply.substring(0, adIndex).trim();
        }

        return reply;
      } else {
        return "Failed to get AI response. Status: ${response.statusCode}";
      }
    } catch (e) {
      return "❌ Error: $e";
    }
  }
}