import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/irworobongdo_theme.dart';
import '../models/movie_model.dart';
import '../services/auth_service.dart';
import '../services/room_service.dart';
import '../widgets/irworobongdo_mountain_icon.dart';
import '../widgets/irworobongdo_peaks_card.dart';
import 'explore_screen.dart';
import 'movie_detail_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({
    super.key,
    required this.user,
    required this.roomId,
    required this.roomData,
  });

  final User user;
  final String roomId;
  final Map<String, dynamic> roomData;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  final RoomService _roomService = RoomService();
  final AuthService _authService = AuthService();

  int _currentIndex = 0;

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: IrworobongdoColors.deepIndigo,
        content: Text(
          'Código $code copiado al portapapeles',
          style: const TextStyle(color: IrworobongdoColors.ivory),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _confirmLeaveRoom() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: IrworobongdoColors.deepIndigo,
        title: const Text('¿Salir de esta sala?'),
        content: const Text(
          'Volverás a la pantalla inicial para crear otra sala o unirte con un código, sin cerrar tu cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: IrworobongdoColors.mutedIvory),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir de sala'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _roomService.leaveRoom(
      roomId: widget.roomId,
      userId: widget.user.uid,
    );
  }

  void _openMovieDetail(Map<String, dynamic> data) {
    final movie = MovieModel(
      id: (data['movieId'] as num?)?.toInt() ?? 0,
      title: data['title']?.toString() ?? 'Sin título',
      originalTitle: data['originalTitle']?.toString() ?? '',
      overview: '',
      posterPath: data['posterPath']?.toString() ?? '',
      backdropPath: '',
      releaseDate: data['releaseDate']?.toString() ?? '',
      voteAverage: (data['voteAverage'] as num?)?.toDouble() ?? 0.0,
    );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MovieDetailScreen(
          initialMovie: movie,
          initialLanguage: 'es-MX',
        ),
      ),
    );
  }

  Future<void> _pickScheduleDate(int movieId, DateTime? currentDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      builder: (context, child) {
        return Theme(
          data: IrworobongdoTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: IrworobongdoColors.vermilion,
              onPrimary: IrworobongdoColors.ivory,
              surface: IrworobongdoColors.deepIndigo,
              onSurface: IrworobongdoColors.ivory,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await _roomService.scheduleMovieDate(
        roomId: widget.roomId,
        movieId: movieId,
        date: picked,
      );
    }
  }

  void _showMovieOptionsSheet(Map<String, dynamic> data) {
    final movieId = (data['movieId'] as num?)?.toInt() ?? 0;
    final title = data['title']?.toString() ?? 'Sin título';
    int selectedRating = (data['rating'] as num?)?.toInt() ?? 0;
    final scheduledTs = data['scheduledDate'] as Timestamp?;
    final scheduledDate = scheduledTs?.toDate();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: IrworobongdoColors.deepIndigo,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: IrworobongdoColors.mutedIvory.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nuestra calificación (1 a 5 estrellas)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      final isFilled = starValue <= selectedRating;
                      return IconButton(
                        onPressed: () async {
                          setModalState(() => selectedRating = starValue);
                          await _roomService.rateAndMarkWatched(
                            roomId: widget.roomId,
                            movieId: movieId,
                            rating: starValue,
                          );
                        },
                        icon: Icon(
                          isFilled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 32,
                          color: isFilled
                              ? IrworobongdoColors.warmGold
                              : IrworobongdoColors.mutedIvory,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.event_available_rounded,
                      color: IrworobongdoColors.jade,
                    ),
                    title: Text(
                      scheduledDate != null
                          ? 'Cita agendada: ${_formatDate(scheduledDate)}'
                          : 'Agendar cita de cine',
                    ),
                    subtitle: const Text(
                      'Se mostrará en la pantalla principal Nuestra Sala',
                    ),
                    trailing: scheduledDate != null
                        ? IconButton(
                            tooltip: 'Quitar fecha',
                            icon: const Icon(
                              Icons.close_rounded,
                              color: IrworobongdoColors.mutedIvory,
                            ),
                            onPressed: () async {
                              await _roomService.scheduleMovieDate(
                                roomId: widget.roomId,
                                movieId: movieId,
                                date: null,
                              );
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                            },
                          )
                        : null,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await _pickScheduleDate(movieId, scheduledDate);
                    },
                  ),
                  const Divider(color: IrworobongdoColors.borderSubtle),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.info_outline_rounded,
                      color: IrworobongdoColors.warmGold,
                    ),
                    title: const Text('Ver ficha y sinopsis multilingüe'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openMovieDetail(data);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _roomService.watchRoomWatchlist(widget.roomId),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        final pages = [
          _buildNuestraSalaTab(docs, isLoading),
          const ExploreScreen(),
          _buildNuestraListaTab(docs, isLoading),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: NavigationBar(
            backgroundColor: IrworobongdoColors.deepIndigo,
            indicatorColor: IrworobongdoColors.jade.withValues(alpha: 0.3),
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: IrworobongdoMountainIcon(isSelected: false),
                selectedIcon: IrworobongdoMountainIcon(isSelected: true),
                label: 'Nuestra Sala',
              ),
              NavigationDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(
                  Icons.explore_rounded,
                  color: IrworobongdoColors.ivory,
                ),
                label: 'Explorar',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmarks_outlined),
                selectedIcon: Icon(
                  Icons.bookmarks_rounded,
                  color: IrworobongdoColors.ivory,
                ),
                label: 'Nuestra Lista',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNuestraSalaTab(
    List<QueryDocumentSnapshot> docs,
    bool isLoading,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final roomName = widget.roomData['name']?.toString() ?? 'Nuestra Sala';
    final roomCode = widget.roomData['code']?.toString() ?? '------';
    final memberNames =
        Map<String, dynamic>.from(widget.roomData['memberNames'] ?? {});
    final membersList = memberNames.values.map((e) => e.toString()).toList();
    final sunMember = membersList.isNotEmpty ? membersList[0] : 'Integrante 1';
    final moonMember = membersList.length > 1 ? membersList[1] : 'Pendiente';

    final watchedDocs = docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      return data['watched'] == true;
    }).toList();

    watchedDocs.sort((a, b) {
      final tsA = (a.data() as Map<String, dynamic>)['watchedAt'] as Timestamp?;
      final tsB = (b.data() as Map<String, dynamic>)['watchedAt'] as Timestamp?;
      if (tsA == null && tsB == null) return 0;
      if (tsA == null) return 1;
      if (tsB == null) return -1;
      return tsB.compareTo(tsA);
    });

    final lastWatchedData = watchedDocs.isNotEmpty
        ? watchedDocs.first.data() as Map<String, dynamic>
        : null;

    final scheduledDocs = docs.where((d) {
      final data = d.data() as Map<String, dynamic>;
      return data['scheduledDate'] != null && data['watched'] != true;
    }).toList();

    scheduledDocs.sort((a, b) {
      final tsA =
          (a.data() as Map<String, dynamic>)['scheduledDate'] as Timestamp;
      final tsB =
          (b.data() as Map<String, dynamic>)['scheduledDate'] as Timestamp;
      return tsA.compareTo(tsB);
    });

    final nextScheduledData = scheduledDocs.isNotEmpty
        ? scheduledDocs.first.data() as Map<String, dynamic>
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Opciones de cuenta y sala',
            color: IrworobongdoColors.deepIndigo,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'leave_room') {
                _confirmLeaveRoom();
              } else if (value == 'sign_out') {
                _authService.signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'leave_room',
                child: Row(
                  children: [
                    Icon(
                      Icons.meeting_room_outlined,
                      color: IrworobongdoColors.warmGold,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text('Abandonar sala'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sign_out',
                child: Row(
                  children: [
                    Icon(
                      Icons.power_settings_new_rounded,
                      color: IrworobongdoColors.vermilion,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    IrworobongdoColors.deepIndigo,
                    IrworobongdoColors.elevatedIndigo,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: IrworobongdoColors.warmGold.withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCelestialBadge(
                        label: sunMember,
                        role: 'Sol · 해',
                        color: IrworobongdoColors.vermilion,
                        icon: Icons.wb_sunny_rounded,
                      ),
                      Container(
                        height: 44,
                        width: 1,
                        color: IrworobongdoColors.borderSubtle,
                      ),
                      _buildCelestialBadge(
                        label: moonMember,
                        role: 'Luna · 달',
                        color: IrworobongdoColors.ivory,
                        icon: Icons.nightlight_round,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: IrworobongdoColors.nightSky.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Código de sala: ',
                              style: textTheme.bodyMedium,
                            ),
                            Text(
                              roomCode,
                              style: textTheme.titleMedium?.copyWith(
                                color: IrworobongdoColors.warmGold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _copyInviteCode(roomCode),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 18,
                              color: IrworobongdoColors.warmGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: IrworobongdoColors.vermilion,
                  ),
                ),
              )
            else ...[
              _buildDashboardCard(
                icon: Icons.event_available_rounded,
                accentColor: IrworobongdoColors.jade,
                title: 'Nuestra próxima cita de cine',
                mainText: nextScheduledData != null
                    ? nextScheduledData['title']?.toString() ?? 'Sin título'
                    : 'Sin función agendada aún',
                subText: nextScheduledData != null
                    ? 'Fecha programada: ${_formatDate((nextScheduledData['scheduledDate'] as Timestamp).toDate())}'
                    : 'Toca una película en Nuestra Lista para elegir fecha en el calendario.',
                onTap: () => setState(() => _currentIndex = 2),
              ),
              const SizedBox(height: 12),
              _buildDashboardCard(
                icon: Icons.movie_filter_rounded,
                accentColor: IrworobongdoColors.warmGold,
                title: 'Última película vista',
                mainText: lastWatchedData != null
                    ? lastWatchedData['title']?.toString() ?? 'Sin título'
                    : 'Aún no marcan películas vistas',
                subText: lastWatchedData != null
                    ? _buildStarsText(
                        (lastWatchedData['rating'] as num?)?.toInt() ?? 0,
                      )
                    : 'Califica del 1 al 5 tus películas vistas en Nuestra Lista.',
                onTap: () => setState(() => _currentIndex = 2),
              ),
              const SizedBox(height: 12),
IrworobongdoPeaksCard(
             watchedCount: watchedDocs.length,
             totalSavedCount: docs.length,
             onTap: () => setState(() => _currentIndex = 1),
           ),
            ],
          ],
        ),
      ),
    );
  }

  String _buildStarsText(int rating) {
    if (rating <= 0) return 'Vista · Sin calificación en estrellas aún';
    final filled = '★' * rating;
    final empty = '☆' * (5 - rating);
    return 'Calificación: $filled$empty ($rating/5)';
  }

  Widget _buildCelestialBadge({
    required String label,
    required String role,
    required Color color,
    required IconData icon,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.18),
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          role,
          style: textTheme.bodyMedium?.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String mainText,
    required String subText,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mainText,
                      style: textTheme.titleLarge?.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subText,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNuestraListaTab(
    List<QueryDocumentSnapshot> docs,
    bool isLoading,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuestra Lista'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: IrworobongdoColors.vermilion,
              ),
            )
          : docs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Aún no han guardado películas.\nVe a Explorar para agregar su próxima función.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final movieId = (data['movieId'] as num?)?.toInt() ?? 0;
                    final title = data['title']?.toString() ?? 'Sin título';
                    final posterPath = data['posterPath']?.toString() ?? '';
                    final releaseDate = data['releaseDate']?.toString() ?? '';
                    final year = releaseDate.length >= 4
                        ? releaseDate.substring(0, 4)
                        : '----';
                    final watched = data['watched'] == true;
                    final rating = (data['rating'] as num?)?.toInt() ?? 0;
                    final scheduledTs = data['scheduledDate'] as Timestamp?;
                    final posterUrl = posterPath.isNotEmpty
                        ? '${AppConstants.tmdbImageBaseUrl}$posterPath'
                        : '';

                    String statusLabel =
                        watched ? '$year · Vista' : '$year · Pendiente';
                    if (rating > 0) {
                      statusLabel += ' · ${'★' * rating}';
                    } else if (!watched && scheduledTs != null) {
                      statusLabel +=
                          ' · Cita: ${_formatDate(scheduledTs.toDate())}';
                    }

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        onTap: () => _showMovieOptionsSheet(data),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: posterUrl.isNotEmpty
                              ? Image.network(
                                  posterUrl,
                                  width: 46,
                                  height: 68,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      _buildMiniPlaceholder(),
                                )
                              : _buildMiniPlaceholder(),
                        ),
                        title: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: watched
                                ? IrworobongdoColors.mutedIvory
                                : IrworobongdoColors.ivory,
                          ),
                        ),
                        subtitle: Text(
                          statusLabel,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: watched
                                ? IrworobongdoColors.jade
                                : IrworobongdoColors.warmGold,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Agendar o calificar',
                              icon: const Icon(
                                Icons.star_half_rounded,
                                color: IrworobongdoColors.warmGold,
                              ),
                              onPressed: () => _showMovieOptionsSheet(data),
                            ),
                            IconButton(
                              tooltip: 'Quitar de la lista',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: IrworobongdoColors.vermilion,
                              ),
                              onPressed: () =>
                                  _roomService.removeMovieFromWatchlist(
                                roomId: widget.roomId,
                                movieId: movieId,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildMiniPlaceholder() {
    return Container(
      width: 46,
      height: 68,
      color: IrworobongdoColors.elevatedIndigo,
      child: const Icon(
        Icons.movie_outlined,
        size: 22,
        color: IrworobongdoColors.mutedIvory,
      ),
    );
  }
}