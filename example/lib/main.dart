import 'package:flutter/material.dart';
// ignore: unnecessary_library_name, depend_on_referenced_packages
import 'package:error_stack/error_stack.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ErrorStack.init(
    initialRoute: "/",
    level: ErrorStackLogLevel.verbose,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ErrorStack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic data = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(data),
      ),
    );
  }
}
