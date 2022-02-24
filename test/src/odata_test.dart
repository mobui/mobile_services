import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_services/mobile_services.dart';
import 'package:mockito/mockito.dart';

import '../fixture/utils.dart';
import 'registration_test.mocks.dart';

main() {
  final props = MobileServicesProps(
      endpoint: Utils.ENDPOINT,
      appid: Utils.APPID,
      techUsername: '',
      techPassword: '', server: '');
  final auth = MobileServicesAuth.basic(username: 'hello', password: 'world');

  group('Edm type test', () {
    test('Edm string test', () {
      final value1 = EdmType.string('Hello');
      final value2 = EdmType.string('Hello');
      final value3 = EdmType.string('Hello1');

      expect(value1, value2);
      expect(value1, isNot(equals(value3)));
      expect(value1.value, 'Hello');
      expect(value1.json, 'Hello');
      expect(value1.query, '\'Hello\'');
      expect(value1.toString(), 'Hello');
    });

    test('Edm boolean test', () {
      final value1 = EdmType.boolean(true);
      final value2 = EdmType.boolean(true);
      final value3 = EdmType.boolean(false);

      expect(value1, value2);
      expect(value1, isNot(equals(value3)));
      expect(value1.value, true);
      expect(value1.json, true);
      expect(value1.query, 'true');
      expect(value1.toString(), 'true');
    });
  });

  group('Create entity text', () {
    late MobileServicesClient client;
    late MockDio httpClient;

    setUp(() {
      httpClient = MockDio();
      when(httpClient.interceptors).thenReturn(Interceptors());
      when(
        httpClient.get(
          any,
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: anyNamed('data'),
          requestOptions: RequestOptions(
            path: '',
            data: '',
          ),
        ),
      );
      client = MobileServicesClient(
          props: props, auth: auth, httpClient: httpClient);
    });

    test('Filter', () {
      final filter1 = ODataFilter(
          path: "asdas",
          operator: ODataFilterOperator.EQ,
          value1: EdmType.dateTime(DateTime.now()));
      final filter2 = ODataFilter(
          path: "asdas",
          operator: ODataFilterOperator.EQ,
          value1: EdmType.boolean(true));
      final filter3 = ODataFilter(
          path: 'www',
          operator: ODataFilterOperator.BT,
          value1: EdmType.string('1'),
          value2: EdmType.string('3'),
          filters: [filter1, filter2],
          and: true);

    });

    test('EdmString', () {
      final str = EdmType.string('hello');
      expect(str.query, '\'hello\'');
    });

    test('EdmInteger', () {
      final int = EdmType.integer(123);
      expect(int.query, '123');
    });

    test('EdmBool', () {
      final bool = EdmType.boolean(true);
      expect(bool.query, 'true');
    });
  });
}
