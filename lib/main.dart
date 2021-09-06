import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.blue,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // this will give us the instance of database
  final db = FirebaseFirestore.instance;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late String task;

  void showdialog(bool isUpdate, String id){
    showDialog(
      context : context,
      builder : (context){
        return AlertDialog(
          title: isUpdate ? Text("Update Todo") : Text("Add Todo"),
          content: Form(
            autovalidateMode: AutovalidateMode.always,
              key: formKey,
              child: TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Task"
                ),
                validator: (_val){
                  if(_val!.isEmpty){
                    return "Can't be empty";
                  }else{
                    return null;
                  }
                },
                onChanged: (_val){
                  task = _val;
                },
              )
          ),
          actions: <Widget>[
            MaterialButton(
                onPressed: (){
                 if(isUpdate){
                  db.collection('tasks').doc(id).update({
                    'task' : task, 'time': DateTime.now()
                  });
                 }else{
                   db.collection('tasks').add({'task': task, 'time': DateTime.now()});
                 }
                 Navigator.pop(context);
                },
              child: Text(
                "Add",
              ),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () => showdialog(false, null.toString()),
        child: Icon(Icons.add, size: 30, color: Colors.black,),
      ),
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("TODO APP"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('tasks').orderBy('time').snapshots(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            // we are using listview.builder bcz we are getting a lot of data
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index){
                DocumentSnapshot ds = snapshot.data!.docs[index];
                return Container(
                  child: ListTile(
                    tileColor: Colors.amber,
                    hoverColor: Colors.red,
                    title: Text(ds['task'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                    onLongPress: (){
                      // delete the data
                      db.collection('tasks').doc(ds.id).delete();
                      // we can also use this code
                      // db
                      //     .collection('crud')
                      //     .doc(snapshot.data.docs[index].id)
                      //     .delete();

                    },
                    onTap: (){
                      // update the data
                      // db.collection('tasks').doc(ds.id).update({'task': 'Ahmer Iqbal'});
                      showdialog(true, snapshot.data!.docs[index].id);
                    },
                  ),
                );
                }
            );
          }
          else if(snapshot.hasError){
            return Text("Error");
          }else{
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}




