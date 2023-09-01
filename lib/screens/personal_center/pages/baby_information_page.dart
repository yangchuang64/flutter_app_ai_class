import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'package:dio/dio.dart';

import 'package:blingabc_base/blingabc_base.dart' as Base;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/screens/login/switch_student.dart';
import 'package:flutter_app_ai_math/screens/personal_center/model/baby_information_model.dart';
import 'package:flutter_app_ai_math/screens/personal_center/view_model/baby_information_view_model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterblingaiplugin/screen/configs/dark_mode_config.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/common_widget.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app_ai_math/screens/personal_center/widgets/information_edit_widget.dart';

class BabyInformationPage extends StatefulWidget {
  @override
  _BabyInformationPageState createState() => _BabyInformationPageState();
}

class _BabyInformationPageState extends State<BabyInformationPage> {
  BabyInformationViewModel _viewModel = BabyInformationViewModel();
  int currentIndex = 0;

  File imageFile;
  File corpimageFile;
  File compressimageFile;
  File baseimageFile;

  @override
  void initState() {
    UiUtil.setPortraitUpMode();
    super.initState();
    _loadData();

    DarkModeConfig().readLocalModeData().then((value) {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    });
  }

  void _loadData(){
    if (mounted == false) return;
    StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
    String stunum = stuInfo.stuNum;
    if (stunum == null || stunum.length == 0) {
      print("学生编号参数有误");
    } else {
      Base.showCoCoLoading(context);
      _viewModel.getBabyData(stunum).then((con) {
        Base.hideCoCoLoading(context);
      });
    }
  }

  void _didClickIcon() {
    // 苹果原生风格的弹出框
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("取消")),
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Text('从手机相册选择'),
            onPressed: () {
              Navigator.pop(context, 'One');
              _pickImage();
            },
          ),
        ],
      ),
    );
  }

  void _didClickNameTile() {
    showEditInfoDialog(context, name: _viewModel.infoModel.name ,callback: (name){
      String newName = name;
      StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
      String stunum = stuInfo.stuNum;
      var param = {"stuNum":stunum, "name":newName};
      Base.showCoCoLoading(context);
      NetRequest.post(url: ApiConfigs.babyInformationEdit, param: param).then((response){
        Base.hideCoCoLoading(context);
        if (response.code == 10000){
          UiUtil.showToast("宝贝信息更新成功");
          _viewModel.updateName(newName);
          StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
          stuInfo.name = newName;
          Provider.of<LoginUserInfo>(context).updateSelectedStudent(stuInfo);
        }else{
          UiUtil.showToast(response?.msg ?? "");
        }
      });
    });
  }

  void _didClickGenderTile() {
    showEditInfoDialog(context, type: EditInfoType.gender,gender: _viewModel.infoModel.sex ,callback: (gender){
      if(gender!=1 && gender!=2)return;
      StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
      String stunum = stuInfo.stuNum;
      var param = {"stuNum":stunum, "sex":gender};
      Base.showCoCoLoading(context);
      NetRequest.post(url: ApiConfigs.babyInformationEdit, param: param).then((response){
        Base.hideCoCoLoading(context);
        if (response.code == 10000){
          UiUtil.showToast("宝贝信息更新成功");
          _viewModel.updateGender(gender);
        }else{
          UiUtil.showToast(response?.msg ?? "");
        }
      });
    });
  }

  void _didClickBirthdayTile() {
    showEditInfoDialog(context, type: EditInfoType.birthday,callback: (birthday){
      StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
      String stunum = stuInfo.stuNum;
      var param = {"stuNum":stunum, "birthday":birthday};
      Base.showCoCoLoading(context);
      NetRequest.post(url: ApiConfigs.babyInformationEdit, param: param).then((response){
        Base.hideCoCoLoading(context);
        if (response.code == 10000){
          UiUtil.showToast("宝贝信息更新成功");
          _viewModel.updateBirthday(birthday);
        }else{
          UiUtil.showToast(response?.msg ?? "");
        }
      });
    });
  }

  void _didClickGradeTile() {
    showEditInfoDialog(context, type: EditInfoType.grade,callback: (grade){
      StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
      String stunum = stuInfo.stuNum;
      var param = {"stuNum":stunum, "grade":grade};
      Base.showCoCoLoading(context);
      NetRequest.post(url: ApiConfigs.babyInformationEdit, param: param).then((response){
        Base.hideCoCoLoading(context);
        if (response.code == 10000){
          UiUtil.showToast("宝贝信息更新成功");
          _viewModel.updateGrade(grade);
          StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
          stuInfo.grade = grade;
          Provider.of<LoginUserInfo>(context).updateSelectedStudent(stuInfo);
        }else{
          UiUtil.showToast(response?.msg ?? "");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _viewModel,
      child: Scaffold(
        appBar: CommonPreferredSize(text: '宝贝信息'),
        body: Container(
          color: DarkModeConfig().mainBackgroundColor,
          child: Center(
            child: _creatContentWidget(),
          ),
        ),
      ),
    );
  }

  Widget _creatHeadTile(String name, BabyInformationModel infoModel) {
    return GestureDetector(
      onTap: _didClickIcon,
      child: Container(
        padding: EdgeInsets.only(left: pxWithPad(20), right: pxWithPad(20)),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  name ?? "",
                  style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(16)),
                ),
                Expanded(
                  child: Text(""),
                ),
                Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(pxWithPad(22)),
                      child: _creatIconImage(infoModel),
                    ),
                    Positioned(right: px(-3),bottom: px(-3),child: Image.asset("assets/ai_package/images/personalCenter/icon_camera@3x.webp",width: px(17),height: px(14),),),
                  ],
                ),
                SizedBox(
                  width: pxWithPad(1),
                  height: pxWithPad(52),
                ),
              ],
            ),
            Container(
              color: DarkModeConfig().dividerColor,
              height: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _creatIconImage(BabyInformationModel infoModel) {
    if (infoModel.headImageFile == null && infoModel.headImg == null) {
      return Image.asset(
        "assets/ai_package/images/personalCenter/default_baby_img.webp",
        width: pxWithPad(44),
        height: pxWithPad(44),
      );
    } else {
      return infoModel.headImageFile == null
          ? Image.network(
              infoModel.headImg,
              width: pxWithPad(44),
              height: pxWithPad(44),
              fit: BoxFit.cover,
            )
          : Image.file(infoModel.headImageFile, width: pxWithPad(44), height: pxWithPad(44), fit: BoxFit.cover);
    }
  }

  Widget _creatNormalTile(String name, String value, Function callBack) {
    return GestureDetector(
      onTap: callBack,
      child: Container(
        padding: EdgeInsets.only(left: pxWithPad(20), right: pxWithPad(20)),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  name,
                  style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(16)),
                ),
                Expanded(
                  child: Text(""),
                ),
                Text(
                  value ?? "",
                  style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().secondTitleColor, fontSize: fontSizeWithPad(16)),
                ),
                SizedBox(
                  width: pxWithPad(1),
                  height: pxWithPad(52),
                ),
                Image.asset(
                  "assets/ai_package/images/personalCenter/icon_arrow.webp",
                  width: pxWithPad(12),
                  height: pxWithPad(12),
                ),
              ],
            ),
            Container(
              color: DarkModeConfig().dividerColor,
              height: 1.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _creatContentWidget() {
    return Consumer<BabyInformationViewModel>(builder: (context, viewModel, _) {
      if (viewModel.infoModel == null) {
        return Text("");
      } else {
        BabyInformationModel _infoModel = viewModel.infoModel;
        String name = _infoModel.name;
        if(name!=null && name.length>12){
          name = name.substring(0, 12);
          name = "${name}...";
        }
        String genderString(){
          if(_infoModel.sex == null)return " ";
          if(_infoModel.sex == 1)return "男孩";
          if(_infoModel.sex == 2)return "女孩";
        }
        return ListView(
          children: <Widget>[
            Container(height: px(10), width: double.infinity,color: DarkModeConfig().secondBackgroundColor,),
            _creatHeadTile("头像", _infoModel),
            _creatNormalTile("中文姓名", name, _didClickNameTile),
            _creatNormalTile("宝贝性别", genderString(), _didClickGenderTile),
            _creatNormalTile("出生日期", _birthdayStringWith(_infoModel), _didClickBirthdayTile),
            _creatNormalTile("年级", _infoModel.gradeString(), _didClickGradeTile),
            _isShowSwitch()?GestureDetector(
              onTap: _didClickSwitchButton,
              child: Container(
                padding: EdgeInsets.only(left: pxWithPad(20), right: pxWithPad(20)),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '切换学生',
                            style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(18)),
                          ),
                        ),
                        Text(
                          "",
                          style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().secondTitleColor, fontSize: fontSizeWithPad(18)),
                        ),
                        SizedBox(
                          width: pxWithPad(1),
                          height: pxWithPad(60),
                        ),
                        Image.asset(
                          "assets/ai_package/images/personalCenter/icon_arrow.webp",
                          width: pxWithPad(12),
                          height: pxWithPad(12),
                        ),
                      ],
                    ),
                    Container(
                      color: DarkModeConfig().dividerColor,
                      height: 1.0,
                    ),
                  ],
                ),
              ),
            ):Container(),
          ],
        );
      }
    });
  }

  String _birthdayStringWith(BabyInformationModel model) {
    if (model.birthday == null)return "";
    if (model.birthday is String) {
      if (model.birthday.startsWith("Invalid"))return"";
    }else{
      return "";
    }

    if (model.birthday.length >= 10) {
      return model.birthday.substring(0, 10);
    }
    return model.birthday;
  }

  Future<Null> _pickImage() async {
    // 1、从相册选取图片
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      // 2、对照片进行裁剪
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        //        toolbarTitle: 'Cropper',
        //        toolbarColor: Colors.blue,
      );
      if (croppedFile != null) {
        String testcropImagePath = croppedFile.path;
        print('裁切后的图片路径 $testcropImagePath');

        // 3、裁剪后的照片进行压缩
        File compressFile = await FlutterImageCompress.compressAndGetFile(
          croppedFile.path,
          croppedFile.path,
          quality: 50,
          minWidth: 500,
          minHeight: 500,
        );

        String testcompressPath = compressFile.path;
        if (compressFile == null) {
          compressFile = imageFile;
        }
        if (compressFile != null) {
          Base.showCoCoLoading(context);
          FormData data = FormData();
          data.files.add(MapEntry('file', MultipartFile.fromFileSync(compressFile.path)));
          NetRequest.uploadFile(url: ApiConfigs.uploadFile, fileData: data).then((response) {
            Base.hideCoCoLoading(context);
            if (response.code == 10000) {
              BaseRespData respData = response.data;
              if (respData.originValue["url"] != '') {
                String newImageUrl = respData.originValue["url"];
                StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
                String stunum = stuInfo.stuNum;
                var param = {"stuNum":stunum, "headImg":newImageUrl};
                NetRequest.post(url: ApiConfigs.babyInformationEdit, param: param).then((response){
                  if (response.code == 10000){
                    _viewModel.updateIconImageFile(newImageUrl);
                    StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
                    stuInfo.headImg = newImageUrl;
                    Provider.of<LoginUserInfo>(context).updateSelectedStudent(stuInfo);
                  }else{
                    UiUtil.showToast(response?.msg ?? "");
                  }
                });
              }
            } else {
              UiUtil.showToast(response?.msg ?? "");
            }
          });
        }
      }
    }
  }
  // 是否启用按钮
  bool _isShowSwitch() {
    LoginInfo loginInfo = Provider.of<LoginUserInfo>(context, listen: false).loginInfo;
    if (loginInfo == null || loginInfo.studentList == null) {
      return false;
    }
    if (loginInfo.studentList is List) {
    } else {
      return false;
    }
    return loginInfo.studentList.length > 1;
  }


  void _didClickSwitchButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SwitchStudentPage(showBack: true)),
    ).then((value) {
      if (value == null || !value) return;
      _loadData();
//      setState(() {});
    });
  }
}
