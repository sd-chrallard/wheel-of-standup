import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_of_standup/models/participant.dart';
import 'package:wheel_of_standup/pages/manage_participants_page.dart';
import 'package:wheel_of_standup/pages/wheel_page.dart';
import 'package:wheel_of_standup/services/participant_storage_service.dart';
import 'package:wheel_of_standup/state/participants_controller.dart';

class _FakeStorageService extends ParticipantStorageService {
  List<Participant> _records = <Participant>[];

  @override
  Future<List<Participant>> loadParticipants() async {
    return _records;
  }

  @override
  Future<void> saveParticipants(List<Participant> participants) async {
    _records = List<Participant>.from(participants);
  }

  @override
  Future<void> eagerlyInitializeStorage() async {
    // No-op for fake storage
  }
}

void main() {
  testWidgets('wheel page shows empty state and opens participant page', (
    WidgetTester tester,
  ) async {
    final ParticipantsController controller = ParticipantsController(
      storageService: _FakeStorageService(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      MaterialApp(
        routes: <String, WidgetBuilder>{
          WheelPage.routeName: (_) => WheelPage(controller: controller),
          ManageParticipantsPage.routeName: (_) =>
              ManageParticipantsPage(controller: controller),
        },
        initialRoute: WheelPage.routeName,
      ),
    );

    expect(find.text('No participants available'), findsOneWidget);

    await tester.tap(find.text('Edit Participants'));
    await tester.pumpAndSettle();

    expect(find.text('Manage Participants'), findsOneWidget);
  });
}
