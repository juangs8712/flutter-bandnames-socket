import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'services/socket_service.dart';

import 'pages/home.dart';
import 'pages/status.dart';

// -----------------------------------------------------------------------------
void main() => runApp(MyApp());

// -----------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      providers: [
        ChangeNotifierProvider(create: (context) => SocketService(),)
      ],
      
      child: MaterialApp(
        debugShowCheckedModeBanner: false ,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          "home" : (context) => const HomePage(),
          "status" : (context) => const StatusPage(),
        },
      ),
    );
  }
}
// -----------------------------------------------------------------------------