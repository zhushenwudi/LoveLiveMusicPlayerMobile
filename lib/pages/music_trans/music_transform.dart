import 'dart:convert' as convert;
import 'dart:io';

import 'package:concurrent_queue/concurrent_queue.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_db.dart';
import 'package:lovelivemusicplayer/models/FtpCmd.dart';
import 'package:lovelivemusicplayer/models/FtpMusic.dart';
import 'package:lovelivemusicplayer/network/http_request.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import 'package:web_socket_channel/io.dart';

class MusicTransform extends StatefulWidget {
  final IOWebSocketChannel channel =
      IOWebSocketChannel.connect(Uri.parse("ws://${Get.arguments}:4388"));
  final queue = ConcurrentQueue(concurrency: 1);

  MusicTransform({Key? key}) : super(key: key);

  @override
  State<MusicTransform> createState() => _MusicTransformState();
}

class _MusicTransformState extends State<MusicTransform> {
  bool isPermission = false;
  String message = "";
  String song = "";
  String progress = "";
  String currentMusic = "";
  final musicList = <DownloadMusic>[];
  String port = "10000";
  int currentProgress = 0;
  bool isRunning = false;
  CancelToken? cancelToken;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    widget.channel.stream.listen((msg) {
      final ftpCmd = ftpCmdFromJson(msg as String);
      switch (ftpCmd.cmd) {
        case "noTrans":
          Future.forEach<DownloadMusic>(downloadMusicFromJson(ftpCmd.body), (music) async {
            if (File(SDUtils.path + music.musicPath).existsSync()) {
              song = music.musicName;
              setState(() {});
              await DBLogic.to.insertMusicIntoAlbum(music);
            }
          }).then((_) {
            DBLogic.to.findAllListByGroup("all").then((value) => Get.back());
          });
          break;
        case "port":
          port = ftpCmd.body;
          break;
        case "prepare":
          if (ftpCmd.body.contains(" === ")) {
            final array = ftpCmd.body.split(" === ");
            final json = array[0];
            final needTransAll = array[1] == "true" ? true : false;
            final downloadList = downloadMusicFromJson(json);
            final musicIdList = <String>[];

            for (var music in downloadList) {
              if (needTransAll) {
                musicIdList.add(music.musicUId);
              } else if (!SDUtils.checkFileExist(
                  SDUtils.path + music.musicPath)) {
                musicIdList.add(music.musicUId);
              }
            }
            final message = {
              "cmd": "musicList",
              "body": convert.jsonEncode(musicIdList)
            };
            widget.channel.sink.add(convert.jsonEncode(message));
          }
          break;
        case "ready":
          final downloadList = downloadMusicFromJson(ftpCmd.body);
          musicList.addAll(downloadList);
          isRunning = true;
          break;
        case "download":
          for (var music in musicList) {
            if (ftpCmd.body.contains(" === ")) {
              final array = ftpCmd.body.split(" === ");
              final musicUId = array[0];
              final isLast = array[1] == "true" ? true : false;
              if (music.musicUId == musicUId) {
                genFileList(music).forEach((url, dest) {
                  pushQueue(
                      music, url, dest, url.contains("jpg") ? false : isLast);
                });
                musicList.remove(music);
              }
            } else {
              final message = ftpCmdToJson(
                  FtpCmd(cmd: "download fail", body: music.musicUId));
              widget.channel.sink.add(message);
            }
          }
          break;
        case "stop":
          isRunning = false;
          widget.queue.clear();
          musicList.clear();
          cancelToken?.cancel();
          SmartDialog.dismiss();
          DBLogic.to.findAllListByGroup("all").then((value) => Get.back());
          break;
        case "back":
          Get.back();
          break;
      }
      message = msg;
      setState(() {});
    });

    final system = {
      "cmd": "system",
      "body": Platform.isAndroid ? "android" : "ios"
    };
    widget.channel.sink.add(convert.jsonEncode(system));
  }

  Map<String, String> genFileList(DownloadMusic music) {
    final musicUrl = "http://${Get.arguments}:$port/${music.musicPath}";
    final picUrl = "http://${Get.arguments}:$port/${music.coverPath}";
    final musicDest = SDUtils.path + music.musicPath;
    final picDest = SDUtils.path + music.coverPath;
    final tempList = musicDest.split(Platform.pathSeparator);
    var destDir = "";
    for (var i = 0; i < tempList.length - 1; i++) {
      destDir += tempList[i] + Platform.pathSeparator;
    }
    SDUtils.makeDir(destDir);
    if (!isRunning) {
      return {};
    }
    return {picUrl: picDest, musicUrl: musicDest};
  }

  pushQueue(DownloadMusic music, String url, String dest, bool isLast) async {
    final isMusic = url.endsWith("flac") || url.endsWith("wav");
    await widget.queue.add(() async {
      try {
        cancelToken = CancelToken();
        await Network.download(url, dest, (received, total) {
          if (total != -1 && isMusic) {
            final _progress = (received / total * 100).toStringAsFixed(0);
            progress = _progress + "%";
            song = music.musicName;
            setState(() {});
            final p = double.parse(_progress).truncate();
            if (currentProgress != p) {
              currentProgress = p;
              if (_progress == "100") {
                final message = ftpCmdToJson(
                    FtpCmd(cmd: "download success", body: music.musicUId));
                widget.channel.sink.add(message);
              } else {
                if (isRunning) {
                  final message = ftpCmdToJson(
                      FtpCmd(cmd: "downloading", body: music.musicUId));
                  widget.channel.sink.add(message);
                }
              }
            }
          }
        }, cancelToken);
        if (isMusic) {
          DBLogic.to.insertMusicIntoAlbum(music);
        }
      } catch (e) {
        final message =
            ftpCmdToJson(FtpCmd(cmd: "download fail", body: music.musicUId));
        widget.channel.sink.add(message);
      }
    });
    if (isLast) {
      await widget.queue.onIdle();
      final message = ftpCmdToJson(FtpCmd(cmd: "finish", body: ""));
      widget.channel.sink.add(message);
      await DBLogic.to.findAllListByGroup("all");
      Get.back();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.channel.sink.close();
    Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: checkPermission(),
        onWillPop: () async {
          SmartDialog.compatible.show(
              widget: Container(
            width: 300.w,
            height: 150.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 250.w,
                margin: EdgeInsets.only(bottom: 30.h),
                child: Text("???????????????????????????????????????????????????", style: TextStyleMs.black_14),
              ),
              ElevatedButton(
                onPressed: () async {
                  final message = ftpCmdToJson(FtpCmd(cmd: "stop", body: ""));
                  widget.channel.sink.add(message);
                  SmartDialog.dismiss();
                  await DBLogic.to.findAllListByGroup("all");
                  Get.back();
                },
                child: const Text('??????'),
              )
            ]),
          ));
          return false;
        });
  }

  checkPermission() {
    if (isPermission) {
      return Scaffold(
        appBar: AppBar(
          title: Text("????????????", style: TextStyleMs.white_14),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text("message: $message"),
              Text("song: $song",
                  style: Get.isDarkMode
                      ? TextStyle(fontSize: 17.sp, color: Colors.amber)
                      : TextStyleMs.black_14),
              Text("progress: $progress",
                  style: Get.isDarkMode
                      ? TextStyle(fontSize: 17.sp, color: Colors.amber)
                      : TextStyleMs.black_14),
            ],
          ),
        ),
      );
    } else {
      requestPermission();
      return Container();
    }
  }

  requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      isPermission = true;
      setState(() {
        checkPermission();
      });
    } else {
      isPermission = false;
    }
  }
}
