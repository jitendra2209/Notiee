import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notiee/firebase_options.dart';
import 'core/di/injector.dart';
import 'features/authentication/application/bloc/auth_bloc.dart';
import 'features/authentication/application/bloc/auth_event.dart';
import 'features/authentication/presentation/login_page.dart';
import 'features/authentication/presentation/signup_page.dart';
import 'features/todo/application/bloc/todo_bloc.dart';
import 'features/todo/presentation/pages/todo_list_page.dart';
import 'features/todo/presentation/pages/add_edit_todo_page.dart';
import 'home.dart';
import 'splash_screen.dart';

// ignore: unused_import
// After running `flutterfire configure`, you can import generated options:
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupInjector();
  runApp(const NotieeApp());
}

class NotieeApp extends StatelessWidget {
  const NotieeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<TodoBloc>(
          create: (_) => getIt<TodoBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginPage(),
          '/signup': (_) => const SignupPage(),
          '/todos': (_) => const TodoListPage(),
          '/main': (_) => const MainNavigationPage(),
          '/add_edit_todo': (_) => const AddEditTodoPage(),
        },
      ),
    );
  }
}
