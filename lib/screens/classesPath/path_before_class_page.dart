import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/routers/router_config.dart';
import 'package:flutter_app_ai_math/screens/classesPath/bling_call_page.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/ai_lesson_resource_vo.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/bling_call_model.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/student_class_vo.dart';
import 'package:flutter_app_ai_math/screens/classesPath/view_model/path_before_model.dart';
import 'package:flutter_app_ai_math/screens/classesPath/view_model/path_view_model.dart';
import 'package:flutterblingaiplugin/screen/ai_class_detail/aiClass_detail_page2.dart';
import 'package:flutterblingaiplugin/screen/ai_class_detail/study_report_page.dart';
import 'package:flutterblingaiplugin/screen/configs/img_source_config.dart';
import 'package:flutterblingaiplugin/screen/configs/plugin_login_user_info.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/back_navi_bar.dart';
import 'package:flutterblingaiplugin/screen/widgets/dialogs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

///
/// 由路径页面到上课页面之间的课前课后中转，
/// 显示 去上课和学习报告页面
///
class PathBeforeClassPage extends StatefulWidget {
  final int classId;
  final int classLessonId;
  final String classLessonName;
  final int subjectCode;
  final int lessonType;

  // 旧版ai课使用的
  final int classLessonNum;

  PathBeforeClassPage(
    this.classId,
    this.classLessonId,
    this.classLessonName,
    this.subjectCode,
    this.lessonType, {
    this.classLessonNum,
  });

  @override
  _PathBeforeClassPageState createState() => _PathBeforeClassPageState();
}

class _PathBeforeClassPageState extends State<PathBeforeClassPage> with RouteAware {
  List<AiLessonResourceVO> _resource;
  int classStartTime = 0;
  PathBeforeModel pathBeforeModel;
  LessonResourceContentModel _lessonResourceContentModel;

  @override
  void initState() {
    super.initState();
    pathBeforeModel = PathBeforeModel();
    _getData();
  }

  void _getData() async {
    /// 旧版ai课列表
    if (widget.lessonType == 1) {
      NetRequest.get<OldAiLessonResourceVO>(
        url: ApiConfigs.oldAiResourceList,
        dateTypeInstance: OldAiLessonResourceVO(),
        param: {
          "stuNum": LoginUserInfo.getInstance(null).selectedStudent.stuNum,
          "classId": widget.classId,
          "lessonNum": widget.classLessonNum,
        },
      ).then((BaseResp<OldAiLessonResourceVO> resp) {
        if (resp?.result == true) {
          _resource = OldAiLessonResourceVO.convertFrom(resp.data);
          if (_resource != null && _resource.length > 0) {
            _loadBlingCall("${_resource.first.lessonId}");
          }
          setState(() {});
        } else {
          UiUtil.showToast(resp?.msg ?? "");
        }
      });
      return;
    }

    /// 获取数据
    StudentInfo info = LoginUserInfo.getInstance(null).selectedStudent;
    NetRequest.post<AiLessonResourceVO>(
      url: ApiConfigs.beforeClass,
      dateTypeInstance: AiLessonResourceVO(),
      param: {"stuNum": info.stuNum, "classId": widget.classId, "classLessonId": widget.classLessonId},
    ).then((BaseResp<AiLessonResourceVO> resp) async {
      if (resp.result == true) {
        await _courseFinishedFetch(resp.data);
        if (mounted) setState(() => _resource = resp.data);
        if (_resource != null && _resource.length > 0) {
          _loadBlingCall("${_resource.first.lessonId}");
        }
      } else {
        UiUtil.showToast(resp?.msg ?? "");
      }
    });
  }

  /// 课时资源是否学完状态查询
  Future<void> _courseFinishedFetch(List<AiLessonResourceVO> resourceVOs) async {
    if (resourceVOs == null || resourceVOs?.length == 0) return;
    String stuNum = LoginUserInfo.getInstance(null).selectedStudent.stuNum;
    List params = [];
    resourceVOs.forEach((AiLessonResourceVO resourceVO) {
      Map<String, dynamic> map = {
        "stuNum": stuNum,
        "resourceId": resourceVO.resourceId,
        "resourceType": 3,
        "classLessonId": resourceVO.classLessonId,
        "lessonAttr": "AI_INTERACTIVE_LESSON",
      };
      params.add(map);
    });
    BaseResp resp = await NetRequest.post(url: ApiConfigs.lessonFinished, param: params);
    List resMaps = resp.data?.originValue ?? [];
    resMaps.forEach((var map) {
      for (AiLessonResourceVO value in resourceVOs) {
        if (map["resourceId"] == value.resourceId) {
          value.finishedCount = map["finishedCount"];
          value.finishedState = map["finishedState"];
          value.lessonCount = map["lessonCount"];
        }
      }
    });
  }

  void _loadBlingCall(String lessonid) {
    StudentInfo info = LoginUserInfo.getInstance(null).selectedStudent;
    NetRequest.get<PreviewReviewResourceModel>(
      url: ApiConfigs.blingCallResource,
      dateTypeInstance: PreviewReviewResourceModel(),
      //??"3118"
      param: {"stuNum": info.stuNum, "lessonId": lessonid ?? ""},
    ).then((BaseResp<PreviewReviewResourceModel> resp) async {
      if (resp.result == true) {
        print(resp.data);
        if (resp.data == null) return;
        PreviewReviewResourceModel model = resp.data;
        if (model.reviewLessonResources != null && model.reviewLessonResources.length > 0) {
          _lessonResourceContentModel = model.reviewLessonResources.first.resourceContent;
          if (mounted) setState(() {});
        }
      } else {
        UiUtil.showToast(resp?.msg ?? "");
      }
    });
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _rotatingScreenLandscape();
    _getData();
  }

  /// 横屏设置
  Future<void> _rotatingScreenLandscape() async {
    if (UiUtil.isLandscape() == true) return;
    await SystemChrome.setEnabledSystemUIOverlays([]);
    await UiUtil.setLandscapeRightMode();
  }

  /// 评价本课
  void _evaluateClassTapAction() {
    AiLessonResourceVO resourceVO;
    try {
      resourceVO = _resource.first;
    } catch (_) {}
    if (resourceVO == null) {
      UiUtil.showToast("数据错误");
      return;
    }
    Navigator.of(context).pushNamed(PagePath.evaluateCourse, arguments: {
      "lessonId": "${resourceVO.aiLessonId}",
      "lessonName": "${resourceVO.aiLessonName}",
      "classLessonId": "${resourceVO.classLessonId}",
      "classLessonName": resourceVO.classLessonName,
    });
  }

  /// 列表点击，跳转
  void _resourceItemTapAction(AiLessonResourceVO resourceVO, int itemIndex) async {
    bool classComplete = false;
    PluginLoginUserInfo.aiClassCompleteHandler = (
      BuildContext aiContext,
      int aiLessonId,
      int subjectCode,
      int classLessonId,
    ) {
      if (aiContext == null) return;
      classComplete = true;
      PathViewModel.unlockNextLesson(aiContext, widget.classLessonId); //解锁下一关
      Navigator.of(aiContext).pushReplacementNamed(PagePath.aiFinish, arguments: {
        "aiLessonId": aiLessonId,
        "subjectCode": subjectCode,
        "classLessonId": widget.classLessonId,
        "oldAiId": resourceVO.aiId,
      });
    };

    if (itemIndex == 0) {
      PermissionHandler().requestPermissions([
        PermissionGroup.storage,
        PermissionGroup.camera,
        PermissionGroup.microphone,
      ]).then((Map<PermissionGroup, PermissionStatus> result) {
        bool hasPermission = true;
        result.forEach((permissionGroup, permissionStatus) {
          if (/*permissionGroup == PermissionGroup.camera || */ permissionStatus == PermissionStatus.granted) {
            hasPermission &= true;
          } else {
            hasPermission = false;
          }
        });
        if (hasPermission) {
          //去上课
          classStartTime = DateTime.now().millisecondsSinceEpoch;
          Map<String, dynamic> param = {
            'classId': widget.classId,
            'classLessonId': widget.classLessonId,
            'classLessonName': widget.classLessonName,
            'resourceId': resourceVO.resourceId,
            "lessonId": resourceVO.lessonId,
            "oldAiId": resourceVO.aiId,
            "finishedState": resourceVO.finishedState,
          };
          Navigator.pushNamed(context, PagePath.aiDetail, arguments: param).then((value) {
            if (value == null || value == true) {
              // 打点记录上课
              pathBeforeModel.dotRecord(
                LoginUserInfo.getInstance(null).selectedStudent.stuNum,
                LoginUserInfo.getInstance(null).loginInfo.mobile,
                widget.classId,
                widget.classLessonId,
                classComplete ? 1 : 0,
                classStartTime,
                DateTime.now().millisecondsSinceEpoch,
                resourceVO.resourceId,
                3,
                28,
                isClassContinue,
                studyTime,
              );
            }
          });
        } else {
          showPermissionDialog(context);
        }
      });
    } else if (itemIndex == 1) {
      if (resourceVO.finishedState == 0) {
        UiUtil.showToast("报告还未生成，请稍后重试!");
        return;
      }
      //学习报告
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return StudyReportPage(
          resourceId: resourceVO.aiId ?? resourceVO.resourceId,
          classLessonId: resourceVO.classLessonId,
          resourceType: 3,
          subjects: () {
            if (resourceVO.aiId != null) return 4;
            if (widget.subjectCode == 10) return 1;
            if (widget.subjectCode == 40) return 2;
            if (widget.subjectCode == 50) return 3;
            return 0;
          }(),
        );
      }));
    } else {
      if (resourceVO.finishedState == 0) {
        UiUtil.showToast("先学完课程，才能解锁哦！");
        return;
      }

      PermissionHandler().requestPermissions([
        PermissionGroup.storage,
        PermissionGroup.camera,
        PermissionGroup.microphone,
      ]).then((Map<PermissionGroup, PermissionStatus> result) {
        bool hasPermission = true;
        result.forEach((permissionGroup, permissionStatus) {
          if (/*permissionGroup == PermissionGroup.camera || */ permissionStatus == PermissionStatus.granted) {
            hasPermission &= true;
          } else {
            hasPermission = false;
          }
        });

        if (hasPermission) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return BlingCallPage(
              model: _lessonResourceContentModel,
            );
          }));
        } else {
          showPermissionDialog(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String navigationTitle;
    try {
      navigationTitle = _resource?.first?.classLessonName;
    } catch (_) {}
    navigationTitle ??= "";
    Text titleText = Text(navigationTitle ?? "", style: CustomTextStyle.fz(fontSize: px(20)));

    String bgImagePath(int subjectCode) {
      String imagePath = "assets/ai_package/images/path/beforeClassBg@3x.webp";
      if (subjectCode == 40) {
        imagePath = "assets/ai_package/images/path/before_class_yuwen_bg.webp";
      }
      if (subjectCode == 10) {
        imagePath = "assets/ai_package/images/path/before_english_bg.webp";
      }
      return imagePath;
    }

    return Scaffold(
      body: Material(
        child: Stack(children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(),
            child: Image.asset(bgImagePath(widget.subjectCode), fit: BoxFit.fill),
          ),
          NavigatorBackBar(
            callback: () => Navigator.of(context).pop(),
            controller: NavigatorController(),
            title: titleText,
            isCenter: true,
          ),
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.none,
              child: Row(children: _listViewChildrenBuild(), mainAxisAlignment: MainAxisAlignment.center),
            ),
          ),
          _buildEvaluationButton(),
        ]),
      ),
    );
  }

  /// 评价本课
  Widget _buildEvaluationButton() {
    return Positioned(
      right: px(16),
      top: px(12),
      child: GestureDetector(
        onTap: _evaluateClassTapAction,
        child: Column(children: <Widget>[
          Image.asset("assets/ai_package/images/path/new_btn_evaluation.webp", width: px(44), height: px(44)),
          Container(height: px(5)),
          Text("评价本课", style: CustomTextStyle.fz(fontSize: px(12))),
        ]),
      ),
    );
  }

  /// 列表创建
  List<Widget> _listViewChildrenBuild() {
    if (_resource == null || _resource?.length == 0) {
      return [
        Center(
          child: Image.asset("assets/ai_package/images/utils/loading_coco.gif", width: px(100) /*, height: px(100)*/
              ),
        ),
      ];
    }
    AiLessonResourceVO resourceVO = _resource.first;
    // 锁
    Widget itemMaskBuild(int index) {
      String bgImagePath = (index == 0 ? "assets/ai_package/images/path/ailesson@3x.webp" : PathImg.pathStudyReportBg);
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(bgImagePath), fit: BoxFit.fill),
        ),
        child: Visibility(
          visible: index != 0 && resourceVO.finishedState != 1,
          child: Container(
            color: Colors.black.withOpacity(0.6),
            child: Center(child: Image.asset("assets/ai_package/images/path/path_image_lock.webp", width: px(34), height: px(44))),
          ),
        ),
      );
    }

    Widget itemBuilder(int index) {
      bool lessonHasDone() {
        List<AiStudentLessonVO> lessons = [];
        try {
          lessons = Provider.of<ValueNotifier<AiStudentClassVO>>(context, listen: false)?.value?.studentLessonVOList ?? [];
        } catch (_) {}
        for (AiStudentLessonVO lesson in lessons) {
          if (lesson.classLessonId == resourceVO.classLessonId && lesson.lessonId == resourceVO.lessonId) {
            if (lesson.stuState == 20 || lesson.stuState == 21) {
              resourceVO.finishedState = 1;
              return true;
            }
          }
        }
        return false;
      }

      String title = index == 0 ? "1 AI互动课" : "2 学习报告";
      String bgImagePath = "assets/ai_package/images/path/beforeClass_board@3x.webp";
      return GestureDetector(
        onTap: () => _resourceItemTapAction(resourceVO, index),
        child: Container(
          width: px(180),
          height: px(165),
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(bgImagePath)),
          ),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: px(7)),
                child: Text(title, style: CustomTextStyle.fz(fontSize: px(16))),
              ),
              Positioned(
                left: px(24),
                right: px(20),
                bottom: px(20),
                height: px(98),
                child: itemMaskBuild(index),
              ),
              Visibility(
                visible: index == 0 && lessonHasDone() && resourceVO.finishedState == 1,
                child: Positioned(
                  bottom: px(-30),
                  child: Image.asset("assets/ai_package/images/path/icon_select_s@3x.webp", width: px(28), height: px(28)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    /// 语文英语锁
    Widget chineseItemMaskBuild(int index) {
      String bgImagePath = (index == 0 ? "assets/ai_package/images/path/before_lesson_card.webp" : "assets/ai_package/images/path/before_yuwen_report.webp");
      switch (index) {
        case 0:
          bgImagePath = "assets/ai_package/images/path/before_lesson_card.webp";
          break;
        case 1:
          bgImagePath = "assets/ai_package/images/path/before_yuwen_report.webp";
          break;
        case 2:
          bgImagePath = "assets/ai_package/images/path/image_bling_call.webp";
          break;
      }
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(bgImagePath), fit: BoxFit.fill),
        ),
        child: Visibility(
          visible: index != 0 && resourceVO.finishedState != 1,
          child: Container(
            child: Center(child: Image.asset("assets/ai_package/images/path/before_yuwen_image_lock.webp")),
          ),
        ),
      );
    }

    /// 语文英语卡片
    Widget chineseItemBuilder(int index) {
      String title = index == 0 ? "1 AI互动课" : "2 学习报告";
      switch (index) {
        case 0:
          title = "1 AI互动课";
          break;
        case 1:
          title = "2 学习报告";
          break;
        case 2:
          title = "3 Bling Call";
          break;
      }
      // 卡片背景图
      String bgImagePath = "assets/ai_package/images/path/before_card_yuwen_bg.webp";
      return GestureDetector(
        onTap: () => _resourceItemTapAction(resourceVO, index),
        child: Container(
          width: px(206),
          height: px(177),
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage(bgImagePath)),
          ),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: px(7)),
                child: Text(title, style: CustomTextStyle.fz(fontSize: px(16))),
              ),
              Positioned(
                left: px(15),
                right: px(16),
                top: px(24),
                bottom: px(22),
                child: chineseItemMaskBuild(index),
              ),
              Visibility(
                visible: index == 0 && resourceVO.finishedState == 1,
                child: Positioned(
                  bottom: px(-30),
                  child: Image.asset("assets/ai_package/images/path/icon_select_s@3x.webp", width: px(28), height: px(28)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.subjectCode == 50) {
      return <Widget>[itemBuilder(0), Container(width: px(70)), itemBuilder(1)];
    } else if (widget.subjectCode == 40) {
      return <Widget>[chineseItemBuilder(0), Container(width: px(24)), chineseItemBuilder(1)];
    } else {
      int itemCount = 2;
      double margin = px(24);
      if (_lessonResourceContentModel != null) {
        itemCount = 3;
        margin = px(14);
      }
      List<Widget> childs = [chineseItemBuilder(0)];
      for (int i = 1; i < itemCount; i++) {
        childs.add(Container(width: margin));
        childs.add(chineseItemBuilder(i));
      }
      return childs;
    }
  }
}
