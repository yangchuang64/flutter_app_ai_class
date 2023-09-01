import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';

import '../model/baby_information_model.dart';

class BabyInformationViewModel with ChangeNotifier {
  BabyInformationModel infoModel;

  /// 获取模拟宝贝数据
  void getLocalData(String stuNum) async {
    BaseResp<BabyInformationModel> resp = await NetRequest.get<BabyInformationModel>(
      url: ApiConfigs.babyInformationPage,
      dateTypeInstance: BabyInformationModel(),
      param: {"stuNum": stuNum},
//      jsonInAsset: "baby_infomation_mock.json",
    );
    infoModel = resp.data;
    notifyListeners();
  }

  Future<void> getBabyData(String stuNum) async {
    Completer completer = Completer();
    BaseResp<BabyInformationModel> resp = await NetRequest.get<BabyInformationModel>(
      url: ApiConfigs.babyInformationPage,
      dateTypeInstance: BabyInformationModel(),
      param: {"stuNum": stuNum},
//      jsonInAsset: "baby_infomation_mock.json",
    );
    infoModel = resp.data;
    notifyListeners();
    completer.complete();
    return completer.future;
  }

  void updateIconImageFile(String headImageUrl) {
    infoModel.headImg = headImageUrl;
    notifyListeners();
  }

  void updateName(String name) {
    infoModel.name = name;
    notifyListeners();
  }

  void updateGender(int gender) {
    infoModel.sex = gender;
    notifyListeners();
  }

  void updateBirthday(String birthday) {
    infoModel.birthday = birthday;
    notifyListeners();
  }

  void updateGrade(int grade) {
    infoModel.grade = grade;
    notifyListeners();
  }
}
