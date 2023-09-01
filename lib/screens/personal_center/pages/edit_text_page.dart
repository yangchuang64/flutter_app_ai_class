import 'package:flutter/material.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/uitils/validators.dart';


class TextEditPage extends StatefulWidget {
  final String text;

  TextEditPage({this.text});

  @override
  State<StatefulWidget> createState() {
    return TextEditPageState();
  }
}

class TextEditPageState extends State<TextEditPage> {
  TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
    if (widget.text != null) {
      controller.text = widget.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    var title = widget.text;

    return Theme(
      data: ThemeData(primaryColor: Colors.grey, hintColor: Colors.grey),
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, style: CustomTextStyle.fz(color: Color(0xFF4a4a4a), fontSize: 18.0)),
          centerTitle: true,
          elevation: 0.0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Color(0xFF4A4A4A)),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Color(0xFFFFFFFF),
          bottom: PreferredSize(
            preferredSize: Size(double.infinity, 1),
            child: Container(
              width: double.infinity,
              height: 1,
              color: Color(0x66B2B2B2),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                '保存',
                style: CustomTextStyle.fz(fontSize: 18.0, color: Color.fromRGBO(117, 94, 251, 1.0)),
              ),
              onPressed: () {
                var result = true;
                // 验证输入名字是否符合逻辑

                result = Validators.isChineseName(controller.text);

                if (result) {
                  Navigator.pop(context, controller.text);
                } else {
                  UiUtil.showToast("请输入正确的中文名");
                }
              },
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: controller,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(contentPadding: EdgeInsets.all(10.0), hintText: title != null ? title : ''),
                autofocus: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
