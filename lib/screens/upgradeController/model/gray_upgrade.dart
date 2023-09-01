import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';

/// 更新检测 模型
//class UpgradeInfo extends BaseRespData {
//  int id;
//  String appKey;
//  int platform;
//  String version;
//  int forcedUpdate;
//  String downloadUrl;
//  String upgradeInstructions;
//  int state;
//  String publishDate;
//  String publisher;
//  String createDate;
//  String modifyDate;
//
//  UpgradeInfo({
//    this.id,
//    this.platform,
//    this.appKey,
//    this.version,
//    this.forcedUpdate,
//    this.downloadUrl,
//    this.upgradeInstructions,
//    this.state,
//    this.publishDate,
//    this.publisher,
//    this.createDate,
//    this.modifyDate,
//  });
//
//  factory UpgradeInfo.fromJson(Map<String, dynamic> json) {
//    if ((json is Map) == false) return UpgradeInfo();
//    return UpgradeInfo(
//      id: (json['id'] ?? 0) ~/ 1 as int,
//      platform: json['platform'],
//      appKey: json['appKey'],
//      version: json['version'],
//      forcedUpdate: (json['forcedUpdate'] ?? 0) ~/ 1 as int,
//      downloadUrl: json['downloadUrl'],
//      upgradeInstructions: json['upgradeInstructions'],
//      state: (json['state'] ?? 0) ~/ 1 as int,
//      publishDate: json['publishDate'],
//      publisher: json['publisher'],
//      createDate: json['createDate'],
//      modifyDate: json['modifyDate'],
//    );
//  }
//
//  @override
//  BaseRespData translateData(data) {
//    return UpgradeInfo.fromJson(data);
//  }
//}

class GrayUpdateData extends BaseRespData {
  AppGrayStudent appGrayStudent;
  UpgradeInfo upgradeInfo;

  GrayUpdateData({this.appGrayStudent, this.upgradeInfo});

  factory GrayUpdateData.fromJson(Map<String, dynamic> json) {
    if (json == null) return GrayUpdateData();
    AppGrayStudent appGrayStudent;
    UpgradeInfo upgradeInfo;
    if (null != json['upgradeStudent']) {
      appGrayStudent = AppGrayStudent.fromJson(json['upgradeStudent']);
    }
    if (null != json['upgradeInfo']) {
      upgradeInfo = UpgradeInfo.fromJson(json['upgradeInfo']);
    }
    return GrayUpdateData(
      appGrayStudent: appGrayStudent,
      upgradeInfo: upgradeInfo,
    );
  }

  @override
  BaseRespData translateData(data) {
    if (data is Map) {
      return GrayUpdateData.fromJson(data);
    }
    return GrayUpdateData();
  }
}

class AppGrayStudent {
  int id;
  String stuNum;
  int grayType;
  int successType;
  int refuseTime;
  String gmtCreate;
  String successDate;
  int upgradeInfoId;
  String grayVersion;

  AppGrayStudent({
    this.id,
    this.stuNum,
    this.grayType,
    this.successType,
    this.refuseTime,
    this.gmtCreate,
    this.successDate,
    this.upgradeInfoId,
    this.grayVersion,
  });

  factory AppGrayStudent.fromJson(Map<String, dynamic> json) {
    return AppGrayStudent(
      id: json['id'],
      stuNum: json['stuNum'],
      grayType: json['grayType'],
      successType: json['successType'],
      refuseTime: json['refuseTime'],
      gmtCreate: json['gmtCreate'],
      successDate: json['successDate'],
      upgradeInfoId: json['upgradeInfoId'],
      grayVersion: json['grayVersion'],
    );
  }
}

class UpgradeInfo {
  int id;
  int platform;
  String appKey;
  String version;
  int forcedUpdate;
  String downloadUrl;
  String upgradeInstructions;
  int state;
  String publishDate;
  String publisher;
  String createDate;
  String modifyDate;
  int isGray;
  int forcedUpdateGray;
  int grayCounts;

  UpgradeInfo({
    this.id,
    this.platform,
    this.appKey,
    this.version,
    this.forcedUpdate,
    this.downloadUrl,
    this.upgradeInstructions,
    this.state,
    this.publishDate,
    this.publisher,
    this.createDate,
    this.modifyDate,
    this.isGray,
    this.forcedUpdateGray,
    this.grayCounts,
  });

  factory UpgradeInfo.fromJson(Map<String, dynamic> json) {
    return UpgradeInfo(
      id: json['id'],
      platform: json['platform'],
      appKey: json['appKey'],
      version: json['version'],
      forcedUpdate: json['forcedUpdate'],
      downloadUrl: json['downloadUrl'],
      upgradeInstructions: json['upgradeInstructions'],
      state: json['state'],
      publishDate: json['publishDate'],
      publisher: json['publisher'],
      createDate: json['createDate'],
      modifyDate: json['modifyDate'],
      isGray: json['isGray'],
      forcedUpdateGray: json['forcedUpdateGray'],
      grayCounts: json['grayCounts'],
    );
  }
}
