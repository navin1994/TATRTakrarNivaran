import 'package:flutter/material.dart';
import 'package:foldable_sidebar/foldable_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:swipedetector/swipedetector.dart';

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
  FSBStatus drawerStatus;
  // _pwdchng used to hide or show password change screen
  var _pwdchng = false;
  //  _isLoading used to show circular progress indicator while loading the data on screen
  var _isLoading = false;
  // _init is used to control the didChangeDependencies() methods executions
  var _isInit = true;
  // _isEditable is used to show or hide profile update form fields
  bool _isEditable = false;
  final _profileForm = GlobalKey<FormState>();
  // variables to store data for profile update
  String fName, uMname, lName, email, mobile;

// _toggleEdit() method is to toggle between profile update form fields and profile details
  void _toggleEdit() {
    setState(() {
      _isEditable = !_isEditable;
    });
  }

// _togglePwdChange() method to toggle between profile details and password form
  void _togglePwdChange() {
    setState(() {
      _pwdchng = !_pwdchng;
    });
  }

  void _toggleAppDrawer() {
    setState(() {
      drawerStatus = drawerStatus == FSBStatus.FSB_OPEN
          ? FSBStatus.FSB_CLOSE
          : FSBStatus.FSB_OPEN;
    });
  }

// getUserPrfile() method to get the logged in user profile details
  Future<void> getUserPrfile() async {
    try {
      setState(() {
        // Set true to show circular progress indicator while fetching data from server
        _isLoading = true;
      });
      //  call getProfile() method of Auth provider class
      final resp = await Provider.of<Auth>(context, listen: false).getProfile();
      setState(() {
        // Set false to hide circular progress indicator data fetched from server
        _isLoading = false;
      });
      if (resp['Result'] != "OK") {
        // Show message if any error occurs while getting user profile details
        SweetAlertV2.show(context,
            title: '${LocaleKeys.svd.tr()}!',
            subtitle: resp['Msg'],
            style: SweetAlertV2Style.success);
      }
    } catch (error) {
      if (error != null) {
        // Show message if any error occurs while getting user profile details
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
    // Call  getUserPrfile() to get logged in user profiel for first time
    getUserPrfile();
    _isInit = false;
    super.didChangeDependencies();
  }

// _submitUpdateProfileForm() to update the user profile details
  Future<void> _submitUpdateProfileForm() async {
    final isValid = _profileForm.currentState
        .validate(); // this will trigger validator on each textFormField
    if (!isValid) {
      // Stop execution if profile form is invalid
      return;
    }
    _profileForm.currentState.save(); // Trigger save on profile form fields
    try {
      setState(() {
        //  Set false to hide circular progress indicator
        _isLoading = true;
      });
      // call updateProfile() methode of Auth provider class
      final respo = await Provider.of<Auth>(context, listen: false)
          .updateProfile(fName, uMname, lName, mobile, email);
      setState(() {
        //  Set false to hide circular progress indicator
        _isLoading = false;
      });
      if (respo["Result"] == "OK") {
        setState(() {
          // Set false to hide profiel form fields
          _isEditable = false;
        });
        // Show sucess message on update of profile
        SweetAlertV2.show(context,
            title: "${LocaleKeys.svd.tr()}!",
            subtitle: respo['Msg'],
            style: SweetAlertV2Style.success);
      } else {
//  Show message if any error occures while updating the profile
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: respo['Msg'],
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      if (error != null) {
//  Show message if any error occures while updating the profile
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_updating_prof.tr(),
            style: SweetAlertV2Style.error);
      }
    }
  }

// decoration() method to decorate the form fields
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

// dropdownBuilder() to set dropdon values in dropdown
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
    // Get fetched user profile data from Auth provder class
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
          // if (_isEditable)
          // Button to toggle between profile form fields and profile details
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              elevation: 12,
              primary:
                  _isEditable ? Colors.red : Colors.pink.shade300, // background
              onPrimary: Colors.white, // foreground
            ),
            onPressed: _toggleEdit,
            icon: _isEditable ? Icon(Icons.edit_off) : Icon(Icons.edit),
            label: _isEditable
                ? Text(LocaleKeys.cancel.tr())
                : Text(LocaleKeys.edit.tr()),
          ),
          // if (!_isEditable)
          // Button to toggle between profile form fields and profile details
          // ElevatedButton.icon(
          //   style: ElevatedButton.styleFrom(
          //     elevation: 12,
          //     primary: , // background
          //     onPrimary: Colors.white, // foreground
          //   ),
          //   onPressed: _toggleEdit,
          //   icon: ,
          //   label: ,
          // ),
        ]),
      );
    }

    //  _detailsCard() method to show profile details and update profile form fields
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
                      if (_isEditable)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Flexible(
                              // Button to submit or update the profile details
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    elevation: 12,
                                    primary: Colors.green, // background
                                    onPrimary: Colors.white,
                                    textStyle: TextStyle(fontSize: 18)),
                                label: Text(LocaleKeys.update.tr()),
                                icon: Icon(Icons.check_circle_outline),
                                onPressed: _submitUpdateProfileForm,
                              ),
                            ),
                            Flexible(
                              // Button to toggle view between update profile form and profile details
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  elevation: 12,
                                  primary: Colors.red, // background
                                  onPrimary: Colors.white, // foreground
                                  textStyle: TextStyle(fontSize: 18),
                                ),
                                icon: Icon(Icons.cancel_outlined),
                                label: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(LocaleKeys.cancel.tr()),
                                ),
                                onPressed: _toggleEdit,
                              ),
                            ),
                          ],
                        ),
                      if (!_isEditable)
                        SizedBox(
                          height: 20,
                        ),
                      if (!_isEditable && !_pwdchng)
                        // Button to toggle between password change form and Profile details
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            elevation: 12,
                            primary: Colors.pink.shade300, // background
                            onPrimary: Colors.white, // foreground
                          ),
                          onPressed: _togglePwdChange,
                          icon: Icon(Icons.vpn_key),
                          label: _pwdchng
                              ? Text(LocaleKeys.close.tr())
                              : Text(LocaleKeys.change_password.tr()),
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
        leading:
            IconButton(onPressed: _toggleAppDrawer, icon: Icon(Icons.menu)),
        title: Text(LocaleKeys.user_profile.tr()),
      ),
      // Side Navigation drower
      // drawer: AppDrawer(),
      body: SwipeDetector(
        onSwipeLeft: _toggleAppDrawer,
        onSwipeRight: _toggleAppDrawer,
        child: FoldableSidebarBuilder(
          drawerBackgroundColor: Color(0xFF581845),
          status: drawerStatus,
          drawer: AppDrawer(
            closeDrawer: () {
              setState(() {
                drawerStatus = FSBStatus.FSB_CLOSE;
              });
            },
          ),
          screenContents: _isLoading
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
                            width: MediaQuery.of(context).size.width * 0.80,
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
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.only(top: 30),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF1EFF1),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40),
                                  ),
                                ),
                              ),
                              if (!_pwdchng) _detailsCard(),
                              if (_pwdchng)
                                Container(
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          .20),
                                  //  Change password widget
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
        ),
      ),
    );
  }
}
