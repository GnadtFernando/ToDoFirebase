import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estudos_firebase/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TasksPage extends StatelessWidget {
  TasksPage({Key? key}) : super(key: key);

  final _controller = TextEditingController();

  void _saveTask() {
    final taskName = _controller.text;
    FirebaseFirestore.instance.collection("tasks").add(
      {"name": taskName},
    );
    _controller.clear();
  }

  void _deleteTask(String name) {
    FirebaseFirestore.instance
        .collection("tasks")
        .where("name", isEqualTo: name)
        .get()
        .then((value) {
      for (var element in value.docs) {
        FirebaseFirestore.instance
            .collection("tasks")
            .doc(element.id)
            .delete()
            .then((value) {
          debugPrint("Success!");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tarefas"),
        leading: GestureDetector(
          onTap: () => context.read<AuthService>().logout(),
          child: const Icon(
            Icons.logout,
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: "Qual a tarefa?"),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: const Color(0xFF42A5F5),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _saveTask();
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("tasks").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return Expanded(
                child: _buildList(snapshot.data!),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList(QuerySnapshot snapshot) {
    return ListView.builder(
      itemCount: snapshot.docs.length,
      itemBuilder: (context, index) {
        final doc = snapshot.docs[index];
        return Dismissible(
          onDismissed: (direction) => {
            if (direction == DismissDirection.startToEnd)
              {
                _deleteTask(
                  doc['name'],
                ),
              },
          },
          key: Key(
            DateTime.now().microsecondsSinceEpoch.toString(),
          ),
          direction: DismissDirection.startToEnd,
          background: Container(
            width: MediaQuery.of(context).size.width,
            height: 10,
            color: Colors.amber,
            child: const Align(
              alignment: Alignment(-0.9, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              elevation: 10,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    doc["name"],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
