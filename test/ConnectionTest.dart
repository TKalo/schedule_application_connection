

import 'dart:async';

import 'package:schedule_application_entities/Enums/Enums.dart';
import 'package:test/test.dart';
import 'package:schedule_application_conn/ConnectionModule/WebSocketConnection.dart';


void main() async{

  test('connection', () async {

    Completer<bool> connectionCompleter = Completer();

    WebSocketConnection().connect(
        email: 'temp@temp.temp',
        password: 'temp',
        userType: UserType.store_administrator,
        onConnect: () => connectionCompleter.complete(true),
        onError: (string) {connectionCompleter.complete(false); print(string);}
    );

    //SingleValue tests
    expect(await connectionCompleter.future, true, reason: 'connection failed');

  });
}



