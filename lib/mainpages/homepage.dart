import 'package:flutter/material.dart';
import 'package:memo_re/cards/postcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  getData() async {
    try {
      var result = await firestore.collection('post').get();
      for (var doc in result.docs) {
        print(doc['name']);
      }
    } catch (e) {
      print('error');
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomRight,
        child: GestureDetector(
          onTap: () {
            print('Container Tapped!');
            // Add more onTap functionality here if needed
          },
          child: Container(
            margin: EdgeInsets.all(15),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), // Made it half of width/height
              color: Color(0xFFF4B353),
            ),
            child: Icon(Icons.add),
          ),
        ),
      ),

    );
  }
}