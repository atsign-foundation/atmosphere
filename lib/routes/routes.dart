import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/blocked_users/blocked_users.dart';
import 'package:atsign_atmosphere_app/screens/contact/contact.dart';
import 'package:atsign_atmosphere_app/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_app/screens/home/home.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/website_webview.dart';
import 'package:atsign_atmosphere_app/screens/terms_conditions/terms_conditions_screen.dart';
import 'package:atsign_atmosphere_app/screens/welcome_screen/welcome_screen.dart';
import 'package:atsign_atmosphere_app/utils/constants.dart';
import 'package:flutter/material.dart';

class SetupRoutes {
  static String initialRoute = Routes.HOME;

  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.HOME: (context) => Home(),
      Routes.WEBSITE_SCREEN: (context) {
        Map<String, String> args =
            ModalRoute.of(context).settings.arguments as Map<String, String>;
        return WebsiteScreen(title: args["title"], url: args["url"]);
      },
      Routes.WELCOME_SCREEN: (context) => WelcomeScreen(),
      Routes.FAQ_SCREEN: (context) => WebsiteScreen(
          title: 'FAQ', url: '${MixedConstants.WEBSITE_URL}/faqs'),
      Routes.TERMS_CONDITIONS: (context) => TermsConditions(),
      Routes.HISTORY: (context) => HistoryScreen(),
      Routes.BLOCKED_USERS: (context) => BlockedUsers(),
      Routes.CONTACT_SCREEN: (context) => ContactScreen(),
    };
  }
}
