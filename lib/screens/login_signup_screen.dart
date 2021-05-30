import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:easy_localization/easy_localization.dart';
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

class LoginSignupScreen extends StatefulWidget {
  static const routeName = '/login-singup-screen';
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  Language selLanguage =
      Language(language: LocaleKeys.english.tr(), value: Locale('en', 'US'));
  List<Language> _languages = [
    Language(language: LocaleKeys.english.tr(), value: Locale('en', 'US')),
    Language(language: LocaleKeys.marathi.tr(), value: Locale('mr', 'IN')),
  ];
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _loginId = TextEditingController();
  var _init = true;
  String loginIdMsg;
  var _isLoading = false;
  var _isLoginLoading = false;
  var _isRepOfcrLoading = false;
  var _loginData = Login(uLogin: '', uPwd: '');
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
  final _passwordField = FocusNode();
  final _loginIdField = FocusNode();
  final _loginForm = GlobalKey<FormState>();
  final _signupForm = GlobalKey<FormState>();
  Division selDivOfc;
  Designation selDesig;
  WorkOffice selwrkOfc;
  ReportingOfficer selRprtOfcr;
  bool isSignupScreen = false;

  void checkAppUpdate() async {
    try {
      final res = await Provider.of<Auth>(context).checkAppVersion();
      if (res == null) {
        return;
      }
      showDialog(
        barrierColor: Colors.white,
        barrierDismissible: false,
        context: context,
        builder: (_) => WillPopScope(
          onWillPop: () => Future.value(false),
          child: Dialog(
            child: Container(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("${res['Msg']}"),
                  Flexible(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blueAccent, // background
                        onPrimary: Colors.white, // foreground
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      onPressed: () async => await canLaunch("${res['rtyp']}")
                          ? await launch("${res['rtyp']}")
                          : throw '${LocaleKeys.could_not_launch.tr()} ${res['rtyp']}',
                      child: Text(LocaleKeys.update.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      print("Error $error");
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_checking_app_version.tr(),
          style: SweetAlertV2Style.error);
    }
  }

  @override
  void didChangeDependencies() async {
    if (!_init) {
      return;
    }
    try {
      checkAppUpdate();
      setState(() {
        _isLoading = true;
      });
      final res = await Provider.of<Divisions>(context, listen: false)
          .fetchAndSetDivisons();
      setState(() {
        _init = false;
        _isLoading = false;
      });
      if (res == 0) {
        _fetchDesigAndWrkOfc(
            Provider.of<Divisions>(context, listen: false).divisions[0]);
      } else {
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
      print("Error $error");
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

  Future<void> _fetchReportingOfcr() async {
    try {
      setState(() {
        _isRepOfcrLoading = true;
      });
      final resp = await Provider.of<ReportingOfficers>(context, listen: false)
          .fetchAndSetReportingOfficers(selDesig?.hdid, selwrkOfc?.hdid);

      setState(() {
        _isRepOfcrLoading = false;
      });
      if (resp != null && resp['Result'] != "OK") {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: resp['Msg'],
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        _isRepOfcrLoading = false;
      });
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_fetching_rep.tr(),
          style: SweetAlertV2Style.error);
    }
    setState(() {
      _isRepOfcrLoading = false;
    });
  }

  Future<void> _fetchDesigAndWrkOfc(Division value) async {
    if (value == null) {
      return;
    }
    selDivOfc = value;
    try {
      Provider.of<DesignationAndWorkOffices>(context, listen: false)
          .fetchAndSetDesigAndWorkOfcs(int.parse(value.value))
          .then((resp) {
        if (resp != 0) {
          SweetAlertV2.show(context,
              title: LocaleKeys.error.tr(),
              subtitle: resp,
              style: SweetAlertV2Style.error);
        }
      });
    } catch (error) {
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
        _isLoginLoading = true;
      });
      // Execute your API validation here
      final response = await Provider.of<Auth>(context, listen: false)
          .verifyLoginId(_loginId.text);
      setState(() {
        _isLoginLoading = false;
      });
      if (response != null) {
        setState(() {
          loginIdMsg = response['Msg'];
        });
        return;
      }
    } catch (error) {
      setState(() {
        _isLoginLoading = false;
      });
      print("Error $error");
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_checking_login_id.tr(),
          style: SweetAlertV2Style.error);
    }
    setState(() {
      _isLoginLoading = false;
      loginIdMsg = null;
    });
  }

  @override
  void dispose() {
    _loginIdField.dispose();
    _passwordField.dispose();
    _confirmPassword.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submitLoginForm() async {
    final isValid = _loginForm.currentState
        .validate(); // this will trigger validator on each textFormField
    if (!isValid) {
      return;
    }
    _loginForm.currentState
        .save(); // this will trigger onSaved on each textFormField
    print('Login Id: ${_loginData.uLogin}');
    print('Login Password: ${_loginData.uPwd}');
    try {
      setState(() {
        _isLoading = true;
      });
      final response =
          await Provider.of<Auth>(context, listen: false).login(_loginData);
      setState(() {
        _isLoading = false;
      });
      if (response != 0) {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: response,
            style: SweetAlertV2Style.error);
        return;
      }
      Navigator.of(context).pushReplacementNamed(Dashboard.routeName);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (error != null) {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_user_login.tr(),
            style: SweetAlertV2Style.error);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

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

  void _submitRegistrationForm() async {
    final isValid = _signupForm.currentState.validate();
    if (!isValid) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _signupForm.currentState.save();
    try {
      final res =
          await Provider.of<Auth>(context, listen: false).signUp(_signupData);
      setState(() {
        _isLoading = false;
      });
      print("Server response on signup => $res");
      if (res['Result'] == "OK") {
        _resetSignUpForm();
        SweetAlertV2.show(context,
            title: LocaleKeys.registration.tr(),
            subtitle: res['Msg'],
            style: SweetAlertV2Style.success);
      } else {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: res['Msg'],
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (error != null) {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_user_reg.tr(),
            style: SweetAlertV2Style.error);
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
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
                              Colors.black.withOpacity(0.8), BlendMode.darken),
                          image: AssetImage("assets/images/bg3.jpg"),
                          fit: BoxFit.fill),
                    ),
                    child: Container(
                      padding: EdgeInsets.only(
                          top: !isSignupScreen ? 125 : 30, left: 20),
                      color: Color(0xFF3b5999).withOpacity(.50),
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
                                        ? "TATR तक्रार निवारण नोंदणी,"
                                        : "TATR तक्रार निवारण लॉगिन,",
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
                  top: isSignupScreen ? 130 : 230,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.bounceInOut,
                    height: isSignupScreen
                        ? MediaQuery.of(context).size.height - 140
                        : 270,
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
                          if (isSignupScreen) buildSignupSection(),
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
            ],
          ),
        ),
      ),
    );
  }

  Container buildSignupSection() {
    final _divisions = Provider.of<Divisions>(context).divisions;
    final _designations =
        Provider.of<DesignationAndWorkOffices>(context).designations;
    List<WorkOffice> _workOffices =
        Provider.of<DesignationAndWorkOffices>(context).workOffices;
    List<ReportingOfficer> _reportingOfficers =
        Provider.of<ReportingOfficers>(context).reportingOfficers;

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Form(
        key: _signupForm,
        child: Padding(
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
                    print("${LocaleKeys.password.tr()}: $value");
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
                    print("${LocaleKeys.cnf_pwd.tr()}: $value");
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

  Widget buildBottomHalfContainer(bool showShadow) {
    return Positioned(
      top: 460,
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
