# slack_login_button

This Flutter plugin is Widget for Slack login.

You can provide Slack login feature by set it to your parent Widget simply.
As result, you will get access_token from callback you specified.

## Getting Started

main.dart of example is simple. This code shows us how to use.
First, you need to create Slack app to fill clientId and secret.
sopce is you can set what you want. In my case, that is users:read permission only.

```
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

```
