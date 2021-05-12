import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './translations/codegen_loader.g.dart';
import './screens/data_management_screen.dart';
import './screens/dashboard-screen.dart';
import './screens/profile_screen.dart';
import './screens/registration_List_screen.dart';
import './screens/login_signup_screen.dart';
import './screens/registration_details_screen.dart';
import './screens/raise_complain_screen.dart';
import './screens/complaint_management_screen.dart';
import './screens/complaint_details_screen.dart';
import './screens/splash_screen.dart';
import './providers/registered_users.dart';
import './providers/designationsWorkOffices.dart';
import './providers/divisions.dart';
import './providers/auth.dart';
import './providers/reporting_officers.dart';
import './providers/categories.dart';
import './providers/complaints.dart';

void main() async {
  // Needs to be called so that we can await for EasyLocalization.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: [Locale('en', 'US'), Locale('mr', 'IN')],
      fallbackLocale: Locale('en', 'US'),
      assetLoader: CodegenLoader(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProvider.value(
          value: DesignationAndWorkOffices(),
        ),
        ChangeNotifierProvider.value(
          value: Divisions(),
        ),
        ChangeNotifierProvider.value(
          value: ReportingOfficers(),
        ),
        ChangeNotifierProxyProvider<Auth, Complaints>(
          update: (ctx, auth, previousComplaints) => Complaints(
            auth.uid,
            auth.clntId,
            auth.name,
            previousComplaints == null ? [] : previousComplaints.complaints,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, RegisteredUsers>(
          update: (ctx, auth, previousRegisteredUsers) => RegisteredUsers(
            auth.uid,
            auth.clntId,
            auth.name,
            previousRegisteredUsers == null
                ? []
                : previousRegisteredUsers.registeredUsers,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Categories>(
          update: (ctx, auth, previousCategories) => Categories(
            auth.uid,
            auth.clntId,
            auth.name,
            previousCategories == null ? [] : previousCategories.categories,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          locale: context.locale,
          title: 'Sanwad',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            // brightness: Brightness.dark,
            // primarySwatch: Colors.purple,
            // accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? Dashboard()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : LoginSignupScreen(),
                ),
          routes: {
            Dashboard.routeName: (ctx) => Dashboard(),
            ComplaintManagementScreen.routeName: (ctx) =>
                ComplaintManagementScreen(),
            ComplaintDetailsScreen.routeName: (ctx) => ComplaintDetailsScreen(),
            ProfilePageScreen.routeName: (ctx) => ProfilePageScreen(),
            RegistrationListScreen.routeName: (ctx) => RegistrationListScreen(),
            RaiseComplainScreen.routeName: (ctx) => RaiseComplainScreen(),
            DataManagementScreen.routeName: (ctx) => DataManagementScreen(),
            RagistrationDetailsScreen.routeName: (ctx) =>
                RagistrationDetailsScreen(),
            LoginSignupScreen.routeName: (ctx) => LoginSignupScreen(),
          },
        ),
      ),
    );
  }
}
