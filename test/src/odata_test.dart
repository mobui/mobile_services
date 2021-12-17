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
      techPassword: '');
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
      expect(value1.query, 'Hello');
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
    test('', () {
      try {
        json.decode('qqweqw');
      } on FormatException catch (err) {
        print(err.source);
      }
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

    test('', () {
      try {
        final result = client.odata
            .get()
            .entitySet('Hello')
            .expand(['asasd', 'qweqweqw']).execute();
      } on FormatException catch (err) {
        print(err.source);
      }
    });

    test('Import function', () {
      try {
        final result =
            client.odata.get().functionImport("GetCurrentUser").execute();
      } on FormatException catch (err) {
        print(err.source);
      }
    });

    test('', () {
      try {
        final x =  EdmType.dateTime('/Date(1615766400000)/');

        print(x.value) ;
      } on FormatException catch (err) {
        print(err.source);
      }
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

      try {
        final result =
            client.odata.get().entitySet('Users').filter(filter3).execute();
      } on FormatException catch (err) {
        print(err.source);
      }
    });
  });
}
