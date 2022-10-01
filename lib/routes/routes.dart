import 'package:atsign_atmosphere_app/routes/route_names.dart';
import 'package:atsign_atmosphere_app/screens/blocked_users/blocked_users.dart';
import 'package:atsign_atmosphere_app/screens/contact/contact.dart';
import 'package:atsign_atmosphere_app/screens/faqs/faqs.dart';
import 'package:atsign_atmosphere_app/screens/history/history_screen.dart';
import 'package:atsign_atmosphere_app/screens/home/home.dart';
import 'package:atsign_atmosphere_app/screens/common_widgets/website_webview.dart';
import 'package:atsign_atmosphere_app/screens/terms_conditions/terms_conditions_screen.dart';
import 'package:atsign_atmosphere_app/screens/welcome_screen/welcome_screen.dart';
import 'package:flutter/material.dart';

class SetupRoutes {
  static String initialRoute = Routes.home;

  static Map<String, WidgetBuilder> get routes {
    return {
      Routes.home: (context) => Home(),
      Routes.websiteScreen: (context) {
        Map<String, String> args =
            ModalRoute.of(context).settings.arguments as Map<String, String>;
        return WebsiteScreen(title: args["title"], url: args["url"]);
      },
      Routes.welcomeScreen: (context) => WelcomeScreen(),
      Routes.faqScreen: (context) => FaqsScreen(),
      Routes.termsConditions: (context) => TermsConditions(),
      Routes.history: (context) => HistoryScreen(),
      Routes.blockedUsers: (context) => BlockedUsers(),
      Routes.contactScreen: (context) => ContactScreen(),
    };
  }
}
