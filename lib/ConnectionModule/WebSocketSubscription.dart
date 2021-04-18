

import 'dart:convert';
import 'package:schedule_application_entities/DataObjects/Post.dart';
import 'package:schedule_application_entities/DataObjects/ScheduleTemplate.dart';
import 'package:schedule_application_entities/DataObjects/ShiftTemplate.dart';
import 'package:schedule_application_entities/DataObjects/WorkerCreationRequest.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'WebSocketConnection.dart';


class WebSocketSubscriptions{
  static final WebSocketSubscriptions _singleton = WebSocketSubscriptions._internal();
  factory WebSocketSubscriptions(){return _singleton;}
  WebSocketSubscriptions._internal();

  StompClient client = WebSocketConnection().client;
  
  void userCreationRequest(int storeId, void Function(Post<WorkerCreationRequest> result) onResult,WorkerCreationRequest Function(Map<String,dynamic>) jsonToElement,{bool debug}) {
    WebSocketSubscriptionObject<WorkerCreationRequest>(
        client: client,
        id: storeId,
        debug: debug,
        destination: 'userCreationRequests'
    ).execute(onResult,jsonToElement);
  }

  void scheduleTemplate(int storeId, void Function(Post<ScheduleTemplate> result) onResult, ScheduleTemplate Function(Map<String,dynamic>) jsonToElement,{bool debug}) {
    WebSocketSubscriptionObject<ScheduleTemplate>(
        client: client,
        id: storeId,
        debug: debug,
        destination: 'scheduleTemplate'
    ).execute(onResult,jsonToElement);
  }

  void shiftTemplate(int storeId, void Function(Post<ShiftTemplate> result) onResult, ShiftTemplate Function(Map<String,dynamic>) jsonToElement,{bool debug}) {
    WebSocketSubscriptionObject<ShiftTemplate>(
        client: client,
        id: storeId,
        debug: debug,
        destination: 'shiftTemplate'
    ).execute(onResult,jsonToElement);
  }
}

class WebSocketSubscriptionObject<T>{
  final StompClient client;
  final int id;
  final bool debug;
  final String destination;

  WebSocketSubscriptionObject({this.client, this.id, this.debug = false, this.destination});

  void execute(void Function(Post<T> result) onResult, T Function(Map<String,dynamic>) jsonToElement){

    client.subscribe(
        destination: '/app/subscribe/' + destination + '/' + id.toString(),
        callback: (StompFrame frame){
          if(debug ?? false) print('WebSocketSubscriptions - ' + destination + ' - return-header: ' + frame.headers.toString());
          if(debug ?? false) print('WebSocketSubscriptions - ' + destination + ' - return-body: ' + frame.body.toString());
          try{
            Post<T> result = Post.fromJson(jsonDecode(frame.body),jsonToElement);
            onResult(result);
          }catch(identifier){
            if(debug ?? false) print('WebSocketSubscriptions - ' + destination + ' - error: ' + identifier.toString());
          }
        }
    );
  }
}