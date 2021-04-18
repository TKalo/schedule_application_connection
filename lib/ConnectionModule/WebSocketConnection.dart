

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:schedule_application_conn/ConnectionModule/PasswordEncoder.dart';
import 'package:schedule_application_entities/DataObjects/User.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

class WebSocketConnection{
  static final WebSocketConnection _singleton = WebSocketConnection._internal();
  factory WebSocketConnection(){return _singleton;}
  WebSocketConnection._internal();

  StompClient client;

  void connect({@required String email,@required String password,@required UserType userType,@required void Function() onConnect,@required void Function(String) onError}) {
    print('login attempt');
    if(email == null || password == null) return null;
    client = StompClient(
      config: StompConfig(
          url: 'ws://localhost:8080/schedule-application-websocket',
          reconnectDelay: Duration(milliseconds: 0),
          onConnect: (frame) => onConnect(),
          onWebSocketError: (error) => onError(error is String ? error : 'could not connect'),
          onStompError: (frame) => onError(frame.headers['message']),
          webSocketConnectHeaders: {'email': email,'password':PasswordEncoder.encode(password), 'usertype' : EnumToString.convertToString(userType)},
          stompConnectHeaders: {'email': email,'password':PasswordEncoder.encode(password), 'usertype' : EnumToString.convertToString(userType)},
          connectionTimeout: Duration(seconds: 10)
      ),
    );

    client.activate();
  }
}