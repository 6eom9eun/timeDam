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

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  var postText = post['text']; // 컬렉션에서 텍스트 데이터를 가져옵니다.
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min, // Column의 크기를 내용물에 맞게 조절합니다.
                      children: <Widget>[
                        Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10), // 이미지와 텍스트 사이에 간격을 추가합니다.
                        Text(
                          postText ?? '텍스트가 없습니다.', // postText가 null이면 대체 텍스트를 표시합니다.
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('닫기'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },

            child: ClipRRect(
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
            ),
          );
        },

        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      );
    },
  );
}