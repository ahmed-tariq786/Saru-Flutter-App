import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

class ShowToast {
  void showErrorToast(String message) {
    toastification.show(
      closeOnClick: true,
      alignment: Alignment.bottomCenter,
      type: ToastificationType.error,
      closeButton: ToastCloseButton(),
      title: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
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
      title: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 12,
        ),
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
      title: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 12,
        ),
      ),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }
}
