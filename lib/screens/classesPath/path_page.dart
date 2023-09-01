import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/routers/router_config.dart';
import 'package:flutter_app_ai_math/routers/routers.dart';
import 'package:flutter_app_ai_math/screens/classesPath/how_to_have_class_page.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/student_class_vo.dart';
import 'package:flutter_app_ai_math/screens/classesPath/view_model/path_view_model.dart';
import 'package:flutter_app_ai_math/screens/classesPath/widgets/path_page_userInfo_bar.dart';
import 'package:flutter_app_ai_math/screens/personal_center/pages/my_coin_page.dart';
import 'package:flutter_app_ai_math/screens/upgradeController/upgrade_controller.dart';
import 'package:flutterblingaiplugin/screen/configs/constant.dart';
import 'package:flutterblingaiplugin/screen/configs/img_source_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/log.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/net_connect.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/slide_amplify_widget.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:provider/provider.dart';
import 'package:push/bling_push.dart';

class PathPage extends StatefulWidget {
  @override
  _PathPageState createState() => _PathPageState();
}

class _PathPageState extends State<PathPage> with RouteAware {
  /// 路径视图模型
  PathViewModel _pathViewModel = PathViewModel();
  int _subjectCode = 40;

  Map<String, dynamic> _event;

  StudentInfo _studentInfo;
  GlobalKey<PathPageUserInfoBarWidgetState> loginValidKey = new GlobalKey<PathPageUserInfoBarWidgetState>();

  @override
  void initState() {
    super.initState();
    rotatingScreenLandscape();
    UpgradeController.checkUpgrade(context);

    /// 信鸽推送注册
    BlingPush.initXGPush(
      onMessageReceived: (Map<dynamic, dynamic> event) {
        printLog('ai_log', 'xinge event $event');
        if (event['customMessage'] == null) return;

        if (isInClass) {
          UiUtil.showToast('正在上课中...');
          return;
        }

        Map<String, dynamic> message = jsonDecode(event['customMessage']);
        String stuNum = message['stuNum'];
        String classId = message['classId'];
        String classLessonId = message['classLessonId'];
        String subjectCode = message['subjectCode'];
        int lessonType = message['lessonType'] ?? 2;
        int classLessonNum = message['classLessonNum'] ?? 0;

        if (stuNum != Provider.of<LoginUserInfo>(context, listen: false).selectedStudent.stuNum) {
          LoginInfo loginInfo = Provider.of<LoginUserInfo>(context, listen: false).loginInfo;
          for (var student in loginInfo.studentList) {
            if (student.stuNum == stuNum) {
              UiUtil.showLongToast('请切换学生${student.name}查看');
              return;
            }
          }
        }
        if (classId == null || classLessonId == null || subjectCode == null) {
          UiUtil.showToast('数据有误...');
          return;
        }

        if (_event != null) return;
        _event = event;
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.pushNamed(
            context,
            PagePath.beforeAiPage,
            arguments: {
              "classId": int.parse(classId),
              "classLessonId": int.parse(classLessonId),
              "subjectCode": int.parse(subjectCode),
              "lessonType": lessonType,
              "classLessonNum": classLessonNum,
            },
          );
          _event = null;
        }).then((value) => loginValidKey.currentState.getWalnutTotalCount());
      },
    );

    LoginInfo loginInfo = Provider.of<LoginUserInfo>(context, listen: false).loginInfo;
    _studentInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
    _pathViewModel.updatePush(loginInfo.mobile, '');
    getPathLessonsData();

    NetConnect.addObserver(_onConnectListener);
  }

  void _onConnectListener(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      LoginInfo loginInfo = Provider.of<LoginUserInfo>(context, listen: false).loginInfo;
      _pathViewModel.updatePush(loginInfo.mobile, '');
      getPathLessonsData();
    }
  }

  void getPathLessonsData() {
    _pathViewModel.getPathLessonsData().then((resp) {
      if (resp.result == false) {
        UiUtil.showToast(resp.code == -1 ? "没有网络" : (resp.msg ?? ""));
        Provider.of<ValueNotifier<AiStudentClassVO>>(context)?.value = AiStudentClassVO.fromJson({});
      } else {
        printLog('ai_log', '_pathViewModel.getLocalData');
        Provider.of<ValueNotifier<AiStudentClassVO>>(context)?.value = resp.data;
        AiStudentClassVO classVO = resp.data;
        _subjectCode = classVO.subjectCode;
      }
    });
  }

  /// 横屏设置
  Future<void> rotatingScreenLandscape() async {
    await SystemChrome.setEnabledSystemUIOverlays([]);
    await UiUtil.setLandscapeRightMode();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    rotatingScreenLandscape();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);

    NetConnect.removeObserver(_onConnectListener);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  /// 点击开始上课
  void _prepareToClass(AiStudentLessonVO lessonVO) async {
    if (lessonVO.isLocked) {
      UiUtil.showToast("课程还没有解锁哦");
      return;
    }
    // 新ai课
    Navigator.pushNamed(
      context,
      PagePath.beforeAiPage,
      arguments: {
        "classId": lessonVO.classId,
        "classLessonId": lessonVO.classLessonId,
        "classLessonName": lessonVO.classLessonName,
        "subjectCode": _subjectCode,
        "lessonType": lessonVO.lessonType,
        "classLessonNum": lessonVO.classLessonNum,
      },
    ).then((value) => loginValidKey.currentState.getWalnutTotalCount());
  }

  /// 设置或反馈按钮事件
  void _settingOrFeedBackButtonAction(PathPageBarActionType actionType) async {
    if (actionType == PathPageBarActionType.feedback) {
      Navigator.pushNamed(context, PagePath.feedback);
    } else if (actionType == PathPageBarActionType.setting) {
      Navigator.pushNamed(context, PagePath.setting);
    } else if (actionType == PathPageBarActionType.userInfo) {
      Navigator.pushNamed(context, PagePath.babyInformation).then((value) {
        StudentInfo studentInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
        if (_studentInfo != studentInfo) {
          setState(() => _studentInfo = studentInfo);
          getPathLessonsData();
        }
      });
    } else if (actionType == PathPageBarActionType.giftTap) {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return HowToHaveClassPage(title: "领取课程", url: "https://em.blingabc.com/report/trial-class?channelOne=59334&channelTwo=461282");
      }));
    } else if (actionType == PathPageBarActionType.coin) {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return MyCoinPage();
      }));
    }
  }

  /// 语数外课程切换回调事件
  void _classTypeChangedAction(AiStudentClassVO classVO) {
    Provider.of<ValueNotifier<AiStudentClassVO>>(context, listen: false)?.value = classVO;
    _subjectCode = classVO.subjectCode;
  }

  /// 点击如何上课
  void _clickHowToHaveClass() {
    Navigator.pushNamed(context, PagePath.howToHaveClass);
  }

  /// 生命周期
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: ValueListenableProvider.value(
        value: Provider.of<ValueNotifier<AiStudentClassVO>>(context),
        child: Scaffold(
          body: Stack(children: <Widget>[
            _returnCurrentBg(),
            _buildListView(),
          ]),
        ),
      ),
      onWillPop: () async {
        MoveToBackground.moveTaskToBack();
        return false;
      },
    );
  }

  /// 返回当前背景图 产品说要根据科目不同更换背景图
  Widget _returnCurrentBg() {
    return Consumer<AiStudentClassVO>(builder: (context, data, _) {
      String imagePath = PathImg.pathMainBg;
      if (data != null) {
        if (data.subjectCode == 50) {
          imagePath = PathImg.pathMathBg;
        } else if (data.subjectCode == 10) {
          imagePath = PathImg.pathEnglishBg;
        }
      }
      return Positioned.fill(
        child: Image.asset(imagePath, fit: BoxFit.fill),
      );
    });
  }

  /// 列表
  /// 本地json布局列表界面
  Widget _buildListView() {
    return Consumer<AiStudentClassVO>(builder: (context, data, _) {
      printLog('ai_log', 'Consumer=============$data');
      if (data == null) {
        return Center(
          child: Image.asset("assets/ai_package/images/utils/loading_coco.gif", width: px(120), height: px(120)),
        );
      }

      List<AiStudentLessonVO> lessons = data?.studentLessonVOList ?? [];
      return Column(children: <Widget>[
        PathPageUserInfoBarWidget(
          key: loginValidKey,
          onButtonTap: _settingOrFeedBackButtonAction,
          onClassChanged: _classTypeChangedAction,
        ),
        lessons.length == 0
            ? Expanded(child: Center(child: _noClassIconBuild()))
            : Expanded(
                child: SlideAmplifyWidget(
                  initialPage: (lessons?.indexWhere((e) => e.isLocked == true) ?? 1) - 1,
                  pageEnable: false,
                  containerSize: Size(px(270), px(180)),
                  itemCount: lessons.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: px(209),
                      height: px(152),
                      child: _buildClassCard(lessons[index]),
                    );
                  },
                ),
              ),
        Container(
            height: px(65),
            child: Row(
              children: <Widget>[
                Container(
                  width: px(111),
                  child: _buildTermMark(data),
                ),
                Spacer(),
                Container(
                  width: px(65),
                  margin: EdgeInsets.only(right: px(20), bottom: px(10)),
                  child: _buildHowToHaveClass(),
                ),
              ],
            )),
      ]);
    });
  }

  /// 没有课程
  Widget _noClassIconBuild() {
    return Container(
      width: px(277),
      height: px(187),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/ai_package/images/path/none_class_card.webp"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(children: <Widget>[
        Image.asset("assets/ai_package/images/path/image_empty3x.webp", width: px(98), height: px(81)),
        Container(height: px(10)),
        Text("暂无课程，请购课或联系班主任～", style: TextStyle(color: Color(0xFF999999), fontSize: px(12))),
      ], mainAxisAlignment: MainAxisAlignment.center),
    );
  }

  /// card内容创建
  Widget _buildClassCard(AiStudentLessonVO lessonVO) {
    // 课序列号
    Widget buildClassNumText() {
      return Positioned(
        top: px(4),
        child: Text("${lessonVO.classLessonNum}", style: CustomTextStyle.fz(fontSize: px(16))),
      );
    }

    // 开始上课按钮
    Widget buildStartButton() {
      return Positioned(
        bottom: -px(10),
        child: GestureDetector(
          onTap: () => _prepareToClass(lessonVO),
          child: Container(
            width: px(94),
            height: px(38),
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("assets/ai_package/images/path/btn_start@3x.webp"), fit: BoxFit.fill),
            ),
          ),
        ),
      );
    }

    // 课程名称
    Widget buildClassNameAndBeginDate() {
      Widget titleWidget = Container(
        width: px(209),
        padding: EdgeInsets.only(left: px(10), right: px(10)),
        child: Text(
          "${lessonVO.classLessonName}",
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: CustomTextStyle.fz(color: Colors.black, fontSize: px(18)),
        ),
      );
      List dateTmp = lessonVO.beginDate?.split(":");
      dateTmp?.removeLast();
      Widget beginDateWidget = Visibility(
        visible: lessonVO.beginDate != null,
        child: Container(
          padding: EdgeInsets.only(left: px(13), right: px(13), top: px(4), bottom: px(4)),
          child: Text(
            "${dateTmp?.join(":") ?? ""}",
            style: CustomTextStyle.fz(color: Color(0xFF666666), fontSize: px(14)),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            border: Border.all(color: Color(0xFFF8832B), width: 2),
          ),
        ),
      );

      return Positioned(
        top: px(25),
        bottom: px(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            titleWidget,
            SizedBox(
              height: px(12),
            ),
            beginDateWidget
          ],
        ),
      );
    }

    Widget buildHasLockedMark() {
      return Visibility(
        visible: lessonVO.isLocked == true,
        child: Positioned(
          top: px(13),
          left: px(8),
          right: px(8),
          bottom: px(9),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.all(Radius.circular(px(20))),
            ),
            alignment: AlignmentDirectional.center,
            child: Image.asset("assets/ai_package/images/path/path_image_lock.webp", width: px(44), height: px(60)),
          ),
        ),
      );
    }

    /// 三套UI适配修改
    /// 背景图
    Widget buildWhiteBackGroundNew() {
      String imagePath = PathImg.pathChineseCardBg;
      if (_subjectCode == 50) imagePath = PathImg.pathMathCardBg;
      if (_subjectCode == 10) imagePath = PathImg.pathEnglishCardBg;
      return Positioned(
        child: Image.asset(imagePath),
      );
    }

    /// 序号背景
    Widget buildClassNumTextBg() {
      return Visibility(
        child: Positioned(
          top: 0,
          child: Image.asset("assets/ai_package/images/path/path_card_index_bg.webp", width: px(62), height: px(25)),
        ),
      );
    }

    /// 已完成标识
    Widget buildDoneMarkNew() {
      return Visibility(
        visible: lessonVO.stuState == 21 || lessonVO.stuState == 20,
        child: Positioned(
          top: px(6),
          right: 0,
          child: Image.asset("assets/ai_package/images/path/path_chinese_card_done@3x.webp", width: px(67), height: px(67)),
        ),
      );
    }

    return Stack(
      alignment: AlignmentDirectional.topCenter,
      overflow: Overflow.visible,
      children: <Widget>[
        buildWhiteBackGroundNew(),
        buildClassNameAndBeginDate(),
        buildHasLockedMark(),
        buildClassNumTextBg(),
        buildClassNumText(),
        buildStartButton(),
        buildDoneMarkNew(),
      ],
    );
  }

  /// 学期以及季度的标签
  Widget _buildTermMark(AiStudentClassVO aiStudentClassVO) {
    AiStudentClassVO classVO = aiStudentClassVO;
    String levelConvert(int grade) {
      String levelStr;
      if (grade == null) {
        levelStr = "";
      }
      levelStr = _getGradeString(grade);
      return levelStr;
    }

    Color textColor = Color(0xFFFF5A0A);
    String bgImagePath = "assets/ai_package/images/path/image_deer@3x.webp";
    if (aiStudentClassVO.subjectCode == 50) {
      textColor = Color(0xFF6399F1);
      bgImagePath = "assets/ai_package/images/path/image_elephant@3x.webp";
    } else if (aiStudentClassVO.subjectCode == 10) {
      textColor = Color(0xFFA96CF8);
      bgImagePath = "assets/ai_package/images/path/image_coco@3x.webp";
    }

    return Stack(
      overflow: Overflow.visible,
      alignment: AlignmentDirectional.bottomCenter,
      children: <Widget>[
        Positioned(
          bottom: 0,
          left: px(0),
          width: px(111),
          height: px(97),
          child: Container(
            alignment: AlignmentDirectional.bottomCenter,
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage(bgImagePath))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Consumer<LoginUserInfo>(builder: (context, LoginUserInfo value, child) {
                  if (value.selectedStudent == null) {
                    return Text("");
                  }
                  return Text("${levelConvert(classVO?.level)} ${classVO?.termName ?? "_"}", style: CustomTextStyle.fz(color: textColor, fontSize: px(14)));
                }),
                Text("共${classVO?.studentLessonVOList?.length ?? 0}课", style: CustomTextStyle.fz(color: textColor, fontSize: px(14))),
                Container(height: px(8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 创建如何上课按钮
  Widget _buildHowToHaveClass() {
    return GestureDetector(
      onTap: _clickHowToHaveClass,
      child: Stack(
        overflow: Overflow.visible,
        alignment: AlignmentDirectional.bottomCenter,
        children: <Widget>[
          Positioned(
            bottom: 0,
            right: px(0),
            width: px(65),
            height: px(65),
            child: Image.asset("assets/ai_package/images/path/path_howtohaveclass@3x.webp"),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: px(7),
            child: Container(
              height: px(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Color(0xFF29DFA4),
                  Color(0xFF07DADC),
                ]),
                borderRadius: BorderRadius.circular(px(18.5)),
                boxShadow: [
                  BoxShadow(color: Color(0xFFB7FFEB), offset: Offset(0, 1.0), blurRadius: 3, spreadRadius: 0),
                  BoxShadow(color: Color(0xFF1F807C), offset: Offset(0, -1.0), blurRadius: 3, spreadRadius: 0),
                ],
              ),
              child: Text(
                "如何上课?",
                style: TextStyle(color: Color(0xFFFFFFFF), fontSize: px(12), fontFamily: CustomFontFamily.FANG_ZHENG_BOLD, shadows: [Shadow(color: Color(0xFF000000).withOpacity(0.19), blurRadius: 1, offset: Offset(0, 2))]),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取
  String _getGradeString(int grade) {
    switch (grade) {
      case 10:
        return "一年级";
      case 20:
        return "二年级";
      case 30:
        return "三年级";
      case 40:
        return "四年级";
      case 50:
        return "五年级";
      case 60:
        return "六年级";
      case 99:
        return "学前";
      default:
        return "_";
    }
  }
}
