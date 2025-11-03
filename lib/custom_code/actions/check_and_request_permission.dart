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

import 'package:permission_handler/permission_handler.dart';
import '/backend/schema/enums/enums.dart'; // N'oubliez pas cet import pour votre Enum

Future<String> checkAndRequestPermission(
    PermissionType permissionTypeEnum) async {
  Permission permission;

  // 1. Fait correspondre notre Enum FlutterFlow à l'objet Permission du package.
  switch (permissionTypeEnum) {
    case PermissionType.LOCATION:
      permission = Permission.location;
      break;
    case PermissionType.CAMERA:
      permission = Permission.camera;
      break;
    case PermissionType.PHOTOS:
      // Le package gère les différences entre iOS (photos) et Android (storage/media).
      permission = Permission.photos;
      break;
    case PermissionType.MICROPHONE:
      permission = Permission.microphone;
      break;
    case PermissionType.NOTIFICATIONS:
      permission = Permission.notification;
      break;
    default:
      // Retourne une erreur si un type non supporté est passé.
      return 'unsupported';
  }

  // 2. Logique corrigée : demande AVANT de vérifier permanentlyDenied
  var status = await permission.status;

  // Étape a : Si déjà accordée, retourner immédiatement
  if (status.isGranted || status.isLimited) {
    return 'granted';
  }

  // Étape b : Si denied (première fois), demander la permission
  if (status.isDenied) {
    // Étape c : Déclencher la demande système et attendre la réponse
    var newStatus = await permission.request();

    // Étape d : Ré-évaluer le statut après la réponse utilisateur
    if (newStatus.isGranted || newStatus.isLimited) {
      return 'granted';
    } else if (newStatus.isPermanentlyDenied) {
      // Étape e : SEULEMENT maintenant, si refusé définitivement, ouvrir les paramètres
      await openAppSettings();
      return 'permanently_denied';
    } else {
      // L'utilisateur a refusé mais peut encore être redemandé
      return 'denied';
    }
  }

  // Étape e : Si déjà permanentlyDenied ou restricted (sans avoir demandé)
  // Cela arrive si l'utilisateur a refusé plusieurs fois auparavant
  if (status.isPermanentlyDenied || status.isRestricted) {
    await openAppSettings();
    return 'permanently_denied';
  }

  // Cas par défaut (ne devrait pas arriver)
  return 'denied';
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
