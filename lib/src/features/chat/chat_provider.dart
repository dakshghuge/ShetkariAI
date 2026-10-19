import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/app_config.dart';
import '../profile/profile_provider.dart';

class ChatMessage {
  final String role; // 'user' or 'model'
  final String text;
  final DateTime timestamp;

  ChatMessage({required this.role, required this.text, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'role': role,
    'parts': [{'text': text}],
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      role: map['role'],
      text: (map['parts'] as List)[0]['text'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final String? _nickname;
  ChatNotifier(this._nickname) : super([]) {
    _init();
  }

  String? _workingModel;
  bool _isSystemInstructionSupported = false;
  String _apiVersion = 'v1beta'; // Defaulting to v1beta which is more feature-rich
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _init() async {
    await _loadHistoryFromFirestore();
    await _discoverBestModel();
  }

  Future<void> _loadHistoryFromFirestore() async {
    if (_nickname == null || _nickname!.isEmpty) return;
    try {
      final doc = await _db.collection('chats').doc(_nickname).get();
      if (doc.exists) {
        final List<dynamic> historyData = doc.data()?['messages'] ?? [];
        state = historyData.map((m) => ChatMessage.fromMap(m)).toList();
      }
      if (state.isEmpty) {
        state = [
          ChatMessage(
            role: 'model', 
            text: 'नमस्कार! मी तुमचा शेती मित्र. मी तुम्हाला मराठी आणि इंग्रजीमध्ये मदत करू शकतो.'
          )
        ];
      }
    } catch (e) {
      debugPrint('Firestore load error: $e');
    }
  }

  Future<void> _saveHistoryToFirestore() async {
    if (_nickname == null || _nickname!.isEmpty) return;
    try {
      await _db.collection('chats').doc(_nickname).set({
        'nickname': _nickname,
        'messages': state.map((m) => m.toMap()).toList(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save error: $e');
    }
  }

  /// Senior Backend Logic: Complete Discovery and Validation of Authorized Models
  Future<void> _discoverBestModel() async {
    try {
      final response = await http.get(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=${AppConfig.geminiApiKey}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List models = data['models'] ?? [];
        
        // Find models that support generateContent
        final supportedModels = models.where((m) {
          final List methods = m['supportedGenerationMethods'] ?? [];
          return methods.contains('generateContent');
        }).toList();

        if (supportedModels.isEmpty) throw "No supported models found for this API key";

        // Prioritize by capability and cost-efficiency for agriculture
        const priorityOrder = [
          'models/gemini-1.5-flash',
          'models/gemini-1.5-flash-latest',
          'models/gemini-1.5-pro',
          'models/gemini-1.5-pro-latest',
          'models/gemini-pro'
        ];

        for (var name in priorityOrder) {
          if (supportedModels.any((m) => m['name'] == name)) {
            _workingModel = name;
            _isSystemInstructionSupported = name.contains('1.5');
            debugPrint('Senior Dev: Discovered Best Model: $_workingModel');
            return;
          }
        }

        // Final fallback: take the first supported model
        _workingModel = supportedModels.first['name'];
        _isSystemInstructionSupported = _workingModel!.contains('1.5');
      } else {
        debugPrint('Model discovery failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Discovery exception: $e');
    }

    // Default hard-fallback
    _workingModel ??= 'models/gemini-1.5-flash';
    _isSystemInstructionSupported = _workingModel!.contains('1.5');
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: 'user', text: text);
    state = [...state, userMessage];
    _saveHistoryToFirestore();

    try {
      if (_workingModel == null) await _discoverBestModel();

      final url = 'https://generativelanguage.googleapis.com/$_apiVersion/$_workingModel:generateContent?key=${AppConfig.geminiApiKey}';
      
      const systemText = "You are 'Shetkari AI', an expert Indian Agriculture Assistant. "
          "Provide detailed, accurate, scientific, and organic farming advice. "
          "Always respond in the language used by the farmer (Marathi or English). "
          "Be helpful, practical, and empathetic to the farmer's problems.";

      // Build turn-based contents
      // Gemini expects: [{"role": "user", "parts": [{"text": "..."}]}, {"role": "model", "parts": [...]}, ...]
      List<Map<String, dynamic>> contents = [];
      
      // Filter history to fit within context (last 20 messages to be safe)
      final historyToInlude = state.length > 20 ? state.sublist(state.length - 20) : state;

      bool injectSystemInFirstUser = !_isSystemInstructionSupported;

      for (var i = 0; i < historyToInlude.length; i++) {
        final msg = historyToInlude[i];
        String contentText = msg.text;

        if (injectSystemInFirstUser && msg.role == 'user') {
          contentText = "Instructions: $systemText\n\nFarmer Query: $contentText";
          injectSystemInFirstUser = false;
        }

        contents.add({
          'role': msg.role,
          'parts': [{'text': contentText}]
        });
      }

      final body = {
        'contents': contents,
        if (_isSystemInstructionSupported)
          'system_instruction': {
            'parts': [{'text': systemText}]
          },
        'generationConfig': {
          'temperature': 0.75,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 2048,
          'stopSequences': []
        },
        'safetySettings': [
          {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_NONE'},
          {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_NONE'},
          {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_NONE'},
          {'category': 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold': 'BLOCK_NONE'},
        ]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          
          if (candidate['content'] != null && candidate['content']['parts'] != null) {
            final aiResponseText = candidate['content']['parts'][0]['text'];
            state = [...state, ChatMessage(role: 'model', text: aiResponseText)];
            _saveHistoryToFirestore();
            return;
          }
          
          // Check for finishReason
          final finishReason = candidate['finishReason'];
          if (finishReason == 'SAFETY') {
            throw "AI response was blocked due to safety filters. Please try rephrasing your question.";
          }
        }
        throw "Received an empty or malformed response from AI.";
      } else {
        final errorBody = jsonDecode(response.body);
        final message = errorBody['error']?['message'] ?? 'Status Code ${response.statusCode}';
        throw "API Error: $message";
      }
    } catch (e) {
      debugPrint('Chat Error: $e');
      state = [...state, ChatMessage(role: 'model', text: 'क्षमस्व, एक तांत्रिक समस्या आली आहे: $e')];
    }
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final nickname = ref.watch(profileProvider);
  return ChatNotifier(nickname);
});
