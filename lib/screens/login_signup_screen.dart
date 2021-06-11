import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/dashboard-screen.dart';
import '../config/palette.dart';
import '../widgets/form_field.dart' as padding;
import '../models/languages.dart';
import '../models/division.dart';
import '../models/reporting_officer.dart';
import '../models/work_office.dart';
import '../models/designation.dart';
import '../models/login.dart';
import '../models/signup.dart';
import '../providers/reporting_officers.dart';
import '../providers/divisions.dart';
import '../providers/designationsWorkOffices.dart';
import '../providers/auth.dart';
import '../translations/locale_keys.g.dart';
import '../config/env.dart';

class LoginSignupScreen extends StatefulWidget {
  static const routeName = '/login-singup-screen';
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

//  WidgetsBindingObserver mixin to observe the screen widget activities
class _LoginSignupScreenState extends State<LoginSignupScreen>
    with WidgetsBindingObserver {
  Language selLanguage =
      Language(language: LocaleKeys.english.tr(), value: Locale('en', 'US'));
  // Localization language list Defaultis English
  List<Language> _languages = [
    Language(language: LocaleKeys.english.tr(), value: Locale('en', 'US')),
    Language(language: LocaleKeys.marathi.tr(), value: Locale('mr', 'IN')),
  ];
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _loginId = TextEditingController();
  // Base API  url
  final _url = Environment.url;
  // updateResp is variable to hold the app version update response
  var updateResp;
  // _init is used to control the didChangeDependencies() methods executions
  var _init = true;
  String loginIdMsg;
  // _isUpdating to show the updating screen
  var _isUpdating = false;
  // _isDownloading to show the downloading message and progress indicator on screen
  var _isDownloading = false;
  // _isLoading is used to show circular progrss indicator while screen is loading
  var _isLoading = false;
  // _isLoginLoading to show the progress indicator while checking availability of login id
  var _isLoginLoading = false;
  //  _isRepOfcrLoading to show progress indicator while fetching the reporting officers list
  var _isRepOfcrLoading = false;
  // _loginData is an object to save the login credentials
  var _loginData = Login(uLogin: '', uPwd: '');
  // _signupData is object to save user registration data
  var _signupData = Signup(
    mainofcNm: "",
    mainclntofc: "",
    clntId: null,
    uFname: "",
    uMname: "",
    uLname: "",
    uDesgId: null,
    uDesgNm: "",
    uSevarthNo: "",
    uMobile: "",
    uEmail: "",
    uOfcId: null,
    uOfcNm: "",
    uReportUid: null,
    uReportUNm: "",
    uLoginId: "",
    uPwd: "",
  );
  // _passwordField focus instance to manage the focus on password text field
  final _passwordField = FocusNode();
  // _loginIdField focus instance to manage the focus on login id text field
  final _loginIdField = FocusNode();
  final _loginForm = GlobalKey<FormState>();
  final _signupForm = GlobalKey<FormState>();
  // Store the value of current division
  Division selDivOfc;
  // Store the value of current designation
  Designation selDesig;
  // Store the value of current Work office
  WorkOffice selwrkOfc;
  // Store the value of current reporting officer
  ReportingOfficer selRprtOfcr;
  // Flag to manage displaying of login or regitration fields/widgets
  bool isSignupScreen = false;
// Method to download the updated version app
  Future<void> downloadUpdate(String url) async {
    try {
      setState(() {
        // To show downloading message and circular progress indicator
        _isDownloading = true;
      });
      // call appUpdateDownload() method of Auth provider class
      final resp = await Provider.of<Auth>(context, listen: false)
          .appUpdateDownload(url);
      // Get the external storage directory of current device
      final externalDirectory = await getExternalStorageDirectory();
      // Get path and name for updated app to store
      File file = new File('${externalDirectory.path}/ताडोबासंवाद.apk');
      // Write downloaded updated app to the device storage from body bytes
      await file.writeAsBytes(resp);
      setState(() {
        // Hide the circular progress indicator
        _isDownloading = false;
      });
      // Open downlaoded app for installation
      OpenFile.open("${externalDirectory.path}/ताडोबासंवाद.apk");
    } catch (error) {
      // Show error message if any error occurs while downloading the updated app
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_downloading_updated_app.tr(),
          style: SweetAlertV2Style.error);
    }
  }

//  Method to check the current app version with server updated app version
  void checkAppUpdate() async {
    try {
      // call checkAppVersion() method of Auth provider class
      updateResp = await Provider.of<Auth>(context).checkAppVersion();
      if (updateResp == null) {
        setState(() {
          // hide Update screen of there is no version mismatch
          _isDownloading = false;
          _isUpdating = false;
        });
        return;
      }
      setState(() {
        // Display the update screen if there is version mismatch
        _isUpdating = true;
      });
    } catch (error) {
      // Show message if any error occurs while checking app version
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_checking_app_version.tr(),
          style: SweetAlertV2Style.error);
    }
  }

// didChangeAppLifecycleState() to observe the Login and signup screen widget lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check if app current screen is comes to foreground from background
    if (state == AppLifecycleState.resumed) {
      // Call checkAppUpdate() method on every time screen is resumed
      checkAppUpdate();
    }
  }

  @override
  void didChangeDependencies() async {
    if (!_init) {
      return;
    }
    try {
      // Check for app updated as soon as screen is loaded
      checkAppUpdate();
      // setState(() {
      //   _isLoading = true;
      // });

      // call fetchAndSetDivisons() of Divisions provider class if app version is correct and
      final res = await Provider.of<Divisions>(context, listen: false)
          .fetchAndSetDivisons();
      setState(() {
        _init = false;
        _isLoading = false;
      });
      //  Fetch desigantions and work offices under the fetched / selected division
      if (res == 0) {
        _fetchDesigAndWrkOfc(
            Provider.of<Divisions>(context, listen: false).divisions[0]);
      } else {
        // Show message if any error occurs while fetching designations and work offices
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: res,
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        _init = false;
        _isLoading = false;
      });
      // Show message if any error occurs while fetching division
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_fetching_div.tr(),
          style: SweetAlertV2Style.error);
    }
    setState(() {
      _init = false;
      _isLoading = false;
    });
    super.didChangeDependencies();
  }

// _fetchReportingOfcr() method to fetch resporting officers
// based on selected designation and work office
  Future<void> _fetchReportingOfcr() async {
    try {
      setState(() {
        // Set true to show circular progrss indicator while fetching reporting officers
        _isRepOfcrLoading = true;
      });
      // call fetchAndSetReportingOfficers() method of ReportingOfficers provider class
      final resp = await Provider.of<ReportingOfficers>(context, listen: false)
          .fetchAndSetReportingOfficers(selDesig?.hdid, selwrkOfc?.hdid);

      setState(() {
        // Set false to hide circular progrss indicator while fetching reporting officers
        _isRepOfcrLoading = false;
      });
      if (resp != null && resp['Result'] != "OK") {
        // Show message if any error occurs while fetching reporting officers
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: resp['Msg'],
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        // Set false to hide circular progrss indicator while fetching reporting officers
        _isRepOfcrLoading = false;
      });
      // Show message if any error occurs while fetching reporting officers
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_fetching_rep.tr(),
          style: SweetAlertV2Style.error);
    }
    setState(() {
      // Set false to hide circular progrss indicator while fetching reporting officers
      _isRepOfcrLoading = false;
    });
  }

// _fetchDesigAndWrkOfc() method to fetch work offices and designation based on selected
// division
  Future<void> _fetchDesigAndWrkOfc(Division value) async {
    if (value == null) {
      return;
    }
    selDivOfc = value;
    try {
      // Call fetchAndSetDesigAndWorkOfcs() method of DesignationAndWorkOffices provider class
      Provider.of<DesignationAndWorkOffices>(context, listen: false)
          .fetchAndSetDesigAndWorkOfcs(int.parse(value.value))
          .then((resp) {
        if (resp != 0) {
          // Show message if any error occurs while fetching designations
          // and work offices under selected division
          SweetAlertV2.show(context,
              title: LocaleKeys.error.tr(),
              subtitle: resp,
              style: SweetAlertV2Style.error);
        }
      });
    } catch (error) {
      // Show message if any error occurs while fetching designations
      // and work offices under selected division
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_fetching_desig.tr(),
          style: SweetAlertV2Style.error);
    }
  }

  Future<void> _loginIdCheck() async {
    // TextField lost focus
    try {
      setState(() {
        // Set true to show progress indicator while checking availability of login id
        _isLoginLoading = true;
      });
      // Execute your API validation here
      final response = await Provider.of<Auth>(context, listen: false)
          .verifyLoginId(_loginId.text);
      setState(() {
        // Set false to hide progress indicator of checking availability of login id
        _isLoginLoading = false;
      });
      if (response != null) {
        setState(() {
          // Store login id availability message from server to display
          loginIdMsg = response['Msg'];
        });
        return;
      }
    } catch (error) {
      setState(() {
        // Set false to hide progress indicator of checking availability of login id
        _isLoginLoading = false;
      });
      // Show message if any error occurs while checking availability of login id
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_checking_login_id.tr(),
          style: SweetAlertV2Style.error);
    }
    setState(() {
      _isLoginLoading = false;
      // Set null login Id availability message if error occured
      loginIdMsg = null;
    });
  }

// _submitLoginForm() Method to proceed for login process with credentials
  void _submitLoginForm() async {
    final isValid = _loginForm.currentState
        .validate(); // this will trigger validator on each textFormField
    if (!isValid) {
      // Stop execution if login form is not valid
      return;
    }
    _loginForm.currentState
        .save(); // this will trigger onSaved on each textFormField
    try {
      setState(() {
        // Set true to show progress indicator while getting login response from server
        _isLoading = true;
      });
      // call login method of Auth provider class with login credentials
      final response =
          await Provider.of<Auth>(context, listen: false).login(_loginData);
      setState(() {
        _isLoading = false;
      });
      if (response != 0) {
        // Show message if any error occurs while login process
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: response,
            style: SweetAlertV2Style.error);
        return;
      }
      // If loggin is successfull Navigate to the User Dashboard screen
      Navigator.of(context).pushReplacementNamed(Dashboard.routeName);
    } catch (error) {
      setState(() {
        // Hide circular progress indicator after getting response from server
        _isLoading = false;
      });
      if (error != null) {
        // Show message if any error occurs while login process
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_user_login.tr(),
            style: SweetAlertV2Style.error);
      }
    }
    setState(() {
      // Hide circular progress indicator after getting response from server
      _isLoading = false;
    });
  }

// _resetSignUpForm() method to reset all signup form fields
  void _resetSignUpForm() {
    setState(() {
      _signupForm.currentState?.reset();
      _password?.clear();
      _confirmPassword?.clear();
      selDesig = null;
      selDivOfc = null;
      selRprtOfcr = null;
      selwrkOfc = null;
    });
  }

// _submitRegistrationForm() method to proceed for user registration
  void _submitRegistrationForm() async {
    final isValid = _signupForm.currentState
        .validate(); // Trigger validation on all form fiels of signup form
    if (!isValid) {
      // Stop execution if signup form is invalid
      return;
    }
    setState(() {
      // Set true to show circular progress indicator while
      // registering user on server with registration data
      _isLoading = true;
    });
    _signupForm.currentState
        .save(); // Trigger save on all form fiels of signup form
    try {
      // call signUp() method of Auth provider class
      final res =
          await Provider.of<Auth>(context, listen: false).signUp(_signupData);
      setState(() {
        // Set false to hide circular progress indicator
        _isLoading = false;
      });
      if (res['Result'] == "OK") {
        // call _resetSignUpForm() if user sucessfully registered and show message
        _resetSignUpForm();
        SweetAlertV2.show(context,
            title: LocaleKeys.registration.tr(),
            subtitle: res['Msg'],
            style: SweetAlertV2Style.success);
      } else {
        // Show message if any error occured while user registration
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: res['Msg'],
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        // Set false to hide circular progress indicator
        _isLoading = false;
      });
      if (error != null) {
        // Show message if any error occured while user registration
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_user_reg.tr(),
            style: SweetAlertV2Style.error);
      }
    }
  }

// decoration() method to set the decoration to form fields
  InputDecoration decoration({IconData icon, String label}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: Palette.iconColor,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Palette.textColor1),
        borderRadius: BorderRadius.all(Radius.circular(35.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Palette.textColor1),
        borderRadius: BorderRadius.all(Radius.circular(35.0)),
      ),
      contentPadding: EdgeInsets.all(10),
      // label: label,
      hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
    );
  }

// call dispose() method to clear memory occupied vaiables
  @override
  void dispose() {
    _loginIdField.dispose();
    _passwordField.dispose();
    _confirmPassword.dispose();
    _password.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: _isUpdating
          ?
          // To show app update message and update the app
          Center(
              child: Container(
                width: MediaQuery.of(context).size.width * .80,
                height: MediaQuery.of(context).size.height * .30,
                child: Card(
                  elevation: 12,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("${updateResp['Msg']}"),
                      if (!_isDownloading)
                        Flexible(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blueAccent, // background
                              onPrimary: Colors.white, // foreground
                              textStyle: TextStyle(fontSize: 18),
                            ),
                            onPressed: () => downloadUpdate(updateResp['rtyp']),
                            child: Text(LocaleKeys.update.tr()),
                          ),
                        ),
                      if (_isDownloading)
                        Center(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                Text(
                                  "${LocaleKeys.downloading_updated_app.tr()}",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            )
          :
          //  Show this section if app version is correct
          Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.5), BlendMode.darken),
                          // Set background image to the screen
                          image: AssetImage("assets/images/bg3.jpg"),
                          fit: BoxFit.fill),
                    ),
                    child: Container(
                      padding: EdgeInsets.only(
                          top: !isSignupScreen ? 125 : 30, left: 20),
                      //color: Color(0xFF3b5999).withOpacity(.50),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                                // text: "Welcome to",
                                style: TextStyle(
                                  fontSize: 25,
                                  letterSpacing: 2,
                                  color: Colors.yellow[700],
                                ),
                                children: [
                                  TextSpan(
                                    text: isSignupScreen
                                        ? "ताडोबा संवाद नोंदणी,"
                                        : "ताडोबा संवाद लॉगिन,",
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.yellow[700],
                                    ),
                                  )
                                ]),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            isSignupScreen
                                ? LocaleKeys.signup_to_continue.tr()
                                : LocaleKeys.signin_to_continue.tr(),
                            style: TextStyle(
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isSignupScreen)
                  // Position the logo of TATR
                  Positioned(
                    top: 23,
                    left: 0,
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/images/logo.png"),
                            fit: BoxFit.fill),
                      ),
                    ),
                  ),
                // Trick to add the shadow for the submit button
                if (!isSignupScreen) buildBottomHalfContainer(true),
                //Main Contianer for Login and Signup
                AnimatedPositioned(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.bounceInOut,
                  top: isSignupScreen ? 130 : 210,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.bounceInOut,
                    height: isSignupScreen
                        ? MediaQuery.of(context).size.height - 140
                        : 310,
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width - 40,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5),
                        ]),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Detect the tap on Login text
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSignupScreen = false;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      LocaleKeys.login.tr(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: !isSignupScreen
                                              ? Palette.activeColor
                                              : Palette.textColor1),
                                    ),
                                    if (!isSignupScreen)
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        height: 2,
                                        width: 55,
                                        color: Colors.orange,
                                      )
                                  ],
                                ),
                              ),
                              // Detect the tap on Signup text
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSignupScreen = true;
                                  });
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      LocaleKeys.signup.tr(),
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSignupScreen
                                              ? Palette.activeColor
                                              : Palette.textColor1),
                                    ).tr(),
                                    if (isSignupScreen)
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        height: 2,
                                        width: 55,
                                        color: Colors.orange,
                                      )
                                  ],
                                ),
                              )
                            ],
                          ),
                          if (isSignupScreen)
                            _isLoading
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : buildSignupSection(),
                          if (!isSignupScreen) buildSigninSection()
                        ],
                      ),
                    ),
                  ),
                ),
                // Trick to add the submit button
                if (!isSignupScreen) buildBottomHalfContainer(false),
                // Bottom buttons
              ],
            ),
    );
  }

  Container buildSigninSection() {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Form(
        key: _loginForm,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              padding.FormFieldWidget(
                DropdownButtonFormField<Language>(
                  isExpanded: true,
                  decoration: decoration(
                      label: LocaleKeys.sel_lang.tr(), icon: Icons.translate),
                  onChanged: (lang) async {
                    context.setLocale(lang.value);
                  },
                  items: _languages
                      ?.map(
                        (lang) => new DropdownMenuItem<Language>(
                          child: new Text(lang.language),
                          value: lang,
                        ),
                      )
                      ?.toList(),
                ),
              ),
              padding.FormFieldWidget(
                TextFormField(
                  decoration: decoration(
                    icon: MaterialCommunityIcons.account_outline,
                    label: LocaleKeys.enter_login_id.tr(),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordField);
                  },
                  onSaved: (loginId) {
                    _loginData = Login(uLogin: loginId, uPwd: _loginData.uPwd);
                  },
                  validator: (loginId) {
                    if (loginId.isEmpty) {
                      return LocaleKeys.please_enter_login_id.tr();
                    }
                    return null; // if there is no err
                  },
                ),
              ),
              padding.FormFieldWidget(
                TextFormField(
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: decoration(
                    icon: MaterialCommunityIcons.lock_outline,
                    label: LocaleKeys.please_enter_password.tr(),
                  ),
                  focusNode: _passwordField,
                  onSaved: ([password]) {
                    _loginData =
                        Login(uLogin: _loginData.uLogin, uPwd: password);
                  },
                  validator: (password) {
                    if (password.isEmpty) {
                      return LocaleKeys.please_enter_password.tr();
                    }
                    return null; // if there is no err
                  },
                  onFieldSubmitted: (_) {
                    _submitLoginForm();
                  },
                ),
              ),
              TextButton(
                onPressed: () async => await canLaunch("$_url/resetpasswd")
                    ? await launch("$_url/resetpasswd")
                    : SweetAlertV2.show(context,
                        title: LocaleKeys.error.tr(),
                        subtitle:
                            '${LocaleKeys.could_not_launch.tr()} $_url/resetpasswd',
                        style: SweetAlertV2Style.error),

                // throw '${LocaleKeys.could_not_launch.tr()} $_url/resetpasswd',
                child: Text(
                  "${LocaleKeys.forgot_password.tr()}",
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildSignupSection() {
    // Get the fetched divisions from Divisions provider class
    final _divisions = Provider.of<Divisions>(context).divisions;
    // Get the fetched designations from DesignationAndWorkOffices provider class
    final _designations =
        Provider.of<DesignationAndWorkOffices>(context).designations;
    // Get the fetched workoffices from DesignationAndWorkOffices provider class
    List<WorkOffice> _workOffices =
        Provider.of<DesignationAndWorkOffices>(context).workOffices;
    // Get the fetched reporting officers from ReportingOfficers provider class
    List<ReportingOfficer> _reportingOfficers =
        Provider.of<ReportingOfficers>(context).reportingOfficers;

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Form(
        key: _signupForm,
        child: Padding(
          // Padding to prevent screen overlapping while keypad is showing
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              padding.FormFieldWidget(
                DropdownButtonFormField<Division>(
                  isExpanded: true,
                  value: selDivOfc,
                  onChanged: (Division division) async {
                    setState(() {
                      selDivOfc = division;
                      selwrkOfc = null;
                      selDesig = null;
                    });
                    _fetchDesigAndWrkOfc(division);
                  },
                  decoration:
                      decoration(label: LocaleKeys.divisonal_office.tr()),
                  // onChanged: (_) {},
                  onSaved: (division) {
                    _signupData = Signup(
                      mainofcNm: division.text,
                      mainclntofc: division.value,
                      clntId: int.parse(division.no),
                      uFname: _signupData.uFname,
                      uMname: _signupData.uMname,
                      uLname: _signupData.uLname,
                      uDesgId: _signupData.uDesgId,
                      uDesgNm: _signupData.uDesgNm,
                      uSevarthNo: _signupData.uSevarthNo,
                      uMobile: _signupData.uMobile,
                      uEmail: _signupData.uEmail,
                      uOfcId: _signupData.uOfcId,
                      uOfcNm: _signupData.uOfcNm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: _signupData.uPwd,
                    );
                  },
                  validator: (value) {
                    if (value == null) {
                      return LocaleKeys.please_select_divisional.tr();
                    }
                    return null;
                  },
                  //  Set divisions list in dropdown
                  items: _divisions
                      ?.map(
                        (div) => new DropdownMenuItem(
                          child: new Text(div.text),
                          value: div,
                        ),
                      )
                      ?.toList(),
                ),
              ),
              padding.FormFieldWidget(
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: decoration(label: LocaleKeys.first_name.tr()),
                  onSaved: (firstName) {
                    _signupData = Signup(
                      mainofcNm: _signupData.mainofcNm,
                      mainclntofc: _signupData.mainclntofc,
                      clntId: _signupData.clntId,
                      uFname: firstName,
                      uMname: _signupData.uMname,
                      uLname: _signupData.uLname,
                      uDesgId: _signupData.uDesgId,
                      uDesgNm: _signupData.uDesgNm,
                      uSevarthNo: _signupData.uSevarthNo,
                      uMobile: _signupData.uMobile,
                      uEmail: _signupData.uEmail,
                      uOfcId: _signupData.uOfcId,
                      uOfcNm: _signupData.uOfcNm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: _signupData.uPwd,
                    );
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return LocaleKeys.please_enter_first_name.tr();
                    }
                    return null;
                  },
                ),
              ),
              padding.FormFieldWidget(
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: decoration(label: LocaleKeys.middle_name.tr()),
                  onSaved: (uMname) {
                    _signupData = Signup(
                      mainofcNm: _signupData.mainofcNm,
                      mainclntofc: _signupData.mainclntofc,
                      clntId: _signupData.clntId,
                      uFname: _signupData.uFname,
                      uMname: uMname,
                      uLname: _signupData.uLname,
                      uDesgId: _signupData.uDesgId,
                      uDesgNm: _signupData.uDesgNm,
                      uSevarthNo: _signupData.uSevarthNo,
                      uMobile: _signupData.uMobile,
                      uEmail: _signupData.uEmail,
                      uOfcId: _signupData.uOfcId,
                      uOfcNm: _signupData.uOfcNm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: _signupData.uPwd,
                    );
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return LocaleKeys.please_enter_middle_name.tr();
                    }
                    return null;
                  },
                ),
              ),
              padding.FormFieldWidget(
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: decoration(label: LocaleKeys.last_name.tr()),
                  onSaved: (lastName) {
                    _signupData = Signup(
                      mainofcNm: _signupData.mainofcNm,
                      mainclntofc: _signupData.mainclntofc,
                      clntId: _signupData.clntId,
                      uFname: _signupData.uFname,
                      uMname: _signupData.uMname,
                      uLname: lastName,
                      uDesgId: _signupData.uDesgId,
                      uDesgNm: _signupData.uDesgNm,
                      uSevarthNo: _signupData.uSevarthNo,
                      uMobile: _signupData.uMobile,
                      uEmail: _signupData.uEmail,
                      uOfcId: _signupData.uOfcId,
                      uOfcNm: _signupData.uOfcNm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: _signupData.uPwd,
                    );
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return LocaleKeys.please_enter_last_name.tr();
                    }
                    return null;
                  },
                ),
              ),
              padding.FormFieldWidget(
                DropdownButtonFormField<Designation>(
                  isExpanded: true,
                  value: selDesig,
                  decoration: decoration(label: LocaleKeys.designation.tr()),
                  onSaved: (designation) {
                    _signupData = Signup(
                      mainofcNm: _signupData.mainofcNm,
                      mainclntofc: _signupData.mainclntofc,
                      clntId: _signupData.clntId,
                      uFname: _signupData.uFname,
                      uMname: _signupData.uMname,
                      uLname: _signupData.uLname,
                      uDesgId: designation.hdid,
                      uDesgNm: designation.hdnm,
                      uSevarthNo: _signupData.uSevarthNo,
                      uMobile: _signupData.uMobile,
                      uEmail: _signupData.uEmail,
                      uOfcId: _signupData.uOfcId,
                      uOfcNm: _signupData.uOfcNm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: _signupData.uPwd,
                    );
                  },
                  validator: (value) {
                    if (value == null) {
                      return LocaleKeys.please_select_designation.tr();
                    }
                    return null;
                  },
                  onChanged: (Designation designation) {
                    setState(() {
                      selRprtOfcr = null;
                      selDesig = designation;
                    });
                    _fetchReportingOfcr();
                  },
                  items: _designations
                      ?.map(
                        (desg) => new DropdownMenuItem(
                          child: new Text(desg.hdnm),
                          value: desg,
                        ),
                      )
                      ?.toList(),
                ),
              ),
              padding.FormFieldWidget(
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: decoration(label: LocaleKeys.sevarth_number.tr()),
                  onSaved: (sevarthNumber) {
                    _signupData = Signup(
                      mainofcNm: _signupData.mainofcNm,
                      mainclntofc: _signupData.mainclntofc,
                      clntId: _signupData.clntId,
                      uFname: _signupData.uFname,
                      uMname: _signupData.uMname,
                      uLname: _signupData.uLname,
                      uDesgId: _signupData.uDesgId,
                      uDesgNm: _signupData.uDesgNm,
                      uSevarthNo: sevarthNumber,
                      uMobile: _signupData.uMobile,
                      uEmail: _signupData.uEmail,
                      uOfcId: _signupData.uOfcId,
                      uOfcNm: _signupData.uOfcNm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: _signupData.uPwd,
                    );
                  },
                ),
              ),
              padding.FormFieldWidget(
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: decoration(label: LocaleKeys.mobile_number.tr()),
                  onSaved: (String mobileNumber) {
                    _signupData = Signup(
                      mainofcNm: _signupData.mainofcNm,
                      mainclntofc: _signupData.mainclntofc,
                      clntId: _signupData.clntId,
                      uFname: _signupData.uFname,
                      uMname: _signupData.uMname,
                      uLname: _signupData.uLname,
                      uDesgId: _signupData.uDesgId,
                      uDesgNm: _signupData.uDesgNm,
                      uSevarthNo: _signupData.uSevarthNo,
                      uMobile: mobileNumber,
                      uEmail: _signupData.uEmail,
                      uOfcId: _signupData.uOfcId,
                      uOfcNm: _signupData.uOfcNm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: _signupData.uPwd,
                    );
                  },
                  validator: (value) {
                    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                    RegExp regExp = new RegExp(patttern);
                    if (value.isEmpty) {
                      return LocaleKeys.please_provide_valid_input.tr();
                    }
                    if (!regExp.hasMatch(value)) {
                      return LocaleKeys.please_mobile_number.tr();
                    }
                    return null;
                  },
                ),
              ),
              padding.FormFieldWidget(
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: decoration(label: LocaleKeys.email.tr()),
                  onSaved: (email) {
                    _signupData = Signup(
                      mainofcNm: _signupData.mainofcNm,
                      mainclntofc: _signupData.mainclntofc,
                      clntId: _signupData.clntId,
                      uFname: _signupData.uFname,
                      uMname: _signupData.uMname,
                      uLname: _signupData.uLname,
                      uDesgId: _signupData.uDesgId,
                      uDesgNm: _signupData.uDesgNm,
                      uSevarthNo: _signupData.uSevarthNo,
                      uMobile: _signupData.uMobile,
                      uEmail: email,
                      uOfcId: _signupData.uOfcId,
                      uOfcNm: _signupData.uOfcNm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: _signupData.uPwd,
                    );
                  },
                ),
              ),
              padding.FormFieldWidget(
                DropdownButtonFormField<WorkOffice>(
                  isExpanded: true,
                  value: selwrkOfc,
                  decoration: decoration(label: LocaleKeys.work_office.tr()),
                  onChanged: (workOffice) {
                    setState(() {
                      selRprtOfcr = null;
                      selwrkOfc = workOffice;
                    });
                    _fetchReportingOfcr();
                  },
                  onSaved: (workOffice) {
                    _signupData = Signup(
                      mainofcNm: _signupData.mainofcNm,
                      mainclntofc: _signupData.mainclntofc,
                      clntId: _signupData.clntId,
                      uFname: _signupData.uFname,
                      uMname: _signupData.uMname,
                      uLname: _signupData.uLname,
                      uDesgId: _signupData.uDesgId,
                      uDesgNm: _signupData.uDesgNm,
                      uSevarthNo: _signupData.uSevarthNo,
                      uMobile: _signupData.uMobile,
                      uEmail: _signupData.uEmail,
                      uOfcId: workOffice.hdid,
                      uOfcNm: workOffice.hdnm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: _signupData.uPwd,
                    );
                  },
                  validator: (value) {
                    if (value == null) {
                      return LocaleKeys.please_select_work.tr();
                    }
                    return null;
                  },
                  items: _workOffices
                      ?.map(
                        (workOfc) => new DropdownMenuItem(
                          child: new Text(workOfc.hdnm),
                          value: workOfc,
                        ),
                      )
                      ?.toList(),
                ),
              ),
              _isRepOfcrLoading
                  ? CircularProgressIndicator()
                  : padding.FormFieldWidget(
                      DropdownButtonFormField<ReportingOfficer>(
                        isExpanded: true,
                        value: selRprtOfcr,
                        decoration: decoration(
                            label: LocaleKeys.reporting_officer.tr()),
                        onChanged: (ReportingOfficer newValue) {
                          setState(() {
                            selRprtOfcr = newValue;
                          });
                        },
                        onSaved: (reportingOfficer) {
                          _signupData = Signup(
                            mainofcNm: _signupData.mainofcNm,
                            mainclntofc: _signupData.mainclntofc,
                            clntId: _signupData.clntId,
                            uFname: _signupData.uFname,
                            uMname: _signupData.uMname,
                            uLname: _signupData.uLname,
                            uDesgId: _signupData.uDesgId,
                            uDesgNm: _signupData.uDesgNm,
                            uSevarthNo: _signupData.uSevarthNo,
                            uMobile: _signupData.uMobile,
                            uEmail: _signupData.uEmail,
                            uOfcId: _signupData.uOfcId,
                            uOfcNm: _signupData.uOfcNm,
                            uReportUid: int.parse(reportingOfficer.value),
                            uReportUNm: reportingOfficer.text,
                            uLoginId: _signupData.uLoginId,
                            uPwd: _signupData.uPwd,
                          );
                        },
                        validator: (value) {
                          if (value == null) {
                            return LocaleKeys.please_select_reporting.tr();
                          }
                          return null;
                        },
                        items: _reportingOfficers
                            ?.map(
                              (rptOfcr) => new DropdownMenuItem(
                                child: new Text('${rptOfcr.text}'),
                                value: rptOfcr,
                              ),
                            )
                            ?.toList(),
                      ),
                    ),
              padding.FormFieldWidget(
                _isLoginLoading
                    ? CircularProgressIndicator()
                    : FocusScope(
                        child: Focus(
                          onFocusChange: (focus) =>
                              // Check for loginid availability when field losses the focus
                              focus ? () {} : _loginIdCheck(),
                          child: TextFormField(
                            controller: _loginId,
                            focusNode: _loginIdField,
                            keyboardType: TextInputType.text,
                            decoration:
                                decoration(label: LocaleKeys.login_id.tr()),
                            onSaved: (loginid) {
                              _signupData = Signup(
                                mainofcNm: _signupData.mainofcNm,
                                mainclntofc: _signupData.mainclntofc,
                                clntId: _signupData.clntId,
                                uFname: _signupData.uFname,
                                uMname: _signupData.uMname,
                                uLname: _signupData.uLname,
                                uDesgId: _signupData.uDesgId,
                                uDesgNm: _signupData.uDesgNm,
                                uSevarthNo: _signupData.uSevarthNo,
                                uMobile: _signupData.uMobile,
                                uEmail: _signupData.uEmail,
                                uOfcId: _signupData.uOfcId,
                                uOfcNm: _signupData.uOfcNm,
                                uReportUid: _signupData.uReportUid,
                                uReportUNm: _signupData.uReportUNm,
                                uLoginId: loginid,
                                uPwd: _signupData.uPwd,
                              );
                            },
                            validator: (String value) {
                              if (value.isEmpty) {
                                return LocaleKeys.please_enter_login_id.tr();
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
              ),
              if (loginIdMsg != null && !_isLoginLoading) Text(loginIdMsg),
              padding.FormFieldWidget(
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: decoration(label: LocaleKeys.password.tr()),
                  onSaved: (password) {
                    _signupData = Signup(
                      mainofcNm: _signupData.mainofcNm,
                      mainclntofc: _signupData.mainclntofc,
                      clntId: _signupData.clntId,
                      uFname: _signupData.uFname,
                      uMname: _signupData.uMname,
                      uLname: _signupData.uLname,
                      uDesgId: _signupData.uDesgId,
                      uDesgNm: _signupData.uDesgNm,
                      uSevarthNo: _signupData.uSevarthNo,
                      uMobile: _signupData.uMobile,
                      uEmail: _signupData.uEmail,
                      uOfcId: _signupData.uOfcId,
                      uOfcNm: _signupData.uOfcNm,
                      uReportUid: _signupData.uReportUid,
                      uReportUNm: _signupData.uReportUNm,
                      uLoginId: _signupData.uLoginId,
                      uPwd: password,
                    );
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return LocaleKeys.please_enter_password.tr();
                    }
                    if (value != _confirmPassword.text) {
                      return LocaleKeys.password_does_not_ma.tr();
                    }
                    return null;
                  },
                ),
              ),
              padding.FormFieldWidget(
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  decoration: decoration(label: LocaleKeys.cnf_pwd.tr()),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return LocaleKeys.please_enter_confirm_pas.tr();
                    }
                    if (_password.text != value) {
                      return LocaleKeys.cnf_pwd_not_match_with_pwd.tr();
                    }
                    return null;
                  },
                ),
              ),
              padding.FormFieldWidget(SizedBox(
                height: 20,
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.greenAccent, // background
                        onPrimary: Colors.white, // foreground
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      onPressed: _submitRegistrationForm,
                      child: Text(LocaleKeys.save.tr()),
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // background
                        onPrimary: Colors.white, // foreground
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      onPressed: _resetSignUpForm,
                      child: Text(LocaleKeys.reset.tr()),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

// buildTextButton() to build the button for login
  TextButton buildTextButton(
      IconData icon, String title, Color backgroundColor) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
          side: BorderSide(width: 1, color: Colors.grey),
          minimumSize: Size(145, 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          primary: Colors.white,
          backgroundColor: backgroundColor),
      child: Row(
        children: [
          Icon(
            icon,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            title,
          )
        ],
      ),
    );
  }

// buildBottomHalfContainer() to hold and manage background for login button
  Widget buildBottomHalfContainer(bool showShadow) {
    return Positioned(
      top: 475,
      right: 0,
      left: 0,
      child: Center(
        child: Container(
          height: 90,
          width: 90,
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                if (showShadow)
                  BoxShadow(
                    color: Colors.black.withOpacity(.3),
                    spreadRadius: 1.5,
                    blurRadius: 10,
                  )
              ]),
          child: !showShadow
              ? GestureDetector(
                  onTap: _submitLoginForm,
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.orange[200], Colors.red[400]],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.3),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1))
                        ]),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                )
              : Center(),
        ),
      ),
    );
  }
}
