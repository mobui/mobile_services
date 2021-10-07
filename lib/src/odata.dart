part of '../mobile_services.dart';

typedef ODataJson = Map<String,dynamic>;
typedef ODataJsonList = List<Map<String,dynamic>>;

class ODataClient {
  final MobileServicesClient _client;

  ODataClient({
    required MobileServicesClient client,
  }) : _client = client;

  Future<ODataJson> getEntityById({
    required String entityName,
    required Map<String, EdmType> key,
    List<String> expand = const [],
    Map<String, dynamic> queries = const {},
  }) async {
    final path =
        _buildPath([_client.endpoint, _buildEntityWithKey(entityName, key)]);

    final queryParameters = <String, dynamic>{}
      ..addAll(_buildExpand(expand))
      ..addAll(queries);

    final options = Options(
      contentType: ContentType.json.toString(),
      responseType: ResponseType.json,
      headers: _client._auth.headers,
    );

    try {
      final response = await _client._httpClient.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _parseBodyOne(response.toString());
    } on DioError catch (err) {
      throw _buildHttpErrorDio(err);
    } on FormatException catch (err) {
      throw _buildBodyError(err);
    }
  }

  // Future<ODataJsonList> getEntityByQuery({
  //   required String entityName,
  //   ODataFilter? filter,
  //   List<String>? expand,
  //   int? top,
  //   int? skip,
  // }) {
  //
  // }

  getDeepEntities({
    required String entityName,
    ODataFilter? filter,
    List<String>? expand,
    int? top,
    int? skip,
  }) {}

  Future<ODataJson> createEntity({
    required String entityName,
    required ODataEntity newEntity,
  }) async {
    ODataJson? _jsonData;
    final path = _buildPath([_client.endpoint, entityName]);
    final data = json.encode(newEntity.toJson());
    final options = Options(
      contentType: ContentType.json.toString(),
      responseType: ResponseType.json,
      headers: _client._auth.headers,
    );

    try {
      final response = await _client._httpClient.post(
        path,
        data: data,
        options: options,
      );
      _jsonData = json.decode(response.toString());
    } on DioError catch (err) {
      throw _buildHttpErrorDio(err);
    }
    return _jsonData?['d'];
  }

  Future<void> updateEntity({
    required String entityName,
    required ODataEntity updatedEntity,
  }) async {}

  Future<void> deleteEntity({
    required String entityName,
    required Map<String, EdmType> key,
  }) async {}

  ODataError _buildBodyError(FormatException err){
    return ODataError.body(body: err.source.toString());
  }

  ODataError _buildHttpErrorDio(DioError err) {
    final statusCode = err.response?.statusCode ?? 0;
    switch (statusCode) {
      case 400:
        final odataError = json.decode(err.response?.data?.toString() ?? '');
        return ODataError.http(
            message: odataError?['message'] ?? 'Unknown error',
            statusCode: statusCode);
      case 401:
        return ODataError.http(message: 'Unauthorized', statusCode: statusCode);
      case 404:
        return ODataError.http(message: 'Unauthorized', statusCode: statusCode);
      case 500:
        final odataError = json.decode(err.response?.data?.toString() ?? '');
        return ODataHttpError(
            message: odataError?['message'] ?? 'Unknown error',
            statusCode: statusCode);
      default:
        return ODataError.http(message: err.message, statusCode: statusCode);
    }
  }

  String _buildEntityWithKey(String entityName, Map<String, EdmType> key) {
    if (key.length == 1) {
      final keyValue = key.values.toList().first.query;
      return '$entityName(\'$keyValue\')';
    } else if (key.length > 1) {
      final keysValue = key.entries
          .fold('', (prev, el) => '$prev, ${el.key}=\'${el.value.query}\'');
      return '$entityName($keysValue)';
    } else {
      throw ODataError.key();
    }
  }

  Map<String, dynamic> _buildExpand(List<String> expand) {
    final result = <String, dynamic>{};
    if (expand.isNotEmpty) result['\$expand'] = expand.join(',');
    return result;
  }

  String _buildPath(List<String> pathChunk) {
    return pathChunk.join('/');
  }

  ODataJson _parseBodyOne(String body) {
    try {
      final _jsonData = json.decode(body);
      if (_jsonData is Map && _jsonData.containsKey('d')) {
        return _jsonData['d']!;
      } else {
        throw FormatException('The response body is not Odata entity', body);
      }
    } on FormatException catch (err) {
      rethrow;
    }
  }
}

abstract class EdmType<T> {
  final T? value;

  EdmType._(this.value);

  factory EdmType.boolean(bool? value) {
    if (value != null)
      return EdmBoolean(value) as EdmType<T>;
    else
      return EdmNull() as EdmType<T>;
  }

  factory EdmType.string(String? value) {
    if (value != null)
      return EdmString(value) as EdmType<T>;
    else
      return EdmNull() as EdmType<T>;
  }

  dynamic get json => value!;

  String get query => toString();

  @override
  String toString() {
    return value.toString();
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is EdmType<T> && value == other.value);
  }

  @override
  int get hashCode => value.hashCode;
}

class EdmNull extends EdmType<Null> {
  EdmNull() : super._(null);

  @override
  dynamic get json => null;

  @override
  String toString() {
    return 'null';
  }

  @override
  bool operator ==(Object other) {
    return other is EdmNull;
  }

  @override
  int get hashCode => 1;
}

class EdmBinary extends EdmType<String> {
  EdmBinary(String value) : super._(value);

  @override
  String get json => throw UnimplementedError();

  @override
  String toString() {
    return super.toString();
  }
}

class EdmString extends EdmType<String> {
  EdmString(String value) : super._(value);
}

class EdmBoolean extends EdmType<bool> {
  EdmBoolean(bool value) : super._(value);
}

class EdmDateTime extends EdmType<DateTime> {
  EdmDateTime(DateTime value) : super._(value);

  @override
  String get json => 'Date(\/${value!.millisecondsSinceEpoch}\/)';

  @override
  String get query => value!.toIso8601String();
}

abstract class ODataError implements Exception {
  const factory ODataError.http({
    required String message,
    required int statusCode,
  }) = ODataHttpError;

  const factory ODataError.body({required String? body}) = ODataBodyError;

  const factory ODataError.key() = ODataKeyError;

  const ODataError();
}

class ODataHttpError extends ODataError {
  final int statusCode;
  final String message;

  const ODataHttpError({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return '$statusCode:$message';
  }
}

class ODataBodyError extends ODataError {
  final String? body;

  const ODataBodyError({
    required this.body,
  }) : super();

  @override
  String toString() {
    return 'Body parse error: $body';
  }
}

class ODataKeyError extends ODataError {
  const ODataKeyError() : super();

  @override
  String toString() {
    return 'Keys is empty';
  }
}

abstract class ODataEntity {
  ODataEntity();

  Map<String, dynamic> toJson();
}

class ODataFilter {
  final String _filter;

  static ODataFilterBuilder get builder {
    return ODataFilterBuilder();
  }

  ODataFilter(this._filter);

  @override
  String toString() {
    return this._filter;
  }
}

abstract class _ODataFilterPart {
  _ODataFilterPart();
}

class _ODataFilterPartBinary extends _ODataFilterPart {
  final String _part;

  _ODataFilterPartBinary(String property, String operation, String value) : this._part = '$property $operation $value';

  @override
  String toString() {
    return _part;
  }
}

class _ODataFilterPartLogic extends _ODataFilterPart {
  final String _part;
  final ODataFilter _filter;

  _ODataFilterPartLogic(String logic, ODataFilter filter)
      : this._part = '$logic',
        this._filter = filter;

  @override
  String toString() {
    return '$_part ($_filter)';
  }
}

class ODataFilterBuilder {
  List<_ODataFilterPart> _filter = [];

  ODataFilterBuilder eq(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'eq', value.toString()));
    return this;
  }

  ODataFilterBuilder ne(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'ne', value.toString()));
    return this;
  }

  ODataFilterBuilder le(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'le', value.toString()));
    return this;
  }

  ODataFilterBuilder lt(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'lt', value.toString()));
    return this;
  }

  ODataFilterBuilder ge(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'ge', value.toString()));
    return this;
  }

  ODataFilterBuilder gt(String name, EdmType value) {
    _filter.add(_ODataFilterPartBinary(name, 'gt', value.toString()));
    return this;
  }

  ODataFilterBuilder get and {
    return this;
  }

  ODataFilterBuilder get or {
    return this;
  }

  ODataFilterBuilder andGroup(ODataFilter filter) {
    _filter.add(_ODataFilterPartLogic('and', filter));
    return this;
  }

  ODataFilterBuilder orGroup(ODataFilter filter) {
    _filter.add(_ODataFilterPartLogic('or', filter));
    return this;
  }

  ODataFilter get build {
    String filter = _filter.fold('', (previousValue, element) {
      if (element is _ODataFilterPartBinary) {
        previousValue = '$element $previousValue'.trim();
      } else if (element is _ODataFilterPartLogic) {
        previousValue = '($previousValue) $element'.trim();
      }
      return previousValue;
    });
    return ODataFilter(filter);
  }
}
