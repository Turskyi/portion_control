import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:home_widget/home_widget.dart';

abstract class HomeWidgetService {
  const HomeWidgetService();

  Future<void> setAppGroupId(String appGroupId);

  Future<bool?> saveWidgetData<T>(String id, T? data);

  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  });

  Future<String> renderFlutterWidget(
    Widget widget, {
    required String key,
    Size logicalSize = const Size(100, 400),
    double? pixelRatio,
  });

  Future<void> requestPinWidget({
    String? name,
    String? androidName,
    String? qualifiedAndroidName,
  });
}

class HomeWidgetServiceImpl implements HomeWidgetService {
  const HomeWidgetServiceImpl();

  @override
  Future<void> setAppGroupId(String appGroupId) {
    return HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  Future<bool?> saveWidgetData<T>(String id, T? data) {
    return HomeWidget.saveWidgetData<T>(id, data);
  }

  @override
  Future<bool?> updateWidget({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) {
    return HomeWidget.updateWidget(
      name: name,
      qualifiedAndroidName: qualifiedAndroidName,
      iOSName: iOSName,
      androidName: androidName,
    );
  }

  @override
  Future<String> renderFlutterWidget(
    Widget widget, {
    required String key,
    Size logicalSize = const Size(100, 400),
    double? pixelRatio,
  }) {
    return HomeWidget.renderFlutterWidget(
      widget,
      key: key,
      logicalSize: logicalSize,
      pixelRatio: pixelRatio,
    );
  }

  @override
  Future<void> requestPinWidget({
    String? name,
    String? androidName,
    String? qualifiedAndroidName,
  }) {
    return HomeWidget.requestPinWidget(
      name: name,
      androidName: androidName,
      qualifiedAndroidName: qualifiedAndroidName,
    );
  }
}
