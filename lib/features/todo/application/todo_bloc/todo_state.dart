import 'package:equatable/equatable.dart';
import '../../domain/models/todo_model.dart';

class TodoState extends Equatable {
  final bool isLoading;
  final List<TodoModel> todos;
  final String? error;

  const TodoState({
    this.isLoading = false,
    this.todos = const [],
    this.error,
  });

  TodoState copyWith({
    bool? isLoading,
    List<TodoModel>? todos,
    String? error,
  }) {
    return TodoState(
      isLoading: isLoading ?? this.isLoading,
      todos: todos ?? this.todos,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, todos, error];
}
