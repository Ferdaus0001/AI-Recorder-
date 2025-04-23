import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class SoundSaveScreen extends StatefulWidget {
  final String? filePath;

  const SoundSaveScreen({super.key, this.filePath});

  @override
  State<SoundSaveScreen> createState() => _SoundSaveScreenState();
}

class _SoundSaveScreenState extends State<SoundSaveScreen> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? _currentlyPlayingPath;
  List<FileSystemEntity> audioFiles = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Permission.storage.request();
    await _player.openPlayer();
    await _loadFiles();
  }

  Future<void> _loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().where((file) =>
    file.path.endsWith('.aac') || file.path.endsWith('.mp3')).toList();

    setState(() {
      audioFiles = files;
    });
  }

  Future<void> _playRecording(String path) async {
    if (_currentlyPlayingPath != null) {
      await _player.stopPlayer();
    }

    await _player.startPlayer(
      fromURI: path,
      whenFinished: () {
        setState(() {
          _currentlyPlayingPath = null;
        });
      },
    );

    setState(() {
      _currentlyPlayingPath = path;
    });
  }

  Future<void> _stopPlaying() async {
    await _player.stopPlayer();
    setState(() {
      _currentlyPlayingPath = null;
    });
  }

  bool _isPlaying(String path) => _currentlyPlayingPath == path;

  void _deleteRecording(FileSystemEntity file) async {
    if (await File(file.path).exists()) {
      if (_currentlyPlayingPath == file.path) {
        await _stopPlaying();
      }

      await File(file.path).delete();
      setState(() {
        audioFiles.remove(file);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recording deleted')),
      );
    }
  }

  String _getFileSize(File file) {
    final sizeInBytes = file.lengthSync();
    final sizeInKB = (sizeInBytes / 1024).toStringAsFixed(2);
    return "$sizeInKB KB";
  }

  String _getFileDate(File file) {
    final lastModified = file.lastModifiedSync();
    return DateFormat('yyyy-MM-dd – hh:mm a').format(lastModified);
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved Recordings')),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: audioFiles.isEmpty
            ? Center(child: Text("No recordings found"))
            : ListView.builder(
          itemCount: audioFiles.length,
          itemBuilder: (context, index) {
            final file = audioFiles[index] as File;
            final fileName = file.path.split('/').last;
            final fileSize = _getFileSize(file);
            final fileDate = _getFileDate(file);
            final isPlaying = _isPlaying(file.path);

            return Card(
              child: ListTile(
                title: Text(fileName),
                subtitle: Text("Size: $fileSize\nDate: $fileDate"),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        isPlaying
                            ? _stopPlaying()
                            : _playRecording(file.path);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRecording(file),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
