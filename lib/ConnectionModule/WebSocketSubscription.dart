

import 'dart:convert';
import 'package:schedule_application_conn/ConnectionModule/Post.dart';
import 'package:schedule_application_entities/DataObjects/ScheduleTemplate.dart';
import 'package:schedule_application_entities/DataObjects/WorkerCreationRequest.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'WebSocketConnection.dart';


class WebSocketSubscriptions{
  static final WebSocketSubscriptions _singleton = WebSocketSubscriptions._internal();
  factory WebSocketSubscriptions(){return _singleton;}
  WebSocketSubscriptions._internal();

  StompClient client = WebSocketConnection().client;
  
  void userCreationRequestSubscribe(int storeId, void Function(Post<WorkerCreationRequest> result) onResult) {
      client.subscribe(
          destination: '/app/subscribe/userCreationRequests/' + storeId.toString(),
          callback: (StompFrame frame) {
            try{
              Post<WorkerCreationRequest> result = jsonDecode(frame.body);
              onResult(result);
            }catch(Exception){

            }
          }
      );
  }

  void scheduleTemplate(int storeId, void Function(Post<ScheduleTemplate> result) onResult){
    client.subscribe(
        destination: '/app/subscribe/scheduleTemplate/'+storeId.toString(),
        callback: (StompFrame frame){
          try{
            Post<ScheduleTemplate> result = jsonDecode(frame.body);
            onResult(result);
          }catch(Exception){

          }
        }
    );
  }
}