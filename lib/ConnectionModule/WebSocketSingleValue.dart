

import 'dart:async';
import 'dart:convert';

import 'package:schedule_application_conn/ConnectionModule/SpringDests.dart';
import 'package:schedule_application_entities/Entities/Store.dart';
import 'package:schedule_application_entities/Entities/User.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'WebSocketConnection.dart';

class WebSocketSingleValue{

  StompClient client = WebSocketConnection().client;

  Future<User> getCurrentUser({bool debug}){
    return WebSocketSingleValueObject<User>(
        debug: debug,
        destination: SpringDests.currentUser,
        client: client,
        timeout: 8)
        .execute((dynamic json) => User.fromJson(json));
  }

  Future<Store> getCurrentUserStore({bool debug}){
    return WebSocketSingleValueObject<Store>(
        debug: debug,
        destination: SpringDests.currentStore,
        client: client,
        timeout: 8)
        .execute((dynamic json) => Store.fromJson(json));
  }
}



class WebSocketSingleValueObject<T>{

  final bool debug;
  final StompClient client;
  final String destination;
  final int timeout;

  WebSocketSingleValueObject({this.client, this.debug = false, this.destination, this.timeout});

  Future<T> execute(T Function(dynamic) decoder){
    if(debug) print(destination + " - initiated");
    if(client == null) return null;
    if(debug) print(destination + " - client active");
    Completer<T> completer = Completer<T>();

    void Function({Map<String, String> unsubscribeHeaders}) unsubscribe = client.subscribe(
        destination: SpringDests.user + SpringDests.subscribe + destination,
        callback: (StompFrame frame){
          if(debug) print(destination + " - return received");
          if(debug) print(destination + " - return: " + frame.body);
          completer.complete(decoder(jsonDecode(frame.body)));
        }
    );

    completer.future.then((value) => {unsubscribe()}).timeout(Duration(seconds: 8), onTimeout: () async {
      if(debug) print(destination + " - timeout");
      unsubscribe();
      completer.complete(null);
      return null;
    });

    return completer.future;
  }
}