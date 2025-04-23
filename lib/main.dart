import 'package:flutter/material.dart';
import 'package:rest_apis_porject/sound_test/sound_text_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Recorder App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home:   VoiceRecorderPage(),
    );
  }
}
