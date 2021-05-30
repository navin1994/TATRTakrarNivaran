import 'package:complaint_management/providers/complaints.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

import '../translations/locale_keys.g.dart';
import '../config/palette.dart';
import '../widgets/form_field.dart' as padding;
import '../providers/categories.dart';
import '../models/complaint.dart';
import '../models/category.dart';

class RaiseComplainScreen extends StatefulWidget {
  static const routeName = '/raise-complain';
  @override
  _RaiseComplainScreenState createState() => _RaiseComplainScreenState();
}

class _RaiseComplainScreenState extends State<RaiseComplainScreen> {
  String _imagePath;
  final picker = ImagePicker();
  Category _selCategory;
  List<PlatformFile> files;
  final _complaintForm = GlobalKey<FormState>();
  String _msg;
  var _isLoading = false;
  var _init = true;
  var _complaint = Complaint(cmpcatid: null, desc: "");

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        files = null;
        _imagePath = pickedFile.path;
        _msg = LocaleKeys.image_file_detected.tr();
      } else {
        _imagePath = null;
        _msg = LocaleKeys.image_file_not_detected.tr();
      }
    });
  }

  Future _submitComplaint() async {
    final isValid = _complaintForm.currentState.validate();
    if (!isValid) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    _complaintForm.currentState.save();

    try {
      final res = await Provider.of<Complaints>(context, listen: false)
          .saveComplaint(
              _complaint, files != null ? files.first.path : _imagePath);
      setState(() {
        _isLoading = false;
      });
      if (res['Result'] == "OK") {
        setState(() {
          _complaintForm.currentState?.reset();
          _selCategory = null;
          files = null;
        });
        SweetAlertV2.show(context,
            title: "${LocaleKeys.svd.tr()}!",
            subtitle: res['Msg'],
            style: SweetAlertV2Style.success);
      } else if (res['Result'] == "NOK") {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: res['Msg'],
            style: SweetAlertV2Style.error);
      } else {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_submit_com.tr(),
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (error != null) {
        print("Error while complaint form submission => $error");
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_complaint_sub.tr(),
            style: SweetAlertV2Style.error);
      }
    }
  }

  @override
  void didChangeDependencies() {
    if (!_init) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      Provider.of<Categories>(context, listen: false)
          .fetchAndSetCategories()
          .then((res) {
        setState(() {
          _init = false;
          _isLoading = false;
        });
        if (res != 0) {
          SweetAlertV2.show(context,
              title: LocaleKeys.error.tr(),
              subtitle: res,
              style: SweetAlertV2Style.error);
        }
      });
    } catch (error) {
      setState(() {
        _init = false;
        _isLoading = false;
      });
      print("Error $error");
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_fetching_cate.tr(),
          style: SweetAlertV2Style.error);
    }
    setState(() {
      _init = false;
      _isLoading = false;
    });
    super.didChangeDependencies();
  }

  Future<void> _loadFiles() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) {
      setState(() {
        files = null;
        _msg = LocaleKeys.no_file_selected.tr();
      });
    }
    var index = result.files.indexWhere((file) => file.size > 2097152);
    if (index >= 0) {
      setState(() {
        files = null;
        _msg = LocaleKeys.selected_file_size_.tr();
      });
    }

    PlatformFile file = result.files.first;
    print(file.name);
    print(file.bytes);
    print(file.size);
    print(file.extension);
    print(file.path);
    setState(() {
      _imagePath = null;
      files = result.files;
      _msg = files.length == 1
          ? LocaleKeys.single_file_selected.tr()
          : '${files.length} ${LocaleKeys.files_are_selected.tr()}';
    });
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
        borderRadius: BorderRadius.all(Radius.circular(22.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Palette.textColor1),
        borderRadius: BorderRadius.all(Radius.circular(22.0)),
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

  Container complaintFormSection() {
    final _categories = Provider.of<Categories>(context).categories;

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: SingleChildScrollView(
        child: Form(
          key: _complaintForm,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                padding.FormFieldWidget(
                  DropdownButtonFormField<Category>(
                    value: _selCategory,
                    isExpanded: true,
                    decoration: decoration(
                        hintText: LocaleKeys.complaint_category.tr()),
                    onSaved: (category) {
                      _complaint = Complaint(cmpcatid: category.hdid, desc: "");
                    },
                    validator: (value) {
                      if (value == null) {
                        return LocaleKeys.please_complaint_category.tr();
                      }
                      return null;
                    },
                    onChanged: (category) {
                      print('selected _complaintCategory $category');
                      setState(() {
                        _selCategory = category;
                      });
                    },
                    items: _categories
                        ?.map(
                          (cat) => new DropdownMenuItem(
                            child: new Text(cat.hdnm),
                            value: cat,
                          ),
                        )
                        ?.toList(),
                  ),
                ),
                padding.FormFieldWidget(
                  TextFormField(
                    maxLines: 5,
                    keyboardType: TextInputType.text,
                    decoration: decoration(hintText: LocaleKeys.desc.tr()),
                    onSaved: (description) {
                      _complaint = Complaint(
                          cmpcatid: _complaint.cmpcatid, desc: description);
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return LocaleKeys.please_enter_description.tr();
                      }
                      return null;
                    },
                  ),
                ),
                padding.FormFieldWidget(
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: files == null
                          ? Colors.grey
                          : Colors.purple, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    child: Text(LocaleKeys.upload_files.tr()),
                    onPressed: _loadFiles,
                  ),
                ),
                padding.FormFieldWidget(
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera),
                    style: ElevatedButton.styleFrom(
                      primary: _imagePath == null
                          ? Colors.grey
                          : Colors.purple, // background
                      onPrimary: Colors.white, // foreground
                    ),
                    label: Text(LocaleKeys.take_a_picture.tr()),
                    onPressed: getImage,
                  ),
                ),
                if (_msg != null) Center(child: Text(_msg)),
                padding.FormFieldWidget(SizedBox(height: 20)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green[600], // background
                      onPrimary: Colors.white,
                      textStyle: TextStyle(fontSize: 18) // foreground
                      ),
                  child: Text(LocaleKeys.submit.tr()),
                  onPressed: _submitComplaint,
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF035AA6),
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Color(0xFF035AA6),
        elevation: 0,
        centerTitle: true,
        title: Text(LocaleKeys.new_complaint.tr()),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : true
              ? SafeArea(
                  bottom: false,
                  child: Center(
                    child: Container(
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          .30),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF1EFF1),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              blurRadius: 15,
                                              spreadRadius: 5),
                                        ]),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Text(
                                            LocaleKeys.comlaint_form.tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Palette.activeColor),
                                          ),
                                          complaintFormSection(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              : Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          image: DecorationImage(
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.8),
                                  BlendMode.darken),
                              image: AssetImage("assets/images/bg3.jpg"),
                              fit: BoxFit.fill),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 800),
                      curve: Curves.bounceInOut,
                      top: MediaQuery.of(context).size.height * .2,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 800),
                        curve: Curves.bounceInOut,
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
                              Text(
                                LocaleKeys.comlaint_form.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Palette.activeColor),
                              ),
                              complaintFormSection(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
