import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = "AIzaSyA4bk6ldx1e1e0-NMfykDun6L8c4c6t58E";

  static Future<String> getAIResponse({
    required String userMessage,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final url =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro-latest:generateContent?key=$apiKey";

      String prompt = """
You are an advanced AI financial advisor.

Rules:
- If savings > 5000 → suggest SIP
- If balance < 10000 → suggest saving
- Suggest 2-3 Indian mutual funds
- Keep answer short

User Data:
Balance: ₹${userData['balance']}
Income: ₹${userData['income']}
Expenses: ₹${userData['expenses']}
Savings: ₹${userData['savings']}

User Question:
$userMessage
""";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      // 👇 YAHAN ADD KARO
print("STATUS CODE: ${response.statusCode}");
print("RESPONSE BODY: ${response.body}");

      final data = jsonDecode(response.body);

      // 🔥 IMPORTANT (safe parsing)
      if (response.statusCode == 200 &&
          data["candidates"] != null &&
          data["candidates"].isNotEmpty) {
        return data["candidates"][0]["content"]["parts"][0]["text"];
      } else {
        return data.toString();
      }
    } catch (e) {
      return "❌ Error: $e";
    }
  }
}