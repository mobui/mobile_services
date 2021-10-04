

import 'dart:io';

abstract class Utils {
  static const String APPCID =  '7e607988-1b29-4b2f-b357-dd2758bbec75';
  static const String APPID = 'com.agroinvest.pm';
  static const String ENDPOINT = 'https://agroinvest.com';

  static String readFixtureFile(fileName){
    return File('./test/fixture/$fileName').readAsStringSync();
  }
}