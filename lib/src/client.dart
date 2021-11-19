part of '../mobile_services.dart';

enum MobileServicesClientType { UNDEFINED, ODATA, LOGGER, REGISTRATION, BUNDLE }

class MobileServicesClient {
  static const TYPE_KEY = 'type';
  late final MobileServicesProps _props;
  late final MobileServicesAuth _auth;
  late final Dio _httpClient;
  bool _closed = false;

  MobileServicesClient({
    required MobileServicesProps props,
    required MobileServicesAuth auth,
    required Dio httpClient,
  }) {
    _props = props;
    _auth = auth;
    _httpClient = httpClient;
    _httpClient.interceptors
      ..removeWhere((element) => element is MobileServicesInterceptors)
      ..add(MobileServicesInterceptors(this._props, this._auth));
  }

  ODataClient get odata => ODataClient(client: this);

  Registration get registration => Registration(client: odata);

  Logger get logger => Logger(client: this);

  Bundle get bundle => Bundle(client: this);

  void close() {
    _closed = true;
    _httpClient.close();
  }

  bool get isClosed => _closed;
}

class MobileServicesInterceptors extends Interceptor {
  final MobileServicesProps _props;
  final MobileServicesAuth _auth;

  MobileServicesInterceptors(this._props, this._auth);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final type = options.extra[MobileServicesClient.TYPE_KEY] ??
        MobileServicesClientType.UNDEFINED;
    if (type == MobileServicesClientType.UNDEFINED) {
      handler.reject(
          DioError(requestOptions: options, error: 'Unsupported request type'));
    }
    options.path = _props.paths[type]! + options.path;
    options.headers.addAll(_auth.headers);
    return handler.next(options);
  }
}

abstract class MobileServicesAuth {
  Map<String, String> get headers;

  Map<String, dynamic> get json;

  MobileServicesAuth();

  factory MobileServicesAuth.no() {
    return NoAuth();
  }

  factory MobileServicesAuth.basic({
    required String username,
    required String password,
  }) {
    return BasicAuth(username, password);
  }

  factory MobileServicesAuth.basicSMP({
    required String username,
    required String password,
    required String appcid,
  }) {
    return BasicAuthSMP(username, password, appcid);
  }

  factory MobileServicesAuth.basicSMPWithToken({
    required String username,
    required String password,
    required String appcid,
    required String token,
  }) {
    return BasicAuthSMP(username, password, appcid);
  }

  factory MobileServicesAuth.auto({
    required String? username,
    required String? password,
    required String? appcid,
    required String? token,
  }) {
    if ((username?.isEmpty ?? true) || (password?.isEmpty ?? true))
      return MobileServicesAuth.no();
    if (appcid?.isEmpty ?? true)
      return MobileServicesAuth.basic(username: username!, password: password!);
    if (token?.isEmpty ?? true)
      return MobileServicesAuth.basicSMP(
          username: username!, password: password!, appcid: appcid!);
    return MobileServicesAuth.basicSMPWithToken(
        username: username!,
        password: password!,
        appcid: appcid!,
        token: token!);
  }

  factory MobileServicesAuth.fromJson(Map<String, dynamic> json) {
    return MobileServicesAuth.auto(
      username: json["username"],
      password: json["password"],
      appcid: json["appcid"],
      token: json["token"],
    );
  }

  bool get isSMPAuth => this is BasicAuthSMP;
}

class NoAuth extends MobileServicesAuth {
  @override
  Map<String, String> get headers => {};

  @override
  Map<String, dynamic> get json => {};
}

class BasicAuth extends MobileServicesAuth {
  final String _username;
  final String _password;

  BasicAuth(this._username, this._password);

  String get username => _username;
  String get password => _password;

  @override
  Map<String, String> get headers => {'Authorization': 'Basic $_toBase64'};

  String get _toBase64 {
    var bytes = utf8.encode('$_username:$_password');
    return base64.encode(bytes);
  }

  @override
  Map<String, dynamic> get json => {
        'username': _username,
        'password': _password,
      };
}

class BasicAuthSMP extends BasicAuth {
  final String _appcid;

  BasicAuthSMP(String username, String password, this._appcid)
      : super(username, password);

  String get appcid => _appcid;

  @override
  Map<String, String> get headers =>
      super.headers..addAll({'X-SMP-APPCID': _appcid});

  @override
  Map<String, dynamic> get json => super.json..addAll({'appcid': _appcid});
}

class BasicAuthSMPWithToken extends BasicAuthSMP {
  final String _token;

  BasicAuthSMPWithToken(
      String username, String password, String appcid, this._token)
      : super(username, password, appcid);

  String get token => _token;

  @override
  Map<String, String> get headers =>
      super.headers..addAll({'X-USER-TOKEN': _token});

  @override
  Map<String, dynamic> get json => super.json..addAll({'token': _token});
}

class MobileServicesProps {
  final String endpoint;
  final String appid;
  final bool withToken;

  MobileServicesProps(
      {required this.endpoint, required this.appid, this.withToken = false});

  factory MobileServicesProps.fromJson(Map<String, dynamic> json) {
    final endpoint = json['endpoint'] ?? '';
    final appid = json['appid'] ?? '';
    final withToken = (json['withToken'] ?? false) as bool;
    return MobileServicesProps(
        endpoint: endpoint, appid: appid, withToken: withToken);
  }

  String get registrationPath => '$endpoint/odata/applications/v4/$appid';

  String get dataPath => '$endpoint/$appid';

  String get logPath =>
      '$endpoint/mobileservices/application/$appid/clientlogs/v1/runtime/log/application/$appid';

  String get bundlePath =>
      '$endpoint/mobileservices/application/$appid/bundles/v1/runtime/bundle/application/$appid/bundle/';

  Map<MobileServicesClientType, String> get paths => {
        MobileServicesClientType.ODATA: dataPath,
        MobileServicesClientType.LOGGER: logPath,
        MobileServicesClientType.REGISTRATION: registrationPath,
        MobileServicesClientType.BUNDLE: bundlePath,
      };
}

class MobileServicesError implements Exception {
  MobileServicesError(String message);
}
