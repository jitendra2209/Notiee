import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/infrastructure/auth_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/infrastructure/todo_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/infrastructure/profile_repository_impl.dart';
import '../../features/authentication/application/bloc/auth_bloc.dart';
import '../../features/todo/application/bloc/todo_bloc.dart';
import '../../features/profile/application/bloc/profile_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupInjector() async {
  // External
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  // Repositories (DI only for repos and implementations)
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
        getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );

  // Blocs
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory<TodoBloc>(() => TodoBloc(getIt<TodoRepository>()));
  getIt.registerFactory<ProfileBloc>(
      () => ProfileBloc(getIt<ProfileRepository>()));
}
