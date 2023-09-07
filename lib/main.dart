import 'package:flutter/material.dart';
import 'package:to_do/todo.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do/todo_status.dart';
import 'boxes.dart';

Future<void> main() async { 
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  toDosBox = await Hive.openBox('toDosBox');
  
  runApp(const ToDoApp());
}

ValueNotifier<List<Todo>> todoListNotifier = ValueNotifier<List<Todo>>([]);
ValueNotifier<TasksStatus> tasksStatusNotifier = ValueNotifier<TasksStatus>(TasksStatus(0, 0),);

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ToDoHomePage(title: 'Daily ToDo'),
      debugShowCheckedModeBanner: false,
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
  TextEditingController _controller = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    todoListNotifier.value = toDosBox.values.toList().cast<Todo>();

    int completedTasks = todoListNotifier.value.where((item) => item.isDone).length;
    int totalTasks = todoListNotifier.value.length;
    tasksStatusNotifier.value = TasksStatus(completedTasks, totalTasks);

    toDosBox.watch().listen((event) {
      todoListNotifier.value = toDosBox.values.toList().cast<Todo>();

      int completedTasks = todoListNotifier.value.where((item) => item.isDone).length;
      int totalTasks = todoListNotifier.value.length;
      tasksStatusNotifier.value = TasksStatus(completedTasks, totalTasks);
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

        ValueListenableBuilder<TasksStatus>(
          valueListenable: tasksStatusNotifier,
          builder: (context, tasksStatus, child) {
            return Text(
              getTasksStatusText(tasksStatus.completedTasks, tasksStatus.totalTasks),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            );
          },
        )

        ],
        ),
        centerTitle: false,
      )

      ,
      body: ValueListenableBuilder<List<Todo>>(
        valueListenable: todoListNotifier,
        builder:  (context, todos, child) {
          return ListView.builder(
            itemCount: todoListNotifier.value.length, // specify the total number of items
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
                    onTap: (){openDialog(todoListNotifier.value[index].toDoTitle,ind:index,isDone: todoListNotifier.value[index].isDone);},
                    title: Text(
                      todoListNotifier.value[index].toDoTitle,
                      style: TextStyle(decoration: todoListNotifier.value[index].isDone? TextDecoration.lineThrough: TextDecoration.none,
                      decorationThickness: 3.0, // Adjust the thickness as needed
                      decorationColor: Colors.black, // Line color
                      ),
                    ),
                    trailing: Checkbox(
                      checkColor: Colors.white,
                      activeColor: Colors.green,
                      value: todoListNotifier.value[index].isDone,
                      onChanged: (value) {
                        onCheck(index, value);
                      }
                    ),
                  ),
                ),
              );
            },
          );
        }
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
            if(txt=="") { addToDo(_controller.text); }
            else { editToDo(_controller.text, ind,isDone); }
            Navigator.of(context).pop();
           },
            child: const Text("Add",style: TextStyle(color: Colors.green)))
        ],
      )
    );
  }
  
  void addToDo(String text) async {
    await toDosBox.add(Todo(toDoTitle: text, isDone: false)); // Add the newTodo to the Hive Box
    todoListNotifier.value = toDosBox.values.toList().cast<Todo>();

    int completedTasks = todoListNotifier.value.where((item) => item.isDone).length;
    int totalTasks = todoListNotifier.value.length;
    tasksStatusNotifier.value = TasksStatus(completedTasks, totalTasks);

  }


  void deleteToDo(int index) async {
    await toDosBox.deleteAt(index); // Remove the Todo from the Hive Box
     todoListNotifier.value = toDosBox.values.toList().cast<Todo>();

    int completedTasks = todoListNotifier.value.where((item) => item.isDone).length;
    int totalTasks = todoListNotifier.value.length;
    tasksStatusNotifier.value = TasksStatus(completedTasks, totalTasks);
  }


  void editToDo(String text,int index,bool isDone)async{
    await toDosBox.putAt(index, Todo(toDoTitle: text, isDone: isDone));
  }


  // void updateCompletedTasksCount() {
  //   int completedTasks = todoListNotifier.value.where((item) => item.isDone).length;
  //   completedTasksCountNotifier.value = completedTasks;
  // }

  String getTasksStatusText(int completedTasks,int totalTasks){
    return '$completedTasks/$totalTasks';
  }

  void onCheck(int index, bool? value) {
    final todo = todoListNotifier.value[index];
    todo.isDone = value!;
    toDosBox.putAt(index, todo);
  }


}
