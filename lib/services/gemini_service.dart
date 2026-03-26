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
You are "BudgetBee Assistant", an intelligent AI financial advisor integrated directly inside the "BudgetBee" App.

Strict Rules for Response:
1. ANSWER DIRECTLY: If the user asks for transactions, give them the transactions.
2. NO DEFINITIONS: Do NOT explain what a mutual fund or SIP is.
3. FIVE OPTIONS MINIMUM: If asked for SIPs, investments, or saving ideas, you MUST provide at least 5 different options. Make sure they are DIFFERENT from anything you suggested earlier in the chat.
4. FULL INFO & LINKS: Do NOT just give names. For each investment/saving option, explain briefly why it's good, expected ROI, risk level, and ALWAYS provide a realistic Markdown URL link where the user can invest (e.g., [Invest via Groww](https://groww.in), Zerodha, or direct AMC website).
5. FORMATTING: Use strict Markdown. Use **bold** for subheadings and important terms. Use simple bullet points (-). NEVER output ascii lines.
6. CONTEXT: You know their financial data (provided below).

User Data:
Balance: ₹${userData['balance']}
Income: ₹${userData['income']}
Expenses: ₹${userData['expenses']}
Savings: ₹${userData['savings']}

Top 5 Transactions (from BudgetBee App):
${userData['transactions']}

Bank Accounts & Balances:
${userData['bank_details']}

User Question:
$userMessage
""";

      // Reconstruct history to fit Pollinations API schema (system, then user/assistant history, then latest prompt)
      List<Map<String, dynamic>> messages = [
        {"role": "system", "content": "You are a helpful financial advisor. Return your response in markdown format."},
      ];

      // Add recent history (up to last 10 messages) to prevent repeating answers
      int startIdx = chatHistory.length > 10 ? chatHistory.length - 10 : 0;
      for (int i = startIdx; i < chatHistory.length - 1; i++) {
        // Skip typing text or anything that isn't true history
        if (chatHistory[i]["text"] != "Typing...") {
          messages.add({
            "role": chatHistory[i]["role"] == "bot" ? "assistant" : "user",
            "content": chatHistory[i]["text"],
          });
        }
      }

      // Add the current prompt (which includes user specific data padding)
      messages.add({"role": "user", "content": prompt});

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "messages": messages,
          "model": "openai" // Forces usage of fastest available model
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