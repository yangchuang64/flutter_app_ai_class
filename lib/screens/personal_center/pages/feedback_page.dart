import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutterblingaiplugin/screen/configs/dark_mode_config.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/uitils/validators.dart';
import 'package:flutterblingaiplugin/screen/widgets/common_widget.dart';
import 'package:flutterblingaiplugin/screen/widgets/pie_progress_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

// author wangjintao
// 问题反馈页

class FeedBackPage extends StatefulWidget {
  @override
  _FeedBackPageState createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  int _currentOptionIndex = 0;

  // 文本框相关
  TextEditingController _editingController = TextEditingController();
  String _inputText = "";
  final maxLength = 500;

  TextEditingController _editingPhoneController = TextEditingController();
  String _inputPhoneText = "";

  //创建存放相册路径的数组
  List<dynamic> imagesPathList = [
    {'url': 'assets/ai_package/images/personalCenter/uploadImage.webp', 'type': false}
  ];

  var _uploadImageFilePath = [];

  // 上传进度控制器
  ProgressController _progressController = ProgressController();

  // 标识是否正常上传图片
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    UiUtil.setPortraitUpMode();

    _addListener();
    DarkModeConfig().readLocalModeData().then((value) {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    });
  }

  // 上传图片进度回调
  void _progressChanged(count, total) {
    double progress = count * 1.0 / total;
    _progressController.updateProgress(progress);
  }

  // 上传单个图片
  Future<BaseResp> _uploadImageFile(FormData data) async {
    return NetRequest.uploadFile(url: ApiConfigs.uploadFile, fileData: data, progressCallBack: _progressChanged);
  }

  // 是否启用按钮
  bool _isSubmitButtonEnable() {
    return true;
  }

  // 点击提交按钮
  void _didClickSubmitButton() {
    // 判断内容是否小于15字  如果小于提示
    String content = _inputText.trim();
    if (content.length < 15) {
      UiUtil.showToast("请描述您的问题，不少于15字");
      return;
    }
    if (_editingPhoneController.text == null || _editingPhoneController.text.length != 11) {
      print("手机号为空");
      UiUtil.showToast("请输入正确的手机号");
      return;
    }

    if (!Validators.phone(_editingPhoneController.text)) {
      UiUtil.showToast("请输入正确的手机号");
      return;
    }

    // 取学生学号
    // 本地拿学生编号
    StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
    String stunum = stuInfo.stuNum;
    if (stunum == null || stunum.length == 0) {
      print("学生编号参数有误");
    }

    var param = {
      "questionContent": content,
      "stuNum": stunum,
      "phone": _editingPhoneController.text,
      "questionType": _currentOptionIndex + 1,
    };

    var string = "";
    for (int i = 0; i < _uploadImageFilePath.length; i++) {
      string += _uploadImageFilePath[i];
      if (i < _uploadImageFilePath.length - 1) {
        string += ",";
      }
    }
    param["images"] = string;

    _submitData(param);
  }

  // 提交网络请求
  void _submitData(Map param) async {
    String deviceName;
    String deviceVersion;
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      deviceName = iosInfo.utsname.machine;
      deviceVersion = iosInfo.systemVersion;
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      deviceName = androidInfo.id;
      deviceVersion = androidInfo.version.release;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    param['deviceName'] = deviceName;
    param['deviceVersion'] = deviceVersion;
    param['appVersion'] = packageInfo.version;

    NetRequest.post(
      url: ApiConfigs.feedback,
      param: param,
    ).then((BaseResp resp) {
      if (resp.code == 10000) {
        UiUtil.showToast("反馈成功");
        Navigator.of(context).pop();
      } else {
        UiUtil.showToast(resp.msg);
      }
    });
  }

  // 监听文本框改变
  void _addListener() {
    _editingController.addListener(() {
      var input = _editingController.text;
      if (input.length > maxLength) {
        input = input.substring(0, maxLength);
        _editingController.text = input;
        FocusScope.of(context).requestFocus(FocusNode());
        UiUtil.showToast("输入内容超出限制");
      } else {
//        print("Listener ${_editingController.text}");
      }
      setState(() {
        _inputText = input;
      });
    });

    // 取登录用户手机号
    LoginInfo loginfo = Provider.of<LoginUserInfo>(context, listen: false).loginInfo;
    _editingPhoneController.text = loginfo.mobile;
    _editingPhoneController.addListener(() {
      var input = _editingPhoneController.text;
      if (input.length > 11) {
        input = input.substring(0, 11);
        _editingPhoneController.text = input;
        FocusScope.of(context).requestFocus(FocusNode());
        UiUtil.showToast("请输入正确的手机号");
      } else {}
      setState(() {
        _inputPhoneText = input;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkModeConfig().mainBackgroundColor,
      appBar: CommonPreferredSize(text: '问题反馈'),
      body: Container(
        child: ListView(
          children: <Widget>[
            _creatTitleWith("选择问题类型"),
            _creatOptionButtons(),
            SizedBox(
              height: pxWithPad(10),
            ),
            _creatTitleWith("反馈内容"),
            _creatInputField(),
            SizedBox(
              height: pxWithPad(10),
            ),
            _creatTitleWith("上传凭证（最多六张）"),
            _creatSelectImageWidget(),
            _creatTitleWith("联系方式"),
            _creatPhoneInputFieldNew(),
            _creatSubmitButton(),
          ],
        ),
      ),
    );
  }

  // 创建文字标题
  Widget _creatTitleWith(String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(23), pxWithPad(15), pxWithPad(16)),
      child: Text(
        text,
        style: CustomTextStyle.fz().copyWith(
          color: DarkModeConfig().mainTitleColor,
          fontSize: fontSizeWithPad(16),
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  // 创建选项
  Widget _creatOptionButtons() {
    List<FeedBackOptionButton> childs = [];
    for (int i = 0; i < 3; i++) {
      FeedBackOptionButton button = FeedBackOptionButton(
        index: i,
        isSelected: (i == _currentOptionIndex),
        onClickCallBack: _didClickOptionButton,
      );
      childs.add(button);
    }
    return Container(
      padding: EdgeInsets.only(left: pxWithPad(15), right: pxWithPad(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: childs,
      ),
    );
  }

  // 点击选项
  void _didClickOptionButton(int index, bool isSelected) {
    _currentOptionIndex = index;
    setState(() {});
  }

  // 创建反馈内容输入框
  Widget _creatInputField() {
    return Container(
      height: pxWithPad(120),
      margin: EdgeInsets.fromLTRB(pxWithPad(15), 0, pxWithPad(15), pxWithPad(0)),
      padding: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(10), pxWithPad(15), pxWithPad(15)),
      decoration: BoxDecoration(
        color: DarkModeConfig().textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(pxWithPad(10.0)),
      ),
      child: TextField(
        controller: _editingController,
        maxLines: 10,
        maxLength: maxLength,
        maxLengthEnforced: false,
        cursorColor: Color(0xFFFABE00),
        style: CustomTextStyle.fz().copyWith(color: Color(0xFF333333), fontSize: fontSizeWithPad(14)),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none, // 去掉下划线
          hintText: "请描述您的问题，不少于15个字",
          hintStyle: CustomTextStyle.fz().copyWith(color: Color(0xFFCCCCCC), fontSize: fontSizeWithPad(14)),
          counterStyle: CustomTextStyle.fz().copyWith(color: Color(0xFFCCCCCC), fontSize: fontSizeWithPad(14)),
        ),
      ),
    );
  }

  // 创建选择图片
  Widget _creatSelectImageWidget() {
    Widget _buildGridItemWith(BuildContext context, int builderIndex) {
      if (imagesPathList[builderIndex]['type'] == true) {
        bool _isShowProgressWidget = !(builderIndex == 0 && _isUploading);
        // 返回图片
        return Container(
            child: Stack(
          overflow: Overflow.visible,
          fit: StackFit.expand,
          children: <Widget>[
            Image.file(
              imagesPathList[builderIndex]['url'],
//                width: pxWithPad(55),
//                height: pxWithPad(55),
              fit: BoxFit.cover,
            ),
            Offstage(
              offstage: _isShowProgressWidget,
              child: _creatPieProgressWidget(),
            ),
            Positioned(
              top: pxWithPad(-8.0),
              right: pxWithPad(-8.0),
              child: GestureDetector(
                child: ClipOval(
                  child: Container(
                    width: pxWithPad(24.0),
                    height: pxWithPad(24.0),
                    color: Color(0xFFFFFFFF),
                    child: new Icon(
                      Icons.cancel,
                      color: Color(0xFFFF6700),
                      size: pxWithPad(24.0),
                    ),
                  ),
                ),
                onTap: () {
                  // 删除图片
                  _deleteImage(builderIndex);
                },
              ),
            ),
          ],
        ));
      } else {
        // 返回添加按钮
        return GestureDetector(
          child: Image.asset(
            imagesPathList[builderIndex]['url'],
//            height: 55,
//            width: 55,
            fit: BoxFit.cover,
          ),
          onTap: () {
            // 打开相册选照片
            _openGallery();
          },
        );
      }
    }

    return Container(
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(left: pxWithPad(15.0), right: pxWithPad(15.0), top: pxWithPad(10.0)),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: UiUtil.isPad() ? 4 : 3,
            mainAxisSpacing: pxWithPad(10.0),
            crossAxisSpacing: pxWithPad(10.0),
            childAspectRatio: 1.0,
          ),
          itemCount: imagesPathList.length,
          itemBuilder: _buildGridItemWith),
    );
  }

  /// 打开相册选取照片
  Future<Null> _openGallery() async {
    try {
      // 判断有图片正在上传  提示
      if (_isUploading) {
        UiUtil.showToast('有图片正在上传，请稍后再试');
        return;
      }

      /// 1、从相册选取图片
      File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
      print('1. 从相册选取图片: $imageFile');
      if (imageFile == null || imageFile.path == null) {
        print("The pick image is null.");
        return;
      }

      _isUploading = true;
      // 刷新界面
      setState(() {
        imagesPathList.insert(0, {'url': imageFile, 'type': true});
        if (imagesPathList.length == 7) {
          imagesPathList.removeLast();
        }
      });

      /// 2、对照片进行压缩
      File compressFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        imageFile.absolute.path,
        quality: 50,
        minWidth: 500,
        minHeight: 500,
      );
      print('2. 打印对压缩后的图片: $compressFile');
      if (compressFile == null) {
        /// 如果压缩后的文件为null，则使用源文件
        compressFile = imageFile;
      }
      if (compressFile != null) {
        FormData a = FormData();
        a.files.add(MapEntry('file', MultipartFile.fromFileSync(compressFile.path)));
//        a.add('file', UploadFileInfo(compressFile, compressFile.path));
        _uploadImageFile(a).then((response) {
          if (response.code == 10000) {
            BaseRespData respData = response.data;
            if (respData.originValue["url"] != '') {
              _uploadImageFilePath.add(respData.originValue["url"]);
            }
            _isUploading = false;
          } else {
            UiUtil.showToast('网络连接错误');
            _isUploading = false;
          }
        });
      }
    } catch (e) {
      print("pickImageError, error is $e");
    }
  }

  // 删除图片
  _deleteImage(index) {
    setState(() {
      imagesPathList.removeAt(index);
      _uploadImageFilePath.removeAt(index);
      var _num = 0;
      imagesPathList.map((item) {
        if (item['type'] == false) {
          _num++;
        }
      }).toList();
      if (_num == 0) {
        imagesPathList.add({'url': 'assets/ai_package/images/personalCenter/uploadImage.webp', 'type': false});
      }
    });
  }

  // 创建手机号输入框
  Widget _creatPhoneInputFieldNew() {
    return Container(
      alignment: Alignment.center,
      height: pxWithPad(44),
      margin: EdgeInsets.fromLTRB(pxWithPad(15), 0, pxWithPad(15), pxWithPad(10)),
      padding: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(6), pxWithPad(15), pxWithPad(6)),
      decoration: BoxDecoration(
        color: DarkModeConfig().textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(pxWithPad(10.0)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              maxLines: 1,
              controller: _editingPhoneController,
              cursorColor: Color(0xFFFABE00),
              style: CustomTextStyle.fz().copyWith(color: Color(0xFF333333), fontSize: fontSizeWithPad(14)),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: InputBorder.none, // 去掉下划线
                hintText: "请输入您的手机号",
                contentPadding: EdgeInsets.only(top: 3),
                hintStyle: CustomTextStyle.fz().copyWith(color: Color(0xFFCCCCCC), fontSize: fontSizeWithPad(14)),
              ),
            ),
          ),
          Image.asset(
            "assets/ai_package/images/personalCenter/feedback_icon_edit.webp",
            width: pxWithPad(20),
            height: pxWithPad(20),
          ),
        ],
      ),
    );
  }

  // 创建提交按钮
  Widget _creatSubmitButton() {
    bool enable = _isSubmitButtonEnable();
    return Container(
      margin: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(20), pxWithPad(15), pxWithPad(30)),
      child: GestureDetector(
        onTap: (enable ? _didClickSubmitButton : null),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: pxWithPad(48),
              decoration: BoxDecoration(
                color: (enable ? Color(0xFFFABE00) : Color(0xFFF4F4F4)),
                borderRadius: BorderRadius.circular(pxWithPad(24)),
              ),
            ),
            Text(
              "提交",
              style: CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainBackgroundColor, fontSize: fontSizeWithPad(18)),
            ),
          ],
        ),
      ),
    );
  }

  // 创建饼图进度指示
  Widget _creatPieProgressWidget() {
    return Container(
      child: PieProgressWidget(
        controller: _progressController,
      ),
    );
  }

  @override
  void dispose() {
    _editingController.dispose();
    _editingPhoneController.dispose();
    _progressController.dispose();
    super.dispose();
  }
}

// 星星按钮
class FeedBackOptionButton extends StatelessWidget {
  final int index;
  final bool isSelected;
  final Function(int, bool) onClickCallBack;

  FeedBackOptionButton({@required this.index, @required this.isSelected, @required this.onClickCallBack});

  @override
  Widget build(BuildContext context) {
    String name = "学习问题";
    if (index == 1) {
      name = "技术支持";
    }
    if (index == 2) {
      name = "其他问题";
    }
    return GestureDetector(
        onTap: _onClick,
        child: Container(
          width: pxWithPad(98),
          height: pxWithPad(32),
          alignment: Alignment.center,
          child: Text(
            name,
            style: CustomTextStyle.fz().copyWith(fontSize: fontSizeWithPad(14), color: (isSelected ? DarkModeConfig().dynamicColorWith(Colors.white, darkColor: Colors.grey) : Color(0xFF666666))),
          ),
          decoration: BoxDecoration(
            color: (isSelected ? Color(0xFFFABE00) : DarkModeConfig().secondBackgroundColor),
            borderRadius: BorderRadius.circular(pxWithPad(16)),
          ),
        ));
  }

  void _onClick() {
    onClickCallBack(index, isSelected);
  }
}
