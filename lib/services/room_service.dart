import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/movie_model.dart';

class RoomService {
  RoomService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _codeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String _generateRoomCode() {
    final random = Random.secure();
    return List.generate(
      6,
      (_) => _codeAlphabet[random.nextInt(_codeAlphabet.length)],
    ).join();
  }

  /// Crea una sala privada nueva con código de invitación de 6 caracteres
  Future<String> createPrivateRoom({
    required String userId,
    required String userName,
    String roomName = 'Nuestra Sala · 수원 시네마',
  }) async {
    String code = _generateRoomCode();

    var existing = await _firestore
        .collection('rooms')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    while (existing.docs.isNotEmpty) {
      code = _generateRoomCode();
      existing = await _firestore
          .collection('rooms')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();
    }

    final docRef = _firestore.collection('rooms').doc();
    await docRef.set({
      'id': docRef.id,
      'code': code,
      'name': roomName.trim(),
      'ownerId': userId,
      'memberIds': [userId],
      'memberNames': {
        userId: userName.trim().isNotEmpty ? userName.trim() : 'Anfitrión',
      },
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Une al usuario a una sala existente mediante su código de 6 caracteres
  Future<String> joinRoomByCode({
    required String code,
    required String userId,
    required String userName,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length != 6) {
      throw Exception('El código de invitación debe tener 6 caracteres.');
    }

    final snapshot = await _firestore
        .collection('rooms')
        .where('code', isEqualTo: cleanCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No se encontró ninguna sala con ese código.');
    }

    final roomDoc = snapshot.docs.first;
    final data = roomDoc.data();
    final members = List<String>.from(data['memberIds'] ?? []);

    if (members.contains(userId)) {
      return roomDoc.id;
    }

    if (members.length >= 2) {
      throw Exception('Esta sala privada ya tiene sus 2 lugares ocupados.');
    }

    await roomDoc.reference.update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'memberNames.$userId':
          userName.trim().isNotEmpty ? userName.trim() : 'Invitado',
    });

    return roomDoc.id;
  }

  /// Permite salir de la sala actual sin cerrar la cuenta de usuario
  Future<void> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'memberNames.$userId': FieldValue.delete(),
    });
  }

  /// Escucha en tiempo real las salas a las que pertenece el usuario
  Stream<QuerySnapshot> watchUserRooms(String userId) {
    return _firestore
        .collection('rooms')
        .where('memberIds', arrayContains: userId)
        .limit(1)
        .snapshots();
  }

  /// Guarda o actualiza una película en la watchlist compartida de la sala
  Future<void> addMovieToWatchlist({
    required String roomId,
    required MovieModel movie,
    required String addedByUid,
  }) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('watchlist')
        .doc(movie.id.toString())
        .set({
      'movieId': movie.id,
      'title': movie.title,
      'originalTitle': movie.originalTitle,
      'posterPath': movie.posterPath,
      'releaseDate': movie.releaseDate,
      'voteAverage': movie.voteAverage,
      'watched': false,
      'rating': 0,
      'scheduledDate': null,
      'watchedAt': null,
      'addedBy': addedByUid,
      'addedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Agenda la fecha para ver una película en pareja
  Future<void> scheduleMovieDate({
    required String roomId,
    required int movieId,
    required DateTime? date,
  }) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('watchlist')
        .doc(movieId.toString())
        .update({
      'scheduledDate': date != null ? Timestamp.fromDate(date) : null,
    });
  }

  /// Califica una película del 1 al 5 y la marca como vista
  Future<void> rateAndMarkWatched({
    required String roomId,
    required int movieId,
    required int rating,
  }) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('watchlist')
        .doc(movieId.toString())
        .update({
      'watched': true,
      'rating': rating,
      'watchedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marca o desmarca una película como vista
  Future<void> toggleMovieWatched({
    required String roomId,
    required int movieId,
    required bool watched,
  }) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('watchlist')
        .doc(movieId.toString())
        .update({
      'watched': watched,
      'watchedAt': watched ? FieldValue.serverTimestamp() : null,
    });
  }

  /// Elimina una película de la watchlist de la sala
  Future<void> removeMovieFromWatchlist({
    required String roomId,
    required int movieId,
  }) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('watchlist')
        .doc(movieId.toString())
        .delete();
  }

  /// Escucha la watchlist de la sala ordenada por fecha de agregado
  Stream<QuerySnapshot> watchRoomWatchlist(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('watchlist')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }
}