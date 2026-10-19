import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileNotifier extends StateNotifier<String?> {
  ProfileNotifier() : super(null) {
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('nickname');
  }

  Future<void> setNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
    state = nickname;
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, String?>((ref) {
  return ProfileNotifier();
});
