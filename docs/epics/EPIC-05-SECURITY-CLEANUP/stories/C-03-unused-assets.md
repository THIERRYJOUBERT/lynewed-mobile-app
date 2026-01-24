# Story C-03: Purger Assets Non References

## Metadata
| Champ | Valeur |
|-------|--------|
| **ID** | C-03 |
| **Epic** | EPIC-05-SECURITY-CLEANUP |
| **Priorite** | P3 - BASSE |
| **Estimation** | 2h |
| **Statut** | NOT_STARTED |

---

## Description

En tant que **maintainer**, je veux purger les assets non references afin de **reduire la taille du build de l'application**.

---

## Contexte

L'audit initial a revele plusieurs problemes d'assets:

### Assets Vides avec Placeholders

| Dossier | Contenu | Taille |
|---------|---------|--------|
| `assets/audios/` | favicon.png (placeholder) | ~1KB |
| `assets/videos/` | favicon.png (placeholder) | ~1KB |
| `assets/jsons/` | favicon.png (placeholder) | ~1KB |
| `assets/pdfs/` | favicon.png (placeholder) | ~1KB |
| `assets/rive_animations/` | favicon.png (placeholder) | ~1KB |

### Images Potentiellement Non Utilisees

| Image | Fichier | Reference? |
|-------|---------|------------|
| Group_1000003014.png | `assets/images/` | A verifier |
| Group_5_(1).png | `assets/images/` | A verifier |
| Group_5.png | `assets/images/` | A verifier |
| 20240504_DOSMASENLAMESA_HT_AMALFI-438-BW.jpg | `assets/images/` | A verifier |
| 25df1c17bbc96fe7af61b08e009c452b_2.png | `assets/images/` | A verifier |
| SCR-20251017-jqhr.png | `assets/images/` | Screenshot test? |
| SCR-20251017-jpwd.png | `assets/images/` | Screenshot test? |
| Capture_decran_2025-07-27_a_21.48.21_5.png | `assets/images/` | Screenshot test? |

### Assets Utilises (Ne Pas Toucher)

| Image | Usage |
|-------|-------|
| app_launcher_icon.png | App icon |
| Splash_Screen.png | Splash screen |
| error_image.png | Fallback image |
| favicon.png | Web icon |
| DSC_0004-2_(1).png | Onboarding? |
| User_Story.png | Onboarding? |

---

## Criteres d'Acceptance

- [ ] Lister tous les assets dans `assets/`
- [ ] Pour chaque asset, verifier reference dans code
- [ ] Supprimer assets confirms non references
- [ ] Nettoyer pubspec.yaml si dossiers vides
- [ ] Build iOS/Android reussi
- [ ] Documentation des suppressions

---

## Checklist Cleanup

### Audit Assets Images
- [ ] `grep -r "Group_1000003014" lib/`
- [ ] `grep -r "Group_5" lib/`
- [ ] `grep -r "DOSMASENLAMESA" lib/`
- [ ] `grep -r "SCR-20251017" lib/`
- [ ] `grep -r "Capture_decran" lib/`

### Audit Dossiers Vides
- [ ] `assets/audios/` - Supprimer ou garder?
- [ ] `assets/videos/` - Supprimer ou garder?
- [ ] `assets/jsons/` - Supprimer ou garder?
- [ ] `assets/pdfs/` - Supprimer ou garder?
- [ ] `assets/rive_animations/` - Supprimer ou garder?

### Nettoyage pubspec.yaml
```yaml
# AVANT
assets:
  - .env
  - assets/fonts/
  - assets/images/
  - assets/videos/      # <-- Vide
  - assets/audios/      # <-- Vide
  - assets/rive_animations/  # <-- Vide
  - assets/pdfs/        # <-- Vide
  - assets/jsons/       # <-- Vide

# APRES (si supprimes)
assets:
  # Note: .env doit aussi etre retire (voir S-01)
  - assets/fonts/
  - assets/images/
```

---

## Implementation

### Script Detection Assets Non Utilises

```bash
#!/bin/bash
# find_unused_assets.sh

# Lister toutes les images
for img in assets/images/*; do
  filename=$(basename "$img")
  # Chercher reference dans code
  refs=$(grep -r "$filename" lib --include="*.dart" | wc -l)
  if [ "$refs" -eq 0 ]; then
    echo "UNUSED: $img"
  fi
done
```

### Verification Manuelle

Certains assets peuvent etre references:
- Via variables (`'assets/images/' + imageName`)
- Dans des fichiers JSON/config
- Dans du HTML (wed_articles?)

---

## Impact sur Taille Build

| Asset | Taille Estimee |
|-------|----------------|
| Images inutilisees | ~500KB-2MB |
| Dossiers vides | ~5KB |
| **Total potentiel** | **~2MB** |

---

## Risques

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Supprimer asset utilise dynamiquement | MOYEN | Tests E2E apres suppression |
| Image utilisee dans backend | BAS | Verifier wed_articles |

---

## Definition of Done

- [ ] Assets non utilises identifies
- [ ] Suppression effectuee
- [ ] pubspec.yaml nettoye
- [ ] Build iOS/Android reussi
- [ ] Documentation des suppressions
- [ ] PR reviewee et mergee
