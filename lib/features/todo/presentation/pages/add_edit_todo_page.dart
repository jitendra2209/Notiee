import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notiee/core/utils/app_colors.dart';
import '../../domain/models/todo_model.dart';
import '../../application/todo_bloc/todo_bloc.dart';
import '../../application/todo_bloc/todo_event.dart';

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
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  // Neumorphic helper methods
  Widget _buildNeumorphicContainer({
    required Widget child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFFE6EBEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildNeumorphicInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return _buildNeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(
          color: Color(0xFF2E3A4B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF9EA8B5),
            fontSize: 14,
          ),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = existing != null;
    return Scaffold(
      backgroundColor: const Color(0xFFE6EBEF),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Todo' : 'Add Todo',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3A4B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF2E3A4B),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            _buildNeumorphicInput(
              controller: titleCtrl,
              label: 'Task Title',
              hint: 'Enter your task title',
            ),
            const SizedBox(height: 20),

            // Description Field
            _buildNeumorphicInput(
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

  Widget _buildPriorityDropdown() {
    return _buildNeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Priority',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedPriority,
            dropdownColor: const Color(0xFFE6EBEF),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              color: Color(0xFF2E3A4B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return _buildNeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminder',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EBEF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedReminderDate != null
                              ? '${selectedReminderDate!.day}/${selectedReminderDate!.month}/${selectedReminderDate!.year}'
                              : 'Select Date',
                          style: TextStyle(
                            color: selectedReminderDate != null
                                ? const Color(0xFF2E3A4B)
                                : const Color(0xFF9EA8B5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
                      color: const Color(0xFFE6EBEF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          selectedReminderTime != null
                              ? _formatTimeWithAmPm(selectedReminderTime!)
                              : 'Select Time',
                          style: TextStyle(
                            color: selectedReminderTime != null
                                ? const Color(0xFF2E3A4B)
                                : const Color(0xFF9EA8B5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildSaveButton(bool isEdit) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
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
          child: Center(
            child: Text(
              isEdit ? 'Update Task' : 'Create Task',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
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
              primary: AppColors.primary,
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
              primary: AppColors.primary,
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
