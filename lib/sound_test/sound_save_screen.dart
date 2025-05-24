import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_sound/flutter_sound.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart'; // <-- GetX import

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
  Set<String> selectedPaths = {};

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
    final files = dir
        .listSync()
        .where((file) =>
    file.path.endsWith('.aac') || file.path.endsWith('.mp3'))
        .toList();

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

  Future<void> _deleteSelectedRecordings() async {
    final toDelete =
    audioFiles.where((file) => selectedPaths.contains(file.path)).toList();
    for (var file in toDelete) {
      if (_currentlyPlayingPath == file.path) {
        await _stopPlaying();
      }
      if (await File(file.path).exists()) {
        await File(file.path).delete();
      }
    }

    setState(() {
      audioFiles.removeWhere((file) => selectedPaths.contains(file.path));
      selectedPaths.clear();
    });

    // GetX Snackbar
    Get.snackbar(
      'Success',
      '${toDelete.length} recordings deleted',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 3),
    );
  }

  void _showCupertinoMenu(BuildContext context, String filePath) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Options'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Edit'),
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Info',
                'Edit tapped',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue.shade400,
                colorText: Colors.white,
                margin: EdgeInsets.all(10),
                duration: Duration(seconds: 2),
              );
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Share'),
            onPressed: () async {
              Navigator.pop(context);
              if (await File(filePath).exists()) {
                Share.shareXFiles([XFile(filePath)],
                    text: 'Check out this recording');
              } else {
                Get.snackbar(
                  'Error',
                  'File not found',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.shade400,
                  colorText: Colors.white,
                  margin: EdgeInsets.all(10),
                  duration: Duration(seconds: 3),
                );
              }
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Saved Recordings'),
        actions: [
          if (selectedPaths.isNotEmpty)
            IconButton(
              icon: Card(
                shape: CircleBorder(),
                elevation: 11,
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.red.shade100,
                  child: Icon(Icons.delete, color: Colors.red, size: 28),
                ),
              ),
              onPressed: _deleteSelectedRecordings,
            ),
        ],
      ),
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
            final isSelected = selectedPaths.contains(file.path);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedPaths.remove(file.path);
                  } else {
                    selectedPaths.add(file.path);
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                    isSelected ? Colors.red.shade100 : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                    border: GradientBoxBorder(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade100,
                          Colors.purple.shade100,
                        ],
                      ),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(fileName),
                    subtitle: Text("Size: $fileSize\nDate: $fileDate"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          onPressed: () {
                            isPlaying
                                ? _stopPlaying()
                                : _playRecording(file.path);
                          },
                        ),
                        GestureDetector(
                          child: Icon(Icons.more_horiz),
                          onTap: () => _showCupertinoMenu(context, file.path),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
