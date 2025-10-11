import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      // 1. Create GoogleSignIn instance
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      // 2. Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled sign-in
        return;
      }

      // 3. Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          // ignore: await_only_futures
          await googleUser.authentication;

      // 4. Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // 5. Sign in to Firebase with the Google credentials
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google Sign-in failed. Please try again.'),
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
            label: const Flexible(
              child: Text('Google', overflow: TextOverflow.ellipsis),
            ),
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
            label: const Flexible(
              child: Text('Microsoft', overflow: TextOverflow.ellipsis),
            ),
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
