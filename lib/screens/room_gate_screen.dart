import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/irworobongdo_theme.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';

class RoomGateScreen extends StatefulWidget {
  const RoomGateScreen({
    super.key,
    required this.user,
  });

  final User user;

  @override
  State<RoomGateScreen> createState() => _RoomGateScreenState();
}

class _RoomGateScreenState extends State<RoomGateScreen> {
  final RoomService _roomService = RoomService();
  final AuthService _authService = AuthService();

  final TextEditingController _roomNameController = TextEditingController(
    text: 'Nuestra Sala · 수원 시네마',
  );
  final TextEditingController _inviteCodeController = TextEditingController();

  bool _isCreating = false;
  bool _isJoining = false;
  String? _errorMessage;

  @override
  void dispose() {
    _roomNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  String get _displayName {
    final name = widget.user.displayName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final email = widget.user.email ?? '';
    return email.contains('@') ? email.split('@').first : 'Cinéfilo';
  }

  Future<void> _handleCreateRoom() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      final rawName = _roomNameController.text.trim();
      await _roomService.createPrivateRoom(
        userId: widget.user.uid,
        userName: _displayName,
        roomName: rawName.isNotEmpty ? rawName : 'Nuestra Sala · 수원 시네마',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isCreating = false;
      });
    }
  }

  Future<void> _handleJoinRoom() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      await _roomService.joinRoomByCode(
        code: _inviteCodeController.text,
        userId: widget.user.uid,
        userName: _displayName,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isJoining = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isBusy = _isCreating || _isJoining;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cine Suwon · 수원 영화'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout_rounded),
            onPressed: isBusy ? null : () => _authService.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hola, $_displayName',
                    style: textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Crea una sala privada para dos o únete con el código de invitación.',
                    style: textTheme.bodyMedium,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: IrworobongdoColors.vermilion
                            .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: IrworobongdoColors.vermilion
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: IrworobongdoColors.ivory,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.add_home_work_rounded,
                                color: IrworobongdoColors.jade,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Crear nueva sala privada',
                                style: textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _roomNameController,
                            enabled: !isBusy,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de la sala',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: isBusy ? null : _handleCreateRoom,
                            child: _isCreating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: IrworobongdoColors.ivory,
                                    ),
                                  )
                                : const Text('Crear sala y generar código'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.vpn_key_rounded,
                                color: IrworobongdoColors.warmGold,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Tengo un código de invitación',
                                style: textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _inviteCodeController,
                            enabled: !isBusy,
                            textCapitalization: TextCapitalization.characters,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              labelText: 'Código de 6 caracteres',
                              hintText: 'Ej. SW8K2M',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: isBusy ? null : _handleJoinRoom,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: const BorderSide(
                                color: IrworobongdoColors.warmGold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isJoining
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: IrworobongdoColors.warmGold,
                                    ),
                                  )
                                : const Text(
                                    'Unirme a la sala',
                                    style: TextStyle(
                                      color: IrworobongdoColors.warmGold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
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