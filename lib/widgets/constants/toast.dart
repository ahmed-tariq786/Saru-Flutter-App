import 'package:flutter/material.dart';
import 'package:saru/widgets/constants/my_text.dart';
import 'package:toastification/toastification.dart';

class ShowToast {
  void showErrorToast(String message) {
    toastification.show(
      closeOnClick: true,
      alignment: Alignment.bottomCenter,
      type: ToastificationType.error,
      closeButton: ToastCloseButton(),
      title: myText(
        message,
        12,
        FontWeight.w300,
        Colors.black,
        TextAlign.left,
      ),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void showSuccessToast(String message) {
    toastification.show(
      closeOnClick: true,
      alignment: Alignment.bottomCenter,
      type: ToastificationType.success,
      closeButton: ToastCloseButton(),
      title: myText(
        message,
        12,
        FontWeight.w300,
        Colors.black,
        TextAlign.left,
      ),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  void showInfoToast(String message) {
    toastification.show(
      closeOnClick: true,
      alignment: Alignment.bottomCenter,
      closeButton: ToastCloseButton(),
      type: ToastificationType.info,
      title: myText(
        message,
        12,
        FontWeight.w300,
        Colors.black,
        TextAlign.left,
      ),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
