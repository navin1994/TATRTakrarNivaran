import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sweetalertv2/sweetalertv2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../translations/locale_keys.g.dart';
import '../models/comments.dart';
import '../models/complaint.dart';
import '../providers/complaints.dart';
import '../providers/auth.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  static const routeName = '/complaint-detail-screen';

  @override
  _ComplaintDetailsScreenState createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  var _isLoading = false;
  TextEditingController _rmrkController = TextEditingController();
  String _getStatus(String stat) {
    switch (stat) {
      case "NA":
        return LocaleKeys.pending.tr();
      case "A":
        return LocaleKeys.approved.tr();
      case "R":
        return LocaleKeys.rejected.tr();
      case "H":
        return LocaleKeys.on_hold.tr();
      case "C":
        return LocaleKeys.closed.tr();
      default:
        return LocaleKeys.rejected.tr();
    }
  }

  Future<void> _donwloadAttchment(int cmplId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final resp = await Provider.of<Complaints>(context, listen: false)
          .downloadAttachment(cmplId);
      print("Download ${resp['fileName']}");
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File file = new File('$tempPath/${resp['fileName']}');
      await file.writeAsBytes(resp['fileBytes']);
      setState(() {
        _isLoading = false;
      });
      OpenFile.open("$tempPath/${resp['fileName']}");
    } catch (error) {
      print("Error ==> $error");
    }
  }

  Future<void> showComments(BuildContext context, int cmpId) async {
    final List<Comment> comments =
        await Provider.of<Complaints>(context, listen: false)
            .getComments(cmpId);
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
                                        color:
                                            _getStatus(comments[index].value) ==
                                                    LocaleKeys.approved.tr()
                                                ? Colors.green.shade400
                                                : _getStatus(comments[index]
                                                            .value) ==
                                                        LocaleKeys.pending.tr()
                                                    ? Colors.yellow.shade400
                                                    : Colors.red.shade400,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(22),
                                        ),
                                      ),
                                      child: Text(
                                        _getStatus(comments[index].value),
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                                ListTile(
                                  title: Text("${comments[index].no}"),
                                  subtitle: Text("${comments[index].text}"),
                                ),
                                Divider(
                                  height: 0.6,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Future<void> _displayDialog(
      BuildContext context, String heading, String stat, int cmpId) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(heading),
            content: TextField(
              maxLines: 5,
              controller: _rmrkController,
              decoration:
                  InputDecoration(hintText: LocaleKeys.enter_remarks.tr()),
            ),
            actions: <Widget>[
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
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    elevation: 12,
                    primary: Colors.green, // background
                    onPrimary: Colors.white,
                    textStyle: TextStyle(fontSize: 18)),
                label: Text(LocaleKeys.yes.tr()),
                icon: Icon(Icons.check_circle_outline),
                onPressed: () {
                  updateStatus(cmpId, stat, _rmrkController.text);
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  void updateStatus(int cmpId, String stat, String rmrk) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final resp = await Provider.of<Complaints>(context, listen: false)
          .updateComplaint(cmpId, stat, rmrk);

      setState(() {
        _isLoading = false;
      });
      if (resp['Result'] == "OK") {
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
        _isLoading = false;
      });
      print("Error => $error");
      SweetAlertV2.show(context,
          title: LocaleKeys.error.tr(),
          subtitle: LocaleKeys.error_while_updating.tr(),
          style: SweetAlertV2Style.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cmpId =
        ModalRoute.of(context).settings.arguments as int; // is the id!
    final int _uid = Provider.of<Auth>(context).uid;
    Widget _heading(String heading, Complaint campData) {
      return Container(
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
              color: _getStatus(campData.stat) == LocaleKeys.approved.tr()
                  ? Colors.green.shade400
                  : _getStatus(campData.stat) == LocaleKeys.pending.tr()
                      ? Colors.yellow.shade400
                      : Colors.red.shade400,
              borderRadius: BorderRadius.all(
                Radius.circular(22),
              ),
            ),
            child: Text(
              _getStatus(campData.stat),
              style: TextStyle(color: Colors.black),
            ),
          ),
        ]),
      );
    }

    Widget _detailsCard(Complaint campData) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 4,
          child: Column(
            children: [
              //row for each deatails
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title:
                    Text("${LocaleKeys.complaint_id.tr()}: ${campData.cmpId}"),
              ),
              Divider(
                height: 0.6,
                color: Colors.black87,
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title: Text("${LocaleKeys.date.tr()}: ${campData.regon}"),
              ),

              Divider(
                height: 0.6,
                color: Colors.black87,
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title: Text("${LocaleKeys.category.tr()}: ${campData.cmpCat}"),
              ),
              Divider(
                height: 0.6,
                color: Colors.black87,
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title: Text("${LocaleKeys.desc.tr()}:"),
                subtitle: Text("${campData.desc}"),
              ),
              Divider(
                height: 0.6,
                color: Colors.black87,
              ),
              ListTile(
                leading: Icon(Icons.arrow_forward_ios),
                title: Text(
                    "${LocaleKeys.complaint_assign_to.tr()}: ${campData.cmpAssignd}"),
              ),

              if (campData.cmpRcntRply != null)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),
              if (campData.cmpRcntRply != null)
                ListTile(
                  leading: Icon(Icons.arrow_forward_ios),
                  title:
                      Text("${LocaleKeys.reply.tr()}: ${campData.cmpRcntRply}"),
                  trailing: TextButton(
                    onPressed: () => showComments(context, campData.cmpId),
                    child: Text(LocaleKeys.show_all.tr()),
                  ),
                ),
              if (campData.cmpRjcnt != null)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),
              if (campData.cmpRjcnt != null)
                ListTile(
                  leading: Icon(Icons.arrow_forward_ios),
                  title: Text(
                      "${LocaleKeys.rejection_count.tr()}: ${campData.cmpRjcnt}"),
                ),
              if (campData.updton != null)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),
              if (campData.updton != null)
                ListTile(
                  leading: Icon(Icons.arrow_forward_ios),
                  title:
                      Text("${LocaleKeys.updated_on.tr()}: ${campData.updton}"),
                ),
              if (campData.updtby != null)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),
              if (campData.updtby != null)
                ListTile(
                  leading: Icon(Icons.arrow_forward_ios),
                  title:
                      Text("${LocaleKeys.updated_by.tr()}: ${campData.updtby}"),
                ),

              if (campData.rmrk != null)
                Divider(
                  height: 0.6,
                  color: Colors.black87,
                ),

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
        future: Provider.of<Complaints>(context, listen: false).findById(cmpId),
        builder: (ctx, resultSnapshot) => resultSnapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<Complaints>(
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
                            comp.complaint.stat != "NA" &&
                            comp.complaint.stat != "H")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
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
                                      "NA",
                                      comp.complaint.cmpId),
                                ),
                              ),
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
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 12,
                                            primary: Colors.green, // background
                                            onPrimary: Colors.white,
                                            textStyle: TextStyle(fontSize: 18)),
                                        label: Text(LocaleKeys.apprv.tr()),
                                        icon: Icon(Icons.check_circle_outline),
                                        onPressed: () => _displayDialog(
                                            context,
                                            LocaleKeys.do_you_want_to_approve
                                                .tr()
                                                .tr(),
                                            "A",
                                            comp.complaint.cmpId),
                                      ),
                                    ),
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 12,
                                          primary: Colors.red, // background
                                          onPrimary: Colors.white, // foreground
                                          textStyle: TextStyle(fontSize: 18),
                                        ),
                                        icon: Icon(Icons.cancel_outlined),
                                        label: Text(LocaleKeys.reject.tr()),
                                        onPressed: () => _displayDialog(
                                            context,
                                            LocaleKeys.do_you_want_to_rejec
                                                .tr(),
                                            "R",
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
                              ],
                            ),
                          ),
                        if (int.parse(comp.complaint.cmpAssigndTo) == _uid &&
                            (comp.complaint.stat != "C" ||
                                comp.complaint.stat != "A" ||
                                comp.complaint.stat != "R"))
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 12,
                                      primary: Colors.deepOrange, // background
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
                          ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                )),
              ),
      ),
    );
  }
}
