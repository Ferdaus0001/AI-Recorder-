import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'sound_save_screen.dart';

class VoiceRecorderScreen extends StatefulWidget {
  const VoiceRecorderScreen({super.key});
  @override
  _VoiceRecorderScreenState createState() => _VoiceRecorderScreenState();
}

class _VoiceRecorderScreenState extends State<VoiceRecorderScreen> {
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
    _filePath =
    '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: _filePath, codec: Codec.aacADTS);

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
    String formattedTime =
        '${(_elapsedSeconds ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          CircleAvatar(child: GestureDetector(child: Icon(Icons.settings))),
          SizedBox(width: 20),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              formattedTime,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.black),
            ),
            SizedBox(height: 20),



            GestureDetector(
              onTap: () {
                _isRecording ? _stopRecording() : _startRecording();
              },
              child: Card(
                shape: CircleBorder(),
                elevation: 1111,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: _isRecording ? Colors.red : Colors.blueAccent,
                  child: Icon(Icons.mic, size: 33, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(_isRecording ? "Recording..." : "Press to Record",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
            SizedBox(height: 20),


          ],
        ),
      ),
        bottomNavigationBar: (_filePath != null)
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            height: 55.h,
            child: ElevatedButton(
             style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 15,
                side: BorderSide(color: Colors.blue.shade100, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                if (_isRecording) {
                  Get.snackbar(
                    "Recording in progress",
                    "Please stop recording before proceeding",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade400,
                    colorText: Colors.white,
                    margin: EdgeInsets.all(10),
                    duration: Duration(seconds: 3),
                  );
                  return;
                }
                if (_filePath != null) {
                  Get.to(SoundSaveScreen(filePath: _filePath));
                } else {
                  Get.snackbar(
                    "No Recording",
                    "Please record something first",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange.shade400,
                    colorText: Colors.white,
                    margin: EdgeInsets.all(10),
                    duration: Duration(seconds: 3),
                  );
                }
              },
              child: Text('Next Screen'),
            ),
          ),
        )
            : SizedBox.shrink(),


    );
  }
}
