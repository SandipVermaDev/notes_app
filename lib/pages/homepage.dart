import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/firestore.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController noteController=TextEditingController();

  //firestore
  final FirestoreService firestoreService=FirestoreService();

  //Open a dialog box to add a note
  void openNoteBox({String? docID}){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        content: TextField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: "Note",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20)
            )
          ),
        ),
        actions: [
          FilledButton(onPressed: (){
            //add new note
            if(docID==null){
              firestoreService.addNote(noteController.text);
            }
            //update an existing note
            else{
              firestoreService.updateNote(docID, noteController.text);
            }

            noteController.clear();
            Navigator.pop(context);
          }, child: docID==null?const Text("Add"):const Text("Update"))
        ],
      );
    },);
  }

  confirmDelete({String? docID}){
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text("Are you sure want to delete?"),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
          }, child: const Text("Cancel")),
          TextButton(onPressed: () {
            firestoreService.deleteNote(docID!);
            Navigator.pop(context);
          }, child: const Text("Delete"))
        ],
      );
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        // backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        openNoteBox();
      },
      child: const Icon(Icons.add),
      ),
      body: StreamBuilder(stream: firestoreService.getNotesStream(), builder: (context, snapshot) {
        //If the snapshot has data,get all docs
        if(snapshot.hasData){
          List noteslist=snapshot.data!.docs;

          //display
          return ListView.builder(
            itemCount: noteslist.length,
            itemBuilder: (context, index) {
              // //get each individual doc
              DocumentSnapshot document=noteslist[index];
              String docId=document.id;
              // //get note from each note
              // Map<String,dynamic> data= document.data() as Map<String,dynamic>;
              // String noteText=data['note'];

              //display
              return ListTile(
              // title: Text(noteslist[index]['note']),
                title: Text(document['note']),
              //   title: Text(noteText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //update
                    IconButton(onPressed: () {
                      openNoteBox(docID: docId);
                    }, icon: const Icon(Icons.settings)),
                    //delete
                    IconButton(onPressed: () {
                      confirmDelete(docID: docId);
                    }, icon: const Icon(Icons.delete))
                  ],
                ),
            );
          },);
        }else{
          return const Center(child: Text("No notes found..."));
        }
      },),
    );
  }
}
