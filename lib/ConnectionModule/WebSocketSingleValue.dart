

import 'dart:async';
import 'dart:convert';
import 'package:schedule_application_entities/DataObjects/Store.dart';
import 'package:schedule_application_entities/DataObjects/User.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'WebSocketConnection.dart';

class WebSocketSingleValue{

  StompClient client = WebSocketConnection().client;

  Future<User> getCurrentUser(){
    return WebSocketSingleValueObject<User>(
        debug: false,
        destination: 'currentUser',
        client: client,
        timeout: 8)
        .execute((dynamic json) => User.fromJson(json));
  }

  Future<Store> getCurrentUserStore(){
    return WebSocketSingleValueObject<Store>(
        debug: false,
        destination: 'currentUserStore',
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
        destination: '/user/subscribe/' + destination,
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