import 'package:flutter/material.dart';

Widget buildBox(Color color) {
  return Container(
    color: color,
    height: 100, // 박스 높이 조정
    width: double.infinity, // 가로로 확장
  );
}

Widget buildGrid(int count) {
  List<Widget> boxes = List.generate(
    count,
        (index) => buildBox(index % 2 == 0 ? Colors.grey : Colors.deepOrangeAccent),
  );

  return GridView.count(
    physics: NeverScrollableScrollPhysics(), // 그리드뷰 자체의 스크롤을 비활성화
    crossAxisCount: 2, // 가로로 2개씩 정렬
    crossAxisSpacing: 10.0, // 가로 간격 설정
    mainAxisSpacing: 10.0, // 세로 간격 설정
    shrinkWrap: true, // 그리드 크기를 그리드 내용에 맞게 자동 조정
    children: boxes,
  );
}