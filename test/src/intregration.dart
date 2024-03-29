import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_services/mobile_services.dart';

main() {
  late final MobileServicesClient client;
  setUp(() {
    client = MobileServicesClient(
        props: MobileServicesProps(
          endpoint:
              'https://agroinvest-dev002-dev-com-agroinvest-mobile-farm.cfapps.eu10.hana.ondemand.com',
          appid: 'com.agroinvest.mobile.farm',
          techUsername: 'ZPM007',
          techPassword: 'Service_2o21!@', server: '',
        ),
        auth: MobileServicesAuth.basic(
          username: 'ZPM007',
          password: 'Service_2o21!@',
        ),
        httpClient: Dio());
  });

  tearDown(() {
    client.close();
  });

  test('Integration test expand', () async {
    final value =
        await client.odata.get(count: true).entitySet('Waybills').execute();
    client.odata.create(json.decode("{}")).entitySet("Notifications").key({"ID": EdmType.string('10000024')}).navigationProperty('to_Comments').execute();
    final x = await client.odata
        .get()
        .entitySet('Waybills')
        .top(100)
        .expand([
      'to_Items',
      'to_Items/to_Crop',
      'to_Items/to_Field',
      'to_Items/to_Operation',
      'to_MasterEquipment',
      'to_PrimaryDriver',
      'to_SecondaryDriver',
      'to_SlavePrimaryEquipment',
      'to_SlaveSecondaryEquipment',
    ]).execute();
    print(x);
  });

  test('Integration test count', () async {
    final x =
        await client.odata.get(count: true).entitySet('Waybills').execute();
    print(x);
  });
}
