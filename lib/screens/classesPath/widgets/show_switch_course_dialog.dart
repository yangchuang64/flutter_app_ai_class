import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/change_course_vo.dart';
import 'package:flutter_app_ai_math/screens/classesPath/model/student_class_vo.dart';
import 'package:flutter_app_ai_math/screens/classesPath/view_model/path_view_model.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/dialogs.dart';
import 'package:flutterblingaiplugin/screen/widgets/feedback_animated_widget.dart';

/// 展示切换课程的弹窗
/// 路径页面切换语数外课程
Future<AiStudentClassVO> showSwitchCourseDialog(BuildContext context, AiStudentClassVO classVO) async {
  AiStudentClassVO _result;
  FeedbackWidgetController _controller = FeedbackWidgetController();
  await showAppDialog(
    context: context,
    builder: (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.trigger());
      return FeedbackAnimatedWidget(
        controller: _controller,
        child: Material(
          color: Colors.black.withOpacity(0.6),
          child: _SwitchCourseWidget((AiStudentClassVO result) => _result = result, classVO.subjectCode),
        ),
      );
    },
  );
  _controller.dispose();
  return _result;
}

class _SwitchCourseWidget extends StatefulWidget {
  final void Function(AiStudentClassVO) selectCallback;
  final int courseType;

  _SwitchCourseWidget(this.selectCallback, this.courseType);

  @override
  __SwitchCourseWidgetState createState() => __SwitchCourseWidgetState();
}

class __SwitchCourseWidgetState extends State<_SwitchCourseWidget> {
  ChangeCourseVO _changeCourseVO;
  int _courseTypeButtonsSelectedIndex;

  List<int> _selectableCourseTypes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    NetRequest.get<ChangeCourseVO>(
      url: ApiConfigs.changeClass,
//      jsonInAsset: "changeLesson.json",
      dateTypeInstance: ChangeCourseVO(),
      param: {"stuNum": LoginUserInfo.getInstance(null).selectedStudent.stuNum},
    ).then((BaseResp<ChangeCourseVO> resp) async {
      if (resp.result && mounted) {
        _changeCourseVO = resp.data;
        if (_changeCourseVO != null) {

          if (_changeCourseVO.chinese != null && _changeCourseVO.chinese.length > 0) {
            _selectableCourseTypes.add(40);
            await _courseLearningProcessFetch(_changeCourseVO.chinese, 40);
          }

          if (_changeCourseVO.math != null && _changeCourseVO.math.length > 0) {
            _selectableCourseTypes.add(50);
            await _courseLearningProcessFetch(_changeCourseVO.math, 50);
          }

          if (_changeCourseVO.english != null && _changeCourseVO.english.length > 0) {
            _selectableCourseTypes.add(10);
            await _courseLearningProcessFetch(_changeCourseVO.english, 10);
          }
          for (int i = 0; i < _selectableCourseTypes.length; i++) {
            if (_selectableCourseTypes[i] == widget.courseType) {
              _courseTypeButtonsSelectedIndex = i;
            }
          }
          if (_courseTypeButtonsSelectedIndex == null) _courseTypeButtonsSelectedIndex = 0;
          if (mounted) setState(() {});
        } else {
          UiUtil.showToast("没有数据");
        }
      } else {
        UiUtil.showToast(resp?.msg ?? "");
      }
    });
    super.didChangeDependencies();
  }

  /// 学习进度批量查询
  Future<void> _courseLearningProcessFetch(List<AiStudentClassVO> classes, int subjectCode) async {
    String stuNum = LoginUserInfo.getInstance(null).selectedStudent.stuNum;
    List ids = classes?.map((i) => i.classId)?.toList();
    Map<String, dynamic> params = {"stuNum": stuNum, "ids": ids, "subjectCode": subjectCode};
    BaseResp<BaseRespData> resp = await NetRequest.post(url: ApiConfigs.classesFinish, param: params);
    List maths = resp.data?.originValue ?? [];
    maths.forEach((var map) {
      for (AiStudentClassVO value in classes) {
        if (value.classId == map["classId"]) {
          value.finishedState = map["finishedState"];
          value.finishedCount = map["finishedCount"];
          value.lessonCount = map["lessonCount"];
        }
      }
    });
  }

  /// 课程选择完成
  void _classSelectedAction(AiStudentClassVO classVO) async {
    String stuNum = LoginUserInfo.getInstance(null).selectedStudent.stuNum;
    Map<String, dynamic> params = {"stuNum": stuNum, "classId": classVO.classId, "courseType": classVO.courseType};
    BaseResp<AiStudentLessonVO> resp = await NetRequest.post<AiStudentLessonVO>(url: ApiConfigs.lessonsInClass, dateTypeInstance: AiStudentLessonVO(), param: params);
    classVO.studentLessonVOList = resp.data;
    PathViewModel.checkLessonsLockState(classVO);
    widget.selectCallback(classVO);
    if (Navigator.canPop(context)) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    Widget courseTitleButton(String title, String bgImagePath, Function callBack,{bool isSelected = false, int index = 0, bool isMirror = false}){
      return GestureDetector(
        onTap: (){callBack(index);},
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(isMirror?pi:0),
              child: Container(
                constraints: BoxConstraints.expand(),
                decoration: BoxDecoration(image: DecorationImage(image: AssetImage(bgImagePath),fit: BoxFit.fill)),
              ),
            ),
            Center(child:Text(title??"", style: CustomTextStyle.fz(color: Colors.white,fontSize: px(isSelected?18:14)),),),
          ],
        ),
      );
    }

    double titleWidth = UiUtil.screenWidth - px(240);
    double titleHeight = titleWidth*(35/370);

    Widget courseTypeButtonsOne(int index){
      return GestureDetector(
        onTap: (){_didClickCourseType(index);},
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(px(12))),
          child: Container(
            width: titleWidth,
            height: titleHeight,
            color: Color(0xFFFABE00),
            child: Center(child:Text(courseTypeName(_selectableCourseTypes[index]), style: CustomTextStyle.fz(color: Colors.white,fontSize: 18)),),
          ),
        ),
      ); 
    }

    Widget courseTypeButtonsTwo(int index){
      List<Widget>childs = [];
      if(index==0){
        double leftWidth = titleWidth*(188/370.0);
        double leftHeight = titleHeight;

        double rightHeight = titleHeight*(27/35.0);
        double rightWidth = titleWidth*(189/370.0);

        childs = [
          Positioned(
            left: -1,
            bottom: 0,
            width: leftWidth,
            height: leftHeight,
            child: courseTitleButton(courseTypeName(_selectableCourseTypes[0]),"assets/ai_package/images/path/two_left_select_bg.webp",_didClickCourseType,isSelected: true,index: 0),
          ),
          Positioned(
            right: -1,
            bottom: 0,
            width: rightWidth,
            height: rightHeight,
            child: courseTitleButton(courseTypeName(_selectableCourseTypes[1]),"assets/ai_package/images/path/two_right_normal_bg.webp",_didClickCourseType,index: 1),
          ),
        ];
      }else if(index==1){

        double leftWidth = titleWidth*(188/370.0);
        double leftHeight = titleHeight*(27/35.0);

        double rightHeight = titleHeight;
        double rightWidth = titleWidth*(189/370.0);
        childs = [
          Positioned(
            left: -1,
            bottom: 0,
            width: leftWidth,
            height: leftHeight,
            child: courseTitleButton(courseTypeName(_selectableCourseTypes[0]),"assets/ai_package/images/path/two_right_normal_bg.webp",_didClickCourseType,index: 0,isMirror: true),
          ),
          Positioned(
            right: -1,
            bottom: 0,
            width: rightWidth,
            height: rightHeight,
            child: courseTitleButton(courseTypeName(_selectableCourseTypes[1]),"assets/ai_package/images/path/two_left_select_bg.webp",_didClickCourseType, isSelected: true,index: 1,isMirror: true),
          ),
        ];
      }
      return Container(
        width: titleWidth,
        height: titleHeight,
        color: Colors.transparent,
        child: Stack(
          children: childs,
        ),
      );
    }

    Widget courseTypeButtonsThree(int index){
      List<Widget>childs = [];
      if(index==0){
        double chineseWidth = titleWidth*(147/370.0);
        double chineseHeight = titleHeight;

        double mathHeight = chineseHeight*(27/35.0);
        double mathWidth = titleWidth*(118/370.0);
        double mathLeft = titleWidth*(140.5/370.0);
        childs = [
          Positioned(
            left: -1,
            bottom: 0,
            width: chineseWidth,
            height: chineseHeight,
            child: courseTitleButton("语文","assets/ai_package/images/path/chinese_chinese_bg.webp",_didClickCourseType,index: 0,isSelected: true),
          ),
          Positioned(
            left: mathLeft,
            bottom: 0,
            width: mathWidth,
            height: mathHeight,
            child: courseTitleButton("数学","assets/ai_package/images/path/chinese_mathematics_bg.webp",_didClickCourseType,index: 1),
          ),
          Positioned(
            right: -1,
            bottom: 0,
            width: mathWidth,
            height: mathHeight,
            child: courseTitleButton("英语","assets/ai_package/images/path/chinese_english_bg.webp",_didClickCourseType,index: 2),
          ),
        ];
      }else if(index==1){

        double chineseWidth = titleWidth*(118/370.0);
        double chineseHeight = titleHeight*(27/35.0);

        double mathHeight = titleHeight;
        double mathWidth = titleWidth*(145/370.0);
        double mathLeft = titleWidth*(112.5/370.0);
        childs = [
          Positioned(
            left: -1,
            bottom: 0,
            width: chineseWidth,
            height: chineseHeight,
            child: courseTitleButton("语文","assets/ai_package/images/path/math_chinese_bg.webp",_didClickCourseType,index: 0),
          ),
          Positioned(
            left: mathLeft,
            bottom: 0,
            width: mathWidth,
            height: mathHeight,
            child: courseTitleButton(null,"assets/ai_package/images/path/math_math_bg.webp",_didClickCourseType,index: 1),
          ),
          Positioned(
            right: -1,
            bottom: 0,
            width: chineseWidth,
            height: chineseHeight,
            child: courseTitleButton("英语","assets/ai_package/images/path/math_english_bg.webp",_didClickCourseType,index: 2),
          ),
        ];
      }else{
        double chineseWidth = titleWidth*(118/370.0);
        double chineseHeight = titleHeight*(27/35.0);

        double englishHeight = titleHeight;
        double englishWidth = titleWidth*(145/370.0);
        double mathLeft = titleWidth*(112.5/370.0);
        childs = [
          Positioned(
            left: -1,
            bottom: 0,
            width: chineseWidth,
            height: chineseHeight,
            child: courseTitleButton("语文","assets/ai_package/images/path/math_chinese_bg.webp",_didClickCourseType,index: 0),
          ),
          Positioned(
            left: mathLeft,
            bottom: 0,
            width: chineseWidth,
            height: chineseHeight,
            child: courseTitleButton("数学","assets/ai_package/images/path/english_math_bg.webp",_didClickCourseType,index: 1),
          ),
          Positioned(
            right: -1,
            bottom: 0,
            width: englishWidth,
            height: englishHeight,
            child: courseTitleButton("英语","assets/ai_package/images/path/english_english_bg.webp",_didClickCourseType, isSelected: true,index: 2),
          ),
        ];
      }
      return Container(
        width: titleWidth,
        height: titleHeight,
        color: Colors.transparent,
        child: Stack(
          children: childs,
        ),
      );
    }

    Widget buildCourseTypeButtonsNew() {
      if(_changeCourseVO == null)return Container(
        width: titleWidth,
        height: titleHeight,
        color: Colors.transparent,
      );
      if(_selectableCourseTypes.length==3)return courseTypeButtonsThree(_courseTypeButtonsSelectedIndex);
      if(_selectableCourseTypes.length==2)return courseTypeButtonsTwo(_courseTypeButtonsSelectedIndex);
      return courseTypeButtonsOne(_courseTypeButtonsSelectedIndex);
    }


    return Stack(children: <Widget>[
      Positioned(
        top: UiUtil.isPad() ? px(70) : px(40),
        left: px(120),
        right: px(120),
        bottom: UiUtil.isPad() ? px(70) : px(40),
        child: Column(children: <Widget>[
//          buildCourseTypeButtons(),
          buildCourseTypeButtonsNew(),
          Expanded(child: buildSelectedCourseLists()),
        ]),
      ),
      Positioned(
        top: UiUtil.isPad() ? px(60) : px(30),
        right: px(90),
        width: px(20),
        height: px(20),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Image.asset("assets/ai_package/images/path/icon_off@3x.webp", fit: BoxFit.fill),
        ),
      )
    ]);
  }

  void _didClickCourseType(int  index){
    print("click ${index}");
    setState(() => _courseTypeButtonsSelectedIndex = index);
  }

  String courseTypeName(int courseType) {
    if (courseType == 40) {
      return "语文";
    } else if (courseType == 50) {
      return "数学";
    } else if (courseType == 10) {
      return "英语";
    } else {
      return "";
    }
  }

  /// 课程种类的切换按钮
  Widget buildCourseTypeButtons() {
    Widget buttonBuild(int index) {
      bool isSelected = _courseTypeButtonsSelectedIndex == index;
      String img = isSelected ? "assets/ai_package/images/path/courseSelect.webp" : "assets/ai_package/images/path/courseUnSelect.webp";
      String title = courseTypeName(_selectableCourseTypes[index]);
      return GestureDetector(
        child: Container(
//          height: px(22),
          height: px(26.4),
//          width: px(96),
          width: px(115.2),
          padding: EdgeInsets.only(top: px(4)),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFFABE00), width: 0.5)),
            image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
          ),
          child: Center(child: Text(title, style: CustomTextStyle.fz(fontSize: px(18)))),
        ),
        onTap: () => setState(() => _courseTypeButtonsSelectedIndex = index),
      );
    }

    List<Widget> typeButtonsBuild() {
      List<Widget> childs = [];
      for (int i = 0; i < _selectableCourseTypes.length; i++) {
        childs.add(buttonBuild(i));
      }
      return childs;
    }

    return _changeCourseVO == null
        ? Container(height: px(22))
        : Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: typeButtonsBuild(),
            ),
          );
  }

  /// 课时列表
  Widget buildSelectedCourseLists() {
    // 学习进度标签
    Widget courseLearningProcess(AiStudentClassVO classVO) {
      if (classVO.finishedCount == classVO.lessonCount) {
        return Row(children: <Widget>[
          Text("已学完", style: CustomTextStyle.fz(fontSize: px(12), color: Color(0xFF999999))),
          Container(width: px(5)),
          Image.asset("assets/ai_package/images/path/icon_select_s@3x.webp", height: px(15), width: px(15)),
        ]);
      }
      return Text("已学 ${classVO.finishedCount}/${classVO.lessonCount}", style: CustomTextStyle.fz(fontSize: px(12), color: Color(0xFF999999)));
    }

    Widget listItemBuild(AiStudentClassVO aiStudentClassVO) {
      return GestureDetector(
        onTap: () => _classSelectedAction(aiStudentClassVO),
        child: Container(
          color: Colors.transparent,
          height: px(70),
          child: Row(children: <Widget>[
            Container(width: px(15)),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(px(10))),
              child: Image.asset("assets/ai_package/images/aiMath/image_class@3x.webp", width: px(46), height: px(46)),
            ),
            Container(width: px(15)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("${aiStudentClassVO.className}", style: CustomTextStyle.fz(fontSize: px(14), color: Colors.black)),
                Container(height: px(5)),
                courseLearningProcess(aiStudentClassVO),
              ],
            ),
          ]),
        ),
      );
    }

    List<AiStudentClassVO> currentCourseTypeSources() {
      if (_courseTypeButtonsSelectedIndex == null) {
        return [];
      }
      int currentCourseType = _selectableCourseTypes[_courseTypeButtonsSelectedIndex];
      if (currentCourseType == 40) {
        return _changeCourseVO.chinese;
      } else if (currentCourseType == 50) {
        return _changeCourseVO.math;
      } else if (currentCourseType == 10) {
        return _changeCourseVO.english;
      } else {
        return [];
      }
    }

//    BorderRadiusGeometry borderRadius = BorderRadius.all(Radius.circular(px(20)));
    BorderRadiusGeometry borderRadius = BorderRadius.vertical(bottom: Radius.circular(px(12)));
    List<AiStudentClassVO> source = currentCourseTypeSources();
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
//          border: Border.all(color: Color(0xFFFABE00), width: px(4)),
        ),
        child: _changeCourseVO == null
            ? Center(
                child: Image.asset("assets/ai_package/images/utils/loading_coco.gif", width: px(80), height: px(80)),
              )
            : ListView.separated(
                itemCount: source.length,
                itemBuilder: (_, int index) => listItemBuild(source[index]),
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(color: Color(0xFFF4F4F4), height: 2);
                },
              ),
      ),
    );
  }
}
