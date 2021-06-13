import 'dart:async';

import 'package:schedule_application_conn/ConnectionModule/WebSocketConnection.dart';
import 'package:schedule_application_conn/ConnectionModule/WebSocketSubscription.dart';
import 'package:schedule_application_entities/Entities/Post.dart';
import 'package:schedule_application_entities/Entities/ScheduleTemplate.dart';
import 'package:schedule_application_entities/Entities/ShiftTemplate.dart';
import 'package:schedule_application_entities/Entities/WorkerCreationRequest.dart';
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

  test('workerCreationRequest', () async {
    Completer<Post<dynamic>> completer = Completer();
    WebSocketSubscriptions().userCreationRequest(0, (result) => completer.complete(result),(Map<String,dynamic> json){return WorkerCreationRequest.fromJson(json);}, debug: true);
    Post<dynamic> post = await completer.future.timeout(Duration(seconds: 8),onTimeout: (){return null;});

    expect(post != null, true, reason: 'post is null');
    expect(post is Post<WorkerCreationRequest>, true);
    expect(post.command, PostCommand.ADD, reason: 'wrong command');
    expect(post.resultList.length > 0, true,reason: 'wrong resultList length');

    WorkerCreationRequest request = post.resultList.first;
    expect(request != null, true,reason: 'request is null');
    expect(request.id,0);
    expect(request.type,WorkerType.below_eighteen);
    expect(request.key,'temp key');
    expect(request.status,WorkerCreationStatus.pending);
  });

  test('scheduleTemplate', () async {
    Completer<Post<dynamic>> completer = Completer();
    WebSocketSubscriptions().scheduleTemplate(0, (result) => completer.complete(result),(Map<String,dynamic> json){return ScheduleTemplate.fromJson(json);}, debug: true);
    Post<dynamic> post = await completer.future.timeout(Duration(seconds: 8),onTimeout: (){return null;});
    expect(post != null, true, reason: 'post is null');
    expect(post is Post<ScheduleTemplate>, true);
    expect(post.command, PostCommand.ADD, reason: 'wrong command');
    expect(post.resultList.length > 0, true,reason: 'wrong resultList length');

    ScheduleTemplate template = post.resultList.first;
    expect(template != null, true,reason: 'request is null');
    expect(template.storeId,0);
    expect(template.weeks,1);
    expect(template.preferenceDeadline,DateTime(2000,3,4,5,6,7));
    expect(template.creationDeadline,DateTime(2001,4,5,6,7,8));
    expect(template.initiationDeadline,DateTime(2002,5,6,7,8,9));
  });

  test('ShiftTemplate', () async {
    Completer<Post<dynamic>> completer = Completer();
    WebSocketSubscriptions().shiftTemplate(0, (result) => completer.complete(result),(Map<String,dynamic> json){return ShiftTemplate.fromJson(json);}, debug: true);
    Post<dynamic> post = await completer.future.timeout(Duration(seconds: 8),onTimeout: (){return null;});
    expect(post != null, true, reason: 'post is null');
    expect(post is Post<ShiftTemplate>, true);
    expect(post.command, PostCommand.ADD, reason: 'wrong command');
    expect(post.resultList.length > 0, true,reason: 'wrong resultList length');

    ShiftTemplate template = post.resultList.first;
    expect(template != null, true,reason: 'request is null');
    expect(template.id,0);
    expect(template.storeId,0);
    expect(template.startTime,DateTime(2000,3,4,5,6,7));
    expect(template.endTime,DateTime(2001,4,5,6,7,8));
    expect(template.weekDay,WeekDay.friday);
    expect(template.workerType,WorkerType.below_eighteen);
  });
}


