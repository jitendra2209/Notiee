import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/models/todo_model.dart';
import '../../domain/repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repo;
  TodoBloc(this._repo) : super(const TodoState()) {
    on<TodoWatchRequested>(_onWatch);
    on<TodoAddRequested>(_onAdd);
    on<TodoUpdateRequested>(_onUpdate);
    on<TodoDeleteRequested>(_onDelete);
  }

  Future<void> _onWatch(TodoWatchRequested e, Emitter<TodoState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    await emit.forEach(_repo.watchTodos(),
        onData: (Either<Failure, List<TodoModel>> data) {
      return data.fold(
        (l) => state.copyWith(isLoading: false, error: l.message),
        (todos) => state.copyWith(isLoading: false, todos: todos, error: null),
      );
    });
  }

  Future<void> _onAdd(TodoAddRequested e, Emitter<TodoState> emit) async {
    final res = await _repo.addTodo(e.todo);
    res.fold(
      (l) => emit(state.copyWith(error: l.message)),
      (_) => null,
    );
  }

  Future<void> _onUpdate(TodoUpdateRequested e, Emitter<TodoState> emit) async {
    final res = await _repo.updateTodo(e.todo);
    res.fold(
      (l) => emit(state.copyWith(error: l.message)),
      (_) => null,
    );
  }

  Future<void> _onDelete(TodoDeleteRequested e, Emitter<TodoState> emit) async {
    final res = await _repo.deleteTodo(e.id);
    res.fold(
      (l) => emit(state.copyWith(error: l.message)),
      (_) => null,
    );
  }
}
