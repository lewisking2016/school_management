import 'package:shared_preferences/shared_preferences.dart';
import 'saved_account.dart';

/// A service to manage storing and retrieving saved user accounts
/// from the device's local storage.
class AccountStorageService {
  static const _googleKey = 'google_accounts';
  static const _microsoftKey = 'microsoft_accounts';

  /// Saves a user account to local storage.
  ///
  /// It avoids duplicates by checking the email and provider.
  static Future<void> saveAccount(SavedAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    final key = account.providerId == 'google.com' ? _googleKey : _microsoftKey;

    final accounts = await getAccounts(account.providerId);
    // Avoid adding duplicate accounts
    if (!accounts.any((a) => a.email == account.email)) {
      accounts.add(account);
      final accountStrings = accounts.map((a) => a.toJsonString()).toList();
      await prefs.setStringList(key, accountStrings);
    }
  }

  /// Retrieves a list of saved accounts for a specific provider.
  static Future<List<SavedAccount>> getAccounts(String providerId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = providerId == 'google.com' ? _googleKey : _microsoftKey;

    final accountStrings = prefs.getStringList(key) ?? [];
    return accountStrings.map((s) => SavedAccount.fromJsonString(s)).toList();
  }

  /// Clears all saved accounts for a specific provider.
  static Future<void> clearAccounts(String providerId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = providerId == 'google.com' ? _googleKey : _microsoftKey;
    await prefs.remove(key);
  }
}
