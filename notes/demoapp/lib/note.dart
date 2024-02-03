import 'dart:convert';
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
    _controller=TextEditingController();
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


  Future<void> CreateNote(String newnote) async {
    final response=await http.post(Uri.parse('http://10.0.2.2:8000/notes/create/'),
    body: jsonEncode(<String, dynamic>{
        'note_name': newnote,
      }),
      );
    if (response.statusCode==300){
      setState(() {
      });
      print("Post done");
    }else{
      print("Failed${response.statusCode}");
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
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
                  Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return ListTile(
                              title: Text(note['body']),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Create Note"),
                content: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(labelText: "Enter note"),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      CreateNote(_controller.text);
                      Navigator.pop(context);
                      _controller.clear();
                    },
                    child: const Text("Create"),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


