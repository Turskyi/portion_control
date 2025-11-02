enum HomeWidgetKey {
  weight,
  consumed,
  portionControl,
  textLastUpdated,
  textRecommendation,
  locale,
  image;

  String get stringValue {
    switch (this) {
      case HomeWidgetKey.weight:
        return 'text_weight';
      case HomeWidgetKey.consumed:
        return 'text_consumed';
      case HomeWidgetKey.portionControl:
        return 'text_portion_control';
      case HomeWidgetKey.textLastUpdated:
        return 'text_last_updated';
      case HomeWidgetKey.textRecommendation:
        return 'text_recommendation';
      case HomeWidgetKey.locale:
        return 'text_locale';
      case HomeWidgetKey.image:
        return 'image';
    }
  }
}
