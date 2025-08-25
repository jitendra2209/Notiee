import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/note_model.dart';
import '../domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  NoteRepositoryImpl(this._auth, this._db);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('notes');

  String _uidOrThrow() {
    final u = _auth.currentUser;
    if (u == null) {
      print('ERROR: User is not authenticated!');
      throw const AuthFailure('Not authenticated');
    }
    return u.uid;
  }

  @override
  Stream<Either<Failure, List<NoteModel>>> watchNotes() async* {
    try {
      final uid = _uidOrThrow();
      print('Starting notes watch for user: $uid');

      yield* _col(uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) {
        final notes =
            snap.docs.map((d) => NoteModel.fromJson(d.data(), d.id)).toList();

        // Sort in memory: pinned notes first, then by update time
        notes.sort((a, b) {
          if ((a.isPinned ?? false) && !(b.isPinned ?? false)) return -1;
          if (!(a.isPinned ?? false) && (b.isPinned ?? false)) return 1;

          final aTime = a.updatedAt ?? a.createdAt ?? DateTime.now();
          final bTime = b.updatedAt ?? b.createdAt ?? DateTime.now();
          return bTime.compareTo(aTime);
        });

        return right<Failure, List<NoteModel>>(notes);
      }).handleError((e) {
        print('Notes stream error: $e');
        return left<Failure, List<NoteModel>>(UnexpectedFailure(e.toString()));
      });
    } catch (e) {
      print('Notes watch error: $e');
      yield left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addNote(NoteModel note) async {
    try {
      final uid = _uidOrThrow();
      final ref = await _col(uid).add(note.toJson());
      print('Note saved successfully with ID: ${ref.id}');
      return right(ref.id);
    } catch (e) {
      print('ERROR adding note: $e');
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateNote(NoteModel note) async {
    try {
      final uid = _uidOrThrow();
      if (note.id == null) return left(const UnexpectedFailure('Missing id'));
      await _col(uid)
          .doc(note.id)
          .update(note.copyWith(updatedAt: DateTime.now()).toJson());
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteNote(String id) async {
    try {
      final uid = _uidOrThrow();
      await _col(uid).doc(id).delete();
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
