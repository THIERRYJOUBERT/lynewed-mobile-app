// Automatic FlutterFlow imports
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
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}
