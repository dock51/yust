import 'package:flutter/material.dart';
import 'package:yust/yust.dart';

typedef StringCallback = void Function(String);
typedef TabCallback = void Function();

class YustTextField extends StatefulWidget {
  final String? label;
  final String? value;
  final StringCallback? onChanged;

  /// if a validator is implemented, onEditingComplete gets only triggerd, if validator is true (true = returns null)
  final StringCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final TabCallback? onTab;
  final int? minLines;
  final bool readOnly;
  final bool enabled;
  final bool obscureText;
  final YustInputStyle? style;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final AutovalidateMode? autovalidateMode;

  YustTextField(
      {Key? key,
      this.label,
      this.value,
      this.onChanged,
      this.onEditingComplete,
      this.validator,
      this.onTab,
      this.minLines,
      this.enabled = true,
      this.readOnly = false,
      this.obscureText = false,
      this.style,
      this.prefixIcon,
      this.suffixIcon,
      this.textCapitalization = TextCapitalization.sentences,
      this.autovalidateMode})
      : super(key: key);

  @override
  _YustTextFieldState createState() => _YustTextFieldState();
}

class _YustTextFieldState extends State<YustTextField> {
  TextEditingController? _controller;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && widget.onEditingComplete != null) {
        var textFieldValue = _controller!.value.text.trim();
        if (widget.validator == null) {
          widget.onEditingComplete!(textFieldValue);
        } else if (widget.validator!(textFieldValue) == null) {
          widget.onEditingComplete!(textFieldValue);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller!.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.label,
        contentPadding: const EdgeInsets.all(20.0),
        border: widget.style == YustInputStyle.outlineBorder
            ? OutlineInputBorder()
            : null,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
      ),
      maxLines: widget.obscureText ? 1 : null,
      minLines: widget.minLines,
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: widget.minLines != null
          ? TextInputAction.newline
          : TextInputAction.next,
      onChanged: widget.onChanged == null
          ? null
          : (value) => widget.onChanged!(value.trim()),
      onTap: widget.onTab,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      obscureText: widget.obscureText,
      textCapitalization: widget.textCapitalization,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator == null
          ? null
          : (value) => widget.validator!(value!.trim()),
    );
  }
}
