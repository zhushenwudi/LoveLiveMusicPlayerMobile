import 'package:get/get.dart';
import 'package:lovelivemusicplayer/models/Album.dart';
import 'package:lovelivemusicplayer/models/Artist.dart';
import '../models/Music.dart';

class GlobalLogic extends SuperController
    with GetSingleTickerProviderStateMixin {
  /// all、μ's、Aqours、Nijigasaki、Liella!、Combine
  final currentGroup = "all".obs;
  final databaseInitOver = false.obs;

  final musicList = <Music>[].obs;
  final albumList = <Album>[].obs;
  final artistList = <Artist>[].obs;
  final loveList = <Music>[].obs;
  final menuList = <Music>[].obs;
  final recentlyList = <Music>[].obs;

  /// 是否正在处理播放逻辑
  var isHandlePlay = false;

  static GlobalLogic get to => Get.find();

  getListSize(int index, bool isDbInit) {
    if (!isDbInit) {
      return 0;
    }
    switch (index) {
      case 0:
        return musicList.length;
      case 1:
        return albumList.length;
      case 2:
        return artistList.length;
      case 3:
        return loveList.length;
      default:
        return 0;
    }
  }

  List<Music> filterMusicListByAlbums(menuIndex) {
    switch (menuIndex) {
      case 0:
        return musicList;
      case 1:
        List<Music> _musicList = [];
        for (var album in albumList) {
          for (var music in musicList) {
            if (music.albumId == album.albumId) {
              _musicList.add(music);
            }
          }
        }
        return _musicList;
      case 3:
        return loveList;
      case 5:
        return [];
      default:
        return [];
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  void onResumed() {}
}
