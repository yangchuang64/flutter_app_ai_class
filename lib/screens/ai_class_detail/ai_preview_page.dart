import 'package:blingabc_base/blingabc_base.dart';
import 'package:blingabc_base/blingabc_base.dart' as prefix0;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_ai_math/models/login_user_model.dart';
import 'package:flutter_app_ai_math/routers/router_config.dart';
import 'package:flutterblingaiplugin/screen/ai_class_detail/models/ai_class_model.dart';
import 'package:flutterblingaiplugin/screen/configs/url_api_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/netWork/src/NetRequest.dart';
import 'package:permission_handler/permission_handler.dart';

///
///  ai 课结束页面
///
class AiPreviewPage extends StatefulWidget {
  @override
  State createState() => _AiPreviewPageState();
}

class _AiPreviewPageState extends State<AiPreviewPage> with RouteAware {
  var title = '';
  TextEditingController textEditingController = new TextEditingController();
  TextEditingController _idController = new TextEditingController();

  @override
  void didPopNext() {
    super.didPopNext();
    rotatingScreenVertical();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
    textEditingController.dispose();
    _idController.dispose();
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }

  /// 竖屏设置
  Future<void> rotatingScreenVertical() async {
    if (UiUtil.isLandscape() == true) {
      await SystemChrome.setEnabledSystemUIOverlays([]);
      await UiUtil.setPortraitUpMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(scaffoldBackgroundColor: Colors.white),
      child: Scaffold(
        appBar: AppBar(
          title: Text("ai预览", style: TextStyle(color: Color(0xFF4a4a4a), fontSize: 18.0)),
          centerTitle: true,
          elevation: 0.0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Color(0xFF4A4A4A)),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Color(0xFFFFFFFF),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: textEditingController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: const Color(0xFFC2C2C2)),
                    hintText: '请输入',
                  ),
                ),
                SizedBox(height: 30),
                ShapeButton(
                  title: '确定',
                  isEnable: true,
                  beginColor: Color(0xFFFABE00),
                  endColor: Color(0xFFFABE00),
                  onTap: () async {
                    await PermissionHandler().requestPermissions([PermissionGroup.camera]);
                    await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
//                  await PermissionHandler().requestPermissions([PermissionGroup.storage]);
                    await SystemChannels.textInput.invokeMethod("TextInput.hide");
                    var params = {'aiLessonId': textEditingController.text};
                    prefix0.showCoCoLoading(context);
                    NetRequest.get(
                      url: ApiConfigs.aiPreview,
                      param: params,
                    ).then((resp) {
                      prefix0.hideCoCoLoading(context);
                      setState(() {
                        if (!resp.result) {
                          title = resp.msg;
                          return;
                        }
                        title = 'success';
                        if (resp.result == true) {
                          AiInteractiveLessonResource model = AiInteractiveLessonResource.fromMap(resp.data?.originValue);
                          if (model.resourceUrl?.isEmpty == true) {
                            UiUtil.showToast("资源不存在");
                            return;
                          }
                          Map<String, dynamic> param = {
                            "lessonId": int.parse(textEditingController.text),
                            "previewModel": model,
                            "finishedState": 1,
                          };
                          Navigator.of(context).pushNamed(PagePath.aiDetail, arguments: param);
                        }
                      });
                    });
                  },
                ),
                SizedBox(height: 30),
                Text('response ${title}'),
                Row(children: <Widget>[
                  Container(width: 70),
                  Expanded(child: TextFormField(controller: _idController, keyboardType: TextInputType.number)),
                  RaisedButton(
                    child: Text("修改用户id"),
                    onPressed: () {
                      LoginUserInfo.getInstance(null).selectedStudent.stuNum = _idController.text;
                      UiUtil.showToast("成功");
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  Container(width: 70),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
