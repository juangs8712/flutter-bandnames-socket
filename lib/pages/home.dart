import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/band.dart';
// -----------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Abba', votes: 4),
    Band(id: '3', name: 'Los Bukis', votes: 5),
    Band(id: '4', name: 'Pimpinela', votes: 3),
    Band(id: '2', name: 'Queen', votes: 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Band names', style: TextStyle(color: Colors.black54),),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: ( context, index ) =>  _bandTile(bands[index]),
      )      ,
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: _addNewBand,
        child: const Icon( Icons.add ),  
      ),
    );
  }

  // -----------------------------------------------------------------------------
  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key( band.id ),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete band', style: TextStyle(color: Colors.white,)),            
        ),
      ),
      child: ListTile(        
        leading: CircleAvatar(  
          backgroundColor: Colors.blue[100],  
          child: Text(band.name.substring(0, 2))
        ),
    
        title: Text(band.name),
        trailing: Text('${ band.votes }', style: const TextStyle(fontSize: 20),),
    
        onTap: (){
          print(band.name);
        },
      ),
    );
  }
  // -----------------------------------------------------------------------------
  void _addNewBand(){

    final textController = TextEditingController();

    if ( Platform.isAndroid ){
      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: const Text('New band Name'),
          content: TextField(
            controller: textController,
          ),
          
          actions: [
            MaterialButton(
              elevation: 5,
              textColor: Colors.blue,
              child: const Text('Add'),
              onPressed: () =>addBandToList( textController.text )
            )
          ],
        )
      );

      return;
    }

    // el cupertino es para el caso en que se este en un dispositivo IOS
    // ya que el material no funciona de igual forma
    showCupertinoDialog(context: context, 
      builder: (context){
        return CupertinoAlertDialog(
          title: const Text('New band Name'),
          content: CupertinoTextField(
            controller: textController,
          ),

          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () =>addBandToList( textController.text )
            ),

            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            ),
          ],

        );
      }
    );

  }
  // -----------------------------------------------------------------------------
  void addBandToList(String name){
    if ( name.length > 1 ){
      bands.add( Band(
        id: DateTime.now().toString(), 
        name: name,
      ));
      setState(() {});
    }

    Navigator.pop(context);
  }
  // -----------------------------------------------------------------------------
}
// -----------------------------------------------------------------------------