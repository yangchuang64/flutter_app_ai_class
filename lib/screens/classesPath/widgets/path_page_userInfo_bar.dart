import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/student_class_vo.dart';
import 'package:flutter_app_ai_math/screens/classesPath/widgets/show_switch_course_dialog.dart';
import 'package:flutterblingaiplugin/screen/configs/img_source_config.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/storage.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:provider/provider.dart';
import 'package:shape_of_view/shape_of_view.dart';

enum PathPageBarActionType {
  feedback, // 点击反馈
  setting, // 点击设置
  userInfo, // 点击用户信息头像等
  giftTap, // 领取免费课程
  coin, // 智慧币
}

///
/// 路径页面，展示用户信息bar。包括切换课程等
///
class PathPageUserInfoBarWidget extends StatefulWidget {
  /// 当按钮点中的回调，
  final void Function(PathPageBarActionType) onButtonTap;

  /// 课程切换点击回调
  final void Function(AiStudentClassVO) onClassChanged;

  const PathPageUserInfoBarWidget({Key key, this.onButtonTap, this.onClassChanged}) : super(key: key);

  @override
  PathPageUserInfoBarWidgetState createState() => PathPageUserInfoBarWidgetState();
}

class PathPageUserInfoBarWidgetState extends State<PathPageUserInfoBarWidget> {
  GlobalKey _giftBoxKey = GlobalKey();
  double _tipsLeftPadding;
  int _canGetGiftState; //10:可解锁  20:不可解锁
  bool _tipsShowState = false, _isShowGif = true;
  StorageKey _storageKey;
  int _coinCount = 0;

  @override
  void initState() {
    super.initState();
    _getGiftShowState();
    String stuNum = "";
    try {
      stuNum = LoginUserInfo.getInstance(null).selectedStudent.stuNum;
    } catch (_) {}
    _storageKey = StorageKey.custom(key: "_tipsVisible_$stuNum", valueType: bool);
    getWalnutTotalCount();
  }

  @override
  void didUpdateWidget(PathPageUserInfoBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isShowGif = true;
    _getGiftShowState();
    getWalnutTotalCount();
  }

  void _getGiftShowState() async {
    BaseResp baseResp = await NetRequest.get(url: ApiConfigs.showGiftState, param: {
      "cityCode": "all",
      "stuNum": LoginUserInfo.getInstance(null)?.selectedStudent?.stuNum,
    });
    _canGetGiftState = baseResp.data?.originValue ?? 20;
    if (_canGetGiftState == 10) {
      bool value = await Storage.boolForKey(_storageKey);
      if (value == null) _tipsShowState = true;
    }
    if (mounted) setState(() {});
    if (_isShowGif == true) {
      await Future.delayed(Duration(seconds: 3));
      if (mounted) setState(() => _isShowGif = false);
    }
  }

  /// 获取当前智慧币总数
  void getWalnutTotalCount() async {
    BaseResp baseResp = await NetRequest.get(url: ApiConfigs.getWalnutTotal, param: {
      "stuNum": LoginUserInfo.getInstance(null)?.selectedStudent?.stuNum,
    });
    if (baseResp.result == true && baseResp.data != null) {
      BaseRespData respData = baseResp.data;
      if (respData.originValue is int) _coinCount = respData.originValue;
      if (respData.originValue is String) _coinCount = respData.originValue as int;
      if (mounted) setState(() {});
    } else {
      _coinCount = 0;
    }
  }

  /// 点击切换课程，语数外切换事件
  void _classSubjectsChangeAction() async {
    AiStudentClassVO result = await showSwitchCourseDialog(context, Provider.of<ValueNotifier<AiStudentClassVO>>(context, listen: false).value);
    if (result != null) widget.onClassChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      IntrinsicHeight(
        child: Row(children: <Widget>[
          Expanded(flex: 1, child: _buildLoginUserInfo()),
//          Expanded(flex: 1, child: _buildClassSubjects2()),
          _buildClassSubjects2(),
          Expanded(flex: 1, child: _buildPathPageBarButton()),
        ]),
      ),
      Visibility(
        visible: _tipsShowState == true,
        child: Container(
          height: px(30),
          child: Stack(overflow: Overflow.visible, children: <Widget>[
            Positioned(
              top: -px(12),
              child: _buildGiftWidgetTips(),
            ),
          ]),
        ),
      ),
    ]);
  }

  /// 反馈按钮和设置按钮
  Widget _buildPathPageBarButton() {
    Widget buttonBuild(PathPageBarActionType index) {
      String imgIcon = index.index == 0 ? "assets/ai_package/images/path/btn_feedback@3x.webp" : "assets/ai_package/images/path/btn_setup@3x.webp";
      return GestureDetector(
        onTap: () => widget.onButtonTap == null ? null : widget.onButtonTap(index),
        child: Column(children: <Widget>[
          Image.asset(imgIcon, width: px(44), height: px(44)),
          Container(height: px(2)),
          Text(index.index == 0 ? "反馈" : "设置", style: CustomTextStyle.fz(fontSize: px(14))),
        ], mainAxisAlignment: MainAxisAlignment.center),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: px(12)),
      child: Row(children: <Widget>[
        Spacer(),
        _buildGetTheGiftWidget(),
        Container(width: px(30)),
        buttonBuild(PathPageBarActionType.feedback),
        Container(width: px(30)),
        buttonBuild(PathPageBarActionType.setting),
        Container(width: px(15)),
      ]),
    );
  }

  Widget _buildClassSubjects2() {
    return SubjectSwitchBar(_classSubjectsChangeAction);
  }

  /// 登录用户头像的信息
  Widget _buildLoginUserInfo() {
    return GestureDetector(
      onTap: () => widget.onButtonTap == null ? null : widget.onButtonTap(PathPageBarActionType.userInfo),
      child: Stack(children: <Widget>[
        Positioned(
          left: px(15),
          top: px(10),
          child: Row(children: <Widget>[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                color: Colors.black.withOpacity(0.3),
              ),
              padding: EdgeInsets.all(px(5)),
              child: Consumer<LoginUserInfo>(
                builder: (context, LoginUserInfo value, child) {
                  StudentInfo info = value.selectedStudent;
                  return Row(children: <Widget>[
                    Container(
                      width: px(37),
                      height: px(37),
                      child: info?.headImg?.isNotEmpty == true
                          ? ClipOval(
                              child: FadeInImage.assetNetwork(
                                fit: BoxFit.cover,
                                image: info.headImg,
                                placeholder: AiClassImg.defaultAvater,
                              ),
                            )
                          : ClipOval(child: Image.asset(AiClassImg.defaultAvater, fit: BoxFit.cover)),
                    ),
                    Container(width: px(5)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _returnInfoBarChilds(info),
                    ),
                    Container(width: px(5)),
                    GestureDetector(
                      onTap: () => widget.onButtonTap == null ? null : widget.onButtonTap(PathPageBarActionType.coin),
                      child: Row(
                        children: <Widget>[
                          Image.asset("assets/ai_package/images/path/icon_gold@3x.webp", width: px(33), height: px(36)),
                          Container(width: px(5)),
                          Text("${_coinCount}", style: CustomTextStyle.fz(fontSize: px(16))),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                  ]);
                },
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  List<Widget> _returnInfoBarChilds(StudentInfo info) {
    List<Widget> childs = [];
    Container name = Container(
      constraints: BoxConstraints(maxWidth: px(80)),
      child: Text(
        "${info?.name ?? "学生姓名"}",
        style: CustomTextStyle.fz(fontSize: px(14)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    childs.add(name);
    if (info != null && info.grade != null && info.grade > 0 && info.grade < 13) {
      String levelStr = _getGradeString(info.grade);
      Text grade = Text(levelStr, style: CustomTextStyle.fz(fontSize: px(12)));
      childs.add(grade);
    }
    return childs;
  }

  /// 获取
  String _getGradeString(int grade) {
    switch (grade) {
      case 1:
        return "小班";
      case 2:
        return "大班";
      case 3:
        return "学前班";
      case 4:
        return "一年级";
      case 5:
        return "二年级";
      case 6:
        return "三年级";
      case 7:
        return "四年级";
      case 8:
        return "五年级";
      case 9:
        return "六年级";
      case 10:
        return "初一";
      case 11:
        return "初二";
      case 12:
        return "初三";
      default:
        return "";
    }
  }

  Widget _buildGetTheGiftWidget() {
    return GestureDetector(
      onTap: () {
        if (_canGetGiftState == 20) {
          UiUtil.showToast("学完任意两节课才能免费领课哦");
          return;
        }
        _hideTipsBarAction();
        widget.onButtonTap(PathPageBarActionType.giftTap);
      },
      child: Container(
        height: px(40),
        width: px(55),
        child: Stack(key: _giftBoxKey, overflow: Overflow.visible, alignment: AlignmentDirectional.center, children: <Widget>[
          () {
            if (_isShowGif == true) {
              return Positioned(
                right: -px(20),
                top: -px(36),
                child: Image.asset("assets/ai_package/images/path/path_getGift_img.webp", fit: BoxFit.fitWidth, height: px(80), width: px(80)),
              );
            }
            return Positioned(
              top: -px(18),
              right: -px(8),
              child: Image.asset("assets/ai_package/images/path/path_gift_icon.webp", fit: BoxFit.fitWidth, height: px(55), width: px(55)),
            );
          }(),
        ]),
      ),
    );
  }

  Widget _buildGiftWidgetTips() {
    if (_tipsLeftPadding == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(seconds: 1));
        RenderBox renderBox = _giftBoxKey.currentContext.findRenderObject();
        double width = renderBox?.size?.width ?? 0;
        _tipsLeftPadding = renderBox.localToGlobal(Offset.zero).dx + px(10) + width / 9 * 8.0;
        if (mounted) setState(() {});
      });
      return Container();
    }
    return Padding(
      padding: EdgeInsets.only(left: _tipsLeftPadding),
      child: Transform(
        transform: Matrix4.rotationY(pi),
        child: ShapeOfView(
          shape: BubbleShape(position: BubblePosition.Top, arrowPositionPercent: 0.1, arrowHeight: px(7), arrowWidth: px(7)),
          elevation: 4,
          child: GestureDetector(
            onTap: _hideTipsBarAction,
            child: Container(
              color: Colors.black.withOpacity(0.24),
              padding: EdgeInsets.only(top: px(15), left: px(8), right: px(8), bottom: px(8)),
              child: IntrinsicWidth(
                child: Transform(
                  transform: Matrix4.rotationY(pi),
                  alignment: AlignmentDirectional.center,
                  child: Row(
                    children: <Widget>[
                      Image.asset("assets/ai_package/images/path/icon_book.webp", width: px(20)),
                      Container(width: 5),
                      Text("你获得了199元外教课,点击领取", style: TextStyle(fontSize: px(14))),
                      Container(width: 5),
                      GestureDetector(
                        onTap: _hideTipsBarAction,
                        child: Icon(Icons.close, color: Colors.white, size: px(15)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _hideTipsBarAction() {
    Storage.setBool(_storageKey, false);
    _tipsShowState = false;
    if (mounted) setState(() {});
  }
}

class SubjectSwitchBar extends StatelessWidget {
  final void Function() callBack;

  SubjectSwitchBar(this.callBack);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callBack,
      child: Container(
        alignment: Alignment.topCenter,
        child: Container(
          height: px(57),
          width: px(147),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: px(17),
                  ),
                  Container(
                    width: px(3),
                    height: px(14),
                    color: Color(0xFFF4F4F4),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    width: px(3),
                    height: px(14),
                    color: Color(0xFFF4F4F4),
                  ),
                  SizedBox(
                    width: px(17),
                  ),
                ],
              ),
              Consumer<AiStudentClassVO>(builder: (_, AiStudentClassVO value, __) {
                String subTitle = "未选定";
                Color titleColor = Color(0xFFEA8514);
                Color borderColor = Color(0xFFEA8514).withOpacity(0.4);
                String imagePath = "assets/ai_package/images/path/change@3x.webp";
                int type = value.subjectCode;
                if (type == 40) {
                  subTitle = "语文";
                  titleColor = Color(0xFFEA8514);
                  borderColor = titleColor.withOpacity(0.4);
                  imagePath = "assets/ai_package/images/path/change@3x.webp";
                }
                if (type == 50) {
                  subTitle = "数学";
                  titleColor = Color(0xFF1690E8);
                  borderColor = titleColor.withOpacity(0.3);
                  imagePath = "assets/ai_package/images/path/subject_switch_math.webp";
                }
                if (type == 10) {
                  subTitle = "英语";
                  titleColor = Color(0xFFA96CF8);
                  borderColor = titleColor.withOpacity(0.3);
                  imagePath = "assets/ai_package/images/path/path_english_switch_button@3x.webp";
                }
                return Container(
                  height: px(39),
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(px(19.5)),
                    boxShadow: [
                      BoxShadow(color: titleColor, offset: Offset(0, 3.0), blurRadius: 0, spreadRadius: 0),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: px(13),
                      ),
                      Container(
                        width: px(10),
                        height: px(10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              width: px(10),
                              height: px(10),
                              decoration: BoxDecoration(
                                color: borderColor,
                                borderRadius: BorderRadius.circular(px(5)),
                              ),
                            ),
                            Container(
                              width: px(6),
                              height: px(6),
                              decoration: BoxDecoration(
                                color: titleColor,
                                borderRadius: BorderRadius.circular(px(3)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Text(subTitle, style: CustomTextStyle.fz(fontSize: px(18), color: titleColor)),
                      SizedBox(
                        width: px(6),
                      ),
                      Image.asset(imagePath, width: px(20), height: px(20)),
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                        width: px(10),
                        height: px(10),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              width: px(10),
                              height: px(10),
                              decoration: BoxDecoration(
                                color: borderColor,
                                borderRadius: BorderRadius.circular(px(5)),
                              ),
                            ),
                            Container(
                              width: px(6),
                              height: px(6),
                              decoration: BoxDecoration(
                                color: titleColor,
                                borderRadius: BorderRadius.circular(px(3)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: px(13),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
