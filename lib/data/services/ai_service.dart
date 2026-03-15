import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<List<String>> generateSubtasks(String taskTitle) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API Key is missing. Please add it to your .env file.');
    }

    // Using gemini-2.5-flash as it is supported by the provided API key
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );

    final prompt = '''
Break down the following task into 3 to 5 simple, actionable subtasks. 
Return ONLY a valid JSON array of strings, with no markdown formatting, no code blocks, and no extra text.
Task: "$taskTitle"
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text != null && text.isNotEmpty) {
        // Clean up the text in case Gemini wraps it in markdown blocks despite the prompt
        String cleanText = text.trim();
        if (cleanText.startsWith('```json')) {
          cleanText = cleanText.substring(7);
        } else if (cleanText.startsWith('```')) {
          cleanText = cleanText.substring(3);
        }
        if (cleanText.endsWith('```')) {
          cleanText = cleanText.substring(0, cleanText.length - 3);
        }
        cleanText = cleanText.trim();

        final List<dynamic> decodedList = jsonDecode(cleanText);
        return decodedList.map((str) => str.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to generate subtasks: $e');
    }
  }
}
