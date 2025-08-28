import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../domain/models/contact_model.dart';

class ContactsService {
  /// Request contact permission from user
  static Future<bool> requestContactPermission() async {
    return await FlutterContacts.requestPermission();
  }

  /// Check if contact permission is granted
  static Future<bool> hasContactPermission() async {
    return await FlutterContacts.requestPermission(readonly: true);
  }

  /// Get all contacts from device
  static Future<List<ContactModel>> getDeviceContacts() async {
    try {
      // Check permission first
      if (!await hasContactPermission()) {
        final granted = await requestContactPermission();
        if (!granted) {
          return [];
        }
      }

      // Get contacts from device using flutter_contacts
      final contacts = await FlutterContacts.getContacts(withProperties: true);

      // Convert to our ContactModel
      final List<ContactModel> contactModels = [];

      for (final contact in contacts) {
        // Skip contacts without phone numbers
        if (contact.phones.isEmpty) {
          continue;
        }

        // Get display name
        final displayName = contact.displayName.isNotEmpty
            ? contact.displayName
            : 'Unknown Contact';

        // Get all phone numbers for this contact
        for (final phone in contact.phones) {
          if (phone.number.isNotEmpty) {
            // Clean phone number (remove spaces, dashes, etc.)
            final cleanPhone = _cleanPhoneNumber(phone.number);

            if (cleanPhone.isNotEmpty) {
              contactModels.add(ContactModel(
                displayName: displayName,
                phoneNumber: cleanPhone,
                isRegistered: false, // Will be checked later
              ));
            }
          }
        }
      }

      // Remove duplicates and sort
      final uniqueContacts = <String, ContactModel>{};
      for (final contact in contactModels) {
        uniqueContacts[contact.phoneNumber] = contact;
      }

      final sortedContacts = uniqueContacts.values.toList();
      sortedContacts.sort((a, b) => a.displayName.compareTo(b.displayName));

      return sortedContacts;
    } catch (e) {
      print('Error getting contacts: $e');
      return [];
    }
  }

  /// Clean phone number by removing non-numeric characters except +
  static String _cleanPhoneNumber(String phone) {
    // Remove all characters except digits and +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it starts with + for international format
    if (cleaned.isNotEmpty && !cleaned.startsWith('+')) {
      // If it's a 10-digit number, assume it's US and add +1
      if (cleaned.length == 10) {
        cleaned = '+1$cleaned';
      }
      // If it's 11 digits starting with 1, add +
      else if (cleaned.length == 11 && cleaned.startsWith('1')) {
        cleaned = '+$cleaned';
      }
      // Otherwise, you might want to add your country code
      else if (cleaned.length >= 10) {
        // Add your default country code here if needed
        cleaned = '+91$cleaned'; // Example for India
      }
    }

    return cleaned;
  }

  /// Get mock contacts for testing (fallback)
  static List<ContactModel> getMockContacts() {
    return [
      const ContactModel(
        displayName: 'John Doe',
        phoneNumber: '+1234567890',
      ),
      const ContactModel(
        displayName: 'Jane Smith',
        phoneNumber: '+1987654321',
      ),
      const ContactModel(
        displayName: 'Bob Johnson',
        phoneNumber: '+1122334455',
      ),
      const ContactModel(
        displayName: 'Alice Brown',
        phoneNumber: '+1555666777',
      ),
      const ContactModel(
        displayName: 'Charlie Wilson',
        phoneNumber: '+1999888777',
      ),
      const ContactModel(
        displayName: 'Diana Prince',
        phoneNumber: '+1444555666',
      ),
      const ContactModel(
        displayName: 'Ethan Hunt',
        phoneNumber: '+1777888999',
      ),
      const ContactModel(
        displayName: 'Fiona Green',
        phoneNumber: '+1333444555',
      ),
    ];
  }
}
