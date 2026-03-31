import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'gemini_service.dart';

class OCRService {
  static Future<Map<String, dynamic>?> scanReceipt(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      await textRecognizer.close();

      String rawText = recognizedText.text;
      
      if (rawText.trim().isEmpty) {
        return null;
      }

      // Now pass the unstructured raw text to Gemini to parse into a clean JSON output
      final structuredData = await GeminiService.parseReceipt(rawText);
      return structuredData;
    } catch (e) {
      print("Error in OCR Scan: $e");
      return null;
    }
  }
}
