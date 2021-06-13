

import 'dart:async';
import 'dart:convert';

import 'package:schedule_application_conn/ConnectionModule/SpringDests.dart';
import 'package:schedule_application_entities/Entities/ScheduleTemplate.dart';
import 'package:schedule_application_entities/Entities/ShiftTemplate.dart';
import 'package:schedule_application_entities/Enums/Enums.dart';
import 'package:schedule_application_entities/Helper/EnumParser.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'WebSocketConnection.dart';


class WebSocketRequest{

  StompClient client = WebSocketConnection().client;

  WebSocketRequest();

  Future<bool> addWorkerCreationRequest(WorkerType type,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: SpringDests.workerCreationRequest + SpringDests.add,
      client: client,
      timeout: 8,
      body: jsonEncode({'type' : EnumParser().enumToString(type)})
    ).execute();
  }

  Future<bool> deleteWorkerCreationRequest(int id,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: SpringDests.workerCreationRequest + SpringDests.delete,
      client: client,
      timeout: 8,
      body: jsonEncode({'id' : id})
    ).execute();
  }

  Future<bool> acceptWorkerCreationRequest(int id,{bool debug}){
    return WebSocketRequestObject(
        debug: debug,
        destination: SpringDests.workerCreationRequest + SpringDests.accept,
        client: client,
        timeout: 8,
      body: jsonEncode({'id' : id})
    ).execute();
  }

  Future<bool> setScheduleTemplate(ScheduleTemplate template,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: SpringDests.scheduleTemplate + SpringDests.update,
      client: client,
      timeout: 8,
      body: jsonEncode(template.toJson())
    ).execute();
  }

  Future<bool> addShift(ShiftTemplate shift,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: SpringDests.shiftTemplate + SpringDests.add,
      client: client,
      timeout: 8,
      body: jsonEncode(shift.toJson())
    ).execute();
  }

  Future<bool> updateShift(ShiftTemplate shift,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: SpringDests.shiftTemplate + SpringDests.update,
      client: client,
      timeout: 8,
      body: jsonEncode(shift.toJson()),
    ).execute();
  }

  Future<bool> deleteShift(int id,{bool debug}){
    return WebSocketRequestObject(
      debug: debug,
      destination: SpringDests.shiftTemplate + SpringDests.delete,
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
        destination: SpringDests.user + SpringDests.request + destination,
        callback: (StompFrame frame){
          dynamic json = jsonDecode(frame.body);
          if(debug ?? false) print(destination + " - return received: " + json.toString());
          completer.complete((json is bool && json));
        }
    );

    if(debug ?? false) print(destination + " - body sent: " + body.toString());
    client.send(
        destination: SpringDests.user + SpringDests.request  + destination,
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