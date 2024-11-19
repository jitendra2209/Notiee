import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todoapp/todohomepage.dart';

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({super.key, this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _textControllerTitle = TextEditingController();
  final TextEditingController _textControllerDescription =
      TextEditingController();
  bool isEdited = false;
  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdited = true;
      _textControllerTitle.text = todo['title'];
      _textControllerDescription.text = todo['description'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(isEdited ? 'Edit Todo' : 'Add Todo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          TextField(
            controller: _textControllerTitle,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: _textControllerDescription,
            decoration: const InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            maxLines: 8,
            minLines: 5,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: isEdited ? updateData : submitData,
              child: Text(isEdited ? 'Update' : 'Submit')),
        ],
      ),
    );
  }

  Future<void> updateData() async {
    //update the data from Form
    final todo = widget.todo;
    final id = todo!['_id'];

    final String title = _textControllerTitle.text;
    final String description = _textControllerDescription.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    //submit data to server
    final url = 'https://api.nstack.in/v1/todos/$id';
    final response = await http.put(Uri.parse(url),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    //show ssuccess or false message based on status
    void showSuccessMessagE(String msg) {
      final snackBar = SnackBar(content: Text(msg));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    void showErrorMessagE(String msg) {
      final snackBar = SnackBar(
          content: Text(
        msg,
        style: const TextStyle(color: Colors.red),
      ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    if (response.statusCode == 200) {
      showSuccessMessagE("UPDATED SUCCESSFULLY");
    } else {
      showErrorMessagE("UPDATE FAILED");
    }
  }

  Future<void> submitData() async {
    //Get the data from Form
    final String title = _textControllerTitle.text;
    final String description = _textControllerDescription.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    //submit data to server
    const url = 'https://api.nstack.in/v1/todos';
    final response = await http.post(Uri.parse(url),
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    //show ssuccess or false message based on status
    void showSuccessMessagE(String msg) {
      final snackBar = SnackBar(content: Text(msg));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    void showErrorMessagE(String msg) {
      final snackBar = SnackBar(
          content: Text(
        msg,
        style: const TextStyle(color: Colors.red),
      ));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    if (response.statusCode == 201) {
      _textControllerDescription.clear();
      _textControllerTitle.clear();
      showSuccessMessagE("CREATED SUCCESSFULLY");
    } else {
      showErrorMessagE("CREATION FAILED");
    }
  }
}
