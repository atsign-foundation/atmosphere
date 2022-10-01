class MixedConstants {
  // static const String WEBSITE_URL = 'https://staging.atsign.wtf/';
  static const String websiteUrl = 'https://atsign.com/';

  // for local server
  // static const String ROOT_DOMAIN = 'vip.ve.atsign.zone';
  // for staging server
  // static const String ROOT_DOMAIN = 'root.atsign.wtf';
  // for production server
  static const String rootDomain = 'root.atsign.org';

  static const String termsConditions = 'https://atsign.com/terms-conditions/';
  // static const String PRIVACY_POLICY = 'https://atsign.com/privacy-policy/';
  static const String privacyPolicy =
      "https://atsign.com/apps/atmosphere/atmosphere-privacy/";

  // the time to await for file transfer acknowledgement in milliseconds
  static const int timeout = 60000;
  static String appNamespace = 'mosphere';
  static String regex = '.$appNamespace@';
}
