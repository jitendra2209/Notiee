import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/todo_model.dart';

abstract class TodoRepository {
  Stream<Either<Failure, List<TodoModel>>> watchTodos();
  Future<Either<Failure, String>> addTodo(TodoModel todo);
  Future<Either<Failure, Unit>> updateTodo(TodoModel todo);
  Future<Either<Failure, Unit>> deleteTodo(String id);
}
