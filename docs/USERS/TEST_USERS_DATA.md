# Données de Test - Utilisateurs LYNEWED

**Document créé:** 2025-11-26  
**Objectif:** Documenter les 40 comptes de test créés avec succès  
**Environnement:** Supabase DEV (hekyovgnovhfhmkpfrna)  
**Statut:** ✅ Seeding complété avec succès

---

## 📋 Structure des Données Réelles

### Rôles et Types
- **BRIDE:** Mariées (10 utilisateurs)
- **PROFESSIONAL:** Professionnels (30 utilisateurs)
  - PHOTOGRAPHER (6), PLANNER (3), VENUE (4), FLORIST (4), MAKEUPARTIST (3), HAIRDRESSER (2), DESIGNER (2), FILMMAKER (2), BRIDALDESIGNER (1)

### Abonnements (Données Réelles du Seeding)
- **TRIAL:** Essai (4 utilisateurs - 13%)
- **PREMIUM_VISIBILITY:** Visibilité Premium (6 utilisateurs - 20%)  
- **ULTIMATE_ACCESS:** Accès Ultime (20 utilisateurs - 67%)

**Note:** La distribution réelle a été ajustée pour refléter un scénario plus réaliste avec plus d'utilisateurs Premium/Ultimate.

---

## 🔐 Accès aux Comptes de Test

### Mot de Passe Universel
**Tous les comptes:** `Test123456!`

### Identification Batch
Tous les utilisateurs identifiés par:
```sql
raw_user_meta_data->>'seed_batch' = 'production_40_users'
```

---

## 🌸 Comptes Brides Test

| Email | UUID | Nom Complet | Localisation |
|-------|------|-------------|--------------|
| emily.johnson.bride@test.com | d9a8eb59-c6ea-480b-b1ed-77acb1d52fe5 | Emily Johnson | |
| emma.thompson.bride@test.com | f31d7699-d73d-4917-8871-9189cac42158 | Emma Thompson | |
| fatima.almansoori.bride@test.com | 50eb55b8-af49-403d-8135-d7efa361ae9c | Fatima Al-Mansoori | |
| jessica.wilson.bride@test.com | 63306ef2-fa3d-4197-8178-27c1bc3e0cb7 | Jessica Wilson | |
| marie.martin.bride@test.com | cc949a0a-5b02-45d1-a2e8-61046b1f9297 | Marie Martin | Paris |
| olivia.taylor.bride@test.com | 105131f3-a1a8-432f-b262-fea9c9371b8b | Olivia Taylor | |
| sakura.yamamoto.bride@test.com | a2e84f86-2674-4972-b111-b40209325a9d | Sakura Yamamoto | |
| sarah.davis.bride@test.com | a02e6fb1-624c-4697-8f9b-f4e04459d361 | Sarah Davis | |
| sophie.dubois.bride@test.com | 87cb4fa9-b6b6-42ba-ac2d-712e713d2cef | Sophie Dubois | Paris |
| yuki.tanaka.bride@test.com | 264ebcaa-3ebe-4657-b059-c2fd0e38e335 | Yuki Tanaka | |

---

## 💼 Comptes Professionnels Test

### Ultimate Access (20)
| Email | UUID | Nom Complet | Profession | Localisation |
|-------|------|-------------|------------|--------------|
| ahmed.hassan.designer@test.com | fe7054b6-9675-445d-bee4-1f4b3a271876 | Ahmed Hassan | DESIGNER | Dubai |
| aiko.tanaka.florist@test.com | 41c32576-19a0-4067-adb2-0db21886424e | Aiko Tanaka | FLORIST | Tokyo |
| alexandre.moreau.venue@test.com | bdd629cc-0519-4d4a-a388-7dcf6384dc97 | Alexandre Moreau | VENUE | Paris |
| camille.roux.hair@test.com | 5d9f56b3-ed5e-4b51-8518-8e0da4e2aa32 | Camille Roux | HAIRDRESSER | Paris |
| david.kim.filmmaker@test.com | 56421e23-7073-425c-b62a-e1263efcccf7 | David Kim | FILMMAKER | New York |
| elizabeth.foster.makeup@test.com | d9c8dcfd-b8f1-48c1-969d-3712d3f01044 | Elizabeth Foster | MAKEUPARTIST | New York |
| emilie.moreau.florist@test.com | 0715505e-cedf-4a91-99a2-ba0ef75ccda3 | Émilie Moreau | FLORIST | Paris |
| hiroshi.sato.photo@test.com | 952c81f7-57ce-4349-9104-cc645261a5e9 | Hiroshi Sato | PHOTOGRAPHER | Tokyo |
| jack.miller.photo@test.com | 6cf96acf-ada3-4e2d-be41-c8f7868c8f2c | Jack Miller | PHOTOGRAPHER | New York |
| jennifer.liu.makeup@test.com | ac9465bd-b4da-48af-8560-61124d019e17 | Jennifer Liu | MAKEUPARTIST | New York |
| julien.girard.designer@test.com | ecf66422-4fd7-4fe3-8c2b-a526a040e122 | Julien Girard | DESIGNER | Paris |
| kenji.yamamoto.makeup@test.com | 87c335a3-1a2d-46ef-94ff-1c5232493c55 | Kenji Yamamoto | MAKEUPARTIST | Tokyo |
| layla.khalid.florist@test.com | df94190f-2f0b-4e55-887d-b2679a460b5d | Layla Khalid | FLORIST | Dubai |
| liam.wilson.venue@test.com | d9e70329-b55c-44d2-b456-474c1d12071a | Liam Wilson | VENUE | Sydney |
| marcus.thompson.hair@test.com | cc3c9a13-3a5f-48ff-ac88-a0f291f54830 | Marcus Thompson | HAIRDRESSER | New York |
| marie.dupont.photo@test.com | 0b82bc7d-08c3-4f9e-a4a4-c4ed0d4bbc26 | Marie Dupont | PHOTOGRAPHER | Paris |
| mohammed.alfahad.venue@test.com | aec7689e-ef69-476a-942a-3cc94efc1cd3 | Mohammed Al-Fahad | VENUE | Dubai |
| robert.martinez.photo@test.com | f948ea53-3e64-46d4-b298-3f05271976de | Robert Martinez | PHOTOGRAPHER | New York |
| william.davies.photo@test.com | 82989081-f73d-48a8-bd35-9dd151d50a32 | William Davies | PHOTOGRAPHER | New York |

### Premium Visibility (6)
| Email | UUID | Nom Complet | Profession | Localisation |
|-------|------|-------------|------------|--------------|
| isabelle.bernard.florist@test.com | 0e482d01-79d9-400e-aee0-5e639c3bdeda | Isabelle Bernard | FLORIST | Paris |
| laurent.dubois.planner@test.com | 8c0a9f89-2c46-428a-b7d2-52e324b9c4c2 | Laurent Dubois | PLANNER | Paris |
| nicolas.petit.makeup@test.com | ccdf41fa-bd19-4e93-ba1a-c550b510c1e3 | Nicolas Petit | MAKEUPARTIST | Paris |
| patricia.obrien.florist@test.com | 49d922ea-569e-4263-8f7e-5f647f164f4c | Patricia O'Brien | FLORIST | London |
| richard.clarke.venue@test.com | c301be47-d97e-4cbe-9059-5e18d6b1e4d3 | Richard Clarke | VENUE | London |
| sophie.laurent.bridal@test.com | 4ab9988a-bd22-485e-ba85-7c4a5d9d06fa | Sophie Laurent | BRIDALDESIGNER | London |

### Trial (4)
| Email | UUID | Nom Complet | Profession | Localisation |
|-------|------|-------------|------------|--------------|
| francois.bernard.venue@test.com | f9baac48-f008-4020-8029-17e36882c471 | François Bernard | VENUE | Versailles |
| michael.rodriguez.venue@test.com | 0c7e7732-ea65-41a6-8710-93e1fdbabf20 | Michael Rodriguez | VENUE | |
| pierre.chenier.photo@test.com | b0866b55-ee69-4795-a3cf-df5e859ab9ed | Pierre Chenier | PHOTOGRAPHER | |
| thomas.leroy.photo@test.com | adea40fd-0fb4-4ddf-be3f-a4e734c4de19 | Thomas Leroy | PHOTOGRAPHER | Paris |

---

## 🎯 Scénarios de Test Disponibles

### Test de Base
- **Email:** `marie.martin.bride@test.com` | **UUID:** `cc949a0a-5b02-45d1-a2e8-61046b1f9297`
- **Email:** `pierre.chenier.photo@test.com` | **UUID:** `b0866b55-ee69-4795-a3cf-df5e859ab9ed`

### Test par Abonnement
- **Ultimate:** `hiroshi.sato.photo@test.com`
- **Premium:** `laurent.dubois.planner@test.com`
- **Trial:** `francois.bernard.venue@test.com`

### Test par Localisation
- **Paris:** `marie.martin.bride@test.com`, `pierre.chenier.photo@test.com`
- **New York:** `david.kim.filmmaker@test.com`, `jack.miller.photo@test.com`
- **Tokyo:** `hiroshi.sato.photo@test.com`, `kenji.yamamoto.makeup@test.com`
- **Dubai:** `ahmed.hassan.designer@test.com`, `mohammed.alfahad.venue@test.com`

---

## 📊 Statistiques du Seeding

| Table | Enregistrements | Détails |
|-------|----------------|---------|
| `auth.users` | 40 | 10 brides + 30 professionnels |
| `profiles` | 40 | Créés automatiquement par trigger |
| `bride_details` | 10 | Un par bride |
| `professional_details` | 30 | Un par professionnel |
| `professional_subscriptions` | 30 | 20 Ultimate + 6 Premium + 4 Trial |
| `wedding_pins` | 10 | Un par bride |
| `wishlist_items` | 29 | Favoris brides→professionnels |
| `chat_rooms` | 15 | Salons de conversation |
| `connection_requests` | 10 | Demandes de connexion |
| `video_sessions` | 8 | Sessions vidéo |

---

*Document généré après le seeding Supabase V1 réussi*