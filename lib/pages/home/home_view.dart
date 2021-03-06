import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/generated/assets.dart';
import 'package:lovelivemusicplayer/global/const.dart';
import 'package:lovelivemusicplayer/global/global_global.dart';
import 'package:lovelivemusicplayer/global/global_player.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/modules/pageview/view.dart';
import 'package:lovelivemusicplayer/modules/tabbar/tabbar.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/pages/home/widget/dialog_bottom_btn.dart';
import 'package:lovelivemusicplayer/utils/android_back_desktop.dart';
import 'package:lovelivemusicplayer/widgets/bottom_bar2.dart';
import 'package:we_slide/we_slide.dart';

import '../../modules/drawer/drawer.dart';
import '../../widgets/bottom_bar1.dart';
import '../player/miniplayer.dart';
import '../player/player.dart';
import 'widget/song_library_top.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final logic = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    logic.tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastPressTime;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return WillPopScope(
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            endDrawer: SizedBox(
              width: 300.w,
              child: const DrawerPage(),
            ),
            body: _weSlider(_scaffoldKey)),
        onWillPop: () async {
          if (lastPressTime == null ||
              DateTime.now().difference(lastPressTime!) >
                  const Duration(seconds: 1)) {
            //??????????????????1??? ???????????????
            lastPressTime = DateTime.now();
            SmartDialog.compatible.showToast("????????????????????????");
            return false;
          }
          AndroidBackDesktop.backToDesktop();
          return false;
        });
  }

  Widget _weSlider(GlobalKey<ScaffoldState> scaffoldKey) {
    final WeSlideController _controller = WeSlideController();
    const double _panelMinSize = 150;
    final double _panelMaxSize = ScreenUtil().screenHeight;

    return WeSlide(
      controller: _controller,
      panelMinSize: _panelMinSize.h,
      panelMaxSize: _panelMaxSize,
      overlayOpacity: 0.9,
      backgroundColor: Theme.of(context).primaryColor,
      overlay: true,
      isDismissible: true,
      body: _getTabBarView(() => scaffoldKey.currentState?.openEndDrawer()),
      blurColor: Theme.of(context).primaryColor,
      overlayColor: Theme.of(context).primaryColor,
      panelBorderRadiusBegin: 10,
      panelBorderRadiusEnd: 10,
      panelHeader: MiniPlayer(onTap: _controller.show),
      panel: Player(onTap: _controller.hide),
      footer: _buildTabBarView(),
      footerHeight: 84.h,
      blur: true,
      parallax: true,
      isUpSlide: false,
      transformScale: true,
      blurSigma: 5.0,
      fadeSequence: [
        TweenSequenceItem<double>(weight: 1.0, tween: Tween(begin: 1, end: 0)),
        TweenSequenceItem<double>(weight: 8.0, tween: Tween(begin: 0, end: 0)),
      ],
    );
  }

  Widget _getTabBar() {
    return Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: Obx(() {
          final isSelect = HomeController.to.state.isSelect.value;
          return isSelect
              ? const IgnorePointer(
                  child: TabBarComponent(),
                )
              : const TabBarComponent();
        }));
  }

  ///????????????
  Widget _getTopHead(GestureTapCallback? onTap) {
    return logoIcon(Const.logo,
        offset: EdgeInsets.only(right: 16.w), onTap: onTap);
  }

  Widget _getTabBarView(GestureTapCallback? onTap) {
    return Column(
      children: [
        AppBar(
          toolbarHeight: 54.w,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          backgroundColor: Get.theme.primaryColor,
          title: _getTabBar(),
          actions: [_getTopHead(onTap)],
        ),
        _buildListTop(),
        const Expanded(child: PageViewComponent())
      ],
    );
  }

  ///?????????????????????
  Widget _buildListTop() {
    return Song_libraryTop(
      onPlayTap: () {
        PlayerLogic.to.playMusic(GlobalLogic.to
            .filterMusicListByAlbums(logic.state.currentIndex.value));
      },
      onScreenTap: () {
        logic.openSelect();
        showSelectDialog();
      },
      onSelectAllTap: (checked) {
        logic.selectAll(checked);
      },
      onCancelTap: () {
        logic.openSelect();
        SmartDialog.dismiss();
      },
    );
  }

  showSelectDialog() {
    List<BtnItem> list = [];
    if (logic.state.currentIndex.value == 1) {
      list.add(BtnItem(
          imgPath: Assets.dialogIcAddPlayList2, title: "????????????", onTap: () {}));
      list.add(BtnItem(
          imgPath: Assets.dialogIcAddSongSheet, title: "???????????????", onTap: () {}));
      list.add(
          BtnItem(imgPath: Assets.dialogIcDelete, title: "????????????", onTap: () {}));
    } else if (logic.state.currentIndex.value == 1) {
      list.add(BtnItem(
          imgPath: Assets.dialogIcAddPlayList2, title: "????????????", onTap: () {}));
      list.add(BtnItem(
          imgPath: Assets.dialogIcAddPlayList, title: "???????????????", onTap: () {}));
    } else {
      list.add(BtnItem(
          imgPath: Assets.dialogIcAddPlayList2, title: "??????????????????", onTap: () {}));
      list.add(BtnItem(
          imgPath: Assets.dialogIcAddPlayList, title: "???????????????", onTap: () {}));
    }
    SmartDialog.compatible.show(
        widget: DialogBottomBtn(
          list: list,
        ),
        isPenetrateTemp: true,
        clickBgDismissTemp: false,
        maskColorTemp: Colors.transparent,
        alignmentTemp: Alignment.bottomCenter);
  }

  Widget _buildTabBarView() {
    return TabBarView(
      children: const [BottomBar(), BottomBar2()],
      controller: logic.tabController,
      physics: const NeverScrollableScrollPhysics(),
    );
  }
}
