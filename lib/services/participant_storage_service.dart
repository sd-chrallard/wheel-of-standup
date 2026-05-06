import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/participant.dart';

class ParticipantStorageService {
  static const String _participantsKey = 'standup_participants';
  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<Participant>> loadParticipants() async {
    final SharedPreferences prefs = await _getPrefs();
    final String? raw = prefs.getString(_participantsKey);
    if (raw == null || raw.isEmpty) {
      return <Participant>[];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map(
          (dynamic item) => Participant.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<void> saveParticipants(List<Participant> participants) async {
    final SharedPreferences prefs = await _getPrefs();
    final String encoded = jsonEncode(
      participants.map((Participant p) => p.toJson()).toList(growable: false),
    );
    await prefs.setString(_participantsKey, encoded);
  }

  Future<void> eagerlyInitializeStorage() async {
    await _getPrefs();
  }
}
