import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

import '../models/participant.dart';
import '../state/participants_controller.dart';
import 'manage_participants_page.dart';

class WheelPage extends StatefulWidget {
  const WheelPage({super.key, required this.controller});

  static const String routeName = '/';

  final ParticipantsController controller;

  @override
  State<WheelPage> createState() => _WheelPageState();
}

class _WheelPageState extends State<WheelPage> {
  late final StreamController<int> _selectedIndexController;
  Participant? _pendingWinner;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _selectedIndexController = StreamController<int>.broadcast();
  }

  @override
  void dispose() {
    _selectedIndexController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wheel of Standup'),
        actions: <Widget>[
          TextButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(ManageParticipantsPage.routeName),
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Participants'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, Widget? child) {
          final List<Participant> participants = widget.controller.participants;

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double wheelSize = constraints.maxWidth > 700
                  ? 420
                  : constraints.maxWidth * 0.8;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Standup Picker',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              participants.isEmpty
                                  ? 'Add participants to start spinning.'
                                  : 'Spin the wheel to pick the next speaker.',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (participants.isEmpty)
                      _buildEmptyState(context)
                    else
                      Center(
                        child: SizedBox(
                          height: wheelSize,
                          width: wheelSize,
                          child: FortuneWheel(
                            selected: _selectedIndexController.stream,
                            animateFirst: false,
                            onAnimationEnd: _handleSpinEnd,
                            indicators: const <FortuneIndicator>[
                              FortuneIndicator(
                                alignment: Alignment.topCenter,
                                child: TriangleIndicator(
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                            items: participants
                                .map(
                                  (Participant participant) => FortuneItem(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        participant.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: participants.isEmpty || _isSpinning
                          ? null
                          : _spin,
                      icon: const Icon(Icons.casino_outlined),
                      label: Text(_isSpinning ? 'Spinning...' : 'Spin'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(ManageParticipantsPage.routeName),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Edit Participants'),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.emoji_events_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isSpinning
                                    ? 'Spinning... winner reveal coming up.'
                                    : 'Winner is revealed after the wheel stops.',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Participants (${participants.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: participants
                          .map((Participant p) => Chip(label: Text(p.name)))
                          .toList(growable: false),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: <Widget>[
            const Icon(Icons.groups, size: 56),
            const SizedBox(height: 12),
            Text(
              'No participants available',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Add names first, then come back and spin the wheel.'),
          ],
        ),
      ),
    );
  }

  void _spin() {
    final int selectedIndex = widget.controller.selectWinnerIndex();
    setState(() {
      _pendingWinner = widget.controller.lastWinner;
      _isSpinning = true;
    });
    _selectedIndexController.add(selectedIndex);
  }

  Future<void> _handleSpinEnd() async {
    if (!_isSpinning) {
      return;
    }

    final Participant? winner = _pendingWinner;
    setState(() {
      _isSpinning = false;
      _pendingWinner = null;
    });

    if (!mounted || winner == null) {
      return;
    }

    await _showWinnerDialog(winner);
  }

  Future<void> _showWinnerDialog(Participant winner) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('And the winner is...'),
          content: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutBack,
            builder: (BuildContext context, double value, Widget? child) {
              return Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: 0.75 + (0.25 * value),
                  child: child,
                ),
              );
            },
            child: Text(
              winner.name,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Nice'),
            ),
          ],
        );
      },
    );
  }
}
