import 'package:dio/dio.dart';
import 'package:mobile_services/odata/auth.dart';
import 'package:mobile_services/odata/entity.dart';
import 'package:mobile_services/odata/filter.dart';
import 'package:mobile_services/odata/param.dart';
import 'package:mobile_services/odata/type.dart';

class ODataClient {
  final Dio _client;
  final ODataServiceParam _param;
  final ODataServiceAuth _auth;

  ODataClient({
    required ODataServiceParam param,
    ODataServiceAuth? auth,
    Dio? client,
  })  : _param = param,
        _auth = auth ?? ODataServiceAuth.no(),
        _client = client ?? Dio();

  getEntityById({
    required String entityName,
    required Map<String, EdmType> key,
    List<String>? expand,
  }) {}

  getEntityByQuery({
    required String entityName,
    ODataFilter? filter,
    List<String>? expand,
    int? top,
    int? skip,
  }) {}

  ODataEntity? createEntity({
    required String entityName,
    required ODataEntity newEntity,
  }) {}

  void updateEntity({
    required String entityName,
    required ODataEntity updatedEntity,
  }) {}

  void deleteEntity({
    required String entityName,
    required Map<String, EdmType> key,
  }) {}
}
