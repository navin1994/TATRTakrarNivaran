import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/complaints.dart';
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
  // _imagePath is used to store the selected image path
  String _imagePath;
  // Create Instance of Image picker
  final picker = ImagePicker();
  // _selCategory used to store the current complaint category
  Category _selCategory;
  // files stores the list of multiple selected files
  List<PlatformFile> files;
  final _complaintForm = GlobalKey<FormState>();
  // _msg used to display the message if file is picked or not
  String _msg;
  // _isLoading used to show the progress indicator after complaint is submitted
  var _isLoading = false;
  // _init is used to control the didChangeDependencies() methods executions
  var _init = true;
  // _complaint used to store the new complaint data
  var _complaint = Complaint(cmpcatid: null, desc: "");
// getImage() method get image through device camera
  Future getImage() async {
    // Here image source is camera
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        // files set to null if there is any image taken from camera
        files = null;
        // Set image path of clicked image by camera
        _imagePath = pickedFile.path;
        // Set message to display image file selected or not
        _msg = LocaleKeys.image_file_detected.tr();
      } else {
        // This is the case if camera is opened but image is not taken
        _imagePath = null;
        _msg = LocaleKeys.image_file_not_detected.tr();
      }
    });
  }

// _submitComplaint() method to submit new complaint
  Future _submitComplaint() async {
    final isValid = _complaintForm.currentState
        .validate(); // Trigger validation on complaint form fields
    if (!isValid) {
      // Stop execution if complaint form is invalid
      return;
    }
    setState(() {
      // Set true to show progress indicator while saving complaint
      _isLoading = true;
    });
    _complaintForm.currentState
        .save(); // Triggers save on complaint form fields

    try {
      // call saveComplaint() of Complaints provider class
      final res = await Provider.of<Complaints>(context, listen: false)
          .saveComplaint(
              _complaint, files != null ? files.first.path : _imagePath);
      setState(() {
        // Set false to hide circular progress indicator and display complaint form
        _isLoading = false;
      });
      if (res['Result'] == "OK") {
        // Reset the variables and complaint form if complaint is successfully saved
        setState(() {
          _complaintForm.currentState?.reset();
          _selCategory = null;
          files = null;
        });
        // Show success message on complaint saved
        SweetAlertV2.show(context,
            title: "${LocaleKeys.svd.tr()}!",
            subtitle: res['Msg'],
            style: SweetAlertV2Style.success);
      } else if (res['Result'] == "NOK") {
        // Show message if any error occurs while saving complaint
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: res['Msg'],
            style: SweetAlertV2Style.error);
      } else {
        // Show message if any error occurs while saving complaint
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_submit_com.tr(),
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        // Set false to hide circular progress indicator and display complaint form
        _isLoading = false;
      });
      if (error != null) {
        // Show message if any error occurs while saving new complaint
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
      // call fetchAndSetCategories() method of Categories provider class
      Provider.of<Categories>(context, listen: false)
          .fetchAndSetCategories()
          .then((res) {
        setState(() {
          _init = false;
          _isLoading = false;
        });
        if (res != 0) {
          // Show message if any error occurs while fetching complaint categories
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
      // Show message if any error occurs while fetching complaint categories
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

  //  _loadFiles() is used to provide the file selection
  Future<void> _loadFiles() async {
    // result stores the selected files
    FilePickerResult result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) {
      setState(() {
        // files set to null if file picker is open but file is not selected
        files = null;
        // Set message to display if file picker is open but file is not selected
        _msg = LocaleKeys.no_file_selected.tr();
      });
    }
    var index = result.files.indexWhere((file) =>
        file.size >
        2097152); // Selected fiel size should not be greater than 2 MB
    if (index >= 0) {
      setState(() {
        // Set files to null if any file found greater than 2 MB
        files = null;
        // Set message if any file found greater than 2 MB
        _msg = LocaleKeys.selected_file_size_.tr();
      });
    }

    setState(() {
      // Set _imagePath to null to remove the image clicked by camera
      _imagePath = null;
      // Store selected files picked by file picker
      files = result.files;
      // Set mesage to show count of selected files
      _msg = files.length == 1
          ? LocaleKeys.single_file_selected.tr()
          : '${files.length} ${LocaleKeys.files_are_selected.tr()}';
    });
  }

// decoration() method to set decoration to complaint form fields
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

// dropdownBuilder() method to set list of items in dropdown field
  dynamic dropdownBuilder(List<String> items) {
    return items.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

// complaintFormSection() method contains the complaint form fields and buttons
  Container complaintFormSection() {
    // Get fetched complaint categories from Categories provider class
    final _categories = Provider.of<Categories>(context).categories;

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: SingleChildScrollView(
        child: Form(
          key: _complaintForm,
          child: Padding(
            padding: EdgeInsets.only(
                // Padding to avoid the screen overflow if kaypad is opened
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
                  // Button to open file picker for file selection
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
                  // Button to open take image by camera
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
                // Button to submit the complaint form
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
            : SafeArea(
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
                                  width: MediaQuery.of(context).size.width - 40,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
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
                )));
  }
}
