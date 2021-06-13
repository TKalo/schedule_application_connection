
import 'package:schedule_application_conn/ConnectionModule/PasswordEncoder.dart';
import 'package:test/test.dart';

void main(){
  test('user',() {
    expect(PasswordEncoder.encode("test").length, 64);
  });
}