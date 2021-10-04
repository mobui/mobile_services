part of '../mobile_services.dart';

class Bundle {
  final MobileServicesClient _client;

  Bundle({
    required MobileServicesClient client,
  }) : _client = client;

  Future<dynamic> get(String name, [int version = 1]) async {
    final path = '${_client.endpoint}/mobileservices/application/${_client.appid}/bundles/v1/runtime/' +
        'bundle/application/${_client.appid}/bundle/$name/version/$version';
    try {
      final response = await _client._httpClient.get(path, options: Options(headers: _client._auth.headers));
      return response.data;
    } on DioError catch (err) {
       throw BundleError(err.toString());
    }
  }
}

class BundleError extends MobileServicesError {
  BundleError(String message) : super(message);
}
