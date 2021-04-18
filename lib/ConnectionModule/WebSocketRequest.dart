

import 'dart:async';
import 'dart:convert';


import 'package:enum_to_string/enum_to_string.dart';
import 'package:schedule_application_entities/DataObjects/ScheduleTemplate.dart';
import 'package:schedule_application_entities/DataObjects/ShiftTemplate.dart';
import 'package:schedule_application_entities/DataObjects/WorkerCreationRequest.dart';
import 'package:schedule_application_entities/EnumParser.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'WebSocketConnection.dart';


class WebSocketRequest{

  StompClient client = WebSocketConnection().client;

  WebSocketRequest();

  Future<bool> addWorkerCreationRequest(WorkerType type,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: 'addWorkerCreationRequest',
      client: client,
      timeout: 8,
      body: jsonEncode({'type' : EnumParser().enumToString(type)})
    ).execute();
  }

  Future<bool> deleteWorkerCreationRequest(int id,{bool debug}){
    print("WebSocketRequest - deleteWorkerCreationRequest");
    return WebSocketRequestObject(
      debug: debug,
      destination: 'deleteWorkerCreationRequest',
      client: client,
      timeout: 8,
      body: jsonEncode({'id' : id})
    ).execute();
  }

  Future<bool> acceptWorkerCreationRequest(int id,{bool debug}){
    return WebSocketRequestObject(
        debug: debug,
        destination: 'acceptWorkerCreationRequest',
        client: client,
        timeout: 8,
      body: jsonEncode({'id' : id})
    ).execute();
  }

  Future<bool> setScheduleTemplate(ScheduleTemplate template,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: 'setScheduleTemplate',
      client: client,
      timeout: 8,
      body: jsonEncode(template.toJson())
    ).execute();
  }

  Future<bool> addShift(ShiftTemplate shift,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: 'addShiftTemplate',
      client: client,
      timeout: 8,
      body: jsonEncode(shift.toJson())
    ).execute();
  }

  Future<bool> updateShift(ShiftTemplate shift,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: 'updateShiftTemplate',
      client: client,
      timeout: 8,
      body: jsonEncode(shift.toJson()),
    ).execute();
  }

  Future<bool> deleteShift(int id,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: 'deleteShiftTemplate',
      client: client,
      timeout: 8,
      body: jsonEncode({'id' : id})
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
    if(debug ?? false) print(destination + " - initiated");
    if(client == null) return null;
    if(debug ?? false) print(destination + " - client active");
    Completer<bool> completer = Completer<bool>();

    void Function({Map<String, String> unsubscribeHeaders}) unsubscribe = client.subscribe(
        destination: '/user/request/' + destination,
        callback: (StompFrame frame){
          dynamic json = jsonDecode(frame.body);
          if(debug ?? false) print(destination + " - return received: " + json.toString());
          completer.complete((json is bool && json));
        }
    );

    if(debug ?? false) print(destination + " - body sent: " + body.toString());
    client.send(
        destination: '/user/request/'  + destination,
        body: body
    );

    completer.future.then((value) => {unsubscribe()}).timeout(Duration(seconds: 8), onTimeout: () async {
      if(debug ?? false) print(destination + " - timeout");
      unsubscribe();
      return null;
    });

    return completer.future;
  }
}