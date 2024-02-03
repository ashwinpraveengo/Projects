import 'package:flutter/material.dart';


class EditNoteScreen extends StatelessWidget {
  final int noteId;
  final String currentNote;

  const EditNoteScreen(this.noteId, this.currentNote);

  @override
  Widget build(BuildContext context) {
    TextEditingController editController =
        TextEditingController(text: currentNote);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(66, 0, 0, 0),
        centerTitle: true,
        title: const Text('Edit Note',
        style: TextStyle(
          color: Color.fromARGB(255, 235, 232, 232)
        ),),
      ),
      backgroundColor: Colors.black12,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: editController,
                decoration: const InputDecoration(labelText: 'Edit Note',hintStyle: TextStyle(color: Colors.white),
              ),),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Save',
                style: TextStyle(
                  color: Colors.white
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
