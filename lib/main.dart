import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/irworobongdo_theme.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/home_shell_screen.dart';
import 'screens/room_gate_screen.dart';
import 'services/auth_service.dart';
import 'services/room_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CineSuwonApp());
}

class CineSuwonApp extends StatelessWidget {
  const CineSuwonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: IrworobongdoTheme.darkTheme,
      home: const _AppGate(),
    );
  }
}

class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final roomService = RoomService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScaffold();
        }

        final user = authSnapshot.data;
        if (user == null) {
          return const AuthScreen();
        }

        return StreamBuilder<QuerySnapshot>(
          stream: roomService.watchUserRooms(user.uid),
          builder: (context, roomSnapshot) {
            if (roomSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScaffold();
            }

            final docs = roomSnapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return RoomGateScreen(user: user);
            }

            final roomDoc = docs.first;
            final roomData = roomDoc.data() as Map<String, dynamic>;

            return HomeShellScreen(
              user: user,
              roomId: roomDoc.id,
              roomData: roomData,
            );
          },
        );
      },
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: IrworobongdoColors.vermilion,
        ),
      ),
    );
  }
}