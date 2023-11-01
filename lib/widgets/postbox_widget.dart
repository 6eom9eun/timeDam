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
        padding: EdgeInsets.all(18),
        itemCount: posts.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200, // 최대 너비를 200으로 설정
          crossAxisSpacing: 18.0,
          mainAxisSpacing: 18.0,
          childAspectRatio: 3 / 4, // 너비와 높이의 비율을 3:4로 설정
        ),
        itemBuilder: (context, index) {
          var post = posts[index];
          var imageUrl = post['imageUrl'];

          if (imageUrl == null) {
            return Center(child: Text('이미지를 불러올 수 없습니다.'));
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(20.0), // 모서리를 둥글게 만듭니다.
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return SizedBox.shrink();
              },
            ),
          );
        },
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      );
    },
  );
}
