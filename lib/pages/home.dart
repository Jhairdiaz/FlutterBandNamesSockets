import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_name/models/band.dart';


class HomePage extends StatefulWidget {  
      
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = <Band>[
    Band(id: '1', name: 'Trym', votes: 5),
    Band(id: '2', name: 'Cltx', votes: 6),
    Band(id: '3', name: '999999999', votes: 10),
    Band(id: '4', name: 'Parfait', votes: 9),
    
  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text('BandNames', style: TextStyle( color: Colors.black87),),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: bands.length,        
        itemBuilder: ( context, i) => _bandTile( bands[i] )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewsBand,
      ),
    );
  }

  Widget _bandTile( Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direction: $direction');
        print('id: ${band.id}');
        //Llamar el borrado en el server
      },
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white),),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text( band.name ),
        trailing: Text('${ band.votes }', style: TextStyle( fontSize: 20)),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  addNewsBand() {

    final textController = TextEditingController();

    // Android
    if( !Platform.isAndroid) {
      
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Nueva Banda:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text),
              )
            ],
          );
        },
      );
    } 

    // Ios
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Nueva Banda'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: <Widget> [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );

  }

  void addBandToList( String name) {

    if( name.length > 1) {

      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0 ));
    }

    setState(() {});
    Navigator.pop(context);

  }

}



