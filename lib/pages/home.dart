import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../models/band.dart';

import '../services/socket_service.dart';
// -----------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    super.initState();

    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBand );
  }

  void _handleActiveBand( dynamic payload ){
    bands = ( payload as List ).map((e) => Band.fromMap(e)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socket = Provider.of<SocketService>(context).socket;

    socket.off('active-bands');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Band names', style: TextStyle(color: Colors.black54),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            child:( socketService.serverStatus == ServerStatus.online )
              ? const  Icon(Icons.check_circle, color: Colors.blue,)
              : const  Icon(Icons.offline_bolt, color: Colors.red,),
          )
        ],
      ),
      
      body: Column(
        children: [

          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( context, index ) =>  _bandTile(bands[index]),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: _addNewBand,
        child: const Icon( Icons.add ),  
      ),
    );
  }

  // -----------------------------------------------------------------------------
  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key( band.id ),
      direction: DismissDirection.startToEnd,

      onDismissed: (direction) => socketService.emit( 'delete-band', { 'id' : band.id } ),

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
    
        onTap: () => socketService.emit('vote-band', { 'id' : band.id }),
      ),
    );
  }
  // -----------------------------------------------------------------------------
  void _addNewBand(){

    final textController = TextEditingController();

    if ( Platform.isAndroid || Platform.isWindows ){
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
      builder: (_) => CupertinoAlertDialog(
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
      )
    );

  }
  // -----------------------------------------------------------------------------
  void addBandToList( String name){
    if ( name.length > 1 ){
      final socket = Provider.of<SocketService>(context, listen: false).socket;

      socket.emit('add-band', {'name' : name});      
    }

    Navigator.pop(context);
  }
  // -----------------------------------------------------------------------------
  // mostrar grafica
  Widget _showGraph(){

    Map<String, double> dataMap = Map();

    // dataMap.putIfAbsent('Flutter', () => 5);
    bands.forEach((band) { 
      dataMap.putIfAbsent( band.name, () => band.votes.toDouble() );
    });
    
    final List<Color> colorList = [
      Colors.blue,
      Colors.blueAccent,
      Colors.pink,
      Colors.pinkAccent,
      Colors.yellow,
      Colors.yellowAccent,
    ];


    return Container(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
      width: double.infinity,
      height: 200,
      child: bands.isEmpty 
        ? const CircularProgressIndicator()
        : PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 32,
          chartRadius: MediaQuery.of(context).size.width / 2.7,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 15,
          centerText: '',
          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
      // gradientList: ---To add gradient colors---
      // emptyColorGradient: ---Empty Color gradient---
    )
    );
  }
}
// -----------------------------------------------------------------------------