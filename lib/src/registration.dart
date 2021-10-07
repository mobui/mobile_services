part of '../mobile_services.dart';

class Registration {
  final MobileServicesClient _client;

  Registration({
    required MobileServicesClient client,
  }) : _client = client;

  Future<Connection> createConnection(Connection connection) async {
    final newConnection =
        await _client.odata.createEntity(entityName: "Connections", newEntity: connection) as Connection;
    return newConnection;
  }

  Future<Connection> getConnection(
    String connectionId, {
    String? eTag,
    bool withCapabilities = false,
  }) async {
    final odataJson = await _client.odata.getEntityById(
        entityName: "Connections",
        key: {"ApplicationConnectionId": EdmType.string(connectionId)},
        expand: [if (withCapabilities) 'Capability']);
    return Connection.fromJson(odataJson);
  }

  Future<void> deleteConnection(String connectionId) async {
    await _client.odata
        .deleteEntity(entityName: "Connections", key: {"ApplicationConnectionId": EdmType.string(connectionId)});
  }

  // Future<void> updateConnection(Connection connection) async {
  //   final newConnection =
  //       await _client.odata.updateEntity(entityName: "Connections", newEntity: connection) as Connection;
  //   return newConnection;
  // }

  Future<void> addCapability(String connectionId, Capability capability) async {
    // final newConnection = await  _client.odata.createEntity(
    //     entityName: "Connections", newEntity: connection) as Connection;
    // return  newConnection;
  }

  Future<List<Capability>> getCapabilities(String connectionId) async {
    // final newConnection = await  _client.odata.getEntityByQuery(
    //     entityName: "Connections", newEntity: connection) as Connection;
    // return  newConnection;
    return <Capability>[];
  }

  Future<void> deleteCapability(String connectionId, String capabilityId) async {
    await _client.odata
        .deleteEntity(entityName: "Connections", key: {"ApplicationConnectionId": EdmType.string(connectionId)});
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
    );
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

class Capability {}
