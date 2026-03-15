import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

InputDecoration Deco(
  String? label,
  Icon? prefixIcon,
  Widget? suffixIcon, {
  String? hintText,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: const BorderSide(color: Colors.red, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 18, 45, 141),
        width: 1.0,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),

      borderSide: const BorderSide(
        color: Color.fromARGB(255, 203, 6, 6),
        width: 2.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),

      borderSide: const BorderSide(
        color: Color.fromARGB(255, 91, 87, 90),
        width: 1.0,
      ),
    ),
  );
}
