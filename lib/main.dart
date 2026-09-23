import 'package:flutter/material.dart';
import 'package:kayo/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'LabourConnect',

      routerConfig: appRouter,

      theme: ThemeData(
        useMaterial3: true,

        colorSchemeSeed: Colors.tealAccent,

        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
