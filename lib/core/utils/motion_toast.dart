import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';

class ToastUtils {
  static void showSuccessToast(
    BuildContext context, {
    required String title,
    required String description,
    MotionToastPosition position = MotionToastPosition.top,
  }) {
    MotionToast(
      icon: Icons.check_circle,
      secondaryColor: Colors.white,
      primaryColor: Colors.green,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(
        description,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
      position: position,
      animationType: position == MotionToastPosition.top
          ? AnimationType.slideInFromTop
          : AnimationType.slideInFromBottom,
      height: 80,
      width: 300,
      constraints: const BoxConstraints(maxWidth: 400),
    ).show(context);
  }

  static void showErrorToast(
    BuildContext context, {
    required String title,
    required String description,
    MotionToastPosition position = MotionToastPosition.top,
  }) {
    MotionToast(
      icon: Icons.error_outline,
      primaryColor: Colors.red,
      barrierColor: Colors.black,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(description),
      position: position,
      animationType: position == MotionToastPosition.top
          ? AnimationType.slideInFromTop
          : AnimationType.slideInFromBottom,
      height: 80,
      width: 300,
      constraints: const BoxConstraints(maxWidth: 300),
    ).show(context);
  }

  static void showWarningToast(
    BuildContext context, {
    required String title,
    required String description,
    MotionToastPosition position = MotionToastPosition.top,
  }) {
    MotionToast(
      icon: Icons.warning_amber,
      primaryColor: Colors.orange,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(description),
      position: position,
      animationType: position == MotionToastPosition.top
          ? AnimationType.slideInFromTop
          : AnimationType.slideInFromBottom,
      height: 80,
      width: 300,
      constraints: const BoxConstraints(maxWidth: 300),
    ).show(context);
  }

  static void showInfoToast(
    BuildContext context, {
    required String title,
    required String description,
    double? animationDuration,
    MotionToastPosition position = MotionToastPosition.top,
  }) {
    MotionToast(
      toastDuration: Duration(seconds: animationDuration!.toInt()),
      icon: Icons.info_outline,
      primaryColor: Colors.blue,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(description),
      position: position,
      animationType: position == MotionToastPosition.top
          ? AnimationType.slideInFromTop
          : AnimationType.slideInFromBottom,
      height: 80,
      width: 300,
      constraints: const BoxConstraints(maxWidth: 300),
    ).show(context);
  }

  static void showDeleteToast(
    BuildContext context, {
    required String title,
    required String description,
    Alignment position = Alignment.topCenter,
  }) {
    MotionToast(
      icon: Icons.delete_outline,
      primaryColor: Colors.red,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(description),
      toastAlignment: position,
      animationType: position == MotionToastPosition.top
          ? AnimationType.slideInFromTop
          : AnimationType.slideInFromBottom,
      height: 80,
      width: 300,
      constraints: const BoxConstraints(maxWidth: 300),
    ).show(context);
  }

  // Custom toast with more options
  static void showCustomToast(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color primaryColor,
    MotionToastPosition position = MotionToastPosition.top,
    AnimationType animationType = AnimationType.slideInFromTop,
    Duration? duration,
  }) {
    MotionToast(
      icon: icon,
      primaryColor: primaryColor,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(description),
      position: position,
      animationType: animationType,
      height: 80,
      width: 300,
      constraints: const BoxConstraints(maxWidth: 300),
      animationDuration: duration ?? const Duration(seconds: 3),
    ).show(context);
  }
}
