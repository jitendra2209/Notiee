import 'package:equatable/equatable.dart';
import '../../domain/models/note_model.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object?> get props => [];
}

class NoteWatchRequested extends NoteEvent {}

class NoteAddRequested extends NoteEvent {
  final NoteModel note;
  const NoteAddRequested(this.note);
  @override
  List<Object?> get props => [note];
}

class NoteUpdateRequested extends NoteEvent {
  final NoteModel note;
  const NoteUpdateRequested(this.note);
  @override
  List<Object?> get props => [note];
}

class NoteDeleteRequested extends NoteEvent {
  final String id;
  const NoteDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class NotePinToggleRequested extends NoteEvent {
  final NoteModel note;
  const NotePinToggleRequested(this.note);
  @override
  List<Object?> get props => [note];
}
