part of '../mobile_services.dart';

class MobileServicesClient {
  late final MobileServicesProps _props;
  late final MobileServicesAuth _auth;
  late final Dio _httpClient;
  Registration? _registration;
  Logger? _logger;
  ODataClient? _odata;
  bool _closed = false;

  MobileServicesClient({
    required MobileServicesProps props,
    MobileServicesAuth? auth,
    Dio? httpClient,
  }) {
    _props = props;
    _auth = auth ?? MobileServicesAuth.no();
    _httpClient = httpClient ?? Dio();
  }

  String get endpoint => _props.endpoint.toString();

  String get appid => _props.appid;

  Registration get registration {
    _checkClosed();
    if (_registration == null) _registration = Registration(client: this);
    return _registration!;
  }

  Logger get logger {
    _checkClosed();
    if (_logger == null) _logger = Logger(client: this);
    return _logger!;
  }

  ODataClient get odata {
    _checkClosed();
    if (_odata == null) _odata = ODataClient(client: this);
    return _odata!;
  }

  ODataClient get bundle {
    _checkClosed();
    if (_odata == null) _odata = ODataClient(client: this);
    return _odata!;
  }

  void close() {
    _closed = true;
    _httpClient.close();
  }

  void _checkClosed(){
    if(_closed) throw MobileServicesError('Connection already closed');
  }
}

abstract class MobileServicesAuth {
  Map<String, String> get headers;

  MobileServicesAuth();

  factory MobileServicesAuth.no() {
    return _NoAuth();
  }

  factory MobileServicesAuth.basic({
    required String username,
    required String password,
  }) {
    return _BasicAuth(username, password);
  }

  factory MobileServicesAuth.basicSMP({
    required String username,
    required String password,
    required String appcid,
  }) {
    return _BasicAuthSMP(username, password, appcid);
  }
}

class _NoAuth extends MobileServicesAuth {
  @override
  Map<String, String> get headers => {};
}

class _BasicAuth extends MobileServicesAuth {
  final String _username;
  final String _password;

  _BasicAuth(this._username, this._password);

  @override
  Map<String, String> get headers => {'Authorization': 'Basic $_toBase64'};

  String get _toBase64 {
    var bytes = utf8.encode('$_username:$_password');
    return base64.encode(bytes);
  }
}

class _BasicAuthSMP extends _BasicAuth {
  final String _appcid;

  _BasicAuthSMP(this._appcid, String username, String password) : super(username, password);

  @override
  Map<String, String> get headers => super.headers..addAll({'X-SMP-APPCID': _appcid});
}

class MobileServicesProps {
  final String endpoint;
  final String appid;

  MobileServicesProps({
    required this.endpoint,
    required this.appid,
  });
}

class MobileServicesError implements Exception {
  MobileServicesError(String message);
}
