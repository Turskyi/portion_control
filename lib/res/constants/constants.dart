const String kCompanyDomain = 'portioncontrol.ca';
const String kBaseUrl = 'https://$kCompanyDomain';
const String kUkrainianWebVersion = 'https://uk.$kCompanyDomain';
const String kFrenchWebVersion = 'https://fr.$kCompanyDomain';
const String kResendEmailDomain = kCompanyDomain;
const String kSupportEmailPrefix = 'support@';
const String kSupportEmail = '$kSupportEmailPrefix$kCompanyDomain';
const String kAppName = 'Portion Control';
const String kGooglePlayUrl =
    'https://play.google.com/store/apps/details?id=com.turskyi.portion_control';

const String kAppStoreUrl = 'https://apps.apple.com/app/id6743641654';

const String kMacOsUrl =
    'https://apps.apple.com/ca/app/portion-control/id6743641654';

// Lookup URL used to query App Store metadata by bundle id.
const String kITunesLookupUrl = 'https://itunes.apple.com/lookup?bundleId=';

const String kImagePath = 'assets/images/';

/// Blur intensity constant.
const double kBlurSigma = 12.0;

// in centimeters
final double kMinUserHeight = 100.0;
// in centimeters
final double kMaxUserHeight = 250.0;

const double kMaxHealthyBmi = 24.9;

const double kMinHealthyBmi = 18.5;

const double kMinBodyWeight = 20.0;

const int kMinAge = 18;

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
const double kWideScreenThreshold = 600.0;

// Max content width for wide layout.
const double kWideScreenContentWidth = 800.0;

const String kMailToScheme = 'mailto';

const String kTelegramUrl = 'https://t.me/+Zmd6QYP3iXc2MjZi';

const String kFeedbackTypeProperty = 'feedback_type';
const String kFeedbackTextProperty = 'feedback_text';
const String kRatingProperty = 'rating';
const String kScreenSizeProperty = 'screenSize';

const String kSubjectParameter = 'subject';

const String kBodyParameter = 'body';

const String kAppleAppGroupId = 'group.dmytrowidget';
const String kIosWidgetName = 'PortionControlWidgets';
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
const double kBmiUnderweightThreshold = 18.5;

/// Marks end of healthy.
const double kBmiHealthyUpperThreshold = 24.9;

/// Marks start of overweight.
const double kBmiOverweightLowerThreshold = 25.0;

/// Marks end of overweight.
const double kBmiOverweightUpperThreshold = 29.9;

/// Marks start of obese.
const double kBmiObeseLowerThreshold = 30.0;

const double kMidpointBuffer = 0.5;

const String kDoNotReplySenderName = 'Do Not Reply';
const String kFeedbackEmailSender =
    '$kDoNotReplySenderName $kAppName <no-reply@$kResendEmailDomain>';
const String kFeedbackScreenshotFileName = 'feedback.png';
const double kHorizontalIndent = 12.0;

const String kLanguageValue = 'language';
