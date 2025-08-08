import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/todo_model.dart';
import '../../application/bloc/todo_bloc.dart';
import '../../application/bloc/todo_event.dart';

class AddEditTodoPage extends StatefulWidget {
  const AddEditTodoPage({super.key});

  @override
  State<AddEditTodoPage> createState() => _AddEditTodoPageState();
}

class _AddEditTodoPageState extends State<AddEditTodoPage> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  TodoModel? existing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is TodoModel) {
      existing = arg;
      titleCtrl.text = existing?.title ?? '';
      descCtrl.text = existing?.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Todo' : 'Add Todo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (isEdit) {
                  context.read<TodoBloc>().add(TodoUpdateRequested(
                        existing!.copyWith(
                            title: titleCtrl.text, description: descCtrl.text),
                      ));
                } else {
                  context.read<TodoBloc>().add(TodoAddRequested(TodoModel(
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        isCompleted: false,
                        createdAt: DateTime.now(),
                      )));
                }
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
