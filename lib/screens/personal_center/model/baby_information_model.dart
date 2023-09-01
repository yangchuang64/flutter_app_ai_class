import 'dart:io';

import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';

// author wangjintao
// 课程评价页

class BabyInformationModel extends BaseRespData {
  String stuNum;
  String xdfCode;
  String headImg;
  String enName;
  String name;
  int age;
  int sex;
  int grade;
  String birthday;

  File headImageFile = null;

  BabyInformationModel({this.stuNum, this.xdfCode, this.headImg, this.enName, this.name, this.age, this.sex, this.grade, this.birthday});

  BabyInformationModel.fromJson(Map<String, dynamic> json) {
    stuNum = json['stuNum'];
    xdfCode = json['xdfCode'];
    String imageUrl = json['headImg'];
    if (imageUrl == null || imageUrl.trim().length == 0) {
      headImg = null;
    } else {
      headImg = imageUrl.trim();
    }
    enName = json['enName'];
    name = json['name'];
    age = json['age'];
    sex = json['sex'];
    grade = json['grade'];
    birthday = json['birthday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stuNum'] = this.stuNum;
    data['xdfCode'] = this.xdfCode;
    data['headImg'] = this.headImg;
    data['enName'] = this.enName;
    data['name'] = this.name;
    data['age'] = this.age;
    data['sex'] = this.sex;
    data['grade'] = this.grade;
    data['birthday'] = this.birthday;
    return data;
  }

  String gradeString() {
    if (grade is int) {
    } else {
      return "";
    }
    switch (grade) {
      case 1:return "小班";
      case 2:return "大班";
      case 3:return "学前班";
      case 4:return "一年级";
      case 5:return "二年级";
      case 6:return "三年级";
      case 7:return "四年级";
      case 8:return "五年级";
      case 9:return "六年级";
      case 10:return "初一";
      case 11:return "初二";
      case 12:return "初三";
      default:return "";
    }
  }

  @override
  BaseRespData translateData(dynamic data) {
    return BabyInformationModel.fromJson(data);
  }
}
