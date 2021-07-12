import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/complaints.dart';
import '../translations/locale_keys.g.dart';
import '../models/remark.dart';

class SavedRemarks extends StatefulWidget {
  final Function _setRemarks;
  SavedRemarks(this._setRemarks);
  @override
  _SavedRemarksState createState() => _SavedRemarksState();
}

class _SavedRemarksState extends State<SavedRemarks> {
  var _init = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() async {
    if (!_init) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    await Provider.of<Complaints>(context, listen: false).fetchSavedComments();
    setState(() {
      _init = false;
      _isLoading = false;
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        // height: 200,
        height: MediaQuery.of(context).size.height * .70,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _buildPanel(),
      ),
    );
  }

  Widget _buildPanel() {
    return Consumer<Complaints>(
      builder: (ctx, cmp, _) => cmp.savedRemarks.length == 0
          ? Center(child: Text(LocaleKeys.no_remarks_available.tr()))
          : ListView(
              children: [
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      cmp.savedRemarks[index].isExpanded = !isExpanded;
                    });
                  },
                  children:
                      cmp.savedRemarks.map<ExpansionPanel>((Remark remark) {
                    return ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: Text(remark.title),
                        );
                      },
                      body: Column(
                        children: [
                          Text(remark.remark),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    widget._setRemarks(remark.remark),
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Provider.of<Complaints>(
                                        context,
                                        listen: false)
                                    .deleteRemarkById(remark.id),
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isExpanded: remark.isExpanded,
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}
