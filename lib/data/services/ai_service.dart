import 'dart:convert';
import 'dart:math';
import 'package:clear_task/data/models/day_plan_model.dart';
import 'package:clear_task/data/models/task_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static final String _apiKey1 = dotenv.env['GEMINI_API_KEY_1'] ?? '';
  static final String _apiKey2 = dotenv.env['GEMINI_API_KEY_2'] ?? '';
  static final List<String> _keys = [_apiKey1, _apiKey2];
  static final _random = Random();

  static GenerativeModel get _model {
    if (_keys.any((k) => k.isEmpty)) {
      throw Exception('Gemini API Key is missing.');
    }

    final apiKey = _keys[_random.nextInt(_keys.length)];

    return GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  /// Clean up markdown blocks from Gemini's response.
  static String _cleanJsonResponse(String text) {
    String clean = text.trim();
    if (clean.startsWith('```json')) {
      clean = clean.substring(7);
    } else if (clean.startsWith('```')) {
      clean = clean.substring(3);
    }
    if (clean.endsWith('```')) {
      clean = clean.substring(0, clean.length - 3);
    }
    return clean.trim();
  }

  // ── Subtask generation (existing) ────────────────────────────────────────

  static Future<List<String>> generateSubtasks({
    required String title,
    String? taskType,
    String? note,
  }) async {
    final List<String> contextParts = ['Task: "$title"'];
    if (taskType != null && taskType.isNotEmpty) {
      contextParts.add('Category: $taskType');
    }
    if (note != null && note.isNotEmpty) {
      contextParts.add('Description/Note: "$note"');
    }
    final taskContext = contextParts.join('\n');

    final prompt = '''
Break down the following task into 3 to 5 simple, actionable subtasks. 
Use the extra context (Category and Description) to make the subtasks highly relevant and specific.
Return ONLY a valid JSON array of strings, with no markdown formatting, no code blocks, and no extra text.

$taskContext
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text != null && text.isNotEmpty) {
        final cleanText = _cleanJsonResponse(text);
        final List<dynamic> decodedList = jsonDecode(cleanText);
        return decodedList.map((str) => str.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to generate subtasks: $e');
    }
  }

  // ── Plan My Day (new) ───────────────────────────────────────────────────

  static Future<DayPlan> planMyDay(List<Task> pendingTasks) async {
    if (pendingTasks.isEmpty) {
      return DayPlan(summary: 'No pending tasks to plan.', tasks: []);
    }

    final now = DateTime.now();
    final timeString = "${now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";

    final taskList = pendingTasks.map((t) {
      final parts = <String>['"${t.title}"'];
      if (t.note != null && t.note!.isNotEmpty) parts.add('note: "${t.note}"');
      if (t.priority != 'none') parts.add('priority: ${t.priority}');
      if (t.dueDate != null) parts.add('due: ${t.dueDate}');
      if (t.taskType.isNotEmpty) parts.add('category: ${t.taskType}');
      if (t.subtasks.isNotEmpty) {
        final pendingSubtasks = t.subtasks.where((s) => !s.isCompleted).toList();
        if (pendingSubtasks.isNotEmpty) {
          final subtaskLines = pendingSubtasks.map((s) => s.title).join(', ');
          parts.add('pending subtasks: [$subtaskLines]');
        }
      }
      return '- ${parts.join(', ')}';
    }).join('\n');

    final prompt = '''
You are a productivity planner. The current time is $timeString. Given the following pending tasks, create a smart daily plan starting from the current time.

Tasks:
$taskList

Return ONLY a valid JSON object (no markdown, no code blocks) with this exact structure:
{
  "summary": "A brief 1-2 sentence motivational summary of the day plan",
  "tasks": [
    {
      "title": "Task title",
      "priority": "high" or "medium" or "low",
      "timeSlot": "1:00 PM – 2:30 PM",
      "steps": ["Step 1", "Step 2", "Step 3"]
    }
  ]
}

Rules:
- Assign realistic time slots starting from the current time ($timeString).
- If it is late in the day, schedule the remaining tasks for tomorrow morning.
- Break each task into actionable steps (use provided subtasks or notes if available).
- Order tasks with high-priority first, then by logical flow.
- Keep time slots reasonable (30 min to 2 hours each).
- Be specific and actionable in the steps.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;

      if (text != null && text.isNotEmpty) {
        final cleanText = _cleanJsonResponse(text);
        final Map<String, dynamic> decoded = jsonDecode(cleanText);
        return DayPlan.fromJson(decoded);
      }
      return DayPlan(summary: 'Could not generate a plan.', tasks: []);
    } catch (e) {
      throw Exception('Failed to generate daily plan: $e');
    }
  }
}
