class AppConfig {
  // Replace these placeholders with your actual API keys
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_GEMINI_API_KEY');
  static const String openWeatherApiKey = String.fromEnvironment('OPENWEATHER_API_KEY', defaultValue: 'YOUR_OPENWEATHER_API_KEY');
  static const String dataGovApiKey = String.fromEnvironment('DATA_GOV_API_KEY', defaultValue: 'YOUR_DATA_GOV_API_KEY');
  static const String googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: 'YOUR_GOOGLE_CLIENT_ID');
}
