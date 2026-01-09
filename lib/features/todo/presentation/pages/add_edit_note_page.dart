import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notiee/core/utils/app_colors.dart';
import '../../application/note_bloc/note_bloc.dart';
import '../../application/note_bloc/note_event.dart';
import '../../domain/models/note_model.dart';

class AddEditNotePage extends StatefulWidget {
  final NoteModel? note;

  const AddEditNotePage({super.key, this.note});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();

  String _selectedColor = 'default';
  bool _isPinned = false;
  List<String> _tags = [];

  final List<Map<String, dynamic>> _noteColors = [
    {'name': 'default', 'color': Colors.grey, 'label': 'Default'},
    {'name': 'yellow', 'color': Colors.amber, 'label': 'Yellow'},
    {'name': 'blue', 'color': Colors.blue, 'label': 'Blue'},
    {'name': 'green', 'color': Colors.green, 'label': 'Green'},
    {'name': 'purple', 'color': Colors.purple, 'label': 'Purple'},
    {'name': 'pink', 'color': Colors.pink, 'label': 'Pink'},
    {'name': 'orange', 'color': Colors.orange, 'label': 'Orange'},
    {'name': 'red', 'color': Colors.red, 'label': 'Red'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title ?? '';
      _contentController.text = widget.note!.content ?? '';
      _selectedColor = widget.note!.color ?? 'default';
      _isPinned = widget.note!.isPinned ?? false;
      _tags = List.from(widget.note!.tags ?? []);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
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
    final selectedColorData = _noteColors.firstWhere(
      (color) => color['name'] == _selectedColor,
      orElse: () => _noteColors.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE6EBEF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.note == null ? 'Add Note' : 'Edit Note',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E3A4B),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF2E3A4B),
        ),
        actions: [
          // Pin button
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _isPinned = !_isPinned;
                  });
                },
                child: Center(
                  child: Icon(
                    _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color:
                        _isPinned ? AppColors.primary : const Color(0xFF7C8BA0),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          // Color picker
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showColorPicker,
                child: Center(
                  child: Icon(
                    Icons.palette_outlined,
                    color: selectedColorData['color'],
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            _buildNeumorphicInput(
              controller: _titleController,
              label: 'Note Title',
              hint: 'Enter your note title',
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            // Tags section
            _buildTagsSection(selectedColorData),
            const SizedBox(height: 20),
            // Content field
            _buildNeumorphicInput(
              controller: _contentController,
              label: 'Content',
              hint: 'Start writing your note...',
              maxLines: 10,
            ),
            const SizedBox(height: 30),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(Map<String, dynamic> selectedColorData) {
    return _buildNeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          // Existing tags
          if (_tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6EBEF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 12,
                                color: selectedColorData['color'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tags.remove(tag);
                                });
                              },
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: selectedColorData['color'],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: const Color(0xFFBEC8D1),
            ),
            const SizedBox(height: 12),
          ],
          // Add tag field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  style: const TextStyle(
                    color: Color(0xFF2E3A4B),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add a tag...',
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9EA8B5),
                      fontSize: 14,
                    ),
                  ),
                  onSubmitted: _addTag,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EBEF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _addTag(_tagController.text),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: selectedColorData['color'],
                        size: 18,
                      ),
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

  Widget _buildSaveButton() {
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
          onTap: _saveNote,
          child: Center(
            child: Text(
              widget.note == null ? 'Create Note' : 'Update Note',
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

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFFE6EBEF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Note Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _noteColors.map((colorData) {
                final isSelected = colorData['name'] == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = colorData['name'];
                    });
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6EBEF),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: colorData['color'],
                              shape: BoxShape.circle,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        colorData['label'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7C8BA0),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content to save the note'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final note = NoteModel(
      id: widget.note?.id,
      title: title.isEmpty ? null : title,
      content: content.isEmpty ? null : content,
      color: _selectedColor,
      isPinned: _isPinned,
      tags: _tags,
      createdAt: widget.note?.createdAt,
      updatedAt: DateTime.now(),
    );

    if (widget.note == null) {
      context.read<NoteBloc>().add(NoteAddRequested(note));
    } else {
      context.read<NoteBloc>().add(NoteUpdateRequested(note));
    }

    Navigator.pop(context);
  }
}
