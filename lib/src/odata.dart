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
  final bool count;

  _ODataActionMethod(
      this._method, this._data, this._client, this.type, this.count)
      : super(null);

  _ODataActionEntitySet entitySet(String entitySet) {
    return _ODataActionEntitySet(entitySet, this);
  }

  _ODataActionFunctionImport functionImport(String functionImport) {
    return _ODataActionFunctionImport(functionImport, this);
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

class _ODataActionFunctionImport extends _ODataActionExecutable {
  final String _functionImport;

  _ODataActionFunctionImport(this._functionImport, _ODataAction prev)
      : super(prev);

  _ODataActionEntityOption options(Map<String, EdmType> options) {
    return _ODataActionEntityOption(
        options.map((key, value) => MapEntry(key, value.toString())), this);
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
  String functionImport = '';
}

class _ODataActionExecutable extends _ODataAction {
  _ODataActionExecutable(_ODataAction prev) : super(prev);

  Future<ODataResult> execute() async {
    final request = _buildRequest();
    final httpClient = request.client?._httpClient;
    try {
      final response = await httpClient?.request(request.path,
          data: request.data,
          options: Options(
              extra: {MobileServicesClient.TYPE_KEY: request.type},
              method: request.method,
              contentType: ContentType.json.toString(),
              responseType: ResponseType.json,
              headers: {'Accept': 'application/json'}),
          queryParameters: request.queryParameters);
      return _parseBody(request, response);
    } on DioError catch (err) {
      if (_isODataError(err))
        throw _dioErrorToOdataServerError(err);
      else if (_isHttpError(err))
        throw _dioErrorToOdataHttpError(err);
      else
        rethrow;
    } catch (err) {
      rethrow;
    }
  }

  bool _isODataError(DioError err) {
    return err.response != null &&
        err.response?.data is Map &&
        err.response?.data['error'] is Map;
  }

  bool _isHttpError(DioError err) {
    return err.response != null;
  }

  ODataError _dioErrorToOdataServerError(DioError err) {
    final errData = err.response?.data['error'] as Map;
    return ODataError.server(
        code: errData['code'], message: errData['message']['value']);
  }

  ODataError _dioErrorToOdataHttpError(DioError err) {
    return ODataError.http(
        message: err.response?.statusMessage ?? err.message,
        statusCode: err.response?.statusCode ?? 0);
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
      if (current is _ODataActionFunctionImport) {
        result.path = '/' + current._functionImport + result.path;
        result.functionImport = current._functionImport;
      }
      if (current is _ODataActionNavigationProperty) {
        result.path = '/' + current._navigationProperty + result.path;
      }

      if (current is _ODataActionEntityKey) {
        final key = current._key;
        if (key.length == 1) {
          final keyValue = key.values.toList().first.query;
          result.path = '($keyValue)' + result.path;
        } else if (key.length > 1) {
          final keysValue = key.entries
              .fold('', (prev, el) => '$prev, ${el.key}=${el.value.query}');
          result.path = '($keysValue)' + result.path;
        }
      }

      if (current is _ODataActionMethod) {
        result.type = current.type;
        result.client = current._client;
        result.data = current._data;
        result.method = current._method.toText();
        if (current.count) {
          result.path = result.path + '/\$count';
        }
      }

      if (current != null) {
        current = current.prev;
      } else {
        break;
      }
    }
    return result;
  }

  ODataResult _parseBody(ODataRequest request, Response? response) {
    // Null
    if (response == null) return ODataResult.none();
    if (response.data == null) return ODataResult.none();

    // Value
    if (response.data is String) {
      if ((response.data as String).isEmpty)
        return ODataResult.none();
      else {
        return ODataResult.val(response.data);
      }
    }

    // Complex
    final dataKey =
        request.functionImport.isNotEmpty ? request.functionImport : 'results';
    try {
      final body = response.data as Map<String, dynamic>;
      if (!body.containsKey('d'))
        throw FormatException('The response body is not Odata entity', body);
      final d = body['d']! as Map<String, dynamic>;
      if (d.containsKey(dataKey)) {
        final result = d[dataKey];
        if (result is List) {
          return ODataResult.many(_toStringMapList(result));
        } else if (result is Map) {
          return ODataResult.single(
              _removeResults(result as Map<String, dynamic>));
        } else {
          throw FormatException('The response body is not Odata entity', body);
        }
      } else {
        // Single
        return ODataResult.single(_removeResults(d));
      }
    } on FormatException catch (err) {
      rethrow;
    }
  }

  List<Map<String, dynamic>> _toStringMapList(List<dynamic> list) {
    return (list)
        .map((e) => _removeResults(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> _removeResults(Map<String, dynamic> val) {
    return val.map((key, value) {
      if (value is Map &&
          value.containsKey('results') &&
          value['results'] is List) {
        return MapEntry(key,
            (value['results'] as List).map((e) => _removeResults(e)).toList());
      } else if (value is Map) {
        return MapEntry(key, _removeResults(value as Map<String, dynamic>));
      } else {
        return MapEntry(key, value);
      }
    });
  }
}

class ODataClient {
  final MobileServicesClient _client;
  Method _method = Method.UNDEFINED;

  ODataClient({
    required MobileServicesClient client,
  }) : _client = client;

  _ODataActionMethod get(
      {MobileServicesClientType type = MobileServicesClientType.ODATA,
      bool count = false}) {
    return _ODataActionMethod(Method.GET, null, _client, type, count);
  }

  _ODataActionMethod update(ODataJson data,
      {MobileServicesClientType type = MobileServicesClientType.ODATA}) {
    return _ODataActionMethod(Method.POST, data, _client, type, false);
  }

  _ODataActionMethod create(ODataJson data,
      {MobileServicesClientType type = MobileServicesClientType.ODATA}) {
    return _ODataActionMethod(Method.POST, data, _client, type, false);
  }

  _ODataActionMethod delete(
      {MobileServicesClientType type = MobileServicesClientType.ODATA}) {
    return _ODataActionMethod(Method.DELETE, null, _client, type, false);
  }
}

abstract class ODataResult<T> {
  final T value;

  ODataResult(this.value);

  static ODataSingleResult single(ODataJson value) => ODataSingleResult(value);

  static ODataManyResult many(ODataJsonList value) => ODataManyResult(value);

  static ODataValueResult val(String value) => ODataValueResult(value);

  static ODataNoneResult none() => ODataNoneResult();
}

class ODataSingleResult extends ODataResult<ODataJson> {
  ODataSingleResult(ODataJson value) : super(value);
}

class ODataManyResult extends ODataResult<ODataJsonList> {
  ODataManyResult(ODataJsonList value) : super(value);
}

class ODataValueResult extends ODataResult<String> {
  ODataValueResult(String value) : super(value);
}

class ODataNoneResult extends ODataResult<Null> {
  ODataNoneResult() : super(null);
}

abstract class EdmType<T> {
  final T? value;

  EdmType._(this.value);

  factory EdmType.boolean(dynamic value) {
    if (value == null)
      return EdmNull() as EdmType<T>;
    else if (value is bool)
      return EdmBoolean(value) as EdmType<T>;
    else if (value is int)
      return EdmBoolean(value != 0) as EdmType<T>;
    else if (value is String) {
      if (value == 'false')
        return EdmBoolean(false) as EdmType<T>;
      else if (value == 'true')
        return EdmBoolean(true) as EdmType<T>;
      else
        return EdmNull() as EdmType<T>;
    } else
      return EdmNull() as EdmType<T>;
  }

  factory EdmType.string(dynamic value) {
    if (value == null)
      return EdmNull() as EdmType<T>;
    else if (value is String) {
      return EdmString(value) as EdmType<T>;
    } else {
      return EdmString(value.toString()) as EdmType<T>;
    }
  }

  factory EdmType.integer(dynamic value) {
    if (value is int)
      return EdmInteger(value) as EdmType<T>;
    else if (value is String)
      try {
        return EdmInteger(int.parse(value)) as EdmType<T>;
      } catch (err) {
        return EdmNull() as EdmType<T>;
      }
    else if (value is double)
      return EdmInteger(value.round()) as EdmType<T>;
    else
      return EdmNull() as EdmType<T>;
  }

  factory EdmType.decimal(dynamic value) {
    if (value is double) {
      return EdmDecimal(value) as EdmType<T>;
    } else if (value is String)
      try {
        return EdmDecimal(double.parse(value)) as EdmType<T>;
      } catch (err) {
        return EdmNull() as EdmType<T>;
      }
    else if (value is int)
      return EdmDecimal(value.toDouble()) as EdmType<T>;
    else
      return EdmNull() as EdmType<T>;
  }

  factory EdmType.dateTime(dynamic value) {
    if (value is String) {
      try {
        return EdmDateTime.parse(value) as EdmType<T>;
      } catch (err) {
        return EdmNull() as EdmType<T>;
      }
    } else if (value is DateTime)
      return EdmDateTime(value) as EdmType<T>;
    else if (value is int) {
      try {
        return EdmDateTime.fromInt(value) as EdmType<T>;
      } catch (err) {
        return EdmNull() as EdmType<T>;
      }
    } else
      return EdmNull() as EdmType<T>;
  }

  factory EdmType.dateTimeOffset(dynamic value) {
    if (value is String) {
      try {
        return EdmDateTimeOffset.parse(value) as EdmType<T>;
      } catch (err) {
        return EdmNull() as EdmType<T>;
      }
    } else if (value is DateTime)
      return EdmDateTimeOffset(value.toUtc()) as EdmType<T>;
    else if (value is int) {
      try {
        return EdmDateTimeOffset.fromInt(value) as EdmType<T>;
      } catch (err) {
        return EdmNull() as EdmType<T>;
      }
    } else
      return EdmNull() as EdmType<T>;
  }

  factory EdmType.binary(String? value) {
    if (value != null)
      return EdmBinary(value) as EdmType<T>;
    else
      return EdmNull() as EdmType<T>;
  }

  dynamic get json => value!;

  String get query => '${toString()}';

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

  String get query => '\'$value\'';
}

class EdmBoolean extends EdmType<bool> {
  EdmBoolean(bool value) : super._(value);
}

class EdmInteger extends EdmType<int> {
  EdmInteger(
    int value,
  ) : super._(value);

  @override
  String get query => '$value';

  @override
  String get json => '$value';
}

class EdmDecimal extends EdmType<double> {
  final int scale;
  final int precision;

  EdmDecimal(
    double value, {
    this.scale = 13,
    this.precision = 3,
  }) : super._(value);

  @override
  String get query => '\'${(value ?? 0).toStringAsFixed(precision)}\'';

  @override
  String get json => '\'${(value ?? 0).toStringAsFixed(precision)}\'';
}

class EdmDateTime extends EdmType<DateTime> {
  EdmDateTime(DateTime value) : super._(value);

  @override
  String get json => '\\/Date(${value!.millisecondsSinceEpoch})\\/';

  @override
  String get query => 'datetime\'${value!.toLocal().toIso8601String()}\'';

  factory EdmDateTime.parse(String value) {
    try {
      return EdmDateTime(DateTime.parse(value));
    } catch (err) {}

    final RegExp dateRegExp = new RegExp(r"/Date\((-?\d*)\)/");
    final String? dateMills = dateRegExp.firstMatch(value)?.group(1);
    if (dateMills == null) throw FormatException("Invalid date format", value);
    final timestamp =
        DateTime.fromMillisecondsSinceEpoch(int.parse((dateMills)), isUtc: true)
            .toLocal();
    return EdmDateTime(timestamp);
  }

  factory EdmDateTime.fromInt(int value) {
    final DateTime timestamp =
        DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
    return EdmDateTime(timestamp);
  }
}

class EdmDateTimeOffset extends EdmType<DateTime> {
  EdmDateTimeOffset(DateTime value) : super._(value);

  @override
  String get json =>
      '\\/Date(${value!.toUtc().millisecondsSinceEpoch}+0000)\\/';

  @override
  String get query => 'datetimeoffset\'${value!.toUtc().toIso8601String()}\'';

  factory EdmDateTimeOffset.parse(String value) {
    try {
      return EdmDateTimeOffset(DateTime.parse(value).toUtc());
    } catch (err) {}

    final RegExp dateRegExp = new RegExp(r"/Date\((-?\d*)([+-]?)?(\d*)?\)/");
    final match = dateRegExp.firstMatch(value);
    final String? dateMills = match?.group(1);
    final String sign = match?.group(2) ?? '+';
    final String offset = match?.group(3) ?? '0000';
    if (dateMills == null) throw FormatException("Invalid date format", value);
    final offsetInt =
        int.parse(offset) * (sign == '-' ? -1 : 1) * 60 * 1000; // offset in ms
    final dateTimeInt = int.parse(dateMills);
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
        dateTimeInt - offsetInt,
        isUtc: true);
    return EdmDateTimeOffset(timestamp);
  }

  factory EdmDateTimeOffset.fromInt(int value) {
    final DateTime timestamp =
        DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    return EdmDateTimeOffset(timestamp);
  }
}

abstract class ODataError implements Exception {
  const factory ODataError.http({
    required String message,
    required int statusCode,
  }) = ODataHttpError;

  const factory ODataError.body({required String? body}) = ODataBodyError;

  const factory ODataError.key() = ODataKeyError;

  const factory ODataError.server(
      {required String code, required String message}) = ODataServerError;

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

class ODataServerError extends ODataError {
  final String code;
  final String message;

  const ODataServerError({
    required this.code,
    required this.message,
  }) : super();

  @override
  String toString() {
    return '$code: $message';
  }
}

abstract class ODataEntity {
  ODataEntity();

  Map<String, dynamic> toJson();
}

enum ODataFilterOperator {
  Contains,
  EndsWith,
  EQ,
  GE,
  LE,
  GT,
  LT,
  BT,
  NB,
  NE,
  NotContains,
  NotEndsWith,
  NotStartsWith,
  StartsWith
}

class ODataFilter {
  final String? path;
  final ODataFilterOperator? operator;
  final EdmType? value1;
  final EdmType? value2;
  final List<ODataFilter> filters;
  final bool and;

  ODataFilter({
    this.path,
    this.operator,
    this.value1,
    this.value2,
    this.filters = const [],
    this.and = false,
  });

  @override
  String toString() {
    final binary = and ? ' and ' : ' or ';
    final hasCurrent = this.path != null && this.operator != null;
    final hasBinary = this.filters.isNotEmpty && hasCurrent;
    final filters = this.filters.map((e) => e.toString()).join(binary);
    final current = hasCurrent ? _simpleCondition() : '';
    return (current + (hasBinary ? binary : '') + filters).trim();
  }

  String _simpleCondition() {
    final val1 = value1?.query ?? '';
    final val2 = value1?.query ?? '';
    switch (operator) {
      case ODataFilterOperator.EQ:
        return "$path eq $val1";
      case ODataFilterOperator.GT:
        return "$path gt $val1";
      case ODataFilterOperator.GE:
        return "$path ge $val1";
      case ODataFilterOperator.LE:
        return "$path le $val1";
      case ODataFilterOperator.LT:
        return "$path lt $val1";
      case ODataFilterOperator.Contains:
        return "contains($path, $val1";
      case ODataFilterOperator.NotContains:
        return "not contains($path, $val1";
      case ODataFilterOperator.EndsWith:
        return "endswith($path, $val1";
      case ODataFilterOperator.StartsWith:
        return "not endswith($path,$val1";
      case ODataFilterOperator.StartsWith:
        return "startswith($path,$val1";
      case ODataFilterOperator.NotStartsWith:
        return "not startswith($path,$val1";
      case ODataFilterOperator.NE:
        return "$path ne $val1";
      case ODataFilterOperator.BT:
        return "$path ge $val1 and $path le $val2";
      case ODataFilterOperator.NB:
        return "$path lt $val1 and $path gt $val2";
      default:
        return '';
    }
  }
}
