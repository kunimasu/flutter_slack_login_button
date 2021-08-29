import 'package:flutter/material.dart';
import 'package:slack_login_button/slack_login_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final clientId = 'clientId';
    final clientSecret = 'secret';
    final scope = ['users:read'];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Slack login button example'),
        ),
        body: Center(
          child: SlackLoginButton(
            clientId,
            clientSecret,
            scope,
            (token) {
              print(token?.accessToken);
            },
          ),
        ),
      ),
    );
  }
}
