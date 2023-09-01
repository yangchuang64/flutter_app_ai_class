import 'package:blingabc_base/blingabc_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_ai_math/models/login_model.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutterblingaiplugin/screen/configs/dark_mode_config.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/local_data.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetBaseModel.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:provider/provider.dart';

class SwitchStudentPage extends StatefulWidget {
  final bool showBack;

  const SwitchStudentPage({Key key, this.showBack = false}) : super(key: key);

  @override
  State createState() => _SwitchStudentPageState();
}

class _SwitchStudentPageState extends State<SwitchStudentPage> {
  StudentInfo _studentInfo;

  @override
  void initState() {
    super.initState();
    _studentInfo = Provider.of<LoginUserInfo>(context, listen: false).selectedStudent;
    if (local_data_get(LOCAL_DATA_SELECTED_STUDENT_NUM) == null) {
      LoginInfo loginInfo = Provider.of<LoginUserInfo>(context, listen: false).loginInfo;
      NetRequest.get(
        url: ApiConfigs.studentList,
        param: {'parentNum': loginInfo.parentNum},
      ).then((resp) {
        if (resp.result) {
          List<StudentInfo> students = ((resp.data as BaseRespData).originValue as List)?.map((e) => e == null ? null : StudentInfo.fromJson(e as Map<String, dynamic>))?.toList();
          for (int i = 0; i < loginInfo.studentList.length; i++) {
            var studentInfo = loginInfo.studentList[i];
            for (var studentInfo2 in students) {
              if (studentInfo.stuNum == studentInfo2.stuNum) {
                studentInfo.active = studentInfo2.active;
                if (studentInfo.active == 1) {
                  _studentInfo = studentInfo;
                  break;
                }
              }
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<StudentInfo> students = Provider.of<LoginUserInfo>(context, listen: false).loginInfo?.studentList;
    return Theme(
      data: ThemeData(scaffoldBackgroundColor: Colors.white),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: widget.showBack
            ? PreferredSize(
                child: AppBar(
                  elevation: 0.0,
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: DarkModeConfig().navigationTitleColor),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  brightness: Brightness.light,
                  backgroundColor: DarkModeConfig().navigationBackgroundColor,
                ),
                preferredSize: Size.fromHeight(kTextTabBarHeight),
              )
            : null,
        body: Container(
          padding: EdgeInsets.fromLTRB(30, widget.showBack ? 10 : 70, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
//              IconButton(
//                icon: Icon(Icons.arrow_back_ios, color: DarkModeConfig().navigationTitleColor),
//                onPressed: () {
//                  Navigator.pop(context, false);
//                },
//              ),
              Text("请选择学生", style: CustomTextStyle.fz(fontSize: 21)),
              SizedBox(
                height: 30,
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: students?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  StudentInfo student = students[index];
                  return _buildStudentItem(student);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return new Container(height: 40.0, color: Colors.white);
                },
              ),
              SizedBox(
                height: 50,
              ),
              ShapeButton(
                title: '确定',
                isEnable: Provider.of<LoginUserInfo>(context, listen: false).selectedStudent != null,
                beginColor: Color(0xFFFABE00),
                endColor: Color(0xFFFABE00),
                onTap: debounce(
                  () {
//                    if (Provider.of<LoginUserInfo>(context, listen: false).selectedStudent != null) {
//                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => PathPage()), (_) => false);
//                    }
                    if (!widget.showBack || _studentInfo != Provider.of<LoginUserInfo>(context, listen: false).selectedStudent) {
                      Provider.of<LoginUserInfo>(context, listen: false).updateSelectedStudent(_studentInfo);
                      Navigator.pop(context, true);
                    } else {
                      Navigator.pop(context, false);
                    }
                  },
                  500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildStudentItem(StudentInfo studentInfo) {
    return GestureDetector(
      onTap: () => setState(() {
        _studentInfo = studentInfo;
      }),
      child: Stack(
        alignment: AlignmentDirectional(1.0, 0.0),
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 20, top: 15, bottom: 15),
            margin: EdgeInsets.only(right: 13),
            decoration: BoxDecoration(
              color: studentInfo.stuNum == _studentInfo.stuNum ? Color(0xFFFABE00) : Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(rem(phone: 30.0, pad: 45))),
                  ),
                  width: rem(phone: 60.0, pad: 60),
                  height: rem(phone: 60.0, pad: 60),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(rem(phone: 30.0, pad: 45)),
                    child: NetworkLoadingImage(
                      width: rem(phone: 60.0, pad: 90),
                      height: rem(phone: 60.0, pad: 90),
                      loadingWidth: 10.0,
                      url: studentInfo.headImg,
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        studentInfo.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CustomTextStyle.fz(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        '学号: ${studentInfo.stuNum}',
                        style: CustomTextStyle.fz(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            child: studentInfo.stuNum == _studentInfo.stuNum
                ? Image(
                    height: 26.0,
                    width: 26.0,
                    image: AssetImage('assets/ai_package/images/login/switch_select_y.webp'),
                  )
                : Image(
                    height: 26.0,
                    width: 26.0,
                    image: AssetImage('assets/ai_package/images/login/switch_select_n.webp'),
                  ),
          ),
        ],
      ),
    );
  }
}
