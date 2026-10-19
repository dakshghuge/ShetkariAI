import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

class MarketCrop {
  final String name;
  final String market;
  final String price;
  final String date;
  final String trend;
  final String change;

  MarketCrop({
    required this.name,
    required this.market,
    required this.price,
    required this.date,
    required this.trend,
    required this.change,
  });
}

class MarketNotifier extends StateNotifier<AsyncValue<List<MarketCrop>>> {
  MarketNotifier() : super(const AsyncValue.loading()) {
    fetchPrices();
  }

  Future<void> fetchPrices() async {
    state = const AsyncValue.loading();
    try {
      String district = "";
      
      // Step 1: Get Exact Location
      Position? position = await _determinePosition();
      
      if (position != null) {
        // Step 2: Reverse Geocode to get District
        // geocoding package only works on Android/iOS.
        // For Laptop (Web/Windows), we use OpenStreetMap Nominatim API.
        if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
          try {
            final geoUrl = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10';
            final geoResponse = await http.get(Uri.parse(geoUrl), headers: {'User-Agent': 'ShetkariAI/1.0'});
            if (geoResponse.statusCode == 200) {
              final geoData = jsonDecode(geoResponse.body);
              final address = geoData['address'];
              district = address['county'] ?? address['district'] ?? address['city'] ?? address['state_district'] ?? "";
              district = district.replaceAll('District', '').trim();
            }
          } catch (e) {
            debugPrint("Nominatim error: $e");
          }
        } else {
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
            if (placemarks.isNotEmpty) {
              district = placemarks[0].subAdministrativeArea ?? placemarks[0].locality ?? "";
            }
          } catch (e) {
            debugPrint("Geocoding plugin error: $e");
          }
        }
      }

      // Final IP fallback if everything else fails
      if (district.isEmpty) {
        try {
          final ipResponse = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 5));
          if (ipResponse.statusCode == 200) {
            final ipData = json.decode(ipResponse.body);
            district = ipData['city'] ?? "Pune";
          }
        } catch (_) {}
      }

      district = district.isEmpty ? "Pune" : district;
      debugPrint("Senior Dev Log: Final District for Mandi: $district");

      // Step 3: Fetch from data.gov.in API
      final apiKey = AppConfig.dataGovApiKey;
      final url = 'https://api.data.gov.in/resource/9ef27315-4fd4-4d64-800b-9304620b5839'
          '?api-key=$apiKey&format=json&limit=50&filters[district]=$district';

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List records = data['records'] ?? [];
        
        if (records.isEmpty) {
          final stateUrl = 'https://api.data.gov.in/resource/9ef27315-4fd4-4d64-800b-9304620b5839'
              '?api-key=$apiKey&format=json&limit=20&filters[state]=Maharashtra';
          final stateResponse = await http.get(Uri.parse(stateUrl));
          if (stateResponse.statusCode == 200) {
            final stateData = jsonDecode(stateResponse.body);
            state = AsyncValue.data(_mapRecords(stateData['records'] ?? []));
          } else {
            throw "Market data unavailable";
          }
        } else {
          state = AsyncValue.data(_mapRecords(records));
        }
      } else {
        throw "Failed to load market data";
      }
    } catch (e) {
      state = AsyncValue.data(_getDemoData());
    }
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) 
            ? LocationAccuracy.medium 
            : LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return await Geolocator.getLastKnownPosition();
    }
  }

  List<MarketCrop> _mapRecords(List records) {
    return records.map((r) {
      return MarketCrop(
        name: _translateCrop(r['commodity'] ?? 'Other'),
        market: r['market'] ?? 'Nearby',
        price: r['modal_price'] ?? '0',
        date: r['arrival_date'] ?? '',
        trend: 'stable',
        change: '0',
      );
    }).toList();
  }

  String _translateCrop(String englishName) {
    final Map<String, String> translation = {
      'Soyabean': 'सोयाबीन', 'Cotton': 'कापूस', 'Onion': 'कांदा', 'Maize': 'मका',
      'Wheat': 'गहू', 'Gram': 'हरभरा', 'Arhar (Tur)': 'तूर', 'Tomato': 'टोमॅटो', 'Potato': 'बटाटा',
    };
    return translation[englishName] ?? englishName;
  }

  List<MarketCrop> _getDemoData() {
    return [
      MarketCrop(name: 'सोयाबीन', market: 'पुणे', price: '४,५८०', date: '२३/०५/२०२४', trend: 'up', change: '+३०'),
      MarketCrop(name: 'कापूस', market: 'अकोला', price: '७,१५०', date: '२३/०५/२०२४', trend: 'down', change: '-५०'),
      MarketCrop(name: 'कांदा', market: 'लासलगाव', price: '२,२५०', date: '२३/०५/२०२४', trend: 'up', change: '+१५०'),
    ];
  }
}

final marketProvider = StateNotifierProvider<MarketNotifier, AsyncValue<List<MarketCrop>>>((ref) {
  return MarketNotifier();
});
