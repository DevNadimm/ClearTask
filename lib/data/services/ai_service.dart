import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:clear_task/data/models/day_plan_model.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class NoInternetException implements Exception {
  final String message;
  const NoInternetException([this.message = 'No internet connection.']);
  @override
  String toString() => message;
}

class AiServiceException implements Exception {
  final String message;
  const AiServiceException(this.message);
  @override
  String toString() => message;
}

class AiService {
  static final String _apiKey1 = dotenv.env['GEMINI_API_KEY_1'] ?? '';
  static final String _apiKey2 = dotenv.env['GEMINI_API_KEY_2'] ?? '';
  static final String _apiKey3 = dotenv.env['GEMINI_API_KEY_3'] ?? '';
  static final List<String> _geminiKeys = [_apiKey1, _apiKey2, _apiKey3];
  static final _random = Random();

  static final String _groqApiKey = dotenv.env['GROQ_API_KEY_1'] ?? '';

  static bool _isValidTitle(String title) {
    final trimmed = title.trim();

    if (trimmed.length < 3) return false;
    if (trimmed.split('').toSet().length == 1) return false;

    final hasVowelOrSpace = RegExp(r'[aeiouAEIOU\s]').hasMatch(trimmed);

    if (!hasVowelOrSpace) return false;
    if (RegExp(r'^\d+$').hasMatch(trimmed)) return false;
    if (RegExp(r'^[^a-zA-Z0-9]+$').hasMatch(trimmed)) return false;

    return true;
  }

  static Future<void> _checkInternet() async {
    final result = await Connectivity().checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      throw const NoInternetException(
        'No internet connection. Please check your Wi-Fi or mobile data.',
      );
    }

    try {
      final lookup = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      if (lookup.isEmpty || lookup.first.rawAddress.isEmpty) {
        throw const NoInternetException(
          'Internet is not reachable. Please check your connection.',
        );
      }
    } on SocketException {
      throw const NoInternetException(
        'Internet is not reachable. Please check your connection.',
      );
    } on Exception {
      throw const NoInternetException(
        'Connection timed out. Please try again.',
      );
    }
  }

  static GenerativeModel get _model {
    if (_geminiKeys.every((k) => k.isEmpty)) {
      throw const AiServiceException(
        'AI service is not configured. Please contact support.',
      );
    }
    final validKeys = _geminiKeys.where((k) => k.isNotEmpty).toList();
    final apiKey = validKeys[_random.nextInt(validKeys.length)];
    return GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  static String _groqUserFriendlyError(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'AI service authentication failed. Please contact support.';
      case 403:
        return 'AI service access denied. Please contact support.';
      case 429:
        return 'AI service is busy right now. Please try again in a moment.';
      case 500:
      case 502:
      case 503:
        return 'AI service is temporarily unavailable. Please try again later.';
      default:
        return 'Something went wrong with the AI service. Please try again.';
    }
  }

  static Future<String> _callGroq(String prompt) async {
    if (_groqApiKey.isEmpty) {
      throw const AiServiceException(
        'AI service is not configured. Please contact support.',
      );
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'max_tokens': 1024,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        print('[AiService] Groq error ${response.statusCode}: ${response.body}');
        throw AiServiceException(_groqUserFriendlyError(response.statusCode));
      }
    } on SocketException catch (e) {
      print('[AiService] Groq socket error: $e');
      throw const NoInternetException(
        'Could not reach AI service. Please check your connection.',
      );
    } on AiServiceException {
      rethrow;
    } on Exception catch (e) {
      print('[AiService] Groq unexpected error: $e');
      throw const AiServiceException(
        'Something went wrong. Please try again.',
      );
    }
  }

  static String _cleanJsonResponse(String text) {
    String clean = text.trim();
    if (clean.startsWith('```json')) {
      clean = clean.substring(7);
    } else if (clean.startsWith('```')) {
      clean = clean.substring(3);
    }
    if (clean.endsWith('```')) clean = clean.substring(0, clean.length - 3);
    return clean.trim();
  }

  static Future<String> _generateWithFallback(String prompt) async {
    await _checkInternet();

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) return text;
      throw const AiServiceException(
        'AI returned an empty response. Please try again.',
      );
    } catch (e) {
      if (e is NoInternetException) rethrow;
      if (e is AiServiceException) rethrow;

      print('[AiService] Gemini failed: $e — falling back to Groq');

      try {
        return await _callGroq(prompt);
      } on NoInternetException {
        rethrow;
      } on AiServiceException {
        rethrow;
      } on Exception catch (e) {
        print('[AiService] Groq also failed: $e');
        throw const AiServiceException(
          'AI service is currently unavailable. Please try again later.',
        );
      }
    }
  }

  static Future<List<String>> generateSubtasks({
    required String title,
    String? taskType,
    String? note,
  }) async {
    if (!_isValidTitle(title)) {
      throw const AiServiceException(
        'Please provide a valid task title to generate subtasks.',
      );
    }

    final List<String> contextParts = ['Task: "$title"'];
    if (taskType != null && taskType.isNotEmpty) {
      contextParts.add('Category: $taskType');
    }
    if (note != null && note.isNotEmpty) {
      contextParts.add('Description/Note: "$note"');
    }

    final prompt = '''
Break down the following task into 3 to 5 simple, actionable subtasks.
Return ONLY a valid JSON array of strings, no markdown, no code blocks.

${contextParts.join('\n')}
''';

    try {
      final text = await _generateWithFallback(prompt);
      final cleanText = _cleanJsonResponse(text);
      final List<dynamic> decoded = jsonDecode(cleanText);
      return decoded.map((s) => s.toString()).toList();
    } on NoInternetException {
      rethrow;
    } on AiServiceException {
      rethrow;
    } on Exception catch (e) {
      print('[AiService] Subtask parse error: $e');
      throw const AiServiceException(
        'Failed to generate subtasks. Please try again.',
      );
    }
  }

  static Future<DayPlan> planMyDay(List<Task> pendingTasks) async {
    if (pendingTasks.isEmpty) {
      return DayPlan(summary: 'No pending tasks to plan.', tasks: []);
    }

    final now = DateTime.now();
    final hour = now.hour;
    final timeString = "${hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)}:${now.minute.toString().padLeft(2, '0')} ${hour >= 12 ? 'PM' : 'AM'}";

    final taskList = pendingTasks.map((t) {
      final parts = <String>['"${t.title}"'];
      if (t.note != null && t.note!.isNotEmpty) parts.add('note: "${t.note}"');
      if (t.priority != 'none') parts.add('priority: ${t.priority}');
      if (t.dueDate != null) parts.add('due: ${t.dueDate}');
      if (t.taskType.isNotEmpty) parts.add('category: ${t.taskType}');
      if (t.subtasks.isNotEmpty) {
        final pending = t.subtasks.where((s) => !s.isCompleted).toList();
        if (pending.isNotEmpty) {
          parts.add(
            'pending subtasks: [${pending.map((s) => s.title).join(', ')}]',
          );
        }
      }
      return '- ${parts.join(', ')}';
    }).join('\n');

    final prompt = '''
You are a productivity planner. Current time: $timeString.
Create a smart daily plan for these tasks.

Tasks:
$taskList

Return ONLY a valid JSON object:
{
  "summary": "brief motivational summary",
  "tasks": [
    {
      "title": "Task title",
      "priority": "high/medium/low",
      "timeSlot": "1:00 PM – 2:30 PM",
      "steps": ["Step 1", "Step 2"]
    }
  ]
}
''';

    try {
      final text = await _generateWithFallback(prompt);
      final cleanText = _cleanJsonResponse(text);
      final Map<String, dynamic> decoded = jsonDecode(cleanText);
      return DayPlan.fromJson(decoded);
    } on NoInternetException {
      rethrow;
    } on AiServiceException {
      rethrow;
    } on Exception catch (e) {
      print('[AiService] Plan My Day parse error: $e');
      throw const AiServiceException(
        'Failed to create your day plan. Please try again.',
      );
    }
  }
}
