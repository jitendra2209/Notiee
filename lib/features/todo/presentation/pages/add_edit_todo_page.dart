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
  DateTime? selectedReminderDate;
  TimeOfDay? selectedReminderTime;
  String selectedPriority = 'Medium';
  TodoModel? existing;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg is TodoModel) {
        existing = arg;
        _initializeFormData();
      }
      _isInitialized = true;
    }
  }

  void _initializeFormData() {
    if (existing != null) {
      setState(() {
        titleCtrl.text = existing!.title ?? '';
        descCtrl.text = existing!.description ?? '';
        selectedReminderDate = existing!.reminderDate;
        selectedReminderTime = existing!.reminderTime != null
            ? TimeOfDay.fromDateTime(existing!.reminderTime!)
            : null;
        selectedPriority = existing!.priority ?? 'Medium';
      });

      // Debug information - can be removed in production
      print('DEBUG: Initialized form data');
      print('Title: ${existing!.title}');
      print('Reminder Date: ${existing!.reminderDate}');
      print('Reminder Time: ${existing!.reminderTime}');
      print('Priority: ${existing!.priority}');
      print('Selected Date: $selectedReminderDate');
      print('Selected Time: $selectedReminderTime');
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Todo' : 'Add Todo',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            _buildTextField(
              controller: titleCtrl,
              label: 'Task Title',
              hint: 'Enter your task title',
            ),
            const SizedBox(height: 20),

            // Description Field
            _buildTextField(
              controller: descCtrl,
              label: 'Description',
              hint: 'Add some details about your task',
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // Priority Dropdown
            _buildPriorityDropdown(),
            const SizedBox(height: 20),

            // Reminder Date
            _buildDateTimePicker(),
            const SizedBox(height: 30),

            // Save Button
            _buildSaveButton(isEdit),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedPriority,
            decoration: const InputDecoration(
              // prefixIcon: Icon(Icons.flag, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            items: [
              DropdownMenuItem(
                value: 'High',
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('High Priority'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Medium',
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Medium Priority'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'Low',
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Low Priority'),
                  ],
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedPriority = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        selectedReminderDate != null
                            ? '${selectedReminderDate!.day}/${selectedReminderDate!.month}/${selectedReminderDate!.year}'
                            : 'Select Date',
                        style: TextStyle(
                          color: selectedReminderDate != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        selectedReminderTime != null
                            ? _formatTimeWithAmPm(selectedReminderTime!)
                            : 'Select Time',
                        style: TextStyle(
                          color: selectedReminderTime != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (titleCtrl.text.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a task title')),
            );
            return;
          }

          final reminderDateTime = _combineDateTime();

          if (isEdit) {
            context.read<TodoBloc>().add(TodoUpdateRequested(
                  existing!.copyWith(
                    title: titleCtrl.text,
                    description: descCtrl.text,
                    reminderDate: selectedReminderDate,
                    reminderTime: reminderDateTime,
                    priority: selectedPriority,
                  ),
                ));
          } else {
            context.read<TodoBloc>().add(TodoAddRequested(TodoModel(
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  isCompleted: false,
                  createdAt: DateTime.now(),
                  reminderDate: selectedReminderDate,
                  reminderTime: reminderDateTime,
                  priority: selectedPriority,
                )));
          }
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.shade100,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isEdit ? 'Update Task' : 'Create Task',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedReminderDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.redAccent.shade100,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedReminderDate) {
      setState(() {
        selectedReminderDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedReminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.redAccent.shade100,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedReminderTime) {
      setState(() {
        selectedReminderTime = picked;
      });
    }
  }

  DateTime? _combineDateTime() {
    if (selectedReminderDate != null && selectedReminderTime != null) {
      return DateTime(
        selectedReminderDate!.year,
        selectedReminderDate!.month,
        selectedReminderDate!.day,
        selectedReminderTime!.hour,
        selectedReminderTime!.minute,
      );
    }
    return null;
  }

  String _formatTimeWithAmPm(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
