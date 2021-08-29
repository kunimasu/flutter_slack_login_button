import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;

/// Access token callback tpye
typedef TokenCallback = void Function(Token? token);

/// Slack sign in button
class SlackLoginButton extends StatefulWidget {
  final String _clientId;
  final String _clientSecret;
  final List<String> _scope;
  final String? _redirectUrl;
  final String? _state;
  final String? _team;
  final TokenCallback _onFinished;
  final VoidCallback? _onCancelled;

  SlackLoginButton(
    this._clientId,
    this._clientSecret,
    this._scope,
    this._onFinished, {
    String? redirectUrl,
    String? state,
    String? team,
    VoidCallback? onCancelled,
  })  : _redirectUrl = redirectUrl,
        _state = state,
        _team = team,
        _onCancelled = onCancelled;

  @override
  _SlackLoginButtonState createState() => _SlackLoginButtonState();
}

/// State for Slack sign in button
class _SlackLoginButtonState extends State<SlackLoginButton> {
  FlutterWebviewPlugin? _flutterWebviewPlugin;
  StreamSubscription<String>? _urlChangedSubscription;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.button,
      color: Colors.white,
      child: InkWell(
        onTap: () => onTap(context),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              const Radius.circular(
                4,
              ),
            ),
            border: Border.all(
              width: 1,
              color: Colors.white54,
            ),
          ),
          child: Container(
            padding: EdgeInsets.only(
              right: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  'packages/slack_login_button/assets/images/slack_logo.png',
                  width: 44,
                  height: 44,
                ),
                Text('Sign in with '),
                Text(
                  'Slack',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Call if tap slack sign in button
  onTap(BuildContext context) async {
    _subscribeUrlChanged(context);
    final params = {
      'client_id': widget._clientId,
      'scope': widget._scope.join(','),
    };
    if (widget._redirectUrl != null) {
      params['redirect_uri'] = widget._redirectUrl!;
    }
    if (widget._state != null) {
      params['state'] = widget._state!;
    }
    if (widget._team != null) {
      params['team'] = widget._team!;
    }
    final url = Uri.https('slack.com', '/oauth/authorize', params).toString();
    final success = await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (context) {
          return WebviewScaffold(
            appBar: AppBar(
              title: Text("Sign in with Slack"),
            ),
            url: url,
          );
        },
      ),
    );
    if (widget._onCancelled != null && success == null) {
      _urlChangedSubscription?.cancel();
      widget._onCancelled!();
    }
  }

  /// Subscribe url changed on web view
  _subscribeUrlChanged(BuildContext context) {
    _flutterWebviewPlugin = FlutterWebviewPlugin();
    _urlChangedSubscription?.cancel();
    _urlChangedSubscription =
        _flutterWebviewPlugin?.onUrlChanged.listen((String changedUrl) async {
      if (changedUrl.contains("slack.com")) return;
      Token? token;
      if (widget._redirectUrl == null ||
          widget._redirectUrl!.startsWith(changedUrl)) {
        final uri = Uri().resolve(changedUrl);
        final code = uri.queryParameters['code'];
        final state = uri.queryParameters['state'];
        if (code == null || (widget._state != null && widget._state != state)) {
        } else {
          final body = {
            "client_id": widget._clientId,
            "client_secret": widget._clientSecret,
            "code": code,
          };
          if (widget._redirectUrl != null) {
            body['redirect_uri'] = widget._redirectUrl!;
          }
          final response = await http.post(
            Uri.https('slack.com', '/api/oauth.access'),
            body: body,
          );
          token = Token.from(json.decode(response.body));
        }
      }
      _urlChangedSubscription?.cancel();
      widget._onFinished(token);
      Navigator.of(context).pop(true);
    });
  }
}

/// Struct for access token
class Token {
  final String accessToken;
  Token.from(Map json) : accessToken = json['access_token'];
}
