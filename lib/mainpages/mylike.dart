import 'package:flutter/material.dart';

class MyLike extends StatefulWidget {
  const MyLike({super.key});

  @override
  State<MyLike> createState() => _MyLikeState();
}

class _MyLikeState extends State<MyLike> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('좋아요한 글'),
    );
  }
}
