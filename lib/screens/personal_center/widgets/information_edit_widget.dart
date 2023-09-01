import 'package:flutter/material.dart';
import 'package:blingabc_base/blingabc_base.dart' as Base;
import 'package:flutter/cupertino.dart';
import 'package:flutterblingaiplugin/screen/configs/dark_mode_config.dart';
import 'package:flutterblingaiplugin/screen/uitils/custom_text_style.dart';
import 'package:flutterblingaiplugin/screen/uitils/ui_util.dart';
import 'package:flutterblingaiplugin/screen/widgets/dialogs.dart';
import 'package:flutterblingaiplugin/screen/widgets/feedback_animated_widget.dart';

Future<void> showEditInfoDialog(BuildContext context,{Function callback, EditInfoType type = EditInfoType.name,String name,int gender}) async {
  FeedbackWidgetController _controller = FeedbackWidgetController();
  await showAppDialog(
    context: context,
    builder: (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _controller.trigger());
      return FeedbackAnimatedWidget(
        controller: _controller,
        child: Material(
          color: Colors.black.withOpacity(0.6),
          child: EditInfoWidget(originalName: name,callBack: callback,type: type,gender: gender,),
        ),
      );
    },
  );
  _controller.dispose();
  return;
}

enum EditInfoType{
  name,gender,birthday,grade
}

class EditInfoWidget extends StatefulWidget {
  final EditInfoType type;
  final String originalName;
  final int gender;
  final Function callBack;

  EditInfoWidget({this.type,this.originalName, this.callBack, this.gender});


  @override
  _EditInfoWidgetState createState() => _EditInfoWidgetState();
}

const int YEAR_SIZE = 50;
const int YEAR_OFFSET = 1970;

class _EditInfoWidgetState extends State<EditInfoWidget> {
  TextEditingController _editingController = TextEditingController();
  String _inputText="";
  int _currentGender = 0;

  // 出生日期相关
  int _changedYear = 0, _selectedYear = YEAR_SIZE;
  int _changedMonth = 0, _selectedMonth = 0;
  int _changedDay = 0, _selectedDay = 0;

  // 年级相关
  int _selectIndex = 0;
  int _selectGradeIndex = 0;
  List<String> _primaryNames = ["一年级","二年级","三年级","四年级","五年级","六年级",];
  List<int> _primaryIds = [4,5,6,7,8,9,];

  List<String> _preschoolNames = ["小班","大班","学前班"];
  List<int> _preschoolIds = [1,2,3];

  List<String> _selectOptionNames;
  List<int> _selectOptionIds;

  @override
  void initState() {
    super.initState();
    _selectOptionNames = _preschoolNames;
    _selectOptionIds = _preschoolIds;
    if(widget.type == EditInfoType.name){
      _inputText = widget.originalName??"";
      _editingController.text = _inputText;

      _editingController.addListener(() {
        var input = _editingController.text;
        if(!Base.Validators.isChineseName(input))UiUtil.showToast("请输入2~20个汉字");
        if (input.length > 20) {
          input = input.substring(0, 20);
          _editingController.text = input;
          FocusScope.of(context).requestFocus(FocusNode());
          UiUtil.showToast("请输入2~20个汉字");
        }
        setState(() {
          _inputText = input;
        });
      });
    }else if(widget.type == EditInfoType.gender){
      _currentGender = widget.gender;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Container(
          width: px(320),
          height: px(237),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(px(12)),
            color: Colors.white
          ),
          child: Stack(
            children: <Widget>[
              Column(
                children: _returnContentWidgets(),
              ),
              Positioned(
                right: 0,
                top: 0,
                width: px(50),
                height: px(50),
                child:  Container(width: px(50),height: px(50),
                  child: Center(child: Image.asset("assets/ai_package/images/personalCenter/efit_close_image.webp",fit: BoxFit.fill,width: px(18),height: px(18),),),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                width: px(50),
                height: px(50),
                child: GestureDetector(
                  onTap: ()=>Navigator.of(context).pop(),
                  child: Container(width: px(50),height: px(50),color: Colors.transparent,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 内容widget
  List<Widget> _returnContentWidgets(){
    if(widget.type == EditInfoType.name){
      return [
        SizedBox(height: px(20),child: Container(),),
        Text("修改姓名",
          style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(18)),
        ),
        SizedBox(height: px(40),child: Container(),),
        _creatTextField(),
        SizedBox(height: px(47),child: Container(),),
        _creatSubmitButton(),
      ];
    }else if(widget.type == EditInfoType.gender){
      Widget genderOptionButton(int index, int currentGender){
        bool selected = (index==currentGender);
        return GestureDetector(
          onTap: (){setState(() {
            _currentGender = index;
          });},
          child: Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Container(
                width: px(110),
                height: px(40),
                decoration: BoxDecoration(
                  color: selected ? Color(0xFFFABE00) : Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(pxWithPad(20.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(index == 1 ? "assets/ai_package/images/personalCenter/edit_boy.webp" : "assets/ai_package/images/personalCenter/edit_girl.webp",width: px(18),height: px(23),),
                    SizedBox(width: px(15),child: Container(),),
                    Text(index==1?"男孩":"女孩",
                      style: CustomTextStyle.fz().copyWith(color: selected?Color(0xFFFFFFFF):Color(0xFF666666), fontSize: fontSizeWithPad(16)),
                    ),
                  ],
                ),
              ),
              Positioned(bottom: px(-10),right: px(-10),child: Visibility(visible: selected,child: Image.asset("assets/ai_package/images/personalCenter/edit_select_s.webp",width: px(26),height: px(26),),),),
            ],
          ),
        );
      }

      return [
        SizedBox(height: px(15),child: Container(),),
        Text("修改性别",
          style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(18)),
        ),
        SizedBox(height: px(52),child: Container(),),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            genderOptionButton(1, _currentGender),
            SizedBox(width: px(40),child: Container(),),
            genderOptionButton(2, _currentGender),
          ],
        ),
        SizedBox(height: px(50),child: Container(),),
        _creatSubmitButton(),
      ];
    }else if(widget.type == EditInfoType.birthday){
      return [
        SizedBox(height: px(15),child: Container(),),
        Text("选择出生日期",
          style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(18)),
        ),
        Container(
          height: px(142),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: px(15),child: Container(),),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedYear,
                  ),
                  itemExtent: px(28),
                  onSelectedItemChanged: (int index) {
                    _changedYear = index;
                  },
                  children: List<Widget>.generate(YEAR_SIZE, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1 + YEAR_OFFSET}',
                        style: CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(16)),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedMonth,
                  ),
                  itemExtent: px(28),
                  onSelectedItemChanged: (int index) {
                    _changedMonth = index;
                  },
                  children: List<Widget>.generate(12, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1}',
                        style: CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(16)),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedDay,
                  ),
                  itemExtent: px(28),
                  backgroundColor: Colors.white,
                  onSelectedItemChanged: (int index) {
                    _changedDay = index;
                  },
                  children: List<Widget>.generate(31, (int index) {
                    return Center(
                      child: Text(
                        '${index + 1}',
                        style: CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(16)),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(width: px(15),child: Container(),),
            ],
          ),
        ),
        _creatSubmitButton(),
      ];
    }else if(widget.type == EditInfoType.grade){
      return [
        SizedBox(height: px(15),child: Container(),),
        Text("选择年级",
          style: Base.CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(18)),
        ),
        Container(
          height: px(142),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: px(30),child: Container(),),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectIndex,
                  ),
                  itemExtent: px(28),
                  backgroundColor: Colors.white,
                  onSelectedItemChanged: (int index) {
                    _selectIndex = index;
                    _selectGradeIndex = 0;
                    if(index==0){
                      _selectOptionNames = _preschoolNames;
                      _selectOptionIds = _preschoolIds;
                    }else{
                      _selectOptionNames = _primaryNames;
                      _selectOptionIds = _primaryIds;
                    }
                    setState(() {});
                  },
                  children: List<Widget>.generate(2, (int index) {
                    return Center(
                      child: Text(
                        index==0?"学前":"小学",
                        style: CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(16)),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  key: GlobalKey(),
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectGradeIndex,
                  ),
                  itemExtent: px(28),
                  backgroundColor: Colors.white,
                  onSelectedItemChanged: (int index) {
                    _selectGradeIndex = index;
                  },
                  children: List<Widget>.generate(_selectOptionNames.length, (int index) {
                    return Center(
                      child: Text(
                        _selectOptionNames[index],
                        style: CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainTitleColor, fontSize: fontSizeWithPad(16)),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(width: px(30),child: Container(),),
            ],
          ),
        ),
        _creatSubmitButton(),
      ];
    }else{
      return [];
    }
  }

  // 创建文本输入框
  Widget _creatTextField() {
    return Container(
      height: pxWithPad(40),
      margin: EdgeInsets.fromLTRB(pxWithPad(30), pxWithPad(0), pxWithPad(30), pxWithPad(0)),
      padding: EdgeInsets.fromLTRB(pxWithPad(15), pxWithPad(5), pxWithPad(15), pxWithPad(0)),
      decoration: BoxDecoration(
        color: DarkModeConfig().textFieldBackgroundColor,
        borderRadius: BorderRadius.circular(pxWithPad(20.0)),
      ),
      child: TextField(
        controller: _editingController,
        cursorColor: Color(0xFFFABE00),
        style: CustomTextStyle.fz().copyWith(color: Color(0xFF333333), fontSize: fontSizeWithPad(16)),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          border: InputBorder.none, // 去掉下划线
          hintText: "请输入中文姓名!",
          hintStyle: CustomTextStyle.fz().copyWith(color: Color(0xFFCCCCCC), fontSize: fontSizeWithPad(16)),
          counterStyle: CustomTextStyle.fz().copyWith(color: Color(0xFFCCCCCC), fontSize: fontSizeWithPad(16)),
        ),
      ),
    );
  }

  // 创建提交按钮
  Widget _creatSubmitButton() {
    bool enable = _isSubmitButtonEnable();
    return Container(
      margin: EdgeInsets.fromLTRB(pxWithPad(30), pxWithPad(0), pxWithPad(30), pxWithPad(0)),
      child: GestureDetector(
        onTap: (enable ? _didClickSubmitButton : null),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: pxWithPad(40),
              decoration: BoxDecoration(
                color: (enable ? Color(0xFFFABE00) : Color(0xFFFABE00).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(pxWithPad(20)),
              ),
            ),
            Text("确定", style: CustomTextStyle.fz().copyWith(color: DarkModeConfig().mainBackgroundColor, fontSize: fontSizeWithPad(18))),
          ],
        ),
      ),
    );
  }

  // 是否启用按钮
  bool _isSubmitButtonEnable() {
    if(widget.type == EditInfoType.name){
      return !(_inputText.length == 0);
    }else if(widget.type == EditInfoType.gender){
      return (_currentGender==1||_currentGender==2);
    }else {
      return true;
    }
  }

  void _didClickSubmitButton() {
    if(widget.type == EditInfoType.name){
      widget.callBack("${_editingController.text}");
    }else if(widget.type == EditInfoType.gender){
      widget.callBack(_currentGender);
    }else if(widget.type == EditInfoType.birthday){
      _selectedYear = _changedYear;
      _selectedMonth = _changedMonth;
      _selectedDay = _changedDay;
      String year = '${_selectedYear + 1 + YEAR_OFFSET}';
      String moth = (_selectedMonth >= 9) ? '${_selectedMonth + 1}' : '0${_selectedMonth + 1}';
      String day = (_selectedDay >= 9) ? '${_selectedDay + 1}' : '0${_selectedDay + 1}';
      String birthday = "${year}-${moth}-${day}";
      widget.callBack(birthday);
    }else if(widget.type == EditInfoType.grade){
      String selectGrade = _selectOptionNames[_selectGradeIndex];
      int selectId = _selectOptionIds[_selectGradeIndex];
      widget.callBack(selectId);
    }
  }
}
