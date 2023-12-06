import 'dart:convert';
import 'dart:developer';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mplos_chat/features/chat/presentation/providers/chat_state_provider.dart';
import 'package:mplos_chat/shared/theme/app_colors.dart';

// ignore: must_be_immutable
class AudioSlider extends ConsumerStatefulWidget {
  String audioURL;
  Duration elapsed, total;
  bool isPlaying;
  AudioSlider(this.audioURL, this.elapsed, this.total, this.isPlaying,
      {Key? key})
      : super(key: key);

  @override
  ConsumerState<AudioSlider> createState() => AudioSliderState();
}

class AudioSliderState extends ConsumerState<AudioSlider> {
  String get url => widget.audioURL;
  Duration get elapsed => widget.elapsed;
  Duration get total => widget.total;
  bool get isPlaying => widget.isPlaying;

  @override
  void initState() {
    super.initState();

    DesktopMultiWindow.invokeMethod(0, 'child_event',
        jsonEncode({'type': 'audio_slider_duration', 'url': url}));

    // audioPlayer.onPlayerComplete.listen((_) {
    //   setState(() {
    //     elapsed = Duration.zero;
    //     isPlaying = false;
    //   });
    // });

    // DesktopMultiWindow.setMethodHandler(_handleMethodCallback);
  }

  @override
  void dispose() {
    // audioPlayer.dispose();
    // DesktopMultiWindow.setMethodHandler(null);

    super.dispose();
  }

  // Future<dynamic> _handleMethodCallback(
  //     MethodCall call, int fromWindowId) async {
  //   if (call.method != 'root_event') return;

  //   log('audio_slider');

  //   final jsonData = jsonDecode(call.arguments.toString());
  //   switch (jsonData['type']) {
  //     // case 'audio_slider_resume':
  //     //   setState(() {
  //     //     isPlaying = true;
  //     //   });
  //     //   break;
  //     // case 'audio_slider_pause':
  //     //   setState(() {
  //     //     isPlaying = false;
  //     //   });
  //     //   break;
  //     case 'audio_slider_complete':
  //       setState(() {
  //         isPlaying = false;
  //         elapsed = Duration.zero;
  //       });
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double max = total.inMinutes * 60.0 + total.inSeconds;
    double value = elapsed.inMinutes * 60.0 + elapsed.inSeconds;
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: togglePlayer,
              splashColor: AppColors.extraLightGrey,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints.tight(Size(24, 24)),
              splashRadius: 4,
              icon: Icon(!isPlaying ? Icons.play_arrow : Icons.pause,
                  color: AppColors.primary)),
          Slider(
              min: 0,
              max: max,
              value: value,
              onChanged: (double value) {
                setState(() {
                  ref
                      .read(chatStateNotifierProvider.notifier)
                      .updateAudioSlider(
                          url,
                          Duration(
                              minutes: value ~/ 60,
                              seconds: value.toInt() % 60),
                          'elapsed',
                          isPlaying);
                });
              }),
          Text('${getTimeString(elapsed)}/${getTimeString(total)}')
        ]);
  }

  togglePlayer() {
    // isPlaying = !isPlaying;
    ref
        .read(chatStateNotifierProvider.notifier)
        .updateAudioSlider(url, total, 'total', !isPlaying);

    if (!isPlaying) {
      // DesktopMultiWindow.invokeMethod(
      //     0,
      //     'child_event',
      //     jsonEncode({
      //       'type': 'audio_slider_seek',
      //       'elapsed': elapsed.inSeconds,
      //       'url': url
      //     }));
      // audioPlayer.seek(elapsed);

      DesktopMultiWindow.invokeMethod(
          0,
          'child_event',
          jsonEncode({
            'type': 'audio_slider_resume',
            'url': url,
            'elapsed': dur2str(elapsed)
          }));
      // audioPlayer.resume();
    } else {
      DesktopMultiWindow.invokeMethod(0, 'child_event',
          jsonEncode({'type': 'audio_slider_pause', 'url': url}));
      // audioPlayer.pause();
    }

    setState(() {});
  }

  getTimeString(Duration dur) {
    return '${dur.inMinutes.toString().padLeft(2, '0')}:${(dur.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  String dur2str(Duration duration) {
    return duration
        .toString()
        .split('.')
        .first
        .split(':')
        .map((el) => el.padLeft(2, '0'))
        .join(':');
  }
}
