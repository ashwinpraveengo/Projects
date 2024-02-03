import 'dart:convert';
import 'package:demoapp/add.dart';
import 'package:demoapp/edit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NoteScreen extends StatefulWidget {
  const NoteScreen({Key? key}) : super(key: key);

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late Future<List<Map<String, dynamic>>> _notesFuture;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _notesFuture = fetchNotes();
    _controller = TextEditingController();
  }

  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/notes/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((note) => {
        'id': note['id'],
        'body': note['body'],
      }).toList();
      print("Successs ");
    } else {
      throw Exception('Failed to fetch notes');
    }
  }

  Future<void> createNote(String newNote) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/notes/create/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'body': newNote,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _notesFuture = fetchNotes();
      });
      print('Post done');
    } else {
      print('Failed ${response.statusCode}');
    }
  }

  Future<void> deleteNote(int noteid) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/notes/$noteid/delete/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 204) {
      setState(() {
        _notesFuture = fetchNotes();
      });
      print('delete done');
    } else {
      print(' delete failed ${response.statusCode}');
    }
  }

  void _showDeleteDialog(int noteId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                deleteNote(noteId);
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'NOTO',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black12,
      ),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _notesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              final List<Map<String, dynamic>> notes = snapshot.data!;
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return Container(
                          height: 150,
                          width: 200,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: const BoxDecoration(
                              color: Colors.lightBlue,
                              borderRadius: BorderRadius.all(
                                  Radius.elliptical(10, 30))),
                          child: ListTile(
                            title: Text(note['body']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditNoteScreen(note['id'], note['body']),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteDialog(note['id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
    
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNoteScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}



