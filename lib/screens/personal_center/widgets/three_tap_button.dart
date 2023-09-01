import 'package:flutter/material.dart';

class ThreeTapButton extends StatelessWidget {
  final Function callBack;

  ThreeTapButton({@required this.callBack});

  final List<Duration> _durations = [];

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: Container(
        width: 100,
        height: 100,
        color: Colors.transparent,
      ),
      onPointerDown: (event) {
        if (_durations.length <= 1) {
          if (_durations.length == 0) {
            _durations.add(event.timeStamp);
          } else {
            Duration firstDuration = _durations[0];
            Duration subDuration = event.timeStamp - firstDuration;
            print(subDuration.inSeconds);
            if (subDuration.inSeconds < 1) {
              _durations.add(event.timeStamp);
            } else {
              _durations.clear();
              _durations.add(event.timeStamp);
            }
          }
        } else {
          Duration firstDuration = _durations[0];
          Duration subDuration = event.timeStamp - firstDuration;
          if (subDuration.inSeconds < 1) {
            _durations.clear();
            callBack();
          } else {
            _durations.clear();
            _durations.add(event.timeStamp);
          }
        }
      },
    );
  }
}
