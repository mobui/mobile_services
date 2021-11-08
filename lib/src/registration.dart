part of '../mobile_services.dart';

class Registration {
  final ODataClient _client;

  Registration({
    required ODataClient client,
  }) : _client = client;

  Future<Connection> createConnection(Connection connection) async {
    final mainEntity = 'Connections';
    final odataJson = await _client
        .create(connection.toJson(),
            type: MobileServicesClientType.REGISTRATION)
        .entitySet(mainEntity)
        .execute();
    return Connection.fromJson(odataJson.value);
  }

  Future<Connection> updateConnection(Connection connection) async {
    final mainEntity = 'Connections';
    final key = {
      'ApplicationConnectionId':
      EdmType.string(connection.applicationConnectionId.json)
    };
    await _client
        .update(connection.toJson(),
            type: MobileServicesClientType.REGISTRATION)
        .entitySet(mainEntity)
        .key(key)
        .execute();
    return connection;
  }

  Future<Connection> getConnection(
    String connectionId, {
    String? eTag,
    bool withCapabilities = false,
  }) async {
    final mainEntity = 'Connections';
    final key = {'ApplicationConnectionId': EdmType.string(connectionId)};
    final expand = [if (withCapabilities) 'Capability'];

    final odataJson = await _client
        .get(type: MobileServicesClientType.REGISTRATION)
        .entitySet(mainEntity)
        .key(key)
        .expand(expand)
        .execute();
    return Connection.fromJson(odataJson.value);
  }

  Future<void> deleteConnection(String connectionId) async {
    final mainEntity = 'Connections';
    final key = {'ApplicationConnectionId': EdmType.string(connectionId)};
    await _client.delete().entitySet(mainEntity).key(key).execute();
  }

  Future<List<Capability>> getCapabilities(String connectionId) async {
    final mainEntity = 'Connections';
    final navigationEntity = 'Capability';
    final key = {'ApplicationConnectionId': EdmType.string(connectionId)};
    final odataJson = await _client
        .delete(type: MobileServicesClientType.REGISTRATION)
        .entitySet(mainEntity)
        .key(key)
        .navigationProperty(navigationEntity)
        .execute();
    if (odataJson is ODataManyResult) {
      return odataJson.value.map((json) => Capability.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  Future<Capability> getCapability(String connectionId,
      String capabilityCategory, String capabilityName) async {
    final mainEntity = 'Capabilities';
    final key = {
      'ApplicationConnectionId': EdmType.string(connectionId),
      'Category': EdmType.string(capabilityCategory),
      'CapabilityName': EdmType.string(capabilityName),
    };
    final odataJson = await _client
        .delete(type: MobileServicesClientType.REGISTRATION)
        .entitySet(mainEntity)
        .key(key)
        .execute();
    if (odataJson is ODataSingleResult) {
      return Capability.fromJson(odataJson.value);
    } else {
      throw ODataError.body(body: odataJson.value.toString());
    }
  }

  Future<void> deleteCapability(String connectionId, String capabilityCategory,
      String capabilityName) async {
    final mainEntity = 'Capabilities';
    final key = {
      'ApplicationConnectionId': EdmType.string(connectionId),
      'Category': EdmType.string(capabilityCategory),
      'CapabilityName': EdmType.string(capabilityName),
    };
    await _client
        .delete(type: MobileServicesClientType.REGISTRATION)
        .entitySet(mainEntity)
        .key(key)
        .execute();
  }
}

class Connection extends ODataEntity {
  final EdmType applicationConnectionId;
  final EdmType deviceType;
  final EdmType deviceModel;
  final EdmType apnsPushEnable;
  final EdmType apnsDeviceToken;
  final EdmType androidGcmPushEnabled;
  final EdmType androidGcmRegistrationId;
  final EdmType eTag;
  final EdmType passwordPolicyEnabled;

  Connection._({
    required this.deviceModel,
    required this.deviceType,
    required this.apnsPushEnable,
    required this.apnsDeviceToken,
    required this.androidGcmPushEnabled,
    required this.androidGcmRegistrationId,
    required this.eTag,
    required this.applicationConnectionId,
    required this.passwordPolicyEnabled,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection.create(
        applicationConnectionId: json['ApplicationConnectionId'] ?? '',
        deviceModel: json['DeviceModel'] ?? '',
        deviceType: DeviceTypeX.fromText(json['DeviceType'] ?? 'Undefined'),
        eTag: json['ETag'] ?? '',
        passwordPolicyEnabled: json['PasswordPolicyEnabled'] ?? false,
        androidGcmPushEnabled: json['AndroidGcmPushEnabled'] ?? false,
        androidGcmRegistrationId: json['AndroidGcmRegistrationId'] ?? '',
        apnsPushEnable: json['ApnsPushEnable'] ?? false,
        apnsDeviceToken: json['ApnsDeviceToken'] ?? '');
  }

  factory Connection.create({
    String? applicationConnectionId,
    required DeviceType deviceType,
    String? deviceModel,
    bool? apnsPushEnable,
    String? apnsDeviceToken,
    bool? androidGcmPushEnabled,
    String? androidGcmRegistrationId,
    String? eTag,
    bool? passwordPolicyEnabled,
  }) {
    return Connection._(
      deviceType: EdmType.string(deviceType.toText()),
      deviceModel: EdmType.string(deviceModel),
      apnsPushEnable: EdmType.boolean(apnsPushEnable),
      apnsDeviceToken: EdmType.string(apnsDeviceToken),
      androidGcmPushEnabled: EdmType.boolean(androidGcmPushEnabled),
      androidGcmRegistrationId: EdmType.string(androidGcmRegistrationId),
      eTag: EdmType.string(eTag),
      applicationConnectionId: EdmType.string(applicationConnectionId),
      passwordPolicyEnabled: EdmType.boolean(passwordPolicyEnabled),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ApplicationConnectionId': this.applicationConnectionId.json,
      'DeviceModel': this.deviceModel.json,
      'DeviceType': this.deviceType.json,
    }..removeWhere((key, value) => value == null);
  }

  Connection copyWith({
    String? applicationConnectionId,
    DeviceType? deviceType,
    String? deviceModel,
    bool? apnsPushEnable,
    String? apnsDeviceToken,
    bool? androidGcmPushEnabled,
    String? androidGcmRegistrationId,
    String? eTag,
    bool? passwordPolicyEnabled,
  }) {
    return Connection._(
      deviceType: deviceType != null
          ? EdmType.string(deviceType.toText())
          : this.deviceType,
      deviceModel:
          deviceModel != null ? EdmType.string(deviceModel) : this.deviceModel,
      apnsPushEnable: apnsPushEnable != null
          ? EdmType.boolean(apnsPushEnable)
          : this.apnsPushEnable,
      apnsDeviceToken: apnsDeviceToken != null
          ? EdmType.string(apnsDeviceToken)
          : this.apnsDeviceToken,
      androidGcmPushEnabled: androidGcmPushEnabled != null
          ? EdmType.boolean(androidGcmPushEnabled)
          : this.androidGcmPushEnabled,
      androidGcmRegistrationId: androidGcmRegistrationId != null
          ? EdmType.string(androidGcmRegistrationId)
          : this.androidGcmRegistrationId,
      eTag: eTag != null ? EdmType.string(eTag) : this.eTag,
      applicationConnectionId: applicationConnectionId != null
          ? EdmType.string(applicationConnectionId)
          : this.applicationConnectionId,
      passwordPolicyEnabled: passwordPolicyEnabled != null
          ? EdmType.boolean(passwordPolicyEnabled)
          : this.passwordPolicyEnabled,
    );
  }
}

class Capability extends ODataEntity {
  final EdmType applicationConnectionId;
  final EdmType capabilityName;
  final EdmType category;
  final EdmType capabilityValue;

  Capability._({
    required this.applicationConnectionId,
    required this.capabilityName,
    required this.category,
    required this.capabilityValue,
  });

  factory Capability.fromJson(Map<String, dynamic> json) {
    return Capability._(
      applicationConnectionId: json['ApplicationConnectionId'],
      capabilityName: json['CapabilityName'],
      category: json['Category'],
      capabilityValue: json['CapabilityValue'],
    );
  }

  factory Capability.create({
    required String applicationConnectionId,
    required String capabilityName,
    required String category,
    required String capabilityValue,
  }) {
    return Capability._(
      applicationConnectionId: EdmType.string(applicationConnectionId),
      capabilityName: EdmType.string(capabilityName),
      category: EdmType.string(category),
      capabilityValue: EdmType.string(capabilityValue),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'ApplicationConnectionId': applicationConnectionId.json,
      'CapabilityName': capabilityName.json,
      'Category': category.json,
      'CapabilityValue': capabilityValue.json,
    };
  }
}

class RegistrationError implements Exception {
  final String message;
  final Exception prev;

  RegistrationError(this.message, this.prev);
}

enum DeviceType {
  Undefined,
  WinMobile,
  WinSmartPhone,
  Windows,
  iPhone,
  iPad,
  iPod,
  iOS,
  BlackBerry,
  Android,
  Rim6,
  Windows8,
  WinPhone8,
  Windows81,
  WinPhone81,
}

extension DeviceTypeX on DeviceType {
  String toText() {
    switch (this) {
      case DeviceType.WinMobile:
        return 'WinMobile';
      case DeviceType.WinSmartPhone:
        return 'WinSmartPhone';
      case DeviceType.Windows:
        return 'Windows';
      case DeviceType.iPhone:
        return 'iPhone';
      case DeviceType.iPad:
        return 'iPad';
      case DeviceType.iPod:
        return 'iPod';
      case DeviceType.iOS:
        return 'iOS';
      case DeviceType.BlackBerry:
        return 'BlackBerry';
      case DeviceType.Android:
        return 'Android';
      case DeviceType.Rim6:
        return 'Rim6';
      case DeviceType.Windows8:
        return 'Windows8';
      case DeviceType.WinPhone8:
        return 'WinPhone8';
      case DeviceType.Windows81:
        return 'Windows81';
      case DeviceType.WinPhone81:
        return 'WinPhone81';
      default:
        return '';
    }
  }

  static DeviceType fromText(String text) {
    switch (text) {
      case 'WinMobile':
        return DeviceType.WinMobile;
      case 'WinSmartPhone':
        return DeviceType.WinSmartPhone;
      case 'Windows':
        return DeviceType.Windows;
      case 'iPhone':
        return DeviceType.iPhone;
      case 'iPad':
        return DeviceType.iPad;
      case 'iPod':
        return DeviceType.iPod;
      case 'iOS':
        return DeviceType.iOS;
      case 'BlackBerry':
        return DeviceType.BlackBerry;
      case 'Android':
        return DeviceType.Android;
      case 'Windows8':
        return DeviceType.Windows8;
      case 'WinPhone8':
        return DeviceType.WinPhone8;
      case 'Windows81':
        return DeviceType.Windows81;
      case 'WinPhone81':
        return DeviceType.WinPhone81;
      default:
        return DeviceType.Undefined;
    }
  }
}
