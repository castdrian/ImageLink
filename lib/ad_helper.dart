import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {

  static String get homeBanner {
    if (Platform.isAndroid) {
      if (kReleaseMode) {
        return 'ca-app-pub-9301280331240379/8128577667';
      } else {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get tabOneBanner {
    if (Platform.isAndroid) {
      if (kReleaseMode) {
        return 'ca-app-pub-9301280331240379/1237249140';
      } else {
         return 'ca-app-pub-3940256099942544/6300978111';
      }
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get tabTwoBanner {
    if (Platform.isAndroid) {
      if (kReleaseMode) {
      } else {
         return 'ca-app-pub-9301280331240379/2254817347';
      }
      return 'ca-app-pub-3940256099942544/6300978111';
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get historyBanner {
    if (Platform.isAndroid) {
      if (kReleaseMode) {
        return 'ca-app-pub-9301280331240379/2358759120';
      } else {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get infoBanner {
    if (Platform.isAndroid) {
      if (kReleaseMode) {
        return 'ca-app-pub-9301280331240379/7227942424';
      } else {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }
}