import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:band_name/models/band.dart';
import 'package:band_name/services/socket_service.dart';
import 'package:pie_chart/pie_chart.dart';


class HomePage extends StatefulWidget {  
      
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = <Band>[
  //   Band(id: '1', name: 'Trym', votes: 5),
  //   Band(id: '2', name: 'Cltx', votes: 6),
  //   Band(id: '3', name: '999999999', votes: 10),
  //   Band(id: '4', name: 'Parfait', votes: 9),    
  ];

  @override
  void initState() {    
    
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('Active-Bands', _handleActiveBands);
    super.initState();    
  }

  _handleActiveBands( dynamic payload ) {

    bands = (payload as List)
        .map( (band) => Band.fromMap(band) )
        .toList();

      setState(() {});
  }

  @override
  void dispose() {    
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('Active-Bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return  Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        title: Text('BandNames', style: TextStyle( color: Colors.black87),),
        backgroundColor: Colors.white,
        actions: <Widget> [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: ( socketService.serverStatus == ServerStatus.Online 
              ? Icon( Icons.check_circle, color: Colors.blue[300])
              : Icon( Icons.offline_bolt, color: Colors.red)
            )
          )
        ],
      ),
      body: Column(
        children:<Widget> [

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,        
              itemBuilder: ( context, i) => _bandTile( bands[i] )
            ),
          )

        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewsBand,
      ),
    );
  }

  Widget _bandTile( Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( _ ) => socketService.socket.emit('delete-band', { 'id': band.id }),          
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
        onTap: () => socketService.socket.emit('vote-band', { 'id': band.id } ),
      ),
    );
  }

  addNewsBand() {

    final textController = TextEditingController();

    // Android
    if( Platform.isAndroid) {
      
      return showDialog(
        context: context,
        builder: ( _ ) => AlertDialog(
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
        )        
      );
    } 

    // Ios
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
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
      )      
    );
  }

  void addBandToList( String name) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    if( name.length > 1) {
      // Podemos agregar      
      // Emitir:
      socketService.socket.emit('add-band', { 'name': name} );
    }
    
    Navigator.pop(context);

  }

  //Mostrar Grafica
  Widget _showGraph() {

    Map<String, double> dataMap = new Map(); 
      // "Trym": 5,
      // "99999999": 3,
      // "Parfait": 2,
      // "Omakss": 2,   
      
      bands.forEach((band) {
        dataMap.putIfAbsent( band.name , () => band.votes.toDouble());
       });

      return Container(
        width: double.infinity,
        height: 200,
        child: PieChart(dataMap: dataMap.isEmpty? {'No hay datos ': 0}: dataMap)
      );       
  }      
}



