import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyA4bk6ldx1e1e0-NMfykDun6L8c4c6t58E';
  final modelsToTest = ['gemini-1.5-flash', 'gemini-1.0-pro', 'gemini-pro', 'gemini-1.5-pro'];

  for (var model in modelsToTest) {
    try {
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/\$model:generateContent?key=\$apiKey';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": [{"text": "hello"}]}]
        })
      );
      print('Model: \$model => \${response.statusCode}');
      if (response.statusCode != 200) {
        var data = jsonDecode(response.body) as Map<String, dynamic>;
        print('  Error: \${data['error']['message']}');
      } else {
        print('  Success!');
      }
    } catch (e) {
      print('Exception for \$model: \$e');
    }
  }
}
