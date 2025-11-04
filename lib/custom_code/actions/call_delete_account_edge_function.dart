// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
// N'oublie pas d'ajouter 'http: ^1.2.0' dans les dépendances pubspec !

Future<bool> callDeleteAccountEdgeFunction() async {
  try {
    // Utiliser directement l'API Supabase pour appeler l'Edge Function
    final response = await SupaFlow.client.functions.invoke(
      'account_delete',
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.status == 200) {
      debugPrint('Account deletion successful.');
      return true;
    } else {
      debugPrint(
          'Failed to delete account. Status: ${response.status}, Data: ${response.data}');
      return false;
    }
  } catch (e) {
    debugPrint('Exception caught while calling delete account function: $e');
    return false;
  }
}
