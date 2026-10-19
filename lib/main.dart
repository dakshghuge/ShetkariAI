import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

// Internal feature providers
import 'src/features/chat/chat_provider.dart';
import 'src/features/disease/disease_provider.dart';
import 'src/features/weather/weather_provider.dart';
import 'src/features/market/market_provider.dart';
import 'src/core/localization/language_provider.dart';
import 'src/core/navigation/navigation_provider.dart';
import 'src/features/schemes/schemes_screen.dart';
import 'src/features/profile/profile_provider.dart';
import 'src/features/disease/report_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(const ProviderScope(child: ShetkariAIApp()));
}

class ShetkariAIApp extends ConsumerWidget {
  const ShetkariAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final nickname = ref.watch(profileProvider);
    
    return MaterialApp(
      title: 'Shetkari AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade700,
          secondary: Colors.orange.shade800,
          surface: Colors.green.shade50,
        ),
        useMaterial3: true,
        textTheme: lang == 'mr' ? GoogleFonts.muktaTextTheme() : GoogleFonts.poppinsTextTheme(),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: nickname == null ? const NicknamePromptScreen() : const MainNavigationScreen(),
    );
  }
}

class NicknamePromptScreen extends ConsumerStatefulWidget {
  const NicknamePromptScreen({super.key});

  @override
  ConsumerState<NicknamePromptScreen> createState() => _NicknamePromptScreenState();
}

class _NicknamePromptScreenState extends ConsumerState<NicknamePromptScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final isMarathi = lang == 'mr';

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_pin, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    isMarathi ? 'आपले नाव सांगा' : 'What is your name?',
                    style: GoogleFonts.mukta(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: isMarathi ? 'टोपणनाव' : 'Nickname',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          ref.read(profileProvider.notifier).setNickname(_controller.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isMarathi ? 'पुढे जा' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    final langNotifier = ref.read(languageProvider.notifier);
    final selectedIndex = ref.watch(navigationProvider);
    
    final List<Widget> _screens = [
      const HomeScreen(),
      const AIChatScreen(),
      const DiseaseDetectionScreen(),
      const MarketPricesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: _screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => ref.read(navigationProvider.notifier).setIndex(index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: langNotifier.translate('home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat),
            label: langNotifier.translate('ai_chat'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.camera_alt_outlined),
            selectedIcon: const Icon(Icons.camera_alt),
            label: langNotifier.translate('disease_detection'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.trending_up_outlined),
            selectedIcon: const Icon(Icons.trending_up),
            label: langNotifier.translate('market_prices'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: langNotifier.translate('profile'),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting(WidgetRef ref) {
    final langNotifier = ref.read(languageProvider.notifier);
    var hour = DateTime.now().hour;
    if (hour < 12) return langNotifier.translate('greeting_morning');
    if (hour < 17) return langNotifier.translate('greeting_afternoon');
    return langNotifier.translate('greeting_evening');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherProvider);
    final langNotifier = ref.read(languageProvider.notifier);
    final nickname = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGreeting(ref), style: GoogleFonts.mukta(fontSize: 14, color: Colors.grey.shade700)),
            Text(nickname ?? langNotifier.translate('farmer_friend'), style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none), 
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsScreen()));
            }
          ),
          const CircleAvatar(radius: 18, backgroundColor: Colors.green, child: Icon(Icons.person, color: Colors.white, size: 20)),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            weatherState.when(
              data: (weather) => Column(
                children: [
                  _buildWeatherCard(weather),
                  if (weather.alerts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildAlertCard(ref, weather.alerts.first),
                  ]
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _buildErrorWeatherCard(ref, err.toString()),
            ),
            const SizedBox(height: 24),
            Text(
              langNotifier.translate('popular_services'),
              style: GoogleFonts.mukta(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildServiceCard(context, langNotifier.translate('ask_ai'), Icons.chat_bubble_outline, Colors.blue, () => ref.read(navigationProvider.notifier).setIndex(1)),
                _buildServiceCard(context, langNotifier.translate('identify_disease'), Icons.bug_report_outlined, Colors.orange, () => ref.read(navigationProvider.notifier).setIndex(2)),
                _buildServiceCard(context, langNotifier.translate('market_prices'), Icons.bar_chart, Colors.green, () => ref.read(navigationProvider.notifier).setIndex(3)),
                _buildServiceCard(context, langNotifier.translate('schemes'), Icons.account_balance_outlined, Colors.purple, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SchemesScreen()));
                }),
              ],
            ),
            const SizedBox(height: 24),
            _buildTipsSection(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherData weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(weather.city, style: GoogleFonts.mukta(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${weather.temp.toStringAsFixed(1)}°C', style: GoogleFonts.mukta(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, height: 1.1)),
                    Text(weather.description.toUpperCase(), style: GoogleFonts.mukta(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              Image.network('https://openweathermap.org/img/wn/${weather.icon}@4x.png', height: 100, width: 100, errorBuilder: (context, error, stackTrace) => const Icon(Icons.wb_cloudy, size: 64, color: Colors.white)),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetail(Icons.water_drop, '${weather.humidity}%', 'Humidity'),
              _buildWeatherDetail(Icons.air, '${weather.windSpeed} km/h', 'Wind'),
              _buildWeatherDetail(Icons.update, 'Live', 'Status'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWeatherCard(WidgetRef ref, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red.shade100)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: Check API or Location', style: GoogleFonts.mukta(fontWeight: FontWeight.bold, color: Colors.red))),
              IconButton(icon: const Icon(Icons.refresh, color: Colors.red), onPressed: () => ref.read(weatherProvider.notifier).getWeather())
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String value, String label) {
    return Column(children: [Icon(icon, color: Colors.white70, size: 20), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12))]);
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, size: 32, color: color)), const SizedBox(height: 12), Text(title, style: GoogleFonts.mukta(fontWeight: FontWeight.w600, fontSize: 16))])));
  }

  Widget _buildAlertCard(WidgetRef ref, String alertText) {
    final langNotifier = ref.read(languageProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.shade200)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(langNotifier.translate('important_alert'), style: GoogleFonts.mukta(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                Text(alertText, style: GoogleFonts.mukta(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(WidgetRef ref) {
    final langNotifier = ref.read(languageProvider.notifier);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(langNotifier.translate('today_tip'), style: GoogleFonts.mukta(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Card(clipBehavior: Clip.antiAlias, child: Column(children: [Image.network('https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=500', height: 150, width: double.infinity, fit: BoxFit.cover), Padding(padding: const EdgeInsets.all(12.0), child: Text(ref.watch(languageProvider) == 'mr' ? 'सेंद्रिय खतांचा वापर वाढवून जमिनीचा पोत कसा सुधारावा?' : 'How to improve soil texture by increasing use of organic fertilizers?', style: GoogleFonts.mukta(fontWeight: FontWeight.w500)))]))]);
  }
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider).value;
    final alerts = weather?.alerts ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: alerts.isEmpty 
        ? const Center(child: Text('No notifications'))
        : ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) => ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: Text(alerts[index]),
              subtitle: Text(DateTime.now().toString().split('.')[0]),
            ),
          ),
    );
  }
}

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  void _initTTS() async {
    await _tts.setLanguage(ref.read(languageProvider) == 'mr' ? "mr-IN" : "en-IN");
    await _tts.setPitch(1.0);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: ref.read(languageProvider) == 'mr' ? "mr_IN" : "en_IN",
          onResult: (val) => setState(() {
            _textController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_textController.text.isNotEmpty) {
        _handleSend();
      }
    }
  }

  void _handleSend() {
    if (_textController.text.isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(_textController.text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final langNotifier = ref.read(languageProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(langNotifier.translate('ai_chat'), style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ChatBubble(message: msg, tts: _tts);
              },
            ),
          ),
          _buildInputArea(langNotifier),
        ],
      ),
    );
  }

  Widget _buildInputArea(LanguageNotifier langNotifier) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.green.shade700), onPressed: () => ref.read(diseaseProvider.notifier).pickAndAnalyzeImage(ImageSource.gallery, ref.read(languageProvider))),
            GestureDetector(onLongPress: _listen, onLongPressUp: _listen, child: IconButton(icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.green.shade700), onPressed: _listen)),
            Expanded(child: TextField(controller: _textController, decoration: InputDecoration(hintText: _isListening ? '...' : 'Ask...', hintStyle: GoogleFonts.mukta(color: Colors.grey), filled: true, fillColor: Colors.grey.shade100, border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)), onSubmitted: (_) => _handleSend())),
            const SizedBox(width: 8),
            CircleAvatar(backgroundColor: Colors.green.shade700, child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _handleSend)),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final FlutterTts tts;

  const ChatBubble({super.key, required this.message, required this.tts});

  @override
  Widget build(BuildContext context) {
    final isAI = message.role == 'model';
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: GestureDetector(
        onDoubleTap: () { if (isAI) tts.speak(message.text); },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isAI ? Colors.white : Colors.green.shade700,
            borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isAI ? 0 : 16), bottomRight: Radius.circular(isAI ? 16 : 0)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.text, style: GoogleFonts.mukta(color: isAI ? Colors.black87 : Colors.white, fontSize: 15)),
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [Text('${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}', style: TextStyle(color: isAI ? Colors.grey : Colors.white70, fontSize: 10)), if (isAI) ...[const SizedBox(width: 8), Icon(Icons.volume_up, size: 12, color: Colors.grey.shade400)]]),
            ],
          ),
        ),
      ),
    );
  }
}

class DiseaseDetectionScreen extends ConsumerWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diseaseProvider);
    final langNotifier = ref.read(languageProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(langNotifier.translate('disease_detection'), style: GoogleFonts.mukta(fontWeight: FontWeight.bold)), actions: [if (state.status == DiseaseStatus.result) IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(diseaseProvider.notifier).reset())]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16.0), child: Column(children: [if (state.status == DiseaseStatus.initial) _buildInitialUI(ref), if (state.status == DiseaseStatus.analyzing) _buildAnalyzingUI(), if (state.status == DiseaseStatus.result) _buildResultUI(state, ref), if (state.status == DiseaseStatus.error) Center(child: Column(children: [const Icon(Icons.error_outline, color: Colors.red, size: 48), const SizedBox(height: 16), Text(state.errorMessage ?? 'काहीतरी चूक झाली. पुन्हा प्रयत्न करा.', textAlign: TextAlign.center, style: GoogleFonts.mukta(color: Colors.red)), const SizedBox(height: 16), ElevatedButton(onPressed: () => ref.read(diseaseProvider.notifier).reset(), child: const Text('Back'))]))])),
    );
  }

  Widget _buildInitialUI(WidgetRef ref) {
    final langNotifier = ref.read(languageProvider.notifier);
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(height: 40), Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle), child: Icon(Icons.camera_enhance, size: 80, color: Colors.green.shade700)), const SizedBox(height: 32), Text(langNotifier.translate('identify_disease'), style: GoogleFonts.mukta(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 12), const Text('Our AI will identify the disease and suggest remedies instantly.', textAlign: TextAlign.center), const SizedBox(height: 40), SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => ref.read(diseaseProvider.notifier).pickAndAnalyzeImage(ImageSource.camera, ref.read(languageProvider)), icon: const Icon(Icons.photo_camera), label: const Text('Camera'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white))), const SizedBox(height: 16), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => ref.read(diseaseProvider.notifier).pickAndAnalyzeImage(ImageSource.gallery, ref.read(languageProvider)), icon: const Icon(Icons.photo_library), label: const Text('Gallery'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16))))]);
  }

  Widget _buildAnalyzingUI() {
    return const Column(children: [SizedBox(height: 60), CircularProgressIndicator(), SizedBox(height: 24), Text('AI is analyzing photo...')]);
  }

  Widget _buildResultUI(DiseaseState state, WidgetRef ref) {
    final isMarathi = ref.watch(languageProvider) == 'mr';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: kIsWeb 
            ? Image.network(state.imagePath!, height: 250, width: double.infinity, fit: BoxFit.cover)
            : Image.file(File(state.imagePath!), height: 250, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          isMarathi ? 'पिकाची माहिती' : 'Crop Info',
          Icons.agriculture,
          [
            _buildDetailRow(isMarathi ? 'पीक:' : 'Crop:', state.cropName ?? ''),
            _buildDetailRow(isMarathi ? 'रोग:' : 'Disease:', state.diseaseName ?? ''),
          ],
          Colors.green,
        ),
        _buildInfoCard(
          isMarathi ? 'लक्षणे' : 'Symptoms',
          Icons.bug_report,
          [Text(state.symptoms ?? '', style: GoogleFonts.mukta(fontSize: 15))],
          Colors.orange,
        ),
        _buildInfoCard(
          isMarathi ? 'सेंद्रिय उपाय' : 'Organic Remedies',
          Icons.eco,
          [Text(state.organicRemedy ?? '', style: GoogleFonts.mukta(fontSize: 15))],
          Colors.teal,
        ),
        _buildInfoCard(
          isMarathi ? 'रासायनिक उपाय' : 'Chemical Remedies',
          Icons.science,
          [Text(state.chemicalRemedy ?? '', style: GoogleFonts.mukta(fontSize: 15))],
          Colors.blue,
        ),
        _buildInfoCard(
          isMarathi ? 'प्रतिबंधात्मक उपाय' : 'Prevention',
          Icons.shield,
          [Text(state.prevention ?? '', style: GoogleFonts.mukta(fontSize: 15))],
          Colors.red,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => ReportGenerator.generateAndShareReport(
              state, 
              ref.read(profileProvider) ?? (isMarathi ? 'शेतकरी मित्र' : 'Farmer Friend'),
              isMarathi
            ),
            icon: const Icon(Icons.picture_as_pdf),
            label: Text(isMarathi ? 'अहवाल डाउनलोड करा' : 'Download PDF Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => ref.read(diseaseProvider.notifier).reset(),
            child: Text(isMarathi ? 'पुन्हा तपासणी करा' : 'Check Again'),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children, Color color) {
    return Card(margin: const EdgeInsets.symmetric(vertical: 8), child: ExpansionTile(initiallyExpanded: true, leading: Icon(icon, color: color), title: Text(title, style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 18)), childrenPadding: const EdgeInsets.all(16), children: children));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: GoogleFonts.mukta(fontWeight: FontWeight.bold, color: Colors.grey.shade700)), const SizedBox(width: 8), Expanded(child: Text(value, style: GoogleFonts.mukta(fontSize: 16, fontWeight: FontWeight.w600)))]));
  }
}

class MarketPricesScreen extends ConsumerWidget {
  const MarketPricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketState = ref.watch(marketProvider);
    final langNotifier = ref.read(languageProvider.notifier);
    final isMarathi = ref.watch(languageProvider) == 'mr';

    return Scaffold(
      appBar: AppBar(title: Text(langNotifier.translate('market_prices'), style: GoogleFonts.mukta(fontWeight: FontWeight.bold)), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(marketProvider.notifier).fetchPrices())]),
      body: Column(children: [Container(padding: const EdgeInsets.all(16), color: Colors.green.shade100, child: Row(children: [const Icon(Icons.location_on, color: Colors.green), const SizedBox(width: 8), Expanded(child: Text(isMarathi ? 'तुमच्या जवळील बाजारभाव' : 'Market Rates Near You', style: GoogleFonts.mukta(fontWeight: FontWeight.w500)))])), Expanded(child: marketState.when(data: (crops) => crops.isEmpty ? const Center(child: Text('माहिती उपलब्ध नाही')) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: crops.length, itemBuilder: (context, index) { final crop = crops[index]; return MarketPriceTile(crop: crop.name, market: crop.market, price: crop.price, date: crop.date, trend: crop.trend, change: crop.change); }), loading: () => const Center(child: CircularProgressIndicator()), error: (err, stack) => Center(child: Text(isMarathi ? 'तात्पुरती माहिती उपलब्ध नाही' : 'Service currently unavailable'))))]),
    );
  }
}

class MarketPriceTile extends StatelessWidget {
  final String crop;
  final String market;
  final String price;
  final String date;
  final String trend;
  final String change;
  const MarketPriceTile({super.key, required this.crop, required this.market, required this.price, required this.date, required this.trend, required this.change});
  @override
  Widget build(BuildContext context) {
    Color trendColor = trend == 'up' ? Colors.green : (trend == 'down' ? Colors.red : Colors.grey);
    return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), title: Text(crop, style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 18)), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('मार्केट: $market', style: const TextStyle(fontSize: 13, color: Colors.black87)), Text('दिनांक: $date', style: const TextStyle(fontSize: 11, color: Colors.grey))]), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('₹$price', style: GoogleFonts.mukta(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade900)), if (change != '0') Row(mainAxisSize: MainAxisSize.min, children: [Text(change, style: TextStyle(color: trendColor, fontWeight: FontWeight.bold, fontSize: 12)), Icon(trend == 'up' ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: trendColor)])])));
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final langNotifier = ref.read(languageProvider.notifier);
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))), builder: (context) => Padding(padding: const EdgeInsets.all(24.0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(langNotifier.translate('select_language'), style: GoogleFonts.mukta(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 16), ListTile(title: const Text('मराठी (Marathi)'), trailing: ref.watch(languageProvider) == 'mr' ? const Icon(Icons.check_circle, color: Colors.green) : null, onTap: () { ref.read(languageProvider.notifier).setLanguage('mr'); Navigator.pop(context); }), ListTile(title: const Text('English'), trailing: ref.watch(languageProvider) == 'en' ? const Icon(Icons.check_circle, color: Colors.green) : null, onTap: () { ref.read(languageProvider.notifier).setLanguage('en'); Navigator.pop(context); })])));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langNotifier = ref.read(languageProvider.notifier);
    final nickname = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(langNotifier.translate('profile'), style: GoogleFonts.mukta(fontWeight: FontWeight.bold))),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.green.shade700,
            child: Column(
              children: [
                const CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.person, size: 60, color: Colors.green)),
                const SizedBox(height: 16),
                Text(nickname ?? langNotifier.translate('farmer_friend'), style: GoogleFonts.mukta(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text(ref.watch(languageProvider) == 'mr' ? 'प्रगत शेतकरी' : 'Advanced Farmer', style: GoogleFonts.mukta(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildProfileTile(Icons.language, langNotifier.translate('language'), ref.watch(languageProvider) == 'mr' ? 'मराठी' : 'English', () => _showLanguageSelector(context, ref)),
          _buildProfileTile(Icons.history, langNotifier.translate('my_queries'), 'View Past Chats', () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => const ChatHistoryScreen()));
          }),
          _buildProfileTile(Icons.agriculture, langNotifier.translate('my_crops'), 'माहिती भरा', () {}),
          _buildProfileTile(Icons.account_balance_wallet_outlined, langNotifier.translate('scheme_benefits'), '', () {}),
          const Divider(),
          _buildProfileTile(Icons.info_outline, langNotifier.translate('about_app'), '', () {
            showAboutDialog(
              context: context,
              applicationName: 'शेतकरी AI (Shetkari AI)',
              applicationIcon: const Icon(Icons.agriculture, size: 50, color: Colors.green),
              children: [
                const Text(
                  'Vision: To act as a 24/7 Digital Agriculture Officer for every farmer, '
                  'leveraging AI to ensure crop health and prosperity.\n\n'
                  'ध्येय: प्रत्येक शेतकऱ्यासाठी २४/७ डिजिटल कृषी अधिकारी म्हणून काम करणे '
                  'आणि AI च्या मदतीने पिकांचे आरोग्य आणि समृद्धी सुनिश्चित करणे.'
                ),
              ],
            );
          }),
          _buildProfileTile(Icons.delete_forever, 'Clear Profile', '', () {
            // Logic to clear nickname for testing
            ref.read(profileProvider.notifier).setNickname('');
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle, VoidCallback onTap, {Color? color}) {
    return ListTile(leading: Icon(icon, color: color ?? Colors.green.shade700), title: Text(title, style: GoogleFonts.mukta(fontWeight: FontWeight.w500)), subtitle: subtitle.isNotEmpty ? Text(subtitle, style: GoogleFonts.mukta(fontSize: 12)) : null, trailing: const Icon(Icons.chevron_right, size: 20), onTap: onTap);
  }
}

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);
    final isMarathi = ref.watch(languageProvider) == 'mr';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(isMarathi ? 'माझे प्रश्न' : 'My Queries', style: GoogleFonts.mukta(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              // Option to clear history if needed
            },
          )
        ],
      ),
      body: messages.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  isMarathi ? 'अद्याप कोणतेही प्रश्न नाहीत' : 'No history found',
                  style: GoogleFonts.mukta(color: Colors.grey, fontSize: 18),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final m = messages[index];
              final isAI = m.role == 'model';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isAI ? Colors.green.shade700 : Colors.blue.shade700,
                          child: Icon(isAI ? Icons.auto_awesome : Icons.person, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isAI ? 'Shetkari AI' : (ref.watch(profileProvider) ?? 'You'),
                          style: GoogleFonts.mukta(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                        ),
                        const Spacer(),
                        Text(
                          '${m.timestamp.hour}:${m.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SelectableText(
                        m.text,
                        style: GoogleFonts.mukta(
                          fontSize: 15,
                          height: 1.5,
                          color: isAI ? Colors.black87 : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}
