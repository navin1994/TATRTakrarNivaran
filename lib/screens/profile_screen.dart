import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';

import '../translations/locale_keys.g.dart';
import '../models/profile.dart';
import '../widgets/app_drawer.dart';
import '../config/palette.dart';
import '../widgets/form_field.dart' as padding;
import '../widgets/change_password.dart';
import '../providers/auth.dart';

class ProfilePageScreen extends StatefulWidget {
  static const routeName = 'profile-page-screen';
  @override
  _ProfilePageScreenState createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  var _pwdchng = false;
  var _isLoading = false;
  var _isInit = true;
  bool _isEditable = false;
  final _profileForm = GlobalKey<FormState>();
  String fName, uMname, lName, email, mobile;

  void _toggleEdit() {
    setState(() {
      _isEditable = !_isEditable;
    });
  }

  void _togglePwdChange() {
    setState(() {
      _pwdchng = !_pwdchng;
    });
  }

  Future<void> getUserPrfile() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final resp = await Provider.of<Auth>(context, listen: false).getProfile();
      setState(() {
        _isLoading = false;
      });
      if (resp['Result'] != "OK") {
        SweetAlertV2.show(context,
            title: '${LocaleKeys.svd.tr()}!',
            subtitle: resp['Msg'],
            style: SweetAlertV2Style.success);
      }
    } catch (error) {
      print("Error ==> $error");
      if (error != null) {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_getting_prof.tr(),
            style: SweetAlertV2Style.error);
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (!_isInit) {
      return;
    }
    getUserPrfile();
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _submitUpdateProfileForm() async {
    final isValid = _profileForm.currentState
        .validate(); // this will trigger validator on each textFormField
    if (!isValid) {
      return;
    }
    _profileForm.currentState.save();
    try {
      setState(() {
        _isLoading = true;
      });
      final respo = await Provider.of<Auth>(context, listen: false)
          .updateProfile(fName, uMname, lName, mobile, email);
      setState(() {
        _isLoading = false;
      });
      print("Response ===> ${respo["Result"]}");
      if (respo["Result"] == "OK") {
        setState(() {
          _isEditable = false;
        });
        SweetAlertV2.show(context,
            title: "${LocaleKeys.svd.tr()}!",
            subtitle: respo['Msg'],
            style: SweetAlertV2Style.success);
      } else {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: respo['Msg'],
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      if (error != null) {
        print("Error ===> $error");
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_updating_prof.tr(),
            style: SweetAlertV2Style.error);
      }
    }
  }

  InputDecoration decoration({IconData icon, String hintText}) {
    return InputDecoration(
      labelText: hintText,
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
      // hintText: hintText,
      hintStyle: TextStyle(fontSize: 14, color: Palette.textColor1),
    );
  }

  dynamic dropdownBuilder(List<String> items) {
    return items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Profile profile =
        Provider.of<Auth>(context, listen: false).userProfile;
    Widget _heading(String heading) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.80, //80% of width,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            heading,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          if (_isEditable)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 12,
                primary: Colors.red, // background
                onPrimary: Colors.white, // foreground
              ),
              onPressed: _toggleEdit,
              icon: Icon(Icons.edit_off),
              label: Text(LocaleKeys.cancel.tr()),
            ),
          if (!_isEditable)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 12,
                primary: Colors.pink.shade300, // background
                onPrimary: Colors.white, // foreground
              ),
              onPressed: _toggleEdit,
              icon: Icon(Icons.edit),
              label: Text(LocaleKeys.edit.tr()),
            ),
        ]),
      );
    }

    Widget _detailsCard() {
      return Container(        
        height: MediaQuery.of(context).size.height * 0.80,        
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Form(
              key: _profileForm,
              child: Card(
                margin: const EdgeInsets.only(top: 15.0),
                color: Colors.transparent,
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_isEditable)
                        SizedBox(
                          height: 10,
                        ),
                      if (_isEditable)
                        padding.FormFieldWidget(
                          TextFormField(
                            initialValue: profile.uFname,
                            keyboardType: TextInputType.text,
                            decoration: decoration(
                                hintText: LocaleKeys.first_name.tr()),
                            onSaved: (firstName) {
                              setState(() {
                                fName = firstName;
                              });
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return LocaleKeys.please_enter_first_name.tr();
                              }
                              return null;
                            },
                          ),
                        ),
                      if (_isEditable)
                        padding.FormFieldWidget(
                          TextFormField(
                            initialValue: profile.uMname,
                            keyboardType: TextInputType.text,
                            decoration: decoration(
                                hintText: LocaleKeys.middle_name.tr()),
                            onSaved: (middleName) {
                              setState(() {
                                uMname = middleName;
                              });
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return LocaleKeys.please_enter_middle_name.tr();
                              }
                              return null;
                            },
                          ),
                        ),
                      if (_isEditable)
                        padding.FormFieldWidget(
                          TextFormField(
                            initialValue: profile.uLname,
                            keyboardType: TextInputType.text,
                            decoration:
                                decoration(hintText: LocaleKeys.last_name.tr()),
                            onSaved: (lastName) {
                              setState(() {
                                lName = lastName;
                              });
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return LocaleKeys.please_enter_last_name.tr();
                              }
                              return null;
                            },
                          ),
                        ),
                      if (!_isEditable)
                        ListTile(
                          leading: Icon(Icons.badge),
                          title: Text(
                              "${LocaleKeys.designation.tr()}: ${profile.uDesgNm}"),
                        ),
                      if (!_isEditable)
                        Divider(
                          height: 0.6,
                          color: Colors.black87,
                        ),
                      if (!_isEditable)
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                              "${LocaleKeys.sevarth_number.tr()}: ${profile.uSevarthNo}"),
                        ),
                      if (!_isEditable)
                        Divider(
                          height: 0.6,
                          color: Colors.black87,
                        ),
                      if (_isEditable)
                        padding.FormFieldWidget(
                          TextFormField(
                            initialValue: profile.uEmail,
                            keyboardType: TextInputType.text,
                            decoration:
                                decoration(hintText: LocaleKeys.email_id.tr()),
                            onSaved: (eMail) {
                              setState(() {
                                email = eMail;
                              });
                            },
                          ),
                        ),
                      if (!_isEditable)
                        ListTile(
                          leading: Icon(Icons.phone),
                          title: Text(
                              "${LocaleKeys.mobile_no.tr()}: ${profile.uMobile}"),
                        ),
                      if (!_isEditable)
                        Divider(
                          height: 0.6,
                          color: Colors.black87,
                        ),
                      if (_isEditable)
                        padding.FormFieldWidget(
                          TextFormField(
                            initialValue: profile.uMobile,
                            keyboardType: TextInputType.number,
                            decoration: decoration(
                                hintText: LocaleKeys.mobile_number.tr()),
                            onSaved: (mobileNo) {
                              setState(() {
                                mobile = mobileNo;
                              });
                            },
                            validator: (value) {
                              String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                              RegExp regExp = new RegExp(patttern);

                              if (!regExp.hasMatch(value) && value != null) {
                                return LocaleKeys.please_mobile_number.tr();
                              }
                              return null;
                            },
                          ),
                        ),
                      if (!_isEditable)
                        ListTile(
                          leading: Icon(Icons.email),
                          title: Text(
                              "${LocaleKeys.email_id.tr()}: ${profile.uEmail}"),
                        ),
                      if (!_isEditable)
                        Divider(
                          height: 0.6,
                          color: Colors.black87,
                        ),
                      if (!_isEditable)
                        ListTile(
                          leading: Icon(Icons.design_services_outlined),
                          title: Text(
                              "${LocaleKeys.work_office.tr()}: ${profile.uOfcNm}"),
                        ),
                      if (!_isEditable)
                        Divider(
                          height: 0.6,
                          color: Colors.black87,
                        ),
                      if (!_isEditable)
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                              "${LocaleKeys.reporting_to.tr()}: ${profile.uReportUNm}"),
                        ),
                      if (_isEditable)
                        SizedBox(
                          height: 10,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF581845),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color(0xFF581845),
        elevation: 0,
        centerTitle: true,
        title: Text(LocaleKeys.user_profile.tr()),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              bottom: false,
              child: Container(
                child: Column(
                  children: [
                    if (!_isEditable)
                      Container(
                        // margin: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: Center(
                          child: Text(
                            '${profile.uFname} ${profile.uMname} ${profile.uLname}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    if (!_pwdchng) _heading(LocaleKeys.user_profile.tr()),
                    Expanded(
                      child: Stack(
                        children: [
                          // Our background
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(top: 30),
                            decoration: BoxDecoration(
                              color: Color(0xFFF1EFF1),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height -
                                        270,
                                  ),
                                  if (!_isEditable && !_pwdchng)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 12,
                                        primary:
                                            Colors.pink.shade300, // background
                                        onPrimary: Colors.white, // foreground
                                      ),
                                      onPressed: _togglePwdChange,
                                      icon: Icon(Icons.vpn_key),
                                      label: _pwdchng
                                          ? Text(LocaleKeys.close.tr())
                                          : Text(
                                              LocaleKeys.change_password.tr()),
                                    ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (_isEditable)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Flexible(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                                elevation: 12,
                                                primary:
                                                    Colors.green, // background
                                                onPrimary: Colors.white,
                                                textStyle:
                                                    TextStyle(fontSize: 18)),
                                            label: Text(LocaleKeys.update.tr()),
                                            icon: Icon(
                                                Icons.check_circle_outline),
                                            onPressed: _submitUpdateProfileForm,
                                          ),
                                        ),
                                        Flexible(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 12,
                                              primary: Colors.red, // background
                                              onPrimary:
                                                  Colors.white, // foreground
                                              textStyle:
                                                  TextStyle(fontSize: 18),
                                            ),
                                            icon: Icon(Icons.cancel_outlined),
                                            label: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child:
                                                  Text(LocaleKeys.cancel.tr()),
                                            ),
                                            onPressed: _toggleEdit,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (!_pwdchng) _detailsCard(),
                          if (_pwdchng)
                            Container(
                              margin: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * .20),
                              child: ChangePassword(profile.uLoginId,
                                  decoration, _togglePwdChange),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
