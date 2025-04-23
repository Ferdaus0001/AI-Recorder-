import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

import 'sound_save_screen.dart'; // ঠিক path ব্যবহার করো

class VoiceRecorderPage extends StatefulWidget {
  const VoiceRecorderPage({super.key});

  @override
  _VoiceRecorderPageState createState() => _VoiceRecorderPageState();
}

class _VoiceRecorderPageState extends State<VoiceRecorderPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _filePath;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    if (kDebugMode) {
      print(_recorder);
    }
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    _filePath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.aacADTS,

    );

    _startTimer();

    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    _stopTimer();

    setState(() => _isRecording = false);
    if (kDebugMode) {
      print('Recording saved at: $_filePath');
    }
  }

  void _startTimer() {
    _elapsedSeconds = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    if (kDebugMode) {
      print(_timer);
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text("Voice Recorder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedTime,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(_isRecording ? "Recording..." : "Press to Record"),
            SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                _isRecording ? _stopRecording() : _startRecording();
              },
              child: CircleAvatar(
                radius: 45,
                backgroundColor: _isRecording ? Colors.red : Colors.blueAccent,
                child: Icon(Icons.mic, size: 33, color: Colors.white),
              ),
            ),

            SizedBox(height: 20),

            if (_filePath != null)
              // Text("Saved: $_filePath"),



            ElevatedButton(
              onPressed: () {
                if (kDebugMode) {
                  print(_isRecording);
                }
                if (_filePath != null) {
                  Get.to(SoundSaveScreen(filePath: _filePath));
                } else {
                  Get.snackbar("No Recording", "Please record something first");
                }
              },
              child: Text('Next Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
