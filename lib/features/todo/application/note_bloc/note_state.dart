import 'package:equatable/equatable.dart';
import '../../domain/models/note_model.dart';

class NoteState extends Equatable {
  final bool isLoading;
  final List<NoteModel> notes;
  final String? error;

  const NoteState({
    this.isLoading = false,
    this.notes = const [],
    this.error,
  });

  NoteState copyWith({
    bool? isLoading,
    List<NoteModel>? notes,
    String? error,
  }) {
    return NoteState(
      isLoading: isLoading ?? this.isLoading,
      notes: notes ?? this.notes,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, notes, error];
}
