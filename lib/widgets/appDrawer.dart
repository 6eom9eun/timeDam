import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memo_re/providers/loginProvider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFFEEEEEE),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: 20,
            height: 210,
            child: DrawerHeader(
              decoration: BoxDecoration(
              ),
              child: Consumer<LoginProvider>(
                builder: (context, provider, child) {
                  if (provider.userInformation != null) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(provider
                              .userInformation!.profileUrl),
                          radius: 40,
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(width: 20), // Space between avatar and texts
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              provider.userInformation!.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 23,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'remind your memory',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.7),
                                // Adjust opacity as needed
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    );
                  }
                },
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('설정'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('계정 관리'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('정보'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('로그아웃'),
            onTap: () {
              Provider.of<LoginProvider>(context, listen: false).signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}