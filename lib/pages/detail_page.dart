import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_service.dart';
import 'create_page.dart';

class DetailPage extends StatelessWidget {
  final String noteId;

  const DetailPage({super.key, required this.noteId});

  @override
  Widget build(BuildContext context) {
    final note = context.watch<NoteService>().getNoteById(noteId);

    if (note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail Note')),
        body: const Center(child: Text('Note introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail Note'),
        backgroundColor: _hexToColor(note.couleur),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateNotePage(note: note),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, note.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.titre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Créée le ${_formatDate(note.dateCreation)}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const Divider(height: 32),
            Text(note.contenu, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: const Text('Voulez-vous vraiment supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<NoteService>().deleteNote(noteId);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close DetailPage
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year à $hour:$minute';
  }
}
