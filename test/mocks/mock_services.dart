import 'package:mocktail/mocktail.dart';
import 'package:portion_control/services/feedback_email_service.dart';
import 'package:portion_control/services/home_widget_service.dart';

class MockHomeWidgetService extends Mock implements HomeWidgetService {
  MockHomeWidgetService();
}

class MockFeedbackEmailService extends Mock implements FeedbackEmailService {
  MockFeedbackEmailService();
}
