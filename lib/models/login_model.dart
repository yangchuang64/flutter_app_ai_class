import 'package:flutterblingaiplugin/screen/uitils/log.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';

class LoginInfo implements BaseRespData {
  @override
  var originValue;
  String accessToken;
  String parentNum;
  String mobile;
  String token;
  List<StudentInfo> studentList;

  LoginInfo();

  LoginInfo.fromJson(Map<String, dynamic> json) {
    this.token = json['token'] as String;
    this.accessToken = json['accessToken'] as String;
    this.parentNum = json['parentNum'] as String;
    this.mobile = json['mobile'] as String;
    this.studentList = (json['studentList'] as List)?.map((e) => e == null ? null : StudentInfo.fromJson(e as Map<String, dynamic>))?.toList();
    try {
      printLog("-loginUserInfo-", "parentNum:$parentNum--mobile:$mobile--stuNum:${studentList[0].stuNum}");
    } catch (_) {}
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'accessToken': accessToken, 'parentNum': parentNum, 'mobile': mobile, 'studentList': studentList, "token": token};

  @override
  BaseRespData translateData(data) {
    return LoginInfo.fromJson(data);
  }
}

class StudentInfo {
  String stuNum;
  String xdfCode;
  String headImg;
  String enName;
  String name;
  int age;
  int sex;
  int grade;
  String birthday;
  int level;
  int integral;
  int active;

  StudentInfo(this.stuNum, this.xdfCode, this.headImg, this.enName, this.name, this.age, this.sex, this.grade, this.birthday, this.level, this.integral, this.active);

  factory StudentInfo.fromJson(Map<String, dynamic> json) => StudentInfo(
        json['stuNum'] as String,
        json['xdfCode'] as String,
        json['headImg'] as String,
        json['enName'] as String,
        json['name'] as String,
        json['age'] as int,
        json['sex'] as int,
        json['grade'] as int,
        json['birthday'] ?? '',
        json['level'] ?? 0,
        json['integral'] ?? 0,
        json['active'] ?? 0,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'stuNum': stuNum,
        'xdfCode': xdfCode,
        'headImg': headImg,
        'enName': enName,
        'name': name,
        'age': age,
        'sex': sex,
        'grade': grade,
        'birthday': birthday,
        'level': level,
        'integral': integral,
        'active': active,
      };
}
