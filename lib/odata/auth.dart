import 'dart:convert';

abstract class ODataServiceAuth {
  Map<String, String> get header;

  ODataServiceAuth();

  factory ODataServiceAuth.no() {
    return _ODataNoAuth();
  }

  factory ODataServiceAuth.basic({
    required String username,
    required String password,
  }) {
    return _ODataBasicAuth(username, password);
  }

  factory ODataServiceAuth.basicSMP({
    required String username,
    required String password,
    required String appicd,
  }) {
    return _ODataBasicAuthSMP(username, password, appicd);
  }
}

class _ODataNoAuth extends ODataServiceAuth {
  @override
  Map<String, String> get header => {};
}

class _ODataBasicAuth extends ODataServiceAuth {
  final String _username;
  final String _password;

  _ODataBasicAuth(this._username, this._password);

  @override
  Map<String, String> get header => {'Authorization': 'Basic $_toBase64'};

  String get _toBase64 {
    var bytes = utf8.encode('$_username:$_password');
    return base64.encode(bytes);
  }
}

class _ODataBasicAuthSMP extends _ODataBasicAuth {
  final String _appcid;

  _ODataBasicAuthSMP(this._appcid, String username, String password)
      : super(username, password);

  @override
  Map<String, String> get header =>
      super.header..addAll({'X-SMP-APPCID': _appcid});
}
