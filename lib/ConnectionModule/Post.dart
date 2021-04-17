
import 'package:enum_to_string/enum_to_string.dart';

class Post<T>{
  PostCommand command;
  List<T> resultList;

  Post(this.command, this.resultList);

  Post.fromJson(Map<String,dynamic> json) :
    command = json['command'] != null ? EnumToString.fromString(PostCommand.values, json['command']) : null,
    resultList = json['resultList'];
}

enum PostCommand{
  ADD,
  UPDATE,
  DELETE
}