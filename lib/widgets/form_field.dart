import 'package:flutter/material.dart';

class FormFieldWidget extends StatefulWidget {
  final Widget formFieldWidget;

  FormFieldWidget(this.formFieldWidget);

  @override
  _FormFieldWidgetState createState() => _FormFieldWidgetState();
}

class _FormFieldWidgetState extends State<FormFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: widget.formFieldWidget,
    );
  }
}
