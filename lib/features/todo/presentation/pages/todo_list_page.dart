import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/todo_bloc.dart';
import '../../application/bloc/todo_event.dart';
import '../../application/bloc/todo_state.dart';
import '../../../authentication/application/bloc/auth_bloc.dart';
import '../../../authentication/application/bloc/auth_event.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  void initState() {
    super.initState();
    context.read<TodoBloc>().add(TodoWatchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
          ),
        ],
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          if (state.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (state.todos.isEmpty)
            return const Center(child: Text('No todos yet'));
          return ListView.separated(
            itemCount: state.todos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final t = state.todos[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(t.title ?? ''),
                subtitle: Text(t.description ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: t.isCompleted ?? false,
                      onChanged: (v) {
                        context.read<TodoBloc>().add(TodoUpdateRequested(
                              t.copyWith(isCompleted: v ?? false),
                            ));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.pushNamed(
                          context, '/add_edit_todo',
                          arguments: t),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => context
                          .read<TodoBloc>()
                          .add(TodoDeleteRequested(t.id!)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add_edit_todo'),
        label: const Text('Add Todo'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
