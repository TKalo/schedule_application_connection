
import 'dart:convert';

import 'package:crypto/crypto.dart';

class PasswordEncoder{

  final Hmac hasher = Hmac(sha256, utf8.encode("@secretkey"));

  static String encode(String string){
    if(string == null || string.isEmpty) return null;
    return Hmac(sha256, utf8.encode("@secretkey")).convert(utf8.encode(string)).toString();
  }
}