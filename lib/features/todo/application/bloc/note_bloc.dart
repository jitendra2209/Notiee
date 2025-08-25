import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/models/note_model.dart';
import '../../domain/repositories/note_repository.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository _repo;
  NoteBloc(this._repo) : super(const NoteState()) {
    on<NoteWatchRequested>(_onWatch);
    on<NoteAddRequested>(_onAdd);
    on<NoteUpdateRequested>(_onUpdate);
    on<NoteDeleteRequested>(_onDelete);
    on<NotePinToggleRequested>(_onPinToggle);
  }

  Future<void> _onWatch(NoteWatchRequested e, Emitter<NoteState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    await emit.forEach(
      _repo.watchNotes(),
      onData: (Either<Failure, List<NoteModel>> data) {
        return data.fold(
          (failure) {
            print('Notes error in BLoC: ${failure.message}');
            return state.copyWith(isLoading: false, error: failure.message);
          },
          (notes) {
            return state.copyWith(isLoading: false, notes: notes, error: null);
          },
        );
      },
      onError: (error, stackTrace) {
        print('Notes stream error in BLoC: $error');
        return state.copyWith(isLoading: false, error: error.toString());
      },
    );
  }

  Future<void> _onAdd(NoteAddRequested e, Emitter<NoteState> emit) async {
    final res = await _repo.addNote(e.note);
    res.fold(
      (l) {
        print('ERROR in BLoC add: ${l.message}');
        emit(state.copyWith(error: l.message));
      },
      (noteId) {
        // Don't emit here - let the stream update handle it
      },
    );
  }

  Future<void> _onUpdate(NoteUpdateRequested e, Emitter<NoteState> emit) async {
    final res = await _repo.updateNote(e.note);
    res.fold(
      (l) => emit(state.copyWith(error: l.message)),
      (_) => null,
    );
  }

  Future<void> _onDelete(NoteDeleteRequested e, Emitter<NoteState> emit) async {
    final res = await _repo.deleteNote(e.id);
    res.fold(
      (l) => emit(state.copyWith(error: l.message)),
      (_) => null,
    );
  }

  Future<void> _onPinToggle(
      NotePinToggleRequested e, Emitter<NoteState> emit) async {
    final updatedNote = e.note.copyWith(isPinned: !(e.note.isPinned ?? false));
    final res = await _repo.updateNote(updatedNote);
    res.fold(
      (l) => emit(state.copyWith(error: l.message)),
      (_) => null,
    );
  }
}
