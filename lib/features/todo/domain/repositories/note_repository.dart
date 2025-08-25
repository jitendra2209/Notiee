import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/note_model.dart';

abstract class NoteRepository {
  Stream<Either<Failure, List<NoteModel>>> watchNotes();
  Future<Either<Failure, String>> addNote(NoteModel note);
  Future<Either<Failure, Unit>> updateNote(NoteModel note);
  Future<Either<Failure, Unit>> deleteNote(String id);
}
