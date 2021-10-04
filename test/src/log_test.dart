import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_services/mobile_services.dart';
void main() {
  const String APPCID = 'b7b52744-cc9c-4947-b63a-3e7a4527c172';
  const String result = '#2021-09-27T12:05:30.000Z#DEBUG#b7b52744-cc9c-4947-b63a-3e7a4527c172#File#File#message';

  test('Model for log. Print log', () {
    final log = Log(
      timestamp: DateTime.utc(2021, 9, 27, 12, 5, 30),
      level: LogLevel.DEBUG,
      appcid: APPCID,
      location: 'File',
      source: 'File',
      message: 'message',
    );
    expect(log.toString(), result);
  });

  test('Logger', (){

  });
}
