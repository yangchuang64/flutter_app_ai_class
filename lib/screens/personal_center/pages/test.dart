import 'package:blingabc_base/blingabc_base.dart';
import 'package:flutter/material.dart';
import 'package:flutterblingaiplugin/screen/game_templates/widgets/template_game_cover_guide_widget.dart';


class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {

  GlobalKey _globalKey = GlobalKey();
  Rect _rect = Rect.fromLTWH(100, 100, 100, 100);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UiUtil.setLandscapeRightMode();

    Future.delayed(Duration(seconds: 2),(){
//      showAnswerTip(context: context,markKey: _globalKey ,type: 2, borderMargin: 30,borderWidth: 20);
      showGameCoverGuide(context: context, firstRect: Rect.fromLTWH(100, 100, 100, 100));
    });
    
  }

  @override
  Widget build(BuildContext context) {

    List<String> words = ["Dreamtime and Pangu","Dreamtime and Pangu","they are both creathion stories","are like", "because", "in which ", "the earth sun and sky","were created"];
    List<String> answer = ["哈哈哈","嘿嘿","哈哈哈","嘿嘿","asdf"];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: (){
              print("on tap inner");
            },
            child: Container(color: Colors.cyan,),
          ),
          Positioned(
            left: _rect.left+100,
            top: _rect.top,
            width: _rect.width,
            height: _rect.height,
            child: Container(
              key: _globalKey,
              color: Colors.orange,
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: (){
                removeGameCoverGuide(context);
              },
              child: Container(
                color: Colors.yellow,
                width: 100,
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );

//    return Scaffold(
//      body: SentenceLongGameWidget(optionStrings: words, resultStrings: words,onCallBack: (result){
//        print("call back￥${result}");
//      },),
//    );
  }
}
