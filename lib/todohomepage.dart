import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todoapp/addtodopage.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Todo List'),
      ),
      body: RefreshIndicator(
          onRefresh: getData,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item['_id'] as String;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(items[index]['title']),
                  subtitle: Text(items[index]['description']),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        navigateToEditPage(item);
                      } else if (value == 'delete') {
                        deleteById(id);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ),
              );
            },
          )),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            navigateToAddPage();
          },
          label: const Text('Add Todo')),
    );
  }

  void navigateToEditPage(Map item) async {
    final route = MaterialPageRoute(
        builder: (context) => AddTodoPage(
              todo: item,
            ));
    await Navigator.push(context, route);
    getData();
  }

  Future<void> navigateToAddPage() async {
    final route = MaterialPageRoute(builder: (context) => const AddTodoPage());
    await Navigator.push(context, route);
    getData();
  }

  Future<void> getData() async {
    const url = 'https://api.nstack.in/v1/todos';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final result = json['items'] as List;

      setState(() {
        items = result;
      });
    }
  }

  Future<void> deleteById(String id) async {
    //delete the item
    final url = 'https://api.nstack.in/v1/todos/$id'; //find the id of the list
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode == 200) {
      //remove item without refresh
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage('Deletion Failed');
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
