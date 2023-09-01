import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutterblingaiplugin/screen/game_templates/base/game_component.dart';
import 'package:flutterblingaiplugin/screen/game_templates/char_fill_blank_tv_widget.dart';
import 'package:flutterblingaiplugin/screen/game_templates/choose_words_old_game.dart';
import 'package:flutterblingaiplugin/screen/game_templates/choose_words_widget.dart';
import 'package:flutterblingaiplugin/screen/game_templates/model/game_template_model.dart';
import 'package:flutterblingaiplugin/screen/game_templates/sentence/sentence_short_game.dart';
import 'package:flutterblingaiplugin/screen/game_templates/tie_line/tie_line_game.dart';
import 'package:flutterblingaiplugin/screen/game_templates/word_switch/single_choice_game.dart';
import 'package:flutterblingaiplugin/screen/model/game_result_info.dart';

class GamePage extends StatefulWidget {
  final int id;

  const GamePage({Key key, this.id}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.id) {
      case 0: //弹弓
        return WordGameWidget(
          content: 'aa cc',
          result: ['bb'],
          options: ['aa', 'bb', 'cc'],
          onCallBack: (result, answer) {},
          isPreview: false,
          guideController: null,
        );
      case 1: // 连线
        return TieLineWidget(
          title: 'Look and Choose',
          questions: {
            'https://img.blingabc.com/ecd7be08f02d4236bc7a6495e2354c4a.png': 'abc',
            'https://img.blingabc.com/25e5308ab3ff43e99c44cd1aea58ceb7.jpg': 'bas',
            'https://img.blingabc.com/4bb2a40b068b43a6b383ee52209813ea.jpg': 'cdsd',
          },
          tieLineType: TieLineType.word,
          onCallBack: (result) {},
          isPreview: false,
          guideController: null,
        );
      case 2: //过桥游戏
        return SentenceShortWidget(
          optionStrs: ['aaaa', 'bbbbb', 'cccc', 'ddddddd', 'eeeeeee'],
          resultStrs: ['aaaa', 'bbbbb', 'cccc', 'ddddddd'],
          isPreview: false,
          onCancelTimer: () {},
          onCallBack: (result, answer) {},
          guideController: null,
        );
        break;
      case 3: //单词组句游戏
        return createChooseWordsOldWidget(
          type: 3,
          gameModel: GameModel.fromMap(json.decode('{"id":3176,"num":"02981","typeNum":20,"typeName":"连线题","templateNum":22,"stems":"aaaa_bbbb_cccc_dddd_eeee_ffff","content":"","resultContent":null,"optionType":"1#2","options":"aaaa#bbbb#cccc#dddd#eeee#ffff#ggggggggg#h#iii#jjjj","result":"aaaa#bbbb#cccc#dddd#eeee#ffff#ggggggggg#h#iii#jjjj#kkkkkk","applyLevel":10,"courseType":20,"isDeleted":0,"isReadFollowed":0,"gmtCreate":"2020-08-19 15:10:57","gmtModified":null,"creator":"15172353121","remark":"秋季牛津G1L4P7"}')),
          callback: (GameResultInfo info) {},
          isPreview: false,
          guideController: null,
          onCancelTimer: () {},
        );
      case 4: // 电视字母填空
        return GameWidget(
          gameModel: GameModel.fromMap(json.decode('{"id":3176,"num":"02981","typeNum":20,"typeName":"连线题","templateNum":22,"stems":"null_https://img.blingabc.com/c27e4419287f4c5c9c5b289e88c8ea27.png_https://img.blingabc.com/89cd21a6b30145d5bf1fdac636d9d89b.m4a","content":"a_b_d","resultContent":null,"optionType":"1#2","options":"a#b","result":"a#b","applyLevel":10,"courseType":20,"isDeleted":0,"isReadFollowed":0,"gmtCreate":"2020-08-19 15:10:57","gmtModified":null,"creator":"15172353121","remark":"秋季牛津G1L4P7"}')),
          isPreview: false,
          countDownStream: null,
          onCancelTimer: () {},
          onCallBack: (result) {},
          guideController: null,
          state: CharFillBlankTvState(),
        );
      case 5: //饮料
        return ChooseWordsTemplate(
          content: 'Find out where _ to vote _ in person _ on Election Day _ or earlier, and _ what form of ID to bring',
          optionStrs: ['aaaa', 'bbbbb', 'cccc', 'ddddddd', 'eeeeeee'],
          resultStrs: ['aaaa', 'bbbbb', 'cccc', 'ddddddd'],
          pictureUrl: 'https://img.blingabc.com/c27e4419287f4c5c9c5b289e88c8ea27.png',
          isPreview: false,
          onCancelTimer: () {},
          onCallBack: (result, answer) {},
          guideController: null,
        );
    }
  }
}
