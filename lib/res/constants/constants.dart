const String baseUrl = 'https://portioncontrol.ca';
const String ukrainianWebVersion = 'https://uk.portioncontrol.ca';
const String frenchWebVersion = 'https://fr.portioncontrol.ca';
const String companyDomain = 'portioncontrol.ca';
const String supportEmailPrefix = 'support@';
const String supportEmail = '$supportEmailPrefix$companyDomain';
const String appName = 'Portion Control';
const String googlePlayUrl =
    'https://play.google.com/store/apps/details?id=com.turskyi.portion_control';

const String appStoreUrl = 'https://apps.apple.com/app/id6743641654';

const String macOsUrl =
    'https://apps.apple.com/ca/app/portion-control/id6743641654';

const String imagePath = 'assets/images/';

/// Blur intensity constant.
const double blurSigma = 12.0;

// in centimeters
final double minUserHeight = 100.0;
// in centimeters
final double maxUserHeight = 250.0;

const double maxHealthyBmi = 24.9;

const double minHealthyBmi = 18.5;

const double minBodyWeight = 20.0;

const int minAge = 18;

/// Absolute upper bound for daily food intake, in grams.
///
/// This value acts as a technical safeguard when there is insufficient
/// user data (for example, during early onboarding or missing history).
/// It prevents unbounded or unrealistic values while avoiding premature
/// restriction before enough observations are available.
///
/// The value of `4000 g` is intentionally conservative and is **not**
/// a recommended or target intake. It is not shown as dietary advice
/// and does not represent a personalized limit.
///
/// Once sufficient body-weight and food log data is available, the app
/// derives adaptive daily values based on observed trends rather than
/// relying on this fallback.
const double kMaxDailyFoodLimit = 4000.0;

/// The minimum daily portion control limit, in grams.
///
/// This safeguard exists to prevent the app from recommending
/// dangerously low food intake.
///
/// The value of `1200 g` is derived from the widely accepted
/// minimum safe caloric intake for adults (≈1200 kcal/day)
/// recommended by many health organizations for weight loss.
///
/// Because the app tracks food weight in grams rather than
/// calories, this constant acts as a conservative proxy: it ensures
/// that even with low-calorie-density foods (for example,
/// vegetables), users are not advised to eat below this threshold.
///
/// This is a general safety floor and does not replace personalized
/// medical advice. Users with special dietary needs should consult
/// a healthcare professional.
const double kSafeMinimumFoodIntakeG = 1200.0;

/// The absolute minimum daily food intake, in grams.
///
/// This value represents a level below which intake might be
/// life-threatening if sustained, and it serves as the ultimate floor
/// for the app's adaptive algorithm, even if weight continues to increase.
const double kAbsoluteMinimumFoodIntakeG = 1000.0;

/// When to switch to wide layout.
const double wideScreenThreshold = 600.0;

// Max content width for wide layout.
const double kWideScreenContentWidth = 800.0;

const String kMailToScheme = 'mailto';

const String telegramUrl = 'https://t.me/+Zmd6QYP3iXc2MjZi';

const String feedbackTypeProperty = 'feedback_type';
const String feedbackTextProperty = 'feedback_text';
const String ratingProperty = 'rating';
const String screenSizeProperty = 'screenSize';

// Expires Mar 13, 2026.
const String resendEmailDomain = 'kima.website';

const String kSubjectParameter = 'subject';

const String kBodyParameter = 'body';

const String appleAppGroupId = 'group.dmytrowidget';
const String iOSWidgetName = 'PortionControlWidgets';
const String kAndroidWidgetName = 'PortionControlWidget';

/// The minimum BMI value considered valid for display and classification.
///
/// Values below this threshold are treated as missing or insufficient input
/// (for example, when body weight has not been entered yet) and are excluded
/// from BMI category messaging.
///
/// This helps prevent showing misleading classifications on first app launch
/// or before the user provides complete data.
const double kMinValidBmi = 10.0;

/// BMI classification thresholds (kg/m²).
/// Source: https://www.who.int/data/gho/data/themes/topics/topic-details/GHO/body-mass-index
/// Marks end of underweight / start of healthy.
const double bmiUnderweightThreshold = 18.5;

/// Marks end of healthy.
const double bmiHealthyUpperThreshold = 24.9;

/// Marks start of overweight.
const double bmiOverweightLowerThreshold = 25.0;

/// Marks end of overweight.
const double bmiOverweightUpperThreshold = 29.9;

/// Marks start of obese.
const double bmiObeseLowerThreshold = 30.0;

const String doNotReplySenderName = 'Do Not Reply';
const String feedbackEmailSender =
    '$doNotReplySenderName $appName <no-reply@$resendEmailDomain>';
const String feedbackScreenshotFileName = 'feedback.png';
const double kHorizontalIndent = 12.0;

const String kLanguageValue = 'language';
