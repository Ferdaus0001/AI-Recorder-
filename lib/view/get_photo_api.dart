import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/models/photo_models.dart';


class PhotoApiScreen extends StatefulWidget {
  const PhotoApiScreen({super.key});

  @override
  State<PhotoApiScreen> createState() => _PhotoApiScreenState();
}

class _PhotoApiScreenState extends State<PhotoApiScreen> {
  late Future<List<PhtoModles>> photoFuture;

  @override
  void initState() {
    super.initState();
    photoFuture = getPhotos();
  }

  Future<List<PhtoModles>> getPhotos() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
    List<PhtoModles> photoList = [];

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.toString());
      for (Map<String, dynamic> i in data) {
        photoList.add(PhtoModles(
          title: i['title'],
          url: i['url'],
          thumbnailUrl: i['thumbnailUrl'],
        ));
      }
    }
    return photoList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Photo List')),
      body: FutureBuilder<List<PhtoModles>>(
        future: photoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data found"));
          } else {
            final photoList = snapshot.data!;
            return ListView.builder(
              itemCount: photoList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(photoList[index].title),
                    leading: CircleAvatar(backgroundImage: NetworkImage(photoList[index].url)),
                    trailing: CircleAvatar(backgroundImage: NetworkImage(photoList[index].thumbnailUrl)),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
