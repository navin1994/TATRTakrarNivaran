import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import './translations/codegen_loader.g.dart';
import './screens/dashboard-screen.dart';
import './screens/profile_screen.dart';
import './screens/registration_List_screen.dart';
import './screens/login_signup_screen.dart';
import './screens/registration_details_screen.dart';
import './screens/raise_complain_screen.dart';
import './screens/complaint_management_screen.dart';
import './screens/complaint_details_screen.dart';
import './providers/registered_users.dart';
import './providers/designationsWorkOffices.dart';
import './providers/divisions.dart';
import './providers/auth.dart';
import './providers/reporting_officers.dart';
import './providers/categories.dart';
import './providers/complaints.dart';
import './config/env.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //await Firebase.initializeApp();
}

Future<void> main() async {
  // Needs to be called so that we can await for EasyLocalization.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ));
    }
  });
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
  final String api = Environment.url;
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
          title: 'ताडोबा संवाद',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            // brightness: Brightness.dark,
            // primarySwatch: Colors.purple,
            // accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: LoginSignupScreen(),
          // home: auth.isAuth
          //     ? Dashboard()
          //     : FutureBuilder(
          //         future: auth.tryAutoLogin(),
          //         builder: (ctx, authResultSnapshot) =>
          //             authResultSnapshot.connectionState ==
          //                     ConnectionState.waiting
          //                 ? Center(
          //                     child: CircularProgressIndicator(),
          //                   )
          //                 : LoginSignupScreen(),
          //       ),
          routes: {
            Dashboard.routeName: (ctx) => Dashboard(),
            ComplaintManagementScreen.routeName: (ctx) =>
                ComplaintManagementScreen(),
            ComplaintDetailsScreen.routeName: (ctx) => ComplaintDetailsScreen(),
            ProfilePageScreen.routeName: (ctx) => ProfilePageScreen(),
            RegistrationListScreen.routeName: (ctx) => RegistrationListScreen(),
            RaiseComplainScreen.routeName: (ctx) => RaiseComplainScreen(),
            RagistrationDetailsScreen.routeName: (ctx) =>
                RagistrationDetailsScreen(),
            LoginSignupScreen.routeName: (ctx) => LoginSignupScreen(),
          },
        ),
      ),
    );
  }
}
