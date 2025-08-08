import 'package:equatable/equatable.dart';
import '../../domain/models/todo_model.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();
  @override
  List<Object?> get props => [];
}

class TodoWatchRequested extends TodoEvent {}

class TodoAddRequested extends TodoEvent {
  final TodoModel todo;
  const TodoAddRequested(this.todo);
  @override
  List<Object?> get props => [todo];
}

class TodoUpdateRequested extends TodoEvent {
  final TodoModel todo;
  const TodoUpdateRequested(this.todo);
  @override
  List<Object?> get props => [todo];
}

class TodoDeleteRequested extends TodoEvent {
  final String id;
  const TodoDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}
