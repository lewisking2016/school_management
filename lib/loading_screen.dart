import 'package:flutter/material.dart';

/// Shows a branded, full-screen loading overlay.
///
/// This is used to block the UI and show progress during async operations
/// like signing in or registering a user.
void showLoadingOverlay(
  BuildContext context, {
  String text = 'Please wait...',
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/stawi_logo.png', height: 100),
                  const SizedBox(height: 24),
                  Text(text, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Hides the currently displayed loading overlay.
void hideLoadingOverlay(BuildContext context) => Navigator.of(context).pop();
