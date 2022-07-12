import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';

import '../../modules/ext.dart';
import '../../utils/sd_utils.dart';
import '../../widgets/details_list_top.dart';
import '../../widgets/listview_item_song.dart';
import '../album_details/widget/details_header.dart';
import '../home/widget/dialog_bottom_btn.dart';
import '../home/widget/dialog_more.dart';
import 'logic.dart';

class SingerDetailsPage extends StatelessWidget {
  final logic = Get.put(SingerDetailsLogic());
  final state = Get.find<SingerDetailsLogic>().state;
  final Album album = Get.arguments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F8FF),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        DetailsHeader(
          title: "Liella!",
        ),
        Expanded(
          child: GetBuilder<SingerDetailsLogic>(builder: (logic) {
            return ListView(
              padding: const EdgeInsets.all(0),
              children: getListItems(),
            );
          }),
        ),
      ],
    );
  }

  List<Widget> getListItems() {
    List<Widget> list = [];
    list.add(_buildCover());
    list.add(SizedBox(
      height: 10.h,
    ));
    list.add(DetailsListTop(
        selectAll: logic.state.selectAll,
        isSelect: logic.state.isSelect,
        itemsLength: album.music.length,
        checkedItemLength: logic.getCheckedSong(),
        onPlayTap: () {},
        onScreenTap: () {
          if (HomeController.to.state.isSelect.value) {
            SmartDialog.dismiss();
          } else {
            showSelectDialog();
          }
          HomeController.to.openSelect();
        },
        onSelectAllTap: (checked) {
          logic.selectAll(checked);
        },
        onCancelTap: () {
          logic.openSelect();
          SmartDialog.dismiss();
        }));
    list.add(SizedBox(
      height: 10.h,
    ));
    for (var index = 0; index < album.music.length; index++) {
      list.add(Padding(
        padding: EdgeInsets.only(left: 16.h, bottom: 20.h),
        child: ListViewItemSong(
          index: index,
          music: album.music[index],
          checked: logic.isItemChecked(album.music[index]),
          onItemTap: (index, checked) {
            logic.selectItem(index, checked);
          },
          onPlayNextTap: (music) => PlayerLogic.to.addNextMusic(music),
          onMoreTap: (music) {
            SmartDialog.compatible.show(
                widget: DialogMore(music: music),
                alignmentTemp: Alignment.bottomCenter);
          },
          onPlayNowTap: () {
            PlayerLogic.to.playMusic(album.music, index: index);
          },
        ),
      ));
    }
    return list;
  }

  showSelectDialog() {
    List<BtnItem> list = [];
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList2, title: "加入播放列表", onTap: () {}));
    list.add(BtnItem(
        imgPath: Assets.dialogIcAddPlayList, title: "添加到歌单", onTap: () {}));
    SmartDialog.compatible.show(
        widget: DialogBottomBtn(
          list: list,
        ),
        isPenetrateTemp: true,
        clickBgDismissTemp: false,
        maskColorTemp: Colors.transparent,
        alignmentTemp: Alignment.bottomCenter);
  }

  Widget _buildCover() {
    return Container(
      padding: EdgeInsets.only(top: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          showImg(SDUtils.getImgPath("ic_head.jpg"), 240, 240, radius: 120),
        ],
      ),
    );
  }
}
