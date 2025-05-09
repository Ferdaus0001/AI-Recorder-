import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

class DeleatProdectScreen extends StatefulWidget {
  const DeleatProdectScreen({super.key});

  @override
  State<DeleatProdectScreen> createState() => _DeleatProdectScreenState();
}

class _DeleatProdectScreenState extends State<DeleatProdectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        shrinkWrap: true,
        itemBuilder: (context, indext) {
          return Container(
            height: 100,
            width: double.infinity,
            color: Colors.blue,
            child: Center(child: Text('Product $indext')),
          );
        },
      ),
    );
  }
}
