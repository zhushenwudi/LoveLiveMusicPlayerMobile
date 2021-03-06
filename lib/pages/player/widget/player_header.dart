import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/utils/text_style_manager.dart';

import '../../../modules/ext.dart';

class PlayerHeader extends StatelessWidget {
  final GestureTapCallback onTap;

  PlayerHeader({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        height: 44.h,
        width: double.infinity,
        child: Row(
          children: <Widget>[
            /// 折叠向下箭头
            materialButton(Icons.keyboard_arrow_down, onTap,
                width: 32,
                height: 32,
                iconSize: 20,
                radius: 6,
                bgColor: Get.isDarkMode ? Colors.white : Colors.black),

            /// 曲名 + 歌手
            Expanded(
              child: Obx(() {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      PlayerLogic.to.playingMusic.value.musicName ?? "暂无歌曲",
                      overflow: TextOverflow.ellipsis,
                      style: Get.isDarkMode
                          ? TextStyleMs.whiteBold_15
                          : TextStyleMs.blackBold_15,
                      maxLines: 1,
                    ),
                    Text(
                      PlayerLogic.to.playingMusic.value.artist ?? "",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: const Color(0xFF999999), fontSize: 12.sp),
                      maxLines: 1,
                    )
                  ],
                );
              }),
            ),

            /// 更多功能
            materialButton(Icons.more_horiz, () => {},
                width: 32, height: 32, iconSize: 18, radius: 6),
          ],
        ),
      ),
    );
  }
}
