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
            height: 200,
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
            leading: Icon(Icons.account_circle_outlined),
            title: Text(
              '계정 관리',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 3,
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text(
              '설정',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 3,
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text(
              '이용약관',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 3,
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            leading: Icon(Icons.mail_outline),
            title: Text(
              '문의하기',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 3,
            indent: 20,
            endIndent: 20,
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(
              '로그아웃',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Provider.of<LoginProvider>(context, listen: false).signOut();
              Navigator.pop(context);
            },
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 3,
            indent: 20,
            endIndent: 20,
          ),
        ],
      ),
    );
  }
}