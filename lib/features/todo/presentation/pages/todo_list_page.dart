import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/todo_bloc.dart';
import '../../application/bloc/todo_event.dart';
import '../../application/bloc/todo_state.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<TodoBloc>().add(TodoWatchRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.redAccent.shade100,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Ongoing'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ongoingTodos = state.todos
                    .where((todo) => !(todo.isCompleted ?? false))
                    .toList();
                final completedTodos = state.todos
                    .where((todo) => todo.isCompleted ?? false)
                    .toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Ongoing Tab
                    _buildTodoList(ongoingTodos, isCompleted: false),
                    // Completed Tab
                    _buildTodoList(completedTodos, isCompleted: true),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(List todos, {required bool isCompleted}) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/empty.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? 'No Completed Tasks' : 'No Ongoing Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a new task',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 100, top: 8),
      itemCount: todos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final t = todos[index];
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
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? Colors.grey : Colors.black87,
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
                      color: isCompleted ? Colors.grey : Colors.grey.shade600,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
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
                        color: _getPriorityColor(t.priority).withOpacity(0.1),
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
                    // Completed timestamp for completed tasks
                    if (isCompleted && t.updatedAt != null) ...[
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed ${t.updatedAt!.day}/${t.updatedAt!.month}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                    const Spacer(),
                    // Action buttons
                    if (!isCompleted) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => Navigator.pushNamed(
                            context, '/add_edit_todo',
                            arguments: t),
                      ),
                    ],
                    IconButton(
                      icon: Icon(
                        isCompleted ? Icons.restore : Icons.delete_outline,
                        size: 20,
                        color: isCompleted ? Colors.blue : Colors.red,
                      ),
                      onPressed: () {
                        if (isCompleted) {
                          // Restore to ongoing
                          context.read<TodoBloc>().add(TodoUpdateRequested(
                                t.copyWith(isCompleted: false),
                              ));
                        } else {
                          // Delete task
                          context
                              .read<TodoBloc>()
                              .add(TodoDeleteRequested(t.id!));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
