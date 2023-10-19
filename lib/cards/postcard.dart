import 'package:flutter/material.dart';
class PostCard extends StatefulWidget {
  int? number;
  PostCard({this.number});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.white70,
      child: Center(child: Text(widget.number.toString()+'번 게시글')),
    );
  }
}
