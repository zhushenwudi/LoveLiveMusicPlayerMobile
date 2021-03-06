import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lovelivemusicplayer/modules/ext.dart';
import 'package:lovelivemusicplayer/pages/home/home_controller.dart';
import 'package:lovelivemusicplayer/utils/sd_utils.dart';

///歌单
class ListViewItemSongSheet extends StatefulWidget {
  Function(bool) onItemTap;

  ///条目数据
  int index;

  ///全选
  bool isSelect;

  ListViewItemSongSheet(
      {Key? key,
      required this.onItemTap,
      this.isSelect = false,
      required this.index})
      : super(key: key);

  @override
  State<ListViewItemSongSheet> createState() => _ListViewItemSongStateSheet();
}

class _ListViewItemSongStateSheet extends State<ListViewItemSongSheet>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InkWell(
      onTap: () {
        HomeController.to.selectItem(
            widget.index, !HomeController.to.isItemChecked(widget.index));
        widget.onItemTap(HomeController.to.isItemChecked(widget.index));
      },
      child: Container(
        color: const Color(0xFFF2F8FF),
        child: Row(
          children: [
            ///缩列图
            _buildIcon(),
            SizedBox(
              width: 10.w,
            ),

            ///中间标题部分
            _buildContent(),
          ],
        ),
      ),
    );
  }

  ///缩列图
  Widget _buildIcon() {
    return showImg(SDUtils.getImgPath("ic_head.jpg"), 48, 48,
        hasShadow: false, radius: 8);
  }

  ///中间标题部分
  Widget _buildContent() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "歌单${widget.index}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: const Color(0xff333333),
                fontSize: 15.sp,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 4.w,
          ),
          Text(
            "10首",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xff999999),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(
            width: 16.w,
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
