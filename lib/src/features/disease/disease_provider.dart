import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

enum DiseaseStatus { initial, picking, analyzing, result, error }

class DiseaseState {
  final DiseaseStatus status;
  final String? imagePath;
  final String? cropName;
  final String? diseaseName;
  final String? symptoms;
  final String? organicRemedy;
  final String? chemicalRemedy;
  final String? prevention;
  final String? errorMessage;
  final String? rawResponse;

  DiseaseState({
    required this.status,
    this.imagePath,
    this.cropName,
    this.diseaseName,
    this.symptoms,
    this.organicRemedy,
    this.chemicalRemedy,
    this.prevention,
    this.errorMessage,
    this.rawResponse,
  });

  factory DiseaseState.initial() => DiseaseState(status: DiseaseStatus.initial);
}

class DiseaseNotifier extends StateNotifier<DiseaseState> {
  DiseaseNotifier() : super(DiseaseState.initial());

  final ImagePicker _picker = ImagePicker();
  String? _workingVisionModel;

  Future<void> _discoverBestVisionModel() async {
    if (_workingVisionModel != null) return;
    try {
      final response = await http.get(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=${AppConfig.geminiApiKey}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List models = data['models'] ?? [];
        var availableModels = models.where((m) {
          final String name = m['name'] ?? '';
          final List methods = m['supportedGenerationMethods'] ?? [];
          bool isStable = !name.contains('robotics') && !name.contains('preview') && !name.contains('experimental');
          return methods.contains('generateContent') && isStable;
        }).toList();

        const priorityOrder = [
          'models/gemini-1.5-flash',
          'models/gemini-1.5-flash-latest',
          'models/gemini-1.5-pro',
        ];

        for (var preferredName in priorityOrder) {
          if (availableModels.any((m) => m['name'] == preferredName)) {
            _workingVisionModel = preferredName;
            return;
          }
        }
        if (availableModels.isNotEmpty) _workingVisionModel = availableModels.first['name'];
      }
    } catch (e) {
      debugPrint('Discovery error: $e');
    }
    _workingVisionModel ??= 'models/gemini-1.5-flash';
  }

  Future<void> pickAndAnalyzeImage(ImageSource source, String language) async {
    try {
      if (!kIsWeb && source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          state = DiseaseState(status: DiseaseStatus.error, errorMessage: 'Camera permission required.');
          return;
        }
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image == null) return;
      state = DiseaseState(status: DiseaseStatus.analyzing, imagePath: image.path);

      await _discoverBestVisionModel();
      await _analyzeWithAI(image, language);
    } catch (e) {
      state = DiseaseState(status: DiseaseStatus.error, errorMessage: 'Capture Error: $e');
    }
  }

  Future<void> _analyzeWithAI(XFile image, String language) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final prompt = language == 'mr' 
        ? "तुम्ही एक तज्ञ शेती शास्त्रज्ञ आहात. या फोटोचे विश्लेषण करा आणि खालील स्वरूपात माहिती द्या:\n"
          "१. पिकाचे नाव: [नाव]\n"
          "२. रोगाचे नाव: [नाव]\n"
          "३. लक्षणे: [प्रमुख लक्षणे]\n"
          "४. सेंद्रिय उपाय: [उपाय यादी]\n"
          "५. रासायनिक उपाय: [औषधांची नावे आणि प्रमाण]\n"
          "६. प्रतिबंधात्मक उपाय: [भविष्यासाठी सल्ला]\n"
          "सूचना: उत्तर देताना प्रत्येक विभागाचे नाव (उदा. 'रोगाचे नाव:') आणि त्याचा क्रमांक (उदा. '२.') स्पष्टपणे लिहा. माहिती अगदी सोप्या मराठीत द्या."
        : "You are an expert Agricultural Scientist. Analyze this image and provide details in the following format:\n"
          "1. Crop Name: [Name]\n"
          "2. Disease Name: [Name]\n"
          "3. Symptoms: [List major symptoms]\n"
          "4. Organic Remedies: [List organic solutions]\n"
          "5. Chemical Remedies: [Medicine names and dosage]\n"
          "6. Prevention: [Advice for future]\n"
          "Ensure you include the labels and numbers (e.g., '2. Disease Name:') exactly as shown.";

      final url = 'https://generativelanguage.googleapis.com/v1beta/$_workingVisionModel:generateContent?key=${AppConfig.geminiApiKey}';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}, {'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image}}]}]
        }),
      ).timeout(const Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text = data['candidates'][0]['content']['parts'][0]['text'];
        
        state = DiseaseState(
          status: DiseaseStatus.result,
          imagePath: image.path,
          cropName: _parseSectionResilient(text, ['पिकाचे नाव:', 'Crop Name:'], ['१.', '1.']),
          diseaseName: _parseSectionResilient(text, ['रोगाचे नाव:', 'Disease Name:'], ['२.', '2.']),
          symptoms: _parseSectionResilient(text, ['लक्षणे:', 'Symptoms:'], ['३.', '3.']),
          organicRemedy: _parseSectionResilient(text, ['सेंद्रिय उपाय:', 'Organic Remedies:'], ['४.', '4.']),
          chemicalRemedy: _parseSectionResilient(text, ['रासायनिक उपाय:', 'Chemical Remedies:'], ['५.', '5.']),
          prevention: _parseSectionResilient(text, ['प्रतिबंधात्मक उपाय:', 'Prevention:'], ['६.', '6.']),
          rawResponse: text,
        );
      } else {
        state = DiseaseState(status: DiseaseStatus.error, errorMessage: 'AI Analysis Failed.');
      }
    } catch (e) {
      state = DiseaseState(status: DiseaseStatus.error, errorMessage: 'Analysis error: $e');
    }
  }

  /// Senior-level resilient parser that handles AI formatting variations
  String _parseSectionResilient(String text, List<String> labels, List<String> numbers) {
    String content = '';
    
    // Clean markdown bolding from AI response
    final cleanText = text.replaceAll('**', '');

    for (var label in labels) {
      if (cleanText.contains(label)) {
        var start = cleanText.indexOf(label) + label.length;
        var end = cleanText.length;
        
        // Potential markers for the next section
        final nextMarkers = [
          '१.', '२.', '३.', '४.', '५.', '६.', 
          '1.', '2.', '3.', '4.', '5.', '6.',
          'पिकाचे नाव:', 'रोगाचे नाव:', 'लक्षणे:', 'सेंद्रिय उपाय:', 'रासायनिक उपाय:', 'प्रतिबंधात्मक उपाय:',
          'Crop Name:', 'Disease Name:', 'Symptoms:', 'Organic Remedies:', 'Chemical Remedies:', 'Prevention:'
        ];

        for (var marker in nextMarkers) {
          var markerIndex = cleanText.indexOf(marker, start);
          if (markerIndex != -1 && markerIndex < end) {
            end = markerIndex;
          }
        }
        
        content = cleanText.substring(start, end).trim();
        if (content.isNotEmpty) return content;
      }
    }

    // Secondary attempt: if labels fail, try extracting by the number sequence
    for (var num in numbers) {
       if (cleanText.contains(num)) {
         var start = cleanText.indexOf(num) + num.length;
         // Try to find the colon after the number
         var colonIndex = cleanText.indexOf(':', start);
         if (colonIndex != -1 && colonIndex - start < 30) {
            start = colonIndex + 1;
         }

         var end = cleanText.length;
         final nextNums = ['१.', '२.', '३.', '४.', '५.', '६.', '1.', '2.', '3.', '4.', '5.', '6.'];
         for (var nextNum in nextNums) {
           var nextNumIndex = cleanText.indexOf(nextNum, start);
           if (nextNumIndex != -1 && nextNumIndex < end) {
             end = nextNumIndex;
           }
         }
         content = cleanText.substring(start, end).trim();
         if (content.isNotEmpty) return content;
       }
    }
    
    return 'माहिती उपलब्ध नाही'; // Fallback for better UX
  }

  void reset() {
    state = DiseaseState.initial();
  }
}

final diseaseProvider = StateNotifierProvider<DiseaseNotifier, DiseaseState>((ref) {
  return DiseaseNotifier();
});
