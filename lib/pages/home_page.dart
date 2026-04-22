import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/note_service.dart';
import 'create_page.dart';
import 'detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // We watch the notes array to rebuild when notes change
    final notes = context.watch<NoteService>().notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par titre ou contenu...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                context.read<NoteService>().search(value);
              },
            ),
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Consumer<NoteService>(
                builder: (context, noteService, child) {
                  return Badge(
                    label: Text('${noteService.count}'),
                    child: const Icon(Icons.note),
                  );
                },
              ),
            ),
          ),
          PopupMenuButton<SortOption>(
            onSelected: (SortOption result) {
              context.read<NoteService>().setSortOption(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.dateDesc,
                child: Text('Date (récent d\'abord)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.dateAsc,
                child: Text('Date (ancien d\'abord)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.titleAsc,
                child: Text('Titre (A \u2192 Z)'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.titleDesc,
                child: Text('Titre (Z \u2192 A)'),
              ),
            ],
          ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text(
                'Aucune note trouvée',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: _hexToColor(note.couleur),
                          width: 5,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        note.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.contenu.length > 30
                                ? '${note.contenu.substring(0, 30)}...'
                                : note.contenu,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Créée le ${_formatDate(note.dateCreation)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // We no longer await the result, state is managed globally
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(noteId: note.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We no longer await the result, state is managed globally
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNotePage()),
          );
        },
        tooltip: 'Nouvelle Note',
        child: const Icon(Icons.add),
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
