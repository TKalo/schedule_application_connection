

import 'dart:async';
import 'dart:convert';


import 'package:enum_to_string/enum_to_string.dart';
import 'package:schedule_application_entities/DataObjects/ScheduleTemplate.dart';
import 'package:schedule_application_entities/DataObjects/ShiftTemplate.dart';
import 'package:schedule_application_entities/DataObjects/WorkerCreationRequest.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'WebSocketConnection.dart';


class WebSocketRequest{

  StompClient client = WebSocketConnection().client;

  WebSocketRequest();

  Future<bool> addWorkerCreationRequest(WorkerType type){
    return WebSocketRequestObject(
      debug: true,
      destination: 'addWorkerCreationRequest',
      client: client,
      timeout: 8,
      body: jsonEncode({'type' : EnumToString.convertToString(type)})
    ).execute();
  }

  Future<bool> deleteWorkerCreationRequest(int id){
    print("WebSocketRequest - deleteWorkerCreationRequest");
    return WebSocketRequestObject(
      debug: true,
      destination: 'deleteWorkerCreationRequest',
      client: client,
      timeout: 8,
      body: jsonEncode({'id' : id})
    ).execute();
  }

  Future<bool> acceptWorkerCreationRequest(int id){
    return WebSocketRequestObject(
        debug: true,
        destination: 'acceptWorkerCreationRequest',
        client: client,
        timeout: 8,
      body: jsonEncode({'id' : id})
    ).execute();
  }

  Future<bool> setScheduleTemplate(ScheduleTemplate template){
    return WebSocketRequestObject(
      debug: true,
      destination: 'setScheduleTemplate',
      client: client,
      timeout: 8,
      body: jsonEncode(template.toJson())
    ).execute();
  }

  Future<bool> addShift(ShiftTemplate shift){
    return WebSocketRequestObject(
      debug: true,
      destination: 'addShift',
      client: client,
      timeout: 8,
      body: jsonEncode(shift.toJson())
    ).execute();
  }

  Future<bool> updateShift(ShiftTemplate shift){
    return WebSocketRequestObject(
      debug: true,
      destination: 'updateShift',
      client: client,
      timeout: 8,
      body: jsonEncode(shift.toJson()),
    ).execute();
  }

  Future<bool> deleteShift(WorkerType type){
    return WebSocketRequestObject(
      debug: true,
      destination: 'deleteShift',
      client: client,
      timeout: 8,
      body: jsonEncode({'id' : EnumToString.convertToString(type)})
    ).execute();
  }

}

class WebSocketRequestObject{

  final bool debug;
  final StompClient client;
  final String destination;
  final int timeout;
  final String body;

  WebSocketRequestObject({this.debug = false, this.client, this.destination, this.timeout, this.body});

  Future<bool> execute() async {
    if(debug) print(destination + " - initiated");
    if(client == null) return null;
    if(debug) print(destination + " - client active");
    Completer<bool> completer = Completer<bool>();

    void Function({Map<String, String> unsubscribeHeaders}) unsubscribe = client.subscribe(
        destination: '/user/request/' + destination,
        callback: (StompFrame frame){
          print(frame.toString());
          dynamic json = jsonDecode(frame.body);
          if(debug) print(destination + " - return received: " + json.toString());
          completer.complete((json is bool && json));
        }
    );

    client.send(
        destination: '/user/request/'  + destination,
        body: body
    );

    completer.future.then((value) => {unsubscribe()}).timeout(Duration(seconds: 8), onTimeout: () async {
      if(debug) print(destination + " - timeout");
      unsubscribe();
      return null;
    });

    return completer.future;
  }
}