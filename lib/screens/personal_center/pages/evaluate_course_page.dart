import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutterblingaiplugin/screen/configs/dark_mode_config.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/common_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// author wangjintao
// 课程评价页
class EvaluateClassPage extends StatefulWidget {
  final String lessonId;
  final String lessonName;
  final String classLessonId;
  final String classLessonName;

  EvaluateClassPage({@required this.lessonId, @required this.lessonName, @required this.classLessonId, @required this.classLessonName});

  @override
  _EvaluateClassPageState createState() => _EvaluateClassPageState();
}

class _EvaluateClassPageState extends State<EvaluateClassPage> {
  // 当前评分
  int _courseContentScore = -1;
  int _courseTeacherScore = -1;

  // 文本框相关
  TextEditingController _editingController = TextEditingController();
  String _inputText = "";
  final maxLength = 500;
  bool _isSubmiting = false;

  @override
  void initState() {
    UiUtil.setPortraitUpMode();
    _editingController.addListener(() {
      var input = _editingController.text;
      if (input.length > maxLength) {
        input = input.substring(0, maxLength);
        _editingController.text = input;
        // 收起键盘
        FocusScope.of(context).requestFocus(FocusNode());
        UiUtil.showToast("输入内容超出限制");
        print("超出限制");
      } else {
        print("Listener ${_editingController.text}");
      }
      setState(() {
        _inputText = input;
      });
    });
    super.initState();

    DarkModeConfig().readLocalModeData().then((value) {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DarkModeConfig().secondBackgroundColor,
      appBar: CommonPreferredSize(text: '评价本课'),
      body: ListView(
        children: <Widget>[
          _creatHeaderWidget(widget.classLessonName),
          Container(
            margin: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(15), pxWithPad(15), 0),
            decoration: BoxDecoration(
              color: DarkModeConfig().mainBackgroundColor,
              borderRadius: BorderRadius.circular(pxWithPad(20)),
            ),
            child: Column(
              children: <Widget>[
                _creatTitleWith("课程内容"),
                _creatEvaluateContentBar(),
                _creatTitleWith("主讲老师"),
                _creatEvaluateTeacherBar(),
                SizedBox(
                  height: pxWithPad(12),
                ),
                _creatTextField(),
                _creatSubmitButton()
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _finishSelectedContentScore(int type, int score) {
    _courseContentScore = score;
    setState(() {});
  }

  void _finishSelectedTeacherScore(int type, int score) {
    _courseTeacherScore = score;
    setState(() {});
  }

  // 创建头部视图
  Widget _creatHeaderWidget(String courseName) {
    return Container(
      height: pxWithPad(68),
      color: DarkModeConfig().mainBackgroundColor,
      padding: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(10), pxWithPad(15), pxWithPad(10)),
      child: Center(
        child: Row(
          children: <Widget>[
            Image.asset(
              "assets/ai_package/images/personalCenter/icon_class.webp",
              width: pxWithPad(35),
              height: pxWithPad(36),
            ),
            Container(
              padding: EdgeInsets.only(left: pxWithPad(10)),
              child: Text(
                "课程：${courseName}",
                style: CustomTextStyle.fz().copyWith(fontSize: fontSizeWithPad(16), color: DarkModeConfig().thirdTitleColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 创建文字标题
  Widget _creatTitleWith(String text) {
    return Container(
      padding: EdgeInsets.fromLTRB(pxWithPad(10), pxWithPad(20), pxWithPad(10), 0),
      child: Center(
        child: Text(text, style: CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(18))),
      ),
    );
  }

  // 创建评价内容条
  Widget _creatEvaluateContentBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(pxWithPad(10), 0, pxWithPad(10), 0),
      child: EvaluateStarBar(
        type: 1,
        score: _courseContentScore,
        finishSelectCallBack: _finishSelectedContentScore,
      ),
    );
  }

  // 创建评价教师条
  Widget _creatEvaluateTeacherBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(pxWithPad(10), 0, pxWithPad(10), 0),
      child: EvaluateStarBar(
        type: 2,
        score: _courseTeacherScore,
        finishSelectCallBack: _finishSelectedTeacherScore,
      ),
    );
  }

  // 创建文本输入框
  Widget _creatTextField() {
    return Container(
      height: pxWithPad(200),
      margin: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(10), pxWithPad(15), pxWithPad(20)),
      padding: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(6), pxWithPad(15), pxWithPad(15)),
      decoration: BoxDecoration(
        color: DarkModeConfig().textFieldBackgroundColor,
//        color: Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(pxWithPad(8.0)),
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
          hintText: "在这里留下你对老师的评价!",
          hintStyle: CustomTextStyle.fz().copyWith(color: Color(0xFFCCCCCC), fontSize: fontSizeWithPad(14)),
          counterStyle: CustomTextStyle.fz().copyWith(color: Color(0xFFCCCCCC), fontSize: fontSizeWithPad(14)),
        ),
      ),
    );
  }

  // 创建提交按钮
  Widget _creatSubmitButton() {
    bool enable = _isSubmitButtonEnable();
    return Container(
      margin: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(100), pxWithPad(15), pxWithPad(30)),
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
            Text("提交", style: CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainBackgroundColor, fontSize: fontSizeWithPad(18))),
          ],
        ),
      ),
    );
  }

  // 是否启用按钮
  bool _isSubmitButtonEnable() {
//    if (_inputText.length == 0){
//      return false;
//    } else {
//      return true;
//    }
    return true;
  }

  void _didClickSubmitButton() {
    if(_isSubmiting==true)return;
    _isSubmiting = true;
    if (_courseContentScore < 0) {
      UiUtil.showToast("请对课程内容评分");
      return;
    }
    if (_courseTeacherScore < 0) {
      UiUtil.showToast("请对主讲老师评分");
      return;
    }
    String content = _inputText.trim();
    StudentInfo stuInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
    String stunum = stuInfo.stuNum;
    if (stunum == null || stunum.length == 0) {
      print("学生编号参数有误");
    }

    // 拼接参数 发起请求
    var param = {
      "aiLessonId": widget.lessonId,
      "aiLessonName": widget.lessonName,
      "classLessonId": widget.classLessonId,
      "classLessonName": widget.classLessonName,
      "courseContentStar": _courseContentScore + 1,
      "courseTeacherStar": _courseTeacherScore + 1,
      "courseAppraise": content, // 评价内容
      "stuNum": stunum,
      "stuName": stuInfo.name ?? "",
    };
    _submitData(param);
  }

  void _submitData(dynamic param) async {
    print(param);
    NetRequest.post(
      url: ApiConfigs.evaluateCourse,
      param: param,
    ).then((BaseResp resp) {
      _isSubmiting=false;
      if (resp.code == 10000) {
        UiUtil.showToast("评价成功");
        Navigator.of(context).pop();
      } else {
        UiUtil.showToast(resp.msg);
      }
    });
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }
}

class EvaluateStarBar extends StatelessWidget {
  final int type;
  final int score;
  final Function(int type, int index) finishSelectCallBack;

  EvaluateStarBar({@required this.score, @required this.type, @required this.finishSelectCallBack});

  List<bool> _starButtonIsSelectedArr = [false, false, false, false, false];
  String _tipText = "asdf";

  Widget _creatStarButtons(List<bool> arr) {
    List<Widget> childs = [];
    for (int i = 0; i < arr.length; i++) {
      var button = EvaluateButton(
        index: i,
        isSelected: arr[i],
        onClickCallBack: _didClickStarButton,
      );
      childs.add(button);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: childs,
    );
  }

  // 星星点击回调
  void _didClickStarButton(int index, bool isEnable) {
    finishSelectCallBack(type, index);
  }

  @override
  Widget build(BuildContext context) {
    _prepareData();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _creatStarButtons(_starButtonIsSelectedArr),
        Container(
          width: pxWithPad(80),
//          color: Colors.red,
          padding: EdgeInsets.fromLTRB(pxWithPad(10), pxWithPad(3), pxWithPad(10), 0),
          child: Text(
            _tipText,
            maxLines: 1,
            style: CustomTextStyle.fz().copyWith(color: Colors.grey, fontSize: fontSizeWithPad(15)),
          ),
        )
      ],
    );
  }

  void _prepareData() {
    for (int i = 0; i <= score; i++) {
      _starButtonIsSelectedArr[i] = true;
    }

    switch (score) {
      case -1:
        {
          _tipText = "未选择";
        }
        break;
      case 0:
        {
          _tipText = "非常差";
        }
        break;
      case 1:
        {
          _tipText = "差  ";
        }
        break;
      case 2:
        {
          _tipText = "一般 ";
        }
        break;
      case 3:
        {
          _tipText = "好  ";
        }
        break;
      case 4:
        {
          _tipText = "非常好";
        }
        break;
      default:
        {
          _tipText = "未知";
        }
        break;
    }
  }
}

// 星星按钮
class EvaluateButton extends StatelessWidget {
  final int index;
  final bool isSelected;
  final Function(int, bool) onClickCallBack;

  EvaluateButton({@required this.index, @required this.isSelected, @required this.onClickCallBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: _onClick,
        child: Container(
          padding: EdgeInsets.all(pxWithPad(5)),
          child: (isSelected
              ? Image.asset(
                  "assets/ai_package/images/personalCenter/image_star.webp",
                  width: pxWithPad(20),
                  height: pxWithPad(20),
                )
              : Image.asset(
                  "assets/ai_package/images/personalCenter/image_star_d.webp",
                  width: pxWithPad(20),
                  height: pxWithPad(20),
                )),
        ));
  }

  void _onClick() {
    onClickCallBack(index, isSelected);
  }
}
