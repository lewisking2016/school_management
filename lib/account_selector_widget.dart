import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:school_management/loading_screen.dart';
import 'package:school_management/saved_account.dart';
import 'package:school_management/account_storage_service.dart';
import 'package:school_management/account_chooser_dialog.dart';

/// A unified widget for handling different authentication methods.
///
/// This widget provides buttons for signing in with Google and Microsoft,
/// ensuring that the user is always prompted to select an account, which is
/// ideal for multi-user environments.
class AccountSelectorWidget extends StatefulWidget {
  const AccountSelectorWidget({super.key});

  @override
  State<AccountSelectorWidget> createState() => _AccountSelectorWidgetState();
}

class _AccountSelectorWidgetState extends State<AccountSelectorWidget> {
  /// Initiates the Google Sign-In flow, showing an account chooser if needed.
  Future<void> _handleGoogleSignIn() async {
    final savedAccounts = await AccountStorageService.getAccounts('google.com');

    if (savedAccounts.isNotEmpty && mounted) {
      final selection = await showAccountChooser(
        context,
        accounts: savedAccounts,
        providerName: 'Google',
      );

      if (selection is SavedAccount) {
        // User selected a previously saved account.
        await _signInWithGoogle();
      } else if (selection == 'add_new') {
        await _signInWithGoogle();
      }
    } else {
      await _signInWithGoogle();
    }
  }

  /// Handles the Google Sign-In process.
  Future<void> _signInWithGoogle() async {
    showLoadingOverlay(context, text: 'Connecting to Google...');
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '657011371867-eq0u90690r0vuna34lvqkd39i4netflc.apps.googleusercontent.com',
        scopes: ['email'],
      );

      // Always disconnect to force the account chooser popup.
      // This ensures the user can always select which account to use.
      await googleSignIn.disconnect();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // ignore: use_build_context_synchronously
        if (context.mounted) hideLoadingOverlay(context);
        return; // User canceled the sign-in.
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Manually update profile to ensure it's fresh.
      final User? user = userCredential.user;
      if (user != null) {
        // Save the account for future use
        final savedAccount = SavedAccount(
          providerId: 'google.com',
          email: user.email!,
          displayName: user.displayName ?? 'Google User',
          photoUrl: user.photoURL,
        );
        await AccountStorageService.saveAccount(savedAccount);

        // Update profile
        await user.updateDisplayName(googleUser.displayName);
        await user.reload();
      }

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        hideLoadingOverlay(context);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        hideLoadingOverlay(context);
        // ignore: use_build_context_synchronously
        _showErrorSnackbar(context, 'Google Sign-in failed. Please try again.');
      }
    }
  }

  /// Initiates the Microsoft Sign-In flow, showing an account chooser if needed.
  Future<void> _handleMicrosoftSignIn() async {
    final savedAccounts = await AccountStorageService.getAccounts(
      'microsoft.com',
    );

    if (savedAccounts.isNotEmpty && mounted) {
      final selection = await showAccountChooser(
        context,
        accounts: savedAccounts,
        providerName: 'Microsoft',
      );

      if (selection is SavedAccount) {
        // User selected a previously saved account.
        await _signInWithMicrosoft(loginHint: selection.email);
      } else if (selection == 'add_new') {
        await _signInWithMicrosoft(forceNew: true);
      }
    } else {
      await _signInWithMicrosoft(forceNew: true);
    }
  }

  /// Handles the Microsoft Sign-In process.
  Future<void> _signInWithMicrosoft({
    bool forceNew = false,
    String? loginHint,
  }) async {
    showLoadingOverlay(context, text: 'Connecting to Microsoft...');
    try {
      final provider = MicrosoftAuthProvider();
      provider.setCustomParameters({
        'tenant': 'e4e32b55-027c-4d94-986b-1f2a460f295e',
        if (loginHint != null) 'login_hint': loginHint,
      });

      if (forceNew) {
        // Sign out to ensure the account selection prompt is shown.
        await FirebaseAuth.instance.signOut();
      }

      final UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        userCredential = await FirebaseAuth.instance.signInWithProvider(
          provider,
        );
      }

      final User? user = userCredential.user;

      if (!context.mounted) return;

      if (user != null) {
        // Save the account for future use
        final savedAccount = SavedAccount(
          providerId: 'microsoft.com',
          email: user.email!,
          displayName: user.displayName ?? 'Microsoft User',
          photoUrl: user.photoURL,
        );
        await AccountStorageService.saveAccount(savedAccount);

        // ignore: use_build_context_synchronously
        hideLoadingOverlay(context);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/dashboard');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Welcome, ${user.displayName ?? 'User'}!'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        hideLoadingOverlay(context);
        _showErrorSnackbar(
          // ignore: use_build_context_synchronously
          context,
          'Microsoft Sign-in failed. Please try again.',
        );
      }
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade600,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {},
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Image.asset(
                  'assets/google_icon.png',
                  height: 22,
                  width: 22,
                ),
                label: const Text('Google', overflow: TextOverflow.ellipsis),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleGoogleSignIn,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: Image.asset(
                  'assets/micro_icon.webp',
                  height: 22,
                  width: 22,
                ),
                label: const Text('Microsoft', overflow: TextOverflow.ellipsis),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  backgroundColor: const Color(0xFFF2F2F2),
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleMicrosoftSignIn,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
