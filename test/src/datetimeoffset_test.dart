import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_services/mobile_services.dart';

main() {
  test("Parse with 0000 offset", (){
    final date = r'\/Date(1576230151000+0000)\/';
    final dto = EdmDateTimeOffset.parse(date);
    expect(dto.value, DateTime.parse('2019-12-13 09:42:31.000Z'));
  });

  test("Parse with +0060 offset", (){
    final date = r'\/Date(1576230151000+0060)\/';
    final dto = EdmDateTimeOffset.parse(date);
    expect(dto.value, DateTime.parse('2019-12-13 08:42:31.000Z'));
  });

  test("Parse with -0060 offset", (){
    final date = r'\/Date(1576230151000-0060)\/';
    final dto = EdmDateTimeOffset.parse(date);
    expect(dto.value, DateTime.parse('2019-12-13 10:42:31.000Z'));
  });

  test("Parse without offset", (){
    final date = r'\/Date(1576230151000)\/';
    final dto = EdmDateTimeOffset.parse(date);
    expect(dto.value, DateTime.parse('2019-12-13 09:42:31.000Z'));
  });

  test("To query", (){
    final date = r'\/Date(1576230151000)\/';
    final query = EdmDateTimeOffset.parse(date).query;
    expect(query, "datetimeoffset'2019-12-13T09:42:31.000Z'");
  });

  test("To json", (){
    final date = r'\/Date(1576230151000)\/';
    final query = EdmDateTimeOffset.parse(date).json;
    expect(query, r'\/Date(1576230151000+0000)\/');
  });
}