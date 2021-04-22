

import 'dart:async';

import 'package:schedule_application_conn/ConnectionModule/WebSocketConnection.dart';
import 'package:schedule_application_conn/ConnectionModule/WebSocketRequest.dart';
import 'package:schedule_application_conn/ConnectionModule/WebSocketSubscription.dart';
import 'package:schedule_application_entities/DataObjects/Post.dart';
import 'package:schedule_application_entities/DataObjects/ShiftTemplate.dart';
import 'package:schedule_application_entities/DataObjects/User.dart';
import 'package:schedule_application_entities/DataObjects/WorkerCreationRequest.dart';
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

  test('WorkerCreationRequest',() async {

    //Setup subscription
    bool checkPending = false;
    bool checkAccepted = false;
    bool checkDeleted = false;

    Completer<WorkerCreationRequest> requestCompleter = Completer();
    Completer<bool> completer = Completer();
    WebSocketSubscriptions().userCreationRequest(0, (Post<WorkerCreationRequest> result) {
      if(result.resultList.first.id != 0 && !requestCompleter.isCompleted){ requestCompleter.complete(result.resultList.last);}
      if(result.resultList.first.id != 0 && result.resultList.last.status == WorkerCreationStatus.accepted) checkAccepted = true;
      if(result.resultList.first.id != 0 && result.resultList.last.status == WorkerCreationStatus.pending) checkPending = true;
      if(result.resultList.first.id != 0 && result.command == PostCommand.DELETE) checkDeleted = true;
      if(checkPending && checkAccepted && checkDeleted) completer.complete(true);
    },(Map<String,dynamic> json){return WorkerCreationRequest.fromJson(json);}, debug: true);
    //Add
    WebSocketRequest().addWorkerCreationRequest(WorkerType.below_eighteen);

    WorkerCreationRequest request = await requestCompleter.future;

    //Accept
    WebSocketRequest().acceptWorkerCreationRequest(request.id);

    //Delete
    WebSocketRequest().deleteWorkerCreationRequest(request.id);

    await completer.future.timeout(Duration(seconds: 10), onTimeout: (){return false;});
    expect(checkPending, true,reason: 'request not added');
    expect(checkAccepted, true,reason: 'request not accepted');
    expect(checkDeleted, true,reason: 'request not deleted');
  });

  test('ShiftTemplate',() async {

    //Setup subscription

    Completer<ShiftTemplate> addCompleter = Completer();
    Completer<ShiftTemplate> updateCompleter = Completer();
    Completer<ShiftTemplate> deleteCompleter = Completer();

    WebSocketSubscriptions().shiftTemplate(0, (Post<ShiftTemplate> result) {
      if(result.resultList.first.id == 0) return;
      if(result.command == PostCommand.ADD && !addCompleter.isCompleted){ addCompleter.complete(result.resultList.last);}
      if(result.command == PostCommand.UPDATE && !updateCompleter.isCompleted){ updateCompleter.complete(result.resultList.last);}
      if(result.command == PostCommand.DELETE && !deleteCompleter.isCompleted){ deleteCompleter.complete(result.resultList.last);}

    },(Map<String,dynamic> json){return ShiftTemplate.fromJson(json);});

    //Add
    ShiftTemplate shift = ShiftTemplate(storeId: 1,startTime: DateTime(2000,3,4,5,6,7),endTime: DateTime(2001,4,5,6,7,8), weekDay: WeekDay.friday, workerType: WorkerType.below_eighteen);
    WebSocketRequest().addShift(shift, debug: true);
    shift = await addCompleter.future.timeout(Duration(seconds: 8), onTimeout: () => null);
    expect(shift != null, true,reason: 'shift never added');
    expect(shift.startTime, DateTime(2000,3,4,5,6,7),reason: 'startTime wrong');
    expect(shift.endTime,DateTime(2001,4,5,6,7,8),reason: 'endTime wrong');
    expect(shift.weekDay, WeekDay.friday,reason: 'weekday wrong');
    expect(shift.workerType,WorkerType.below_eighteen,reason: 'workerType wrong');

    //Update
    shift.workerType = WorkerType.eighteen_plus;
    shift.weekDay = WeekDay.saturday;
    shift.startTime = DateTime(2002,3,4,5,6,7);
    shift.endTime = DateTime(2003,3,4,5,6,7);
    WebSocketRequest().updateShift(shift);
    shift = await updateCompleter.future.timeout(Duration(seconds: 8), onTimeout: () => null);
    expect(shift != null, true,reason: 'shift never updated');
    expect(shift.startTime, DateTime(2002,3,4,5,6,7),reason: 'startTime wrong');
    expect(shift.endTime,DateTime(2003,3,4,5,6,7),reason: 'endTime wrong');
    expect(shift.weekDay, WeekDay.saturday,reason: 'weekday wrong');
    expect(shift.workerType,WorkerType.eighteen_plus,reason: 'workerType wrong');

    //Delete
    WebSocketRequest().deleteShift(shift.id);
    shift = await deleteCompleter.future.timeout(Duration(seconds: 8), onTimeout: () => null);
    expect(shift != null, true,reason: 'shift never deleted');
    expect(shift.startTime, DateTime(2002,3,4,5,6,7),reason: 'startTime wrong');
    expect(shift.endTime,DateTime(2003,3,4,5,6,7),reason: 'endTime wrong');
    expect(shift.weekDay, WeekDay.saturday,reason: 'weekday wrong');
    expect(shift.workerType,WorkerType.eighteen_plus,reason: 'workerType wrong');

  });

}



