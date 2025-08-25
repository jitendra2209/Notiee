import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/note_bloc.dart';
import '../../application/bloc/note_event.dart';
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

  @override
  Widget build(BuildContext context) {
    final selectedColorData = _noteColors.firstWhere(
      (color) => color['name'] == _selectedColor,
      orElse: () => _noteColors.first,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.note == null ? 'Add Note' : 'Edit Note',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Pin button
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? selectedColorData['color'] : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
          ),
          // Color picker
          IconButton(
            icon: Icon(
              Icons.palette_outlined,
              color: selectedColorData['color'],
            ),
            onPressed: _showColorPicker,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            _buildTextField(
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
            _buildTextField(
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

  Widget _buildTagsSection(Map<String, dynamic> selectedColorData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Existing tags
                if (_tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags
                        .map((tag) => Chip(
                              label: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: selectedColorData['color'],
                                ),
                              ),
                              backgroundColor:
                                  selectedColorData['color'].withOpacity(0.2),
                              deleteIcon: Icon(
                                Icons.close,
                                size: 16,
                                color: selectedColorData['color'],
                              ),
                              onDeleted: () {
                                setState(() {
                                  _tags.remove(tag);
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                ],
                // Add tag field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          hintText: 'Add a tag...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                        ),
                        onSubmitted: _addTag,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: selectedColorData['color'],
                      ),
                      onPressed: () => _addTag(_tagController.text),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveNote,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.shade100,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.note == null ? 'Create Note' : 'Update Note',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
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
            const Text(
              'Choose Note Color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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
                          color: colorData['color'].withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorData['color'],
                            width: isSelected ? 3 : 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: colorData['color'],
                                size: 24,
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        colorData['label'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
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
