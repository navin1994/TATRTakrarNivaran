import 'package:complaint_management/providers/complaints.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';

import '../widgets/app_drawer.dart';
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
  Category _selCategory;
  List<PlatformFile> files;
  final _complaintForm = GlobalKey<FormState>();
  String _msg;
  var _isLoading = false;
  var _init = true;
  var _complaint = Complaint(cmpcatid: null, desc: "");

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
          .saveComplaint(_complaint, files != null ? files.first : files);
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
            title: "Saved!",
            subtitle: res['Msg'],
            style: SweetAlertV2Style.success);
      } else if (res['Result'] == "NOK") {
        SweetAlertV2.show(context,
            title: "Error",
            subtitle: res['Msg'],
            style: SweetAlertV2Style.error);
      } else {
        SweetAlertV2.show(context,
            title: "Error",
            subtitle: "Error while submit complaint.",
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (error != null) {
        print("Error while complaint form submission => $error");
        SweetAlertV2.show(context,
            title: "Error",
            subtitle: "Error while complaint submission.",
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
              title: "Error", subtitle: res, style: SweetAlertV2Style.error);
        }
      });
    } catch (error) {
      setState(() {
        _init = false;
        _isLoading = false;
      });
      print("Error $error");
      SweetAlertV2.show(context,
          title: "Error",
          subtitle: "Error while fetching categories",
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
        _msg = 'No File Selected';
      });
    }
    var index = result.files.indexWhere((file) => file.size > 2097152);
    if (index >= 0) {
      setState(() {
        files = null;
        _msg = 'Selected file size should be less than 2 MB';
      });
    }

    PlatformFile file = result.files.first;
    print(file.name);
    print(file.bytes);
    print(file.size);
    print(file.extension);
    print(file.path);
    setState(() {
      files = result.files;
      _msg = files.length == 1
          ? 'Single file selected'
          : '${files.length} Files are selected';
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
      child: Form(
        key: _complaintForm,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              padding.FormFieldWidget(
                DropdownButtonFormField<Category>(
                  value: _selCategory,
                  isExpanded: true,
                  decoration: decoration(hintText: 'Complaint Category'),
                  onSaved: (category) {
                    _complaint = Complaint(cmpcatid: category.hdid, desc: "");
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select complaint category.';
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
                  decoration: decoration(hintText: 'Description'),
                  onSaved: (description) {
                    _complaint = Complaint(
                        cmpcatid: _complaint.cmpcatid, desc: description);
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter description.';
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
                  child: Text("Upload Files"),
                  onPressed: _loadFiles,
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
                child: Text('Submit'),
                onPressed: _submitComplaint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Complaint"),
        centerTitle: true,
        brightness: Brightness.dark,
      ),
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
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      image: DecorationImage(
                          image: AssetImage(
                              "assets/images/background-waterfall.jpg"),
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
                            'Complaint Form',
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
