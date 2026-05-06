import 'package:flutter/material.dart';

import 'pages/manage_participants_page.dart';
import 'pages/wheel_page.dart';
import 'services/participant_storage_service.dart';
import 'state/participants_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences early to avoid blocking on first save
  final ParticipantStorageService storageService = ParticipantStorageService();
  await storageService.eagerlyInitializeStorage();

  final ParticipantsController controller = ParticipantsController(
    storageService: storageService,
  );
  await controller.initialize();
  runApp(StandupWheelApp(controller: controller));
}

class StandupWheelApp extends StatelessWidget {
  const StandupWheelApp({super.key, required this.controller});

  final ParticipantsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          title: 'Wheel of Standup',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0D9488),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            useMaterial3: true,
          ),
          routes: <String, WidgetBuilder>{
            WheelPage.routeName: (_) => WheelPage(controller: controller),
            ManageParticipantsPage.routeName: (_) =>
                ManageParticipantsPage(controller: controller),
          },
          initialRoute: WheelPage.routeName,
        );
      },
    );
  }
}
