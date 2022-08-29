
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

const Color kDarkGray = Color(0xFFA3A3A3);

class CustomDialog {
  static void show(context, String heading, String subHeading,
      String positiveButtonText, VoidCallback onPressedPositive,
      [String? negativeButtonText, VoidCallback? onPressedNegative]) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS-specific code
      showCupertinoDialog(
        context: context,
        useRootNavigator: false,
        builder: (_) => CupertinoAlertDialog(
          title: Text(
            heading,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            subHeading,
            style: TextStyle(
              color: kDarkGray,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                negativeButtonText ?? 'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            FlatButton(
              onPressed: onPressedPositive,
              child: Text(positiveButtonText),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        useRootNavigator: false,
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            heading,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            subHeading,
            style: TextStyle(
              color: kDarkGray,
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                if (onPressedNegative != null) {
                  onPressedNegative();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                negativeButtonText ?? 'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            FlatButton(
              onPressed: onPressedPositive,
              child: Text(positiveButtonText),
            ),
          ],
        ),
      );
    }
  }
}