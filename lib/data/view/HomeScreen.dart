import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rest_apis_porject/data/models/get_post_models.dart';
import 'package:http/http.dart' as http;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
List<PostModles> postList = [];
 Future<List<PostModles>> getPostApi()async{
   final respon = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
   var data = jsonDecode(respon.body.toString());
   if(respon.statusCode ==200){
     for (Map<String, dynamic> i in data) {
       postList.add(PostModles.fromJson(i));
     }
     return postList;

   }else{
     return postList;

   }
 }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: getPostApi(), builder: (context,snapshot){
            if(!snapshot.hasData){

            }else{
              CircularProgressIndicator();
            }
        return ListView.builder(
          itemCount: postList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Text(postList[index].title.toString()),
                subtitle:   Text(postList[index].body.toString()),
                leading:   CircleAvatar(child: Text(postList[index].id.toString()),),
                trailing: CircleAvatar(child: Text(postList[index].userId.toString()),),
                onTap: () {

                },
              ),
            );
          },
        );
      }),


    );
  }
}
