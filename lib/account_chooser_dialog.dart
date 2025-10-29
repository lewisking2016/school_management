import 'package:flutter/material.dart';
import 'saved_account.dart';

/// A dialog that displays a list of previously used accounts for a provider.
///
/// Allows the user to select an existing account, add a new one, or close.
class AccountChooserDialog extends StatelessWidget {
  final List<SavedAccount> accounts;
  final String providerName; // e.g., "Google"

  const AccountChooserDialog({
    super.key,
    required this.accounts,
    required this.providerName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose an account',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('to continue to this app', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: account.photoUrl != null
                          ? NetworkImage(account.photoUrl!)
                          : null,
                      child: account.photoUrl == null
                          ? Text(account.displayName.substring(0, 1))
                          : null,
                    ),
                    title: Text(
                      account.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(account.email),
                    onTap: () {
                      // Return the selected account
                      Navigator.of(context).pop(account);
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person_add_outlined),
              title: const Text(
                'Use another account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Return a special value to indicate adding a new account
                Navigator.of(context).pop('add_new');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the account chooser dialog and returns the user's selection.
///
/// Returns a [SavedAccount] if one is selected, 'add_new' if the user
/// wants to add a new account, or null if the dialog is dismissed.
Future<dynamic> showAccountChooser(
  BuildContext context, {
  required List<SavedAccount> accounts,
  required String providerName,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AccountChooserDialog(
        accounts: accounts,
        providerName: providerName,
      );
    },
  );
}
