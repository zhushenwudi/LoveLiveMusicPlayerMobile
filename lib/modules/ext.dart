import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lovelivemusicplayer/global/const.dart';

import '../utils/sd_utils.dart';

/// 显示图片
///
/// [path] 图片路径
/// [width] 显示的宽度
/// [height] 显示的高度
/// [radius] 圆角度数
/// [hasShadow] 是否有阴影效果
Widget showImg(String? path, double? width, double? height,
    {double radius = 20,
    bool hasShadow = true,
    String defPhoto = Const.logo,
    BoxFit fit = BoxFit.cover}) {
  ImageProvider<Object> noShadowImage;
  ImageProvider<Object> shadowImage;
  if (hasShadow) {
    if (path == null || path.isEmpty) {
      shadowImage = AssetImage(defPhoto);
    } else if (path.startsWith("assets")) {
      shadowImage = AssetImage(path);
    } else if (path.startsWith("http")) {
      shadowImage = NetworkImage(path);
    } else {
      final file = File(path);
      if (file.existsSync()) {
        shadowImage = FileImage(File(path));
      } else {
        shadowImage = AssetImage(defPhoto);
      }
    }

    return Container(
      width: width?.h,
      height: height?.h,
      decoration: BoxDecoration(
        image: DecorationImage(
            image: ResizeImage(shadowImage,
                width: (width?.h.toInt() ?? 1) * 2,
                height: (height?.h.toInt() ?? 1) * 2),
            fit: BoxFit.fill),
        borderRadius: BorderRadius.circular(radius.h),
        boxShadow: [
          BoxShadow(
              color: Get.isDarkMode
                  ? const Color(0xFF05080C)
                  : const Color(0xFFD3E0EC),
              blurRadius: 4,
              offset: Offset(4.h, 8.h)),
        ],
      ),
    );
  } else {
    if (path == null || path.isEmpty) {
      noShadowImage = Image.asset(
        defPhoto,
        width: width?.h,
        height: height?.h,
        fit: fit,
      ).image;
    } else if (path.startsWith("assets")) {
      noShadowImage = Image.asset(
        path,
        width: width?.h,
        height: height?.h,
        fit: fit,
      ).image;
    } else if (path.startsWith("http")) {
      noShadowImage = Image.network(
        path,
        width: width?.h,
        height: height?.h,
        fit: fit,
      ).image;
    } else {
      final file = File(path);
      if (file.existsSync()) {
        noShadowImage = Image.file(
          File(path),
          width: width?.h,
          height: height?.h,
          fit: fit,
        ).image;
      } else {
        noShadowImage = Image.asset(
          defPhoto,
          width: width?.h,
          height: height?.h,
          fit: fit,
        ).image;
      }
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(radius.h),
        child: Image(
          image: ResizeImage(noShadowImage,
              width: (width?.h.toInt() ?? 1) * 2,
              height: (height?.h.toInt() ?? 1) * 2),
          width: width?.h,
          height: height?.h,
        ));
  }
}

/// 具有material风格的按钮
/// https://material.io/resources/icons
///
/// [icon] 支持Icons包下的按钮、本地assets资源
/// [onTap] 触摸事件回调
/// [width] 控件宽度
/// [height] 控件高度
/// [radius] 控件圆角度数
/// [innerColor] 内阴影颜色
/// [outerColor] 外阴影颜色
/// [iconSize] 内部图标的大小
/// [iconColor] 内部图标的颜色
/// [offset] 内部图标的偏移量
Widget materialButton(dynamic icon, GestureTapCallback? onTap,
    {double width = 80,
    double height = 80,
    double radius = 20,
    Color? innerColor,
    Color? outerColor,
    double iconSize = 30,
    Color bgColor = Colors.black,
    Color? iconColor,
    EdgeInsets offset = const EdgeInsets.all(0)}) {
  Widget child;
  if (icon is IconData) {
    child = Icon(icon,
        color: iconColor ??
            (Get.isDarkMode ? Colors.white : const Color(0xFF333333)),
        size: iconSize.h);
  } else if (icon is String &&
      icon.startsWith("assets") &&
      icon.endsWith(".svg")) {
    child = SvgPicture.asset(icon,
        color: iconColor ??
            (Get.isDarkMode ? Colors.white : const Color(0xFF333333)),
        width: iconSize.h,
        height: iconSize.h);
  } else {
    child = Container();
  }
  return Container(
    width: width.h,
    height: height.h,
    decoration: BoxDecoration(
      color: innerColor,
      borderRadius: BorderRadius.circular(radius.h),
      boxShadow: [
        BoxShadow(
            color: Get.isDarkMode ? const Color(0x1005080C) : Colors.white,
            offset: const Offset(-3, -3),
            blurStyle: BlurStyle.inner,
            blurRadius: 6),
        BoxShadow(
            color: outerColor ??
                (Get.isDarkMode
                    ? const Color(0xFF05080C)
                    : const Color(0xFFD3E0EC)),
            offset: const Offset(5, 3),
            blurRadius: 6),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius.h),
      child: Material(
        child: InkWell(
          splashColor: const Color(0xFFD3E0EC),
          highlightColor: const Color(0xFFD3E0EC),
          onTap: onTap,
          child: Stack(
            children: [
              Center(child: child),
              Container(
                width: width.h,
                height: height.h,
                alignment: const Alignment(0, 0),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

/// 团组按钮
///
/// [path] 图片文件路径
/// [innerWidth] 图片宽度
/// [innerHeight] 图片高度
Widget showGroupButton(String path,
    {GestureTapCallback? onTap,
    double innerWidth = 130,
    double innerHeight = 60}) {
  return Container(
    width: 118.h,
    height: 60.h,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8.h),
      boxShadow: [
        BoxShadow(
            color: Get.isDarkMode ? const Color(0x1005080C) : Colors.white,
            offset: const Offset(-3, -3),
            blurStyle: BlurStyle.inner,
            blurRadius: 6),
        BoxShadow(
            color: Get.isDarkMode
                ? const Color(0xFF05080C)
                : const Color(0xFFD3E0EC),
            offset: const Offset(5, 3),
            blurRadius: 6),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8.h),
      child: Material(
        child: InkWell(
          splashColor: const Color(0xFFD3E0EC),
          highlightColor: const Color(0xFFD3E0EC),
          onTap: onTap,
          child: Stack(
            children: [
              Center(
                child: Image.asset(path,
                    width: innerWidth.h, height: innerHeight.h),
              ),
              Container(
                width: 130.h,
                height: 60.h,
                alignment: const Alignment(0, 0),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

Widget logoIcon(String path,
    {double width = 36,
    double height = 36,
    double radius = 18,
    EdgeInsetsGeometry? offset,
    GestureTapCallback? onTap}) {
  final margin = offset ?? const EdgeInsets.only(right: 0);
  final image = path.startsWith("assets") ? path : SDUtils.getImgPath(path);
  return Center(
      child: Container(
          margin: margin,
          width: width.h,
          height: height.h,
          padding: EdgeInsets.all(3.h),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius.h),
              boxShadow: [
                BoxShadow(
                    color: Get.isDarkMode
                        ? const Color(0xFF05080C)
                        : const Color(0xFFD3E0EC),
                    blurRadius: 10,
                    offset: Offset(5.h, 3.h)),
              ]),
          child: InkWell(
              onTap: onTap,
              child: showImg(image, width, height,
                  radius: radius.h, hasShadow: false))));
}

Widget touchIcon(IconData icon, GestureTapCallback onTap,
    {Color color = const Color(0xff333333), double? size}) {
  return InkWell(
    onTap: onTap,
    child: Icon(icon, color: color, size: size),
  );
}

Widget touchIconByAsset(
    {required String path,
    GestureTapCallback? onTap,
    Color color = const Color(0xff999999),
    double width = 20,
    double height = 20}) {
  return InkWell(
    onTap: onTap,
    child:
        SvgPicture.asset(path, width: width.h, height: height.h, color: color),
  );
}
