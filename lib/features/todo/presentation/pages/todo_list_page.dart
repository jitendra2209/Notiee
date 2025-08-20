import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notiee/core/utils/icon_path.dart';
import '../../application/bloc/todo_bloc.dart';
import '../../application/bloc/todo_event.dart';
import '../../application/bloc/todo_state.dart';

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
    return Scaffold(body: BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.todos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(IconPath.empty, width: 100, height: 100),
                const Text(
                  'No Tasks Yet...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Click on the + button to add a task',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: state.todos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final t = state.todos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Priority indicator
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(t.priority),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.title ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: (t.isCompleted ?? false)
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: (t.isCompleted ?? false)
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: t.isCompleted ?? false,
                          activeColor: Colors.redAccent.shade100,
                          onChanged: (v) {
                            context.read<TodoBloc>().add(TodoUpdateRequested(
                                  t.copyWith(isCompleted: v ?? false),
                                ));
                          },
                        ),
                      ],
                    ),
                    if (t.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        t.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: (t.isCompleted ?? false)
                              ? Colors.grey
                              : Colors.grey.shade600,
                          decoration: (t.isCompleted ?? false)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Priority label
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                _getPriorityColor(t.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            t.priority ?? 'Medium',
                            style: TextStyle(
                              fontSize: 12,
                              color: _getPriorityColor(t.priority),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Reminder indicator
                        if (t.reminderDate != null) ...[
                          Icon(
                            Icons.notifications_outlined,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${t.reminderDate!.day}/${t.reminderDate!.month}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        // Action buttons
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => Navigator.pushNamed(
                              context, '/add_edit_todo',
                              arguments: t),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: Colors.red),
                          onPressed: () => context
                              .read<TodoBloc>()
                              .add(TodoDeleteRequested(t.id!)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ));
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.orange; // Default to medium
    }
  }
}
