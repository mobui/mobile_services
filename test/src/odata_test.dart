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

    test('Filter', () {
      final filter1 = ODataFilter(
          path: "asdas",
          operator: ODataFilterOperator.EQ,
          value1: EdmType.datatime(DateTime.now()));
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
//
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mobile_services/mobile_services.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
//
// const String jsonText = '{ "data": "Text" }';
// const String entryPoint = 'http://service.com';
// const String entitySet = 'EntitySet';
// const String entityName = 'EntityName';
//
// class _TestEntity extends ODataEntity {
//   final String data;
//
//   _TestEntity(this.data);
//
//   @override
//   ODataEntity copyWithJson(Map<String, dynamic> json) {
//     return _TestEntity(json["data"]);
//   }
//
//   @override
//   Map<String, dynamic> toJson() {
//     return {data: "Text"};
//   }
// }
//
// @GenerateMocks([Dio, ODataServiceParam, ODataServiceAuth])
// void main() {
//   late MockDio dioClient;
//   late ODataServiceParam params;
//   late ODataServiceAuth auth;
//   late ODataClient client;
//   setUp(() {
//     dioClient = MockDio();
//     params = MockODataServiceParam();
//     auth = MockODataServiceAuth();
//     client = ODataClient(param: params, auth: auth, client: dioClient);
//   });
//
//   tearDown(() => {});
//
//   group('ODataClient, create entity', () {
//     test('Create entity success', () {
//       when(dioClient.post(entryPoint, data: anyNamed("data"))).thenAnswer(
//             (_) async => Response(requestOptions: RequestOptions(path: entryPoint, data: jsonText), statusCode: 200),
//       );
//       when(params.endpoint).thenReturn(Uri.parse(entryPoint));
//       client.createEntity(entityName: entitySet, newEntity: _TestEntity(entityName));
//     });
//
//     test('Create entity failed, server error', () {
//       when(dioClient.post(entryPoint, data: anyNamed("data"))).thenAnswer(
//             (_) async => Response(requestOptions: RequestOptions(path: entryPoint, data: jsonText), statusCode: 500),
//       );
//       when(params.endpoint).thenReturn(Uri.parse(entryPoint));
//       client.createEntity(entityName: "EntitySet", newEntity: _TestEntity(entityName));
//     });
//
//     test('Create entity failed, client error', () {
//       when(dioClient.post(entryPoint, data: anyNamed("data"))).thenThrow(DioError);
//       when(params.endpoint).thenReturn(Uri.parse(entryPoint));
//       client.createEntity(entityName: "EntitySet", newEntity: _TestEntity(entityName));
//     });
//   });
//
//   group('Simple', () {
//     test('eq', () {
//       final filerBuilder = ODataFilter.builder
//           .eq('Simple', EdmType.boolean(true))
//           .build
//           .toString();
//       expect(filerBuilder, 'Simple eq true');
//     });
//
//     test('ne', () {
//       final filerBuilder = ODataFilter.builder
//           .ne('Simple', EdmType.boolean(true))
//           .build
//           .toString();
//       expect(filerBuilder, 'Simple ne true');
//     });
//
//     test('le', () {
//       final filerBuilder = ODataFilter.builder
//           .le('Simple', EdmType.boolean(true))
//           .build
//           .toString();
//       expect(filerBuilder, 'Simple le true');
//     });
//
//     test('lt', () {
//       final filerBuilder = ODataFilter.builder
//           .lt('Simple', EdmType.boolean(true))
//           .build
//           .toString();
//       expect(filerBuilder, 'Simple lt true');
//     });
//
//     test('gt', () {
//       final filerBuilder = ODataFilter.builder
//           .gt('Simple', EdmType.boolean(true))
//           .build
//           .toString();
//       expect(filerBuilder, 'Simple gt true');
//     });
//     test('ge', () {
//       final filerBuilder = ODataFilter.builder
//           .ge('Simple', EdmType.boolean(true))
//           .build
//           .toString();
//       expect(filerBuilder, 'Simple ge true');
//     });
//   });
//
//   group('Logic', (){
//     // test('and', (){
//     //   final filterOneAnd = ODataFilter.builder
//     //       .ge('One', EdmType.boolean(true))
//     //       .build;
//     //   final filterTwoAnd = ODataFilter.builder
//     //       .ge('Two', EdmType.boolean(true))
//     //       .and
//     //       .gt('Two', EdmType.boolean(true)
//     //           .(filterOneAnd).build;
//     //
//     //   final filterThreeAnd = ODataFilter.builder
//     //       .ge('Three', EdmType.boolean(true))
//     //       .and(filterTwoAnd)
//     //       .build
//     //       .toString();
//     //   print(filterThreeAnd);
//     // });
//   });
// }
