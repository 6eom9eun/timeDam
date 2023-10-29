import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30.0,
                  child: Text('hi', style: TextStyle(fontSize: 40.0)),
                ),
                SizedBox(height: 10),
                Text(
                  '여기다가 뭐 넣지',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('달력넣어서 날짜 변경하는거 넣으면 좋을 듯'),
            onTap: () {
              // 달력 로직 ~
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}