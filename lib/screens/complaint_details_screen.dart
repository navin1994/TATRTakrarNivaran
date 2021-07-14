import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../config/palette.dart';
import '../translations/locale_keys.g.dart';
import '../models/comments.dart';
import '../models/complaint.dart';
import '../providers/complaints.dart';
import '../providers/auth.dart';
import '../widgets/saved_remarks.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  static const routeName = '/complaint-detail-screen';

  @override
  _ComplaintDetailsScreenState createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  // _isLoading is used to diaplay the circular progress indicator while screen is loading
  var _isLoading = false;
  // _rmrkSvFlag is used to save the user remarks to auto fill the remarks
  var _rmrkSvFlag = false;
  // _rmrkController used to store the remarks / comments while taking any action on complaint.
  TextEditingController _rmrkController = TextEditingController();

  // This method used to display the status of perticular complaint
  String _getStatus(String stat) {
    switch (stat) {
      case "NA":
        return LocaleKeys.pending.tr();
      case "A":
        return LocaleKeys.solved.tr();
      case "H":
        return LocaleKeys.on_hold.tr();
      case "C":
        return LocaleKeys.closed.tr();
      case "AH":
        return LocaleKeys.transfered.tr();
      default:
        return LocaleKeys.pending.tr();
    }
  }

// This method is used to give background color to complaint status based on it's status
  Color _getColor(String stat) {
    switch (stat) {
      case "NA":
        return Colors.yellow.shade400;
      case "A":
        return Colors.green.shade400;
      case "H":
        return Colors.orange.shade400;
      case "C":
        return Colors.red.shade400;
      case "AH":
        return Colors.purple.shade400;
      default:
        return Colors.yellow.shade400;
    }
  }

// This method is used to donwload the attachment of complaint using complaint id.
  Future<void> _donwloadAttchment(int cmplId) async {
    try {
      setState(() {
        // Show circular progress indicator
        _isLoading = true;
      });
      // Call the downloadAttachment() method inside of "Complaints" class.
      final resp = await Provider.of<Complaints>(context, listen: false)
          .downloadAttachment(cmplId);
      // Get the temporary directory store the file temporarily
      Directory tempDir = await getTemporaryDirectory();
      // Get the path of the directory
      String tempPath = tempDir.path;
      // Store the file returned from server to the file variable
      File file = new File('$tempPath/${resp['fileName']}');
      // Write file bytes to the storage
      await file.writeAsBytes(resp['fileBytes']);
      setState(() {
        // Remove the circular progress indicator and display the complaint screen again
        _isLoading = false;
      });
      // Open downloaded file
      OpenFile.open("$tempPath/${resp['fileName']}");
    } catch (error) {
      // Handle if any error occurs while file downloading
    }
  }

// This method displays the list of comments which mentioned while taking action of complait
  Future<void> showComments(BuildContext context, int cmpId) async {
    /// Get the comments on perticular complaint using complaint id
    final List<Comment> comments =
        await Provider.of<Complaints>(context, listen: false)
            .getComments(cmpId);

    /// If there is no comment return null
    return comments == null
        ? SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: LocaleKeys.error_while_loading_com.tr(),
            style: SweetAlertV2Style.error)
        : showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel:
                MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black45,
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (BuildContext buildContext, Animation animation,
                Animation secondaryAnimation) {
              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width - 10,
                  height: MediaQuery.of(context).size.height - 80,
                  padding: EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Material(
                          /// Display the list of comments
                          child: ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (ctx, index) => Column(
                              children: [
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 15, // 30 padding
                                        vertical: 5, // 5 top and bottom
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getColor(comments[index].value),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(22),
                                        ),
                                      ),
                                      child: Text(
                                        _getStatus(comments[index].value),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                ListTile(
                                  title: Text("${comments[index].text}"),
                                  subtitle: Text("${comments[index].no}"),
                                ),
                                Divider(
                                  height: 0.6,
                                  color: Colors.deepOrange,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Button to close the dialog
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            elevation: 12,
                            primary: Colors.red, // background
                            onPrimary: Colors.white,
                            textStyle: TextStyle(fontSize: 16)),
                        label: Text(LocaleKeys.close.tr()),
                        icon: Icon(Icons.highlight_remove_outlined),
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            });
  }

// This method displays dialog while taking any action on complaint
  Future<void> _displayDialog(
      BuildContext context, String heading, String stat, int cmpId) async {
    // _isShowRemarks used to show/hide the saved remarks list
    var _isShowRemarks = false;
    var errorFlag = false;
    _rmrkController.text = null;
    _setRemarks(String remark) {
      setState(() {
        _rmrkController.text = remark;
      });
      Navigator.pop(context);
      _displayDialog(context, heading, stat, cmpId);
    }

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: _isShowRemarks
                  ? Text(LocaleKeys.saved_remarks.tr())
                  : Text(heading),
              content: SingleChildScrollView(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 2000),
                  curve: Curves.fastOutSlowIn,
                  height: _isShowRemarks
                      ? MediaQuery.of(context).size.height * .70
                      : 200,
                  child: _isShowRemarks
                      ? SavedRemarks(_setRemarks)
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              if (errorFlag)
                                Text(
                                  "${LocaleKeys.please_enter_remarks.tr()}*",
                                  style: TextStyle(color: Colors.red),
                                ),

                              // the texfield is given to enter the remarks while acting on complaint
                              TextField(
                                maxLines: 5,
                                controller: _rmrkController,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Palette.textColor1),
                                      // borderRadius: BorderRadius.all(Radius.circular(35.0)),
                                    ),
                                    hintText: LocaleKeys.enter_remarks.tr()),
                              ),
                              // Checkbox to save entered remarks for future auto fill use
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rmrkSvFlag,
                                    onChanged: (bool value) => setState(() {
                                      _rmrkSvFlag = value;
                                    }),
                                  ),
                                  Text(LocaleKeys.save_remark.tr()),
                                ],
                              )
                            ],
                          ),
                        ),
                ),
              ),
              // actions contains the "Yes" and "No" button to act on complaint
              actions: <Widget>[
                if (_isShowRemarks)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        elevation: 12,
                        primary: Colors.red, // background
                        onPrimary: Colors.white,
                        textStyle: TextStyle(fontSize: 18)),
                    label: Text(LocaleKeys.back.tr()),
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _isShowRemarks = !_isShowRemarks;
                      });
                    },
                  ),
                if (!_isShowRemarks)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        elevation: 12,
                        primary: Colors.red, // background
                        onPrimary: Colors.white,
                        textStyle: TextStyle(fontSize: 18)),
                    label: Text(LocaleKeys.no.tr()),
                    icon: Icon(Icons.highlight_remove_outlined),
                    onPressed: () {
                      setState(() {
                        _rmrkController.text = null;
                        Navigator.pop(context);
                      });
                    },
                  ),
                if (!_isShowRemarks)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        elevation: 12,
                        primary: Colors.green, // background
                        onPrimary: Colors.white,
                        textStyle: TextStyle(fontSize: 18)),
                    label: Text(LocaleKeys.yes.tr()),
                    icon: Icon(Icons.check_circle_outline),
                    onPressed: () {
                      if (_rmrkController.text == null ||
                          _rmrkController.text.trim() == "") {
                        setState(() {
                          errorFlag = true;
                        });
                        return;
                      }
                      // Calling update status to update the status of complaint
                      updateStatus(
                          cmpId, stat, _rmrkController.text, _rmrkSvFlag);
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                if (!_isShowRemarks)
                  IconButton(
                    onPressed: () => setState(() {
                      _isShowRemarks = !_isShowRemarks;
                    }),
                    icon: Icon(
                      Icons.comment_bank_outlined,
                      color: Colors.orange[900],
                      size: 35,
                    ),
                  ),
              ],
            ),
          );
        });
  }

  // This method update the status of complaint Like "Transfer", "approved", etc.
  void updateStatus(
      int cmpId, String stat, String rmrk, bool rmrkSvFlag) async {
    setState(() {
      // Show circular progrss indicator
      _isLoading = true;
    });
    try {
      // Calling updateComplaint() method of Complaints class
      final resp = await Provider.of<Complaints>(context, listen: false)
          .updateComplaint(cmpId, stat, rmrk.trim(), rmrkSvFlag);

      setState(() {
        // Hide circular progrss indicator and display complaint screen
        _isLoading = false;
      });
      if (resp['Result'] == "OK") {
        // Navigating to the previous screen, Complaint management screen
        Navigator.of(context).pop();
        SweetAlertV2.show(context,
            title: "${LocaleKeys.updated.tr()}!",
            subtitle: resp['Msg'],
            style: SweetAlertV2Style.success);
      } else {
        SweetAlertV2.show(context,
            title: LocaleKeys.error.tr(),
            subtitle: resp['Msg'],
            style: SweetAlertV2Style.error);
      }
    } catch (error) {
      setState(() {
        // Hide circular progrss indicator and display complaint screen
        _isLoading = false;
      });
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_updating.tr(),
          style: SweetAlertV2Style.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get complaint Id from route arguments
    final cmpId =
        ModalRoute.of(context).settings.arguments as int; // is the id!
    // Fetch user id from Auth Provider Class
    final int _uid = Provider.of<Auth>(context).uid;
    // This method creates heading widget
    Widget _heading(String heading, Complaint campData) {
      return Container(
        // MediaQuery.of(context).size.width takes device width
        width: MediaQuery.of(context).size.width * 0.80, //80% of width,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            heading,
            style: TextStyle(fontSize: 16),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15, // 30 padding
              vertical: 5, // 5 top and bottom
            ),
            decoration: BoxDecoration(
              // Get background colour for complaint status
              color: _getColor(campData.stat),
              borderRadius: BorderRadius.all(
                Radius.circular(22),
              ),
            ),
            child: Text(
              // Get complaint status String
              _getStatus(campData.stat),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ]),
      );
    }

    // Retruns details card widget which contails all the available info about complaint
    Widget _detailsCard(Complaint campData) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4,
          child: Column(
            children: [
              //row for each deatails
              // display Complaint ID
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title:
                    Text("${LocaleKeys.complaint_id.tr()}: ${campData.cmpId}"),
              ),

              Divider(
                height: 0.6,
                color: Colors.black87,
              ),
              // display Complaint category
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title: Text("${LocaleKeys.category.tr()}: "),
                subtitle: Text("${campData.cmpCat}"),
              ),

              Divider(
                height: 0.6,
                color: Colors.black87,
              ),
              // display Complaint description
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title: Text("${LocaleKeys.desc.tr()}:"),
                subtitle: Text("${campData.desc}"),
              ),

              Divider(
                height: 0.6,
                color: Colors.black87,
              ),
              // display authority to whom complaint is assigned
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title: Text("${LocaleKeys.complaint_assign_to.tr()}:"),
                subtitle: Text("${campData.cmpAssignd}"),
              ),

              if (campData.cmpRcntRply != null)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),
              // display recent Comment on complaint if any
              if (campData.cmpRcntRply != null)
                ListTile(
                  leading: Icon(Icons.arrow_forward_ios),
                  title: Text("${LocaleKeys.reply.tr()}:"),
                  subtitle: Text("${campData.cmpRcntRply}"),
                ),
              if (campData.cmpRcntRply != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    child: Text(
                      "${LocaleKeys.history.tr()}...",
                      style: TextStyle(color: Colors.blue),
                    ),
                    // show all comments with action which taken on complait
                    onPressed: () => showComments(context, campData.cmpId),
                  ),
                ),

              Divider(
                height: 0.6,
                color: Colors.black87,
              ),
              // Complaint registration date
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title: Text("${LocaleKeys.date.tr()}"),
                subtitle: Text("${campData.regon}"),
              ),

              if (campData.cmpRjcnt != null && campData.cmpRjcnt > 0)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),
              // display count of how many times complaint is rejected
              if (campData.cmpRjcnt != null && campData.cmpRjcnt > 0)
                ListTile(
                  leading: Icon(Icons.arrow_forward_ios),
                  title: Text("${LocaleKeys.rejection_count.tr()}: "),
                  subtitle: Text("${campData.cmpRjcnt}"),
                ),
              if (campData.updton != null)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),
              // display last updated date on complaint
              if (campData.updton != null)
                ListTile(
                  leading: Icon(Icons.arrow_forward_ios),
                  title: Text("${LocaleKeys.updated_on.tr()}:"),
                  subtitle: Text("${campData.updton}"),
                ),
              if (campData.updtby != null)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),
              // Display name by whom complaint is last time updated
              if (campData.updtby != null)
                ListTile(
                  leading: Icon(Icons.arrow_forward_ios),
                  title: Text("${LocaleKeys.updated_by.tr()}: "),
                  subtitle: Text("${campData.updtby}"),
                ),

              if (campData.rmrk != null)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),
              // Display remarks on complaint
              if (campData.rmrk != null)
                ListTile(
                  leading: Icon(Icons.arrow_forward_ios),
                  title: Text("${LocaleKeys.remarks.tr()}:"),
                  subtitle: Text("${campData.rmrk}"),
                ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        centerTitle: true,
        title: Text(LocaleKeys.complaint_details.tr()),
        backgroundColor: Color(0xFF581845),
      ),
      body: FutureBuilder(
        // Future builder requests complaint by id
        future: Provider.of<Complaints>(context, listen: false).findById(cmpId),
        builder: (ctx, resultSnapshot) => resultSnapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                // Show Circular progree indicator untill request is in waiting state
                child: CircularProgressIndicator(),
              )
            : Consumer<Complaints>(
                // Fetch complaint data every time it's updated
                builder: (ctx, comp, _) => SafeArea(
                    child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (int.parse(comp.complaint.cmpInitBy) == _uid &&
                            comp.complaint.stat == "NA")
                          Container(
                            margin: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.80,
                            child: Text(
                              LocaleKeys.your_request_is.tr(),
                              style: TextStyle(color: Colors.red[400]),
                            ),
                          ),
                        if (int.parse(comp.complaint.cmpAssigndTo) == _uid &&
                            comp.complaint.stat != "NA" &&
                            comp.complaint.stat != "H")
                          Container(
                            margin: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.80,
                            child: Text(
                              LocaleKeys.you_have_already.tr(),
                              style: TextStyle(color: Colors.red[400]),
                            ),
                          ),
                        if (int.parse(comp.complaint.cmpAssigndTo) == _uid &&
                            comp.complaint.stat == "H")
                          Container(
                            margin: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.80,
                            child: Text(
                              LocaleKeys.you_have_put_on_hold.tr(),
                              style: TextStyle(color: Colors.red[400]),
                            ),
                          ),
                        Container(
                          margin: EdgeInsets.all(10),
                          width: MediaQuery.of(context).size.width * 0.80,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "${comp.complaint.regby}",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _heading(
                            '${LocaleKeys.compl_status.tr()}:', comp.complaint),
                        _detailsCard(comp.complaint),
                        SizedBox(
                          height: 10,
                        ),
                        if (comp.complaint.cmpisAttch == "Y")
                          _isLoading
                              ? Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    Text("${LocaleKeys.donwloading_file.tr()}"),
                                  ],
                                )
                              : TextButton.icon(
                                  // Button to donlaod any attachment with complaint
                                  onPressed: () =>
                                      _donwloadAttchment(comp.complaint.cmpId),
                                  style: TextButton.styleFrom(
                                    elevation: 10,
                                    backgroundColor: Colors.purple,
                                    primary: Colors.white,
                                    textStyle: TextStyle(fontSize: 14),
                                  ),
                                  icon: Icon(Icons.attachment_outlined),
                                  label: Text(
                                      '${LocaleKeys.donwload_attachment.tr()}'),
                                ),
                        if (int.parse(comp.complaint.cmpInitBy) == _uid &&
                            comp.complaint.stat == "AR")
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              elevation: 12,
                              primary: Colors.orange, // background
                              onPrimary: Colors.white, // foreground
                              textStyle: TextStyle(fontSize: 18),
                            ),
                            icon: Icon(Icons.reply),
                            label: Text("${LocaleKeys.reply.tr()}"),
                            onPressed: () => _displayDialog(
                                context,
                                LocaleKeys.do_you_want_to_reply.tr(),
                                "NA",
                                comp.complaint.cmpId),
                          ),
                        if (int.parse(comp.complaint.cmpInitBy) == _uid &&
                            comp.complaint.stat != "NA" &&
                            comp.complaint.stat != "H")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                // Button to re-open the complaint
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 12,
                                      primary: Colors.green, // background
                                      onPrimary: Colors.white,
                                      textStyle: TextStyle(fontSize: 18)),
                                  label: Text(LocaleKeys.reopen.tr()),
                                  icon: Icon(Icons.open_in_new_outlined),
                                  onPressed: () => _displayDialog(
                                      context,
                                      LocaleKeys.do_you_want_to_reopen.tr(),
                                      "RO",
                                      comp.complaint.cmpId),
                                ),
                              ),
                              // Button to close the complaint
                              Flexible(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 12,
                                    primary: Colors.red, // background
                                    onPrimary: Colors.white, // foreground
                                    textStyle: TextStyle(fontSize: 18),
                                  ),
                                  icon: Icon(Icons.close_fullscreen),
                                  label: Text(LocaleKeys.close.tr()),
                                  onPressed: () => _displayDialog(
                                      context,
                                      LocaleKeys.do_you_want_to_close.tr(),
                                      "C",
                                      comp.complaint.cmpId),
                                ),
                              ),
                            ],
                          ),
                        if (int.parse(comp.complaint.cmpAssigndTo) == _uid &&
                            (comp.complaint.stat == "NA" ||
                                comp.complaint.stat == "H"))
                          Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      // Button to approve the complaint
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 12,
                                            primary: Colors.green, // background
                                            onPrimary: Colors.white,
                                            textStyle: TextStyle(fontSize: 18)),
                                        label: Text(LocaleKeys.solve.tr()),
                                        icon: Icon(Icons.check_circle_outline),
                                        onPressed: () => _displayDialog(
                                            context,
                                            LocaleKeys.do_you_want_to_solve
                                                .tr(),
                                            "A",
                                            comp.complaint.cmpId),
                                      ),
                                    ),
                                    Flexible(
                                      // Button to reply the complaint
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 12,
                                          primary: Colors.orange, // background
                                          onPrimary: Colors.white, // foreground
                                          textStyle: TextStyle(fontSize: 18),
                                        ),
                                        icon: Icon(Icons.reply),
                                        label: Text("${LocaleKeys.reply.tr()}"),
                                        onPressed: () => _displayDialog(
                                            context,
                                            LocaleKeys.do_you_want_to_reply
                                                .tr(),
                                            "AR",
                                            comp.complaint.cmpId),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      // Button to transfer the complaint to higher authority
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 12,
                                          primary:
                                              Colors.teal[400], // background
                                          onPrimary: Colors.white, // foreground
                                          textStyle: TextStyle(fontSize: 18),
                                        ),
                                        icon: Icon(Icons.transform_outlined),
                                        label: Text(LocaleKeys
                                            .transfer_to_higher_authority
                                            .tr()),
                                        onPressed: () => _displayDialog(
                                            context,
                                            LocaleKeys.do_you_want_to_transfer
                                                .tr(),
                                            "AH",
                                            comp.complaint.cmpId),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      // Button to hold the complaint
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 12,
                                          primary:
                                              Colors.deepOrange, // background
                                          onPrimary: Colors.white, // foreground
                                          textStyle: TextStyle(fontSize: 18),
                                        ),
                                        icon: Icon(Icons.pause_circle_outline),
                                        label: Text(
                                            LocaleKeys.hold_the_complaint.tr()),
                                        onPressed: () => _displayDialog(
                                            context,
                                            LocaleKeys.do_you_want_to_hold.tr(),
                                            "H",
                                            comp.complaint.cmpId),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
              ),
      ),
    );
  }
}
