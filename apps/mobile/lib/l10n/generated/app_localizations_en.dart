// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NALUM';

  @override
  String get navHome => 'Home';

  @override
  String get navNetwork => 'Network';

  @override
  String get navPosts => 'Posts';

  @override
  String get navEvents => 'Events';

  @override
  String get navMessages => 'Messages';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileTitle => 'Profile';

  @override
  String get postTitle => 'Post';

  @override
  String get eventTitle => 'Event';

  @override
  String get conversationTitle => 'Conversation';

  @override
  String get comingSoon => 'This screen is not built yet.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get retry => 'Retry';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle => 'NSUT Alumni Association';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get createAccount => 'Create an account';

  @override
  String get signUpTitle => 'Create account';

  @override
  String get signOut => 'Sign out';

  @override
  String get fieldRequired => 'Required';

  @override
  String get restoreFailed => 'Could not reach NALUM. Check your connection.';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String get verifyEmailBody =>
      'Enter the code we sent to your email to continue.';

  @override
  String get bannedTitle => 'Account suspended';

  @override
  String get bannedBody =>
      'Your account cannot use NALUM right now. Contact alumni@nsut.ac.in if you think this is a mistake.';

  @override
  String get adminWebTitle => 'Use the web admin panel';

  @override
  String get adminWebBody =>
      'Admin accounts are managed on the website for now.';

  @override
  String get profileSetupTitle => 'Complete your profile';

  @override
  String get verifyAlumniTitle => 'Verify you are an alumnus';

  @override
  String get errorNetwork =>
      'No connection. Check your internet and try again.';

  @override
  String get errorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get errorSessionExpired => 'Your session ended. Please sign in again.';

  @override
  String get errorBanned => 'This account is suspended.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a minute and try again.';

  @override
  String get errorUpgradeRequired => 'Please update the app to continue.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';
}
