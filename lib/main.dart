import 'package:flutter/material.dart';
import 'package:to_do/to_do_item.dart';

void main() => runApp(const ToDoApp());

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ToDoHomePage(title: 'Daily ToDo'),
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  const ToDoHomePage({super.key, required this.title});
  final String title;

  @override
  State<ToDoHomePage> createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  List<ToDoItem> todoList = [
    ToDoItem(toDoTitle: 'Task 0', isDone: true),
    ToDoItem(toDoTitle: 'Task 1', isDone: false),
    ToDoItem(toDoTitle: 'Task 2', isDone: true),
  ];

  String getTasksStatusText() {
    int completedTasks = todoList.where((item) => item.isDone).length;
    int totalTasks = todoList.length;
    return '$completedTasks/$totalTasks';
  }
  void onCheck(List<ToDoItem> todoList, int index, bool? value) {
    setState(() {
      todoList[index].isDone = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.yellow[500],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(width: 100),
            Text(
              getTasksStatusText(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: false,
      )

      ,
      body: ListView.builder(
        itemCount: todoList.length, // specify the total number of items
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.yellow[500],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                onLongPress: (){ deleteToDo(index); },
                onTap: (){openDialog(todoList[index].toDoTitle,ind:index,isDone: todoList[index].isDone);},
                title: Text(
                  todoList[index].toDoTitle,
                  style: TextStyle(decoration: todoList[index].isDone? TextDecoration.lineThrough: TextDecoration.none,
                  decorationThickness: 3.0, // Adjust the thickness as needed
                  decorationColor: Colors.black, // Line color
                  ),
                ),
                trailing: Checkbox(
                  checkColor: Colors.white,
                  activeColor: Colors.green,
                  value: todoList[index].isDone,
                  onChanged: (value) {
                    onCheck(todoList, index, value);
                  }
                ),
              ),
            ),
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {openDialog("");},
        tooltip: 'Increment',
        backgroundColor: Colors.green,
        child:const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    
    );
  }

  TextEditingController _controller = TextEditingController(text: "");
  
void openDialog(String txt, {int ind = -1,bool isDone = false}) { 
    _controller = TextEditingController(text: txt);
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("ToDo item"),
      content: TextField(
        cursorColor: Colors.green,
        decoration: const InputDecoration(
          hintText: "Enter a toDo",
          enabledBorder: UnderlineInputBorder(      borderSide: BorderSide(color: Colors.green),   ),  
          focusedBorder: UnderlineInputBorder(      borderSide: BorderSide(color: Colors.green),   ),
        ),
        controller: _controller,
      ),
        actions: [
          TextButton(
           onPressed: () {
            if(txt=="") {
              addToDo(_controller.text);
            } else {
              editToDo(_controller.text, ind,isDone);
            }
           },
            child: const Text("Add",style: TextStyle(color: Colors.green)))
        ],
      )
    );
  }


  addToDo(String text) {
    setState((){
        todoList.add(ToDoItem(toDoTitle: text, isDone: false));
    });
    Navigator.of(context).pop();
  }
  
  deleteToDo(int index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  editToDo(String text,int index,bool isDone){
    setState(() {
        todoList.removeAt(index);
        todoList.add(ToDoItem(toDoTitle: text, isDone: isDone));
    });
    Navigator.of(context).pop();
  }

}
