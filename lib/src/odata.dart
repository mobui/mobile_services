part of '../mobile_services.dart';

typedef ODataJson = Map<String, dynamic>;
typedef ODataJsonList = List<Map<String, dynamic>>;

enum Method {
  UNDEFINED,
  GET,
  POST,
  PUT,
  DELETE,
}

extension MethodX on Method {
  String toText() {
    return this.toString().split('.')[1];
  }
}

class _ODataAction {
  final _ODataAction? prev;

  _ODataAction(this.prev);
}

mixin _ODataTop on _ODataAction {
  _ODataActionEntityOption top(int top) {
    return _ODataActionEntityOption(
        {'\$top': EdmType.integer(top).query}, this);
  }
}

mixin _ODataSkip on _ODataAction {
  _ODataActionEntityOption skip(int skip) {
    return _ODataActionEntityOption(
        {'\$skip': EdmType.integer(skip).query}, this);
  }
}

mixin _ODataFilter on _ODataAction {
  _ODataActionEntityOption filter(ODataFilter filter) {
    return _ODataActionEntityOption({'\$filter': filter.toString()}, this);
  }
}

mixin _ODataExpand on _ODataAction {
  _ODataActionEntityOption expand(List<String> expand) {
    return _ODataActionEntityOption({'\$expand': expand.join(',')}, this);
  }
}

class _ODataActionMethod extends _ODataAction {
  final Method _method;
  final MobileServicesClient _client;
  final ODataJson? _data;
  final MobileServicesClientType type;

  _ODataActionMethod(this._method, this._data, this._client, this.type)
      : super(null);

  _ODataActionEntitySet entitySet(String entitySet) {
    return _ODataActionEntitySet(entitySet, this);
  }
}

class _ODataActionEntitySet extends _ODataActionExecutable
    with _ODataExpand, _ODataFilter, _ODataSkip, _ODataTop {
  final String _entitySet;

  _ODataActionEntitySet(this._entitySet, _ODataAction prev) : super(prev);

  _ODataActionEntityKey key(Map<String, EdmType> key) {
    return _ODataActionEntityKey(key, this);
  }
}

class _ODataActionNavigationProperty extends _ODataActionExecutable
    with _ODataExpand {
  final String _navigationProperty;

  _ODataActionNavigationProperty(this._navigationProperty, _ODataAction prev)
      : super(prev);
}

class _ODataActionEntityKey extends _ODataActionExecutable with _ODataExpand {
  final Map<String, EdmType> _key;

  _ODataActionEntityKey(this._key, _ODataAction prev) : super(prev);

  _ODataActionNavigationProperty navigationProperty(String navigationProperty) {
    return _ODataActionNavigationProperty(navigationProperty, this);
  }
}

class _ODataActionEntityOption extends _ODataActionExecutable
    with _ODataExpand, _ODataFilter, _ODataSkip, _ODataTop {
  final Map<String, String> _option;

  _ODataActionEntityOption(this._option, _ODataAction prev) : super(prev);
}

class ODataRequest {
  MobileServicesClient? client;
  Map<String, dynamic> queryParameters = {};
  String path = '';
  String method = '';
  ODataJson? data;
  MobileServicesClientType type = MobileServicesClientType.ODATA;
}

class _ODataActionExecutable extends _ODataAction {
  _ODataActionExecutable(_ODataAction prev) : super(prev);

  Future<ODataResult> execute() async {
    final request = _buildRequest();
    final httpClient = request.client?._httpClient;
    final response = await httpClient?.request(request.path,
        data: request.data,
        options: Options(
            extra: {MobileServicesClient.TYPE_KEY: request.type},
            method: request.method,
            contentType: ContentType.json.toString(),
            responseType: ResponseType.json,
            headers: {'Accept': 'application/json'}),
        queryParameters: request.queryParameters);
    return _parseBody(response!.data);
  }

  ODataRequest _buildRequest() {
    final result = ODataRequest();

    _ODataAction? current = this;
    while (true) {
      if (current is _ODataActionEntitySet) {
        result.path = '/' + current._entitySet + result.path;
      }

      if (current is _ODataActionEntityOption) {
        result.queryParameters.addAll(current._option);
      }
      if (current is _ODataActionNavigationProperty) {
        result.path = '/' + current._navigationProperty + result.path;
      }

      if (current is _ODataActionEntityKey) {
        final key = current._key;
        if (key.length == 1) {
          final keyValue = key.values.toList().first.query;
          result.path = '(\'$keyValue\')' + result.path;
        } else if (key.length > 1) {
          final keysValue = key.entries
              .fold('', (prev, el) => '$prev, ${el.key}=\'${el.value.query}\'');
          result.path = '(\'$keysValue\')' + result.path;
        }
      }

      if (current is _ODataActionMethod) {
        result.type = current.type;
        result.client = current._client;
        result.data = current._data;
        result.method = current._method.toText();
      }

      if (current != null) {
        current = current.prev;
      } else {
        break;
      }
    }
    return result;
  }

  ODataResult _parseBody(dynamic body) {
    try {
      final _jsonData = body as Map<String, dynamic>;
      if (_jsonData is Map && _jsonData.containsKey('d')) {
        final d = _jsonData['d']! as Map<String, dynamic>;
        if (d is Map && d.containsKey('results') && d['results']! is List) {
          return ODataResult.many((d['results']! as List)
              .map((e) => e as Map<String, dynamic>)
              .toList());
        } else {
          return ODataResult.single(d);
        }
      } else {
        throw FormatException('The response body is not Odata entity', body);
      }
    } on FormatException catch (err) {
      rethrow;
    }
  }
}

class ODataClient {
  final MobileServicesClient _client;
  Method _method = Method.UNDEFINED;

  ODataClient({
    required MobileServicesClient client,
  }) : _client = client;

  _ODataActionMethod get(
      {MobileServicesClientType type = MobileServicesClientType.ODATA}) {
    return _ODataActionMethod(Method.GET, null, _client, type);
  }

  _ODataActionMethod update(ODataJson data,
      {MobileServicesClientType type = MobileServicesClientType.ODATA}) {
    return _ODataActionMethod(Method.POST, data, _client, type);
  }

  _ODataActionMethod create(ODataJson data,
      {MobileServicesClientType type = MobileServicesClientType.ODATA}) {
    return _ODataActionMethod(Method.POST, data, _client, type);
  }

  _ODataActionMethod delete(
      {MobileServicesClientType type = MobileServicesClientType.ODATA}) {
    return _ODataActionMethod(Method.DELETE, null, _client, type);
  }
}

abstract class ODataResult<T> {
  final T value;

  ODataResult(this.value);

  static ODataSingleResult single(ODataJson value) => ODataSingleResult(value);

  static ODataManyResult many(ODataJsonList value) => ODataManyResult(value);

  static ODataNoneResult none() => ODataNoneResult();
}

class ODataSingleResult extends ODataResult<ODataJson> {
  ODataSingleResult(ODataJson value) : super(value);
}

class ODataManyResult extends ODataResult<ODataJsonList> {
  ODataManyResult(ODataJsonList value) : super(value);
}

class ODataNoneResult extends ODataResult<Null> {
  ODataNoneResult() : super(null);
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

  factory EdmType.integer(int? value) {
    if (value != null)
      return EdmInteger(value) as EdmType<T>;
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
    return identical(this, other) ||
        (other is EdmType<T> && value == other.value);
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

class EdmInteger extends EdmType<int> {
  EdmInteger(int value) : super._(value);
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

  _ODataFilterPartBinary(String property, String operation, String value)
      : this._part = '$property $operation $value';

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
