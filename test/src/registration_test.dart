import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_services/mobile_services.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../fixture/utils.dart';
import 'registration_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  final props = MobileServicesProps(endpoint: Utils.ENDPOINT, appid: Utils.APPID, techUsername: '', techPassword: '');
  final auth = MobileServicesAuth.basic(username: 'hello', password: 'world');
  final outboundConnectionJson = Utils.readFixtureFile('connection.json');
  final entitySetName = 'Connections';

  group('Device type model', () {
    test("To text", () {
      expect(DeviceType.Android.toText(), 'Android');
      expect(DeviceType.iOS.toText(), 'iOS');
    });
    test("From text", () {
      expect(DeviceTypeX.fromText('Android'), DeviceType.Android);
      expect(DeviceTypeX.fromText('iOS'), DeviceType.iOS);
      expect(DeviceTypeX.fromText('XXXXXX'), DeviceType.Undefined);
    });
  });

  group('Registration, create connection ', () {
    late MobileServicesClient client;
    late MockDio httpClient;
    late Registration registration;
    late Connection inboundConnection;
    late Connection outboundConnection;
    late ODataClient odataClient;

    setUp(() {
      httpClient = MockDio();
      client = MobileServicesClient(props: props, auth: auth, httpClient: httpClient);
      odataClient = ODataClient(client: client);
      inboundConnection = Connection.create(deviceType: DeviceType.Android);
      outboundConnection = Connection.create(deviceType: DeviceType.Android, applicationConnectionId: Utils.APPCID);
    });

    tearDown(() {
      client.close();
    });

    test('Create connection success', () async {
      final path = '${Utils.ENDPOINT}/$entitySetName';
      when(
        httpClient.post(
          path,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: outboundConnectionJson,
          requestOptions: RequestOptions(
            path: path,
            data: inboundConnection,
          ),
        ),
      );
      final newConnection = await Registration(client: odataClient).createConnection(inboundConnection);

      verify(httpClient.post(
        path,
        data: anyNamed('data'),
        options: anyNamed('options'),
      ));

      expect(outboundConnection.applicationConnectionId, newConnection.applicationConnectionId);
    });

    test('Get connection success', () async {
      final path = '${Utils.ENDPOINT}/$entitySetName(\'${Utils.APPCID}\')';
      when(
        httpClient.get(
          path,
          options: anyNamed('options'),
        ),
      ).thenAnswer(
            (_) async => Response(
          data: outboundConnectionJson,
          requestOptions: RequestOptions(
            path: path,
            data: inboundConnection,
          ),
        ),
      );
      final newConnection = await Registration(client: odataClient).getConnection(Utils.APPCID, );
    });

    test('Create connection failed', () async {
      // when(client.createEntity(entityName: 'Connections', newEntity: minimalConnection)).thenThrow(ODataError());
      // verifyNever(client.createEntity(entityName: 'Connections', newEntity: minimalConnection));
      // expect(() => registration.createConnection(minimalConnection), throwsA(isA<ODataError>()));
    });
  });
}
