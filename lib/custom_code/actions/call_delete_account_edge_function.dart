// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
// N'oublie pas d'ajouter 'http: ^1.2.0' dans les dépendances pubspec !
import 'dart:convert';

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
      print('Account deletion successful.');
      return true;
    } else {
      print(
          'Failed to delete account. Status: ${response.status}, Data: ${response.data}');
      return false;
    }
  } catch (e) {
    print('Exception caught while calling delete account function: $e');
    return false;
  }
}
