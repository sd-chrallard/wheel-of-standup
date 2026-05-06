import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/participant.dart';
import '../services/participant_storage_service.dart';

class ParticipantsController extends ChangeNotifier {
  ParticipantsController({
    required ParticipantStorageService storageService,
    Random? random,
  }) : _storageService = storageService,
       _random = random ?? Random();

  final ParticipantStorageService _storageService;
  final Random _random;

  final List<Participant> _participants = <Participant>[];
  bool _isLoaded = false;
  Participant? _lastWinner;

  bool get isLoaded => _isLoaded;
  List<Participant> get participants =>
      List<Participant>.unmodifiable(_participants);
  Participant? get lastWinner => _lastWinner;

  Future<void> initialize() async {
    if (_isLoaded) {
      return;
    }
    _participants
      ..clear()
      ..addAll(await _storageService.loadParticipants());
    _isLoaded = true;
    notifyListeners();
  }

  Future<String?> addParticipant(String rawName) async {
    final String name = rawName.trim();
    if (name.isEmpty) {
      return 'Name cannot be empty.';
    }
    if (_isDuplicate(name)) {
      return 'That participant already exists.';
    }

    _participants.add(Participant(id: _generateId(), name: name));
    await _persist();
    return null;
  }

  Future<String?> updateParticipant({
    required String id,
    required String rawName,
  }) async {
    final String name = rawName.trim();
    if (name.isEmpty) {
      return 'Name cannot be empty.';
    }
    if (_isDuplicate(name, excludeId: id)) {
      return 'That participant already exists.';
    }

    final int index = _participants.indexWhere((Participant p) => p.id == id);
    if (index == -1) {
      return 'Participant not found.';
    }

    _participants[index] = _participants[index].copyWith(name: name);
    if (_lastWinner?.id == id) {
      _lastWinner = _participants[index];
    }
    await _persist();
    return null;
  }

  Future<void> removeParticipant(String id) async {
    _participants.removeWhere((Participant p) => p.id == id);
    if (_lastWinner?.id == id) {
      _lastWinner = null;
    }
    await _persist();
  }

  Future<void> clearParticipants() async {
    _participants.clear();
    _lastWinner = null;
    await _persist();
  }

  int selectWinnerIndex() {
    if (_participants.isEmpty) {
      throw StateError('No participants available to spin.');
    }

    final int selectedIndex = _random.nextInt(_participants.length);
    _lastWinner = _participants[selectedIndex];
    notifyListeners();
    return selectedIndex;
  }

  Future<void> _persist() async {
    await _storageService.saveParticipants(_participants);
    notifyListeners();
  }

  bool _isDuplicate(String candidate, {String? excludeId}) {
    final String normalizedCandidate = _normalizeName(candidate);
    return _participants.any((Participant participant) {
      if (excludeId != null && participant.id == excludeId) {
        return false;
      }
      return _normalizeName(participant.name) == normalizedCandidate;
    });
  }

  String _normalizeName(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _generateId() {
    final int now = DateTime.now().microsecondsSinceEpoch;
    final int entropy = _random.nextInt(999999);
    return '$now-$entropy';
  }
}
