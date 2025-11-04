// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<QueryFiltersStruct?> resetAndApplyDefaultFilters(
  BuildContext context,
  QueryFiltersStruct currentFilters,
) async {
  try {
    // 1. Crée un objet QueryFiltersStruct "par défaut".
    // Il récupère toutes les valeurs de l'enum Profession automatiquement.
    final defaultFilters = QueryFiltersStruct(
      // Toggles de visibilité: tous à true
      showPros: true,
      showProRecent: true,
      showFixedLocations: true,
      showBridePrivatePoi: true,
      showWeddingPins: true,
      showProAlerts: true,
      showOnlyMyProfessionPins: false, // Ce filtre reste spécifique
      // Professions: on prend la liste complète de l'enum.
      professions: Profession.values.toList(),
      // Budgets et localisation: remis à zéro (null).
      budgetMin: null,
      budgetMax: null,
      // On conserve la vue actuelle de la carte pour ne pas dézoomer/déplacer
      center: currentFilters.center,
      radiusKm: currentFilters.radiusKm,
      // Métadonnées
      currency: FFAppState().currentUserPreferences.currency,
      nearby: false,
    );

    // 2. Met à jour les préférences utilisateur avec ce filtre par défaut.
    final newFiltersJson = filtersToJsonString(defaultFilters);
    await saveUserPreferences(
      FFAppState().currentUserPreferences,
      newFiltersJson,
    );

    // Met à jour l'état de l'application localement.
    FFAppState().updateCurrentUserPreferencesStruct(
      (e) => e..lastFiltersJson = newFiltersJson,
    );

    // 3. Retourne le nouvel objet de filtres pour que l'UI puisse l'utiliser.
    return defaultFilters;
  } catch (e) {
    debugPrint('Error in resetAndApplyDefaultFilters: $e');
    return null; // Retourne null en cas d'erreur.
  }
}
