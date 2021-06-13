
import 'package:http/http.dart' as http;
import 'package:schedule_application_conn/ConnectionModule/SpringDests.dart';
import 'package:schedule_application_entities/Entities/StoreCreationValues.dart';
import 'package:schedule_application_entities/Entities/UserCreationValues.dart';

class RestConnection{

  static final String url = 'localhost:8080';
  static final Map<String,String> headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    "Access-Control-Allow-Origin": "*", // Required for CORS support to work
  };

  Future<bool> addDepartment (StoreCreationValues values, {void Function(String) onError}) async {
    try {
      http.Response response = await http.post(
          Uri.http(url, SpringDests.department + SpringDests.add),
          headers: headers,
          body: values.toJson()
      );

      if(response.statusCode == 200) return true;
      onError?.call(response.body);
      return false;
    }catch(identifier){
      print(identifier.toString());
      onError?.call(identifier.body);
      return false;
    }
  }


  Future<bool> addUser(UserCreationValues values, {void Function(String) onError}) async {
    try {
      http.Response response = await http.post(
          Uri.http(url, SpringDests.worker + SpringDests.add),
          headers: headers,
          body: values.toJson()
      );

      if(response.statusCode == 200) return true;
      onError?.call(response.body);
      return false;
    }catch(identifier){
      print(identifier.toString());
      onError?.call(identifier.body);
      return false;
    }
  }
}