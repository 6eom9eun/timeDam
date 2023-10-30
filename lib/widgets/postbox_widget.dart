import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget buildGrid() {
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Center(child: Text('로그인을 해주세요.'));
  }

  String userId = user.uid;

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: userId)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('오류가 발생했습니다.'));
      }

      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      var posts = snapshot.data!.docs;

      if (posts.isEmpty) {
        return Center(child: Text('게시물이 없습니다.'));
      }

      return GridView.builder(
        itemCount: posts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemBuilder: (context, index) {
          var post = posts[index];
          if (post['imageUrl'] == null) {
            return Center(child: Text('이미지를 불러올 수 없습니다.'));
          }
          return Image.network(post['imageUrl'], fit: BoxFit.cover);
        },
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      );
    },
  );
}
