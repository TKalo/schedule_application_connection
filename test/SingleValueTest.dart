

import 'dart:async';

import 'package:schedule_application_conn/ConnectionModule/WebSocketConnection.dart';
import 'package:schedule_application_conn/ConnectionModule/WebSocketSingleValue.dart';
import 'package:schedule_application_entities/Entities/Store.dart';
import 'package:schedule_application_entities/Entities/User.dart';
import 'package:schedule_application_entities/Enums/Enums.dart';
import 'package:test/test.dart';

void main() async{

  setUp(() async {
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

  test('user',() async{
    User user = await WebSocketSingleValue().getCurrentUser(debug: true);
    expect(user != null, true);
    expect(user.id, 0);
    expect(user.storeId, 0);
    expect(user.email, 'temp@temp.temp');
    expect(user.name, 'temp');
    expect(user.type, UserType.store_administrator);
  });

  test('store',() async{
    Store store = await WebSocketSingleValue().getCurrentUserStore(debug: true);
    expect(store != null, true);
    expect(store.id,0);
    expect(store.city,'temp city');
    expect(store.key,'temp key');
    expect(store.address,'temp address');
  });
}



