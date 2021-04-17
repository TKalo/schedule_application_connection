
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:schedule_application_entities/DataObjects/StoreCreationValues.dart';
import 'package:schedule_application_entities/DataObjects/UserCreationValues.dart';

import 'PasswordEncoder.dart';

class RestConnection{
  static final RestConnection _singleton = RestConnection._internal();
  factory RestConnection(){return _singleton;}
  RestConnection._internal();

  final String url = 'localhost:8080';
  final Map<String,String> headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    "Access-Control-Allow-Origin": "*", // Required for CORS support to work
  };

  Future<bool> addDepartment (StoreCreationValues values) async {
    try {
      http.Response response = await http.post(
          Uri.http(url, '/addDepartment'),
          headers: headers,
          body: jsonEncode(<String,String>{
            'name' : values.name,
            'email' : values.email,
            'password' : PasswordEncoder.encode(values.password),
            'address' : values.address,
            'city' : values.city,
          })
      );

      if(response.statusCode == 200) return true;
      return false;
    }catch(identifier){
      print(identifier.toString());
      return false;
    }
  }


  Future<bool> addUser(UserCreationValues values, void Function(String) onError) async {
    try {
      http.Response response = await http.post(
          Uri.http(url, '/addWorker'),
          headers: headers,
          body: jsonEncode(<String,String>{
            'key' : values.key,
            'name' : values.name,
            'email' : values.email,
            'password' : PasswordEncoder.encode(values.password),
          })
      );

      if(response.statusCode == 200) return true;
      onError(response.body);
      return false;
    }catch(identifier){
      print(identifier.toString());
      return false;
    }
  }
}