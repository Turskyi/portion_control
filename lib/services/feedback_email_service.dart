import 'package:portion_control/res/constants/constants.dart' as constants;
import 'package:resend/resend.dart';

abstract class FeedbackEmailService {
  const FeedbackEmailService();

  Future<void> sendFeedbackEmail({
    required String subject,
    required String text,
  });
}

class FeedbackEmailServiceImpl implements FeedbackEmailService {
  const FeedbackEmailServiceImpl();

  @override
  Future<void> sendFeedbackEmail({
    required String subject,
    required String text,
  }) {
    return Resend.instance.sendEmail(
      from: constants.feedbackEmailSender,
      to: <String>[constants.supportEmail],
      subject: subject,
      text: text,
    );
  }
}
