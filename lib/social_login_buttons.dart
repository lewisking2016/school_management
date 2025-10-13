import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'loading_screen.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    showLoadingOverlay(context, text: 'Connecting to Google...');
    try {
      // 1. Create GoogleSignIn instance
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            '657011371867-eq0u90690r0vuna34lvqkd39i4netflc.apps.googleusercontent.com',
        scopes: ['email'],
      );

      // 2. Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (context.mounted) hideLoadingOverlay(context);
        // User canceled sign-in
        return;
      }

      // 3. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 4. Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // 5. Sign in to Firebase with the Google credentials
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // 6. Manually update the user's profile information in Firebase
      // This ensures the display name and photo are always up-to-date.
      final User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(googleUser.displayName);
        // Reload the user to get the updated profile information.
        await user.reload();
      }

      if (context.mounted) {
        hideLoadingOverlay(context);
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (context.mounted) {
        hideLoadingOverlay(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-in failed. Please try again.: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Image.asset(
              'assets/google_icon.png',
              height: 22, // Slightly smaller icon
              width: 22,
            ),
            label: const Text('Google', overflow: TextOverflow.ellipsis),

            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _signInWithGoogle(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: Image.asset(
              'assets/micro_icon.webp', // Corrected asset path
              height: 22,
              width: 22,
            ),
            label: const Text('Microsoft', overflow: TextOverflow.ellipsis),

            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              backgroundColor: const Color(0xFFF2F2F2),
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Microsoft sign-in coming soon...'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
