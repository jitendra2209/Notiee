import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failures.dart';
import '../domain/models/todo_model.dart';
import '../domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  TodoRepositoryImpl(this._auth, this._db);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('todos');

  String _uidOrThrow() {
    final u = _auth.currentUser;
    if (u == null) throw const AuthFailure('Not authenticated');
    return u.uid;
  }

  @override
  Stream<Either<Failure, List<TodoModel>>> watchTodos() async* {
    try {
      final uid = _uidOrThrow();
      yield* _col(uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => right<Failure, List<TodoModel>>(snap.docs
              .map((d) => TodoModel.fromJson(d.data(), d.id))
              .toList()))
          .handleError((e) =>
              left<Failure, List<TodoModel>>(UnexpectedFailure(e.toString())));
    } catch (e) {
      yield left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addTodo(TodoModel todo) async {
    try {
      final uid = _uidOrThrow();
      final ref = await _col(uid).add(todo.toJson());
      return right(ref.id);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTodo(TodoModel todo) async {
    try {
      final uid = _uidOrThrow();
      if (todo.id == null) return left(const UnexpectedFailure('Missing id'));
      await _col(uid)
          .doc(todo.id)
          .update(todo.copyWith(updatedAt: DateTime.now()).toJson());
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTodo(String id) async {
    try {
      final uid = _uidOrThrow();
      await _col(uid).doc(id).delete();
      return right(unit);
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
