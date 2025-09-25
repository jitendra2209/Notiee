import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/note_bloc/note_bloc.dart';
import '../../application/note_bloc/note_event.dart';
import '../../domain/models/note_model.dart';

class NotesListContent extends StatelessWidget {
  final List<NoteModel> notes;
  final bool isLoading;

  const NotesListContent({
    super.key,
    required this.notes,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // if (isLoading) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    if (notes.isEmpty) {
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
              'No Notes Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a new note',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Separate pinned and regular notes
    final pinnedNotes = notes.where((note) => note.isPinned ?? false).toList();
    final regularNotes =
        notes.where((note) => !(note.isPinned ?? false)).toList();

    return CustomScrollView(
      slivers: [
        // Pinned notes section
        if (pinnedNotes.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.push_pin, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  const Text(
                    'Pinned',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildNoteCard(context, pinnedNotes[index]),
                childCount: pinnedNotes.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 16, 16, 8),
              child: Text(
                'Others',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        // Regular notes section
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildNoteCard(context, regularNotes[index]),
              childCount: regularNotes.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, NoteModel note) {
    final color = _getNoteColor(note.color);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/add_edit_note',
        arguments: note,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6EBEF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: note.isPinned == true
                  ? color.withOpacity(0.3)
                  : const Color(0xFFBEC8D1),
              offset: const Offset(6, 6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-6, -6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with pin and menu
              Row(
                children: [
                  if (note.isPinned ?? false)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.push_pin,
                        size: 14,
                        color: color,
                      ),
                    ),
                  const Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EBEF),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFBEC8D1),
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white,
                          offset: Offset(-2, -2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: PopupMenuButton<String>(
                      color: const Color(0xFFE6EBEF),
                      icon: const Icon(
                        Icons.more_vert,
                        size: 14,
                        color: Color(0xFF7C8BA0),
                      ),
                      onSelected: (value) =>
                          _handleMenuAction(context, note, value),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'pin',
                          child: Row(
                            children: [
                              Icon(
                                note.isPinned ?? false
                                    ? Icons.push_pin_outlined
                                    : Icons.push_pin,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(note.isPinned ?? false ? 'Unpin' : 'Pin'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              if (note.title?.isNotEmpty == true) ...[
                Text(
                  note.title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E3A4B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              // Content
              Expanded(
                child: Text(
                  note.content ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7C8BA0),
                    height: 1.4,
                  ),
                  maxLines: 8,
                  overflow: TextOverflow.fade,
                ),
              ),
              // Footer with date and tags
              const SizedBox(height: 8),
              if (note.tags?.isNotEmpty == true) ...[
                Wrap(
                  spacing: 4,
                  children: note.tags!
                      .take(2)
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6EBEF),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                                const BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-1, -1),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                _formatDate(note.updatedAt ?? note.createdAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9EA8B5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, NoteModel note, String action) {
    switch (action) {
      case 'pin':
        context.read<NoteBloc>().add(NotePinToggleRequested(note));
        break;
      case 'edit':
        Navigator.pushNamed(context, '/add_edit_note', arguments: note);
        break;
      case 'delete':
        _showDeleteDialog(context, note);
        break;
    }
  }

  void _showDeleteDialog(BuildContext context, NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE6EBEF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Note',
          style: TextStyle(
            color: Colors.redAccent.shade100,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this note?',
          style: TextStyle(
            color: Color(0xFF2E3A4B),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBEF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFBEC8D1),
                  offset: Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF7C8BA0)),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE6EBEF),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFFBEC8D1),
                  offset: Offset(4, 4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<NoteBloc>().add(NoteDeleteRequested(note.id!));
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getNoteColor(String? colorName) {
    switch (colorName?.toLowerCase()) {
      case 'yellow':
        return Colors.amber;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.white;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
