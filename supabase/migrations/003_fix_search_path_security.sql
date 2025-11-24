-- =========================================================================
-- MIGRATION 003: CORRECTION DES WARNINGS DE SÉCURITÉ SEARCH_PATH
-- Date: 9 Novembre 2025
-- Description: Ajout de SET search_path = '' aux 3 fonctions concernées
-- Ref: https://supabase.com/docs/guides/database/database-advisors?lint=0011_function_search_path_mutable
-- =========================================================================

-- -------------------------------------------------------------------------
-- FONCTION 1: get_country_code_from_coords
-- FIX: Ajouter SET search_path = '' et qualifier toutes les références
-- -------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_country_code_from_coords(coords geometry)
RETURNS text
LANGUAGE plpgsql
SET search_path = 'extensions, public'
AS $function$
DECLARE
  lat double precision;
  lon double precision;
BEGIN
  -- Extraire latitude et longitude avec qualification explicite
  lat := extensions.ST_Y(coords);
  lon := extensions.ST_X(coords);
  
  -- ===========================================
  -- PETITS PAYS/TERRITOIRES EN PREMIER (pour éviter les chevauchements)
  -- ===========================================
  
  -- Monaco
  IF lat BETWEEN 43.72 AND 43.76 AND lon BETWEEN 7.40 AND 7.44 THEN
    RETURN 'MC';
  END IF;
  
  -- Luxembourg
  IF lat BETWEEN 49.45 AND 50.18 AND lon BETWEEN 5.73 AND 6.53 THEN
    RETURN 'LU';
  END IF;
  
  -- Liechtenstein
  IF lat BETWEEN 47.05 AND 47.27 AND lon BETWEEN 9.47 AND 9.63 THEN
    RETURN 'LI';
  END IF;
  
  -- Andorre
  IF lat BETWEEN 42.43 AND 42.66 AND lon BETWEEN 1.41 AND 1.79 THEN
    RETURN 'AD';
  END IF;
  
  -- Saint-Marin
  IF lat BETWEEN 43.89 AND 43.99 AND lon BETWEEN 12.40 AND 12.52 THEN
    RETURN 'SM';
  END IF;
  
  -- Vatican
  IF lat BETWEEN 41.90 AND 41.91 AND lon BETWEEN 12.45 AND 12.46 THEN
    RETURN 'VA';
  END IF;
  
  -- Malte
  IF lat BETWEEN 35.80 AND 36.08 AND lon BETWEEN 14.18 AND 14.58 THEN
    RETURN 'MT';
  END IF;
  
  -- ===========================================
  -- DOM-TOM FRANÇAIS (territoires spécifiques)
  -- ===========================================
  
  -- Guadeloupe
  IF lat BETWEEN 15.83 AND 16.51 AND lon BETWEEN -61.81 AND -61.00 THEN
    RETURN 'GP';
  END IF;
  
  -- Martinique
  IF lat BETWEEN 14.39 AND 14.88 AND lon BETWEEN -61.23 AND -60.81 THEN
    RETURN 'MQ';
  END IF;
  
  -- Guyane française
  IF lat BETWEEN 2.11 AND 5.78 AND lon BETWEEN -54.60 AND -51.61 THEN
    RETURN 'GF';
  END IF;
  
  -- Réunion
  IF lat BETWEEN -21.39 AND -20.87 AND lon BETWEEN 55.22 AND 55.84 THEN
    RETURN 'RE';
  END IF;
  
  -- Mayotte
  IF lat BETWEEN -13.00 AND -12.64 AND lon BETWEEN 45.04 AND 45.30 THEN
    RETURN 'YT';
  END IF;
  
  -- Nouvelle-Calédonie
  IF lat BETWEEN -22.70 AND -20.00 AND lon BETWEEN 164.03 AND 167.00 THEN
    RETURN 'NC';
  END IF;
  
  -- Polynésie française (Tahiti, etc.)
  IF lat BETWEEN -27.93 AND -7.90 AND lon BETWEEN -154.70 AND -134.93 THEN
    RETURN 'PF';
  END IF;
  
  -- Saint-Pierre-et-Miquelon
  IF lat BETWEEN 46.75 AND 47.15 AND lon BETWEEN -56.40 AND -56.10 THEN
    RETURN 'PM';
  END IF;
  
  -- Wallis-et-Futuna
  IF lat BETWEEN -14.40 AND -13.15 AND lon BETWEEN -178.20 AND -176.10 THEN
    RETURN 'WF';
  END IF;
  
  -- Saint-Barthélemy
  IF lat BETWEEN 17.88 AND 17.97 AND lon BETWEEN -62.88 AND -62.78 THEN
    RETURN 'BL';
  END IF;
  
  -- Saint-Martin (partie française)
  IF lat BETWEEN 18.04 AND 18.13 AND lon BETWEEN -63.15 AND -63.00 THEN
    RETURN 'MF';
  END IF;
  
  -- ===========================================
  -- SUISSE (avant France/Allemagne/Italie)
  -- ===========================================
  
  IF lat BETWEEN 45.82 AND 47.81 AND lon BETWEEN 5.96 AND 10.49 THEN
    RETURN 'CH';
  END IF;
  
  -- ===========================================
  -- PAYS BENELUX
  -- ===========================================
  
  -- Belgique
  IF lat BETWEEN 49.50 AND 51.51 AND lon BETWEEN 2.54 AND 6.41 THEN
    RETURN 'BE';
  END IF;
  
  -- Pays-Bas
  IF lat BETWEEN 50.75 AND 53.55 AND lon BETWEEN 3.36 AND 7.23 THEN
    RETURN 'NL';
  END IF;
  
  -- ===========================================
  -- EUROPE DE L'OUEST
  -- ===========================================
  
  -- Portugal
  IF lat BETWEEN 36.96 AND 42.15 AND lon BETWEEN -9.50 AND -6.19 THEN
    RETURN 'PT';
  END IF;
  
  -- Espagne
  IF lat BETWEEN 36.00 AND 43.79 AND lon BETWEEN -9.30 AND 3.32 THEN
    RETURN 'ES';
  END IF;
  
  -- France métropolitaine (en dernier des pays francophones européens)
  IF lat BETWEEN 41.33 AND 51.09 AND lon BETWEEN -5.14 AND 9.56 THEN
    RETURN 'FR';
  END IF;
  
  -- Royaume-Uni
  IF lat BETWEEN 49.96 AND 60.86 AND lon BETWEEN -8.18 AND 1.76 THEN
    RETURN 'GB';
  END IF;
  
  -- Irlande
  IF lat BETWEEN 51.45 AND 55.43 AND lon BETWEEN -10.48 AND -5.99 THEN
    RETURN 'IE';
  END IF;
  
  -- Islande
  IF lat BETWEEN 63.30 AND 66.57 AND lon BETWEEN -24.54 AND -13.50 THEN
    RETURN 'IS';
  END IF;
  
  -- ===========================================
  -- EUROPE CENTRALE
  -- ===========================================
  
  -- Allemagne
  IF lat BETWEEN 47.27 AND 55.06 AND lon BETWEEN 5.87 AND 15.04 THEN
    RETURN 'DE';
  END IF;
  
  -- Autriche
  IF lat BETWEEN 46.37 AND 49.02 AND lon BETWEEN 9.53 AND 17.16 THEN
    RETURN 'AT';
  END IF;
  
  -- Pologne
  IF lat BETWEEN 49.00 AND 54.84 AND lon BETWEEN 14.12 AND 24.15 THEN
    RETURN 'PL';
  END IF;
  
  -- République tchèque
  IF lat BETWEEN 48.55 AND 51.06 AND lon BETWEEN 12.09 AND 18.86 THEN
    RETURN 'CZ';
  END IF;
  
  -- Slovaquie
  IF lat BETWEEN 47.73 AND 49.61 AND lon BETWEEN 16.83 AND 22.56 THEN
    RETURN 'SK';
  END IF;
  
  -- Hongrie
  IF lat BETWEEN 45.74 AND 48.58 AND lon BETWEEN 16.11 AND 22.90 THEN
    RETURN 'HU';
  END IF;
  
  -- ===========================================
  -- EUROPE DU SUD
  -- ===========================================
  
  -- Italie
  IF lat BETWEEN 36.65 AND 47.09 AND lon BETWEEN 6.63 AND 18.52 THEN
    RETURN 'IT';
  END IF;
  
  -- Grèce
  IF lat BETWEEN 34.80 AND 41.75 AND lon BETWEEN 19.37 AND 28.24 THEN
    RETURN 'GR';
  END IF;
  
  -- Croatie
  IF lat BETWEEN 42.39 AND 46.55 AND lon BETWEEN 13.49 AND 19.43 THEN
    RETURN 'HR';
  END IF;
  
  -- Slovénie
  IF lat BETWEEN 45.42 AND 46.88 AND lon BETWEEN 13.38 AND 16.61 THEN
    RETURN 'SI';
  END IF;
  
  -- Bosnie-Herzégovine
  IF lat BETWEEN 42.56 AND 45.27 AND lon BETWEEN 15.73 AND 19.62 THEN
    RETURN 'BA';
  END IF;
  
  -- Serbie
  IF lat BETWEEN 42.23 AND 46.19 AND lon BETWEEN 18.82 AND 23.00 THEN
    RETURN 'RS';
  END IF;
  
  -- Monténégro
  IF lat BETWEEN 41.85 AND 43.57 AND lon BETWEEN 18.43 AND 20.36 THEN
    RETURN 'ME';
  END IF;
  
  -- Albanie
  IF lat BETWEEN 39.65 AND 42.66 AND lon BETWEEN 19.26 AND 21.07 THEN
    RETURN 'AL';
  END IF;
  
  -- Macédoine du Nord
  IF lat BETWEEN 40.86 AND 42.36 AND lon BETWEEN 20.46 AND 23.04 THEN
    RETURN 'MK';
  END IF;
  
  -- Bulgarie
  IF lat BETWEEN 41.24 AND 44.22 AND lon BETWEEN 22.36 AND 28.61 THEN
    RETURN 'BG';
  END IF;
  
  -- Roumanie
  IF lat BETWEEN 43.62 AND 48.27 AND lon BETWEEN 20.26 AND 29.71 THEN
    RETURN 'RO';
  END IF;
  
  -- ===========================================
  -- EUROPE DU NORD
  -- ===========================================
  
  -- Norvège
  IF lat BETWEEN 57.98 AND 71.19 AND lon BETWEEN 4.65 AND 31.08 THEN
    RETURN 'NO';
  END IF;
  
  -- Suède
  IF lat BETWEEN 55.34 AND 69.06 AND lon BETWEEN 11.12 AND 24.17 THEN
    RETURN 'SE';
  END IF;
  
  -- Finlande
  IF lat BETWEEN 59.81 AND 70.09 AND lon BETWEEN 20.55 AND 31.59 THEN
    RETURN 'FI';
  END IF;
  
  -- Danemark
  IF lat BETWEEN 54.56 AND 57.75 AND lon BETWEEN 8.08 AND 15.19 THEN
    RETURN 'DK';
  END IF;
  
  -- Estonie
  IF lat BETWEEN 57.52 AND 59.68 AND lon BETWEEN 21.76 AND 28.21 THEN
    RETURN 'EE';
  END IF;
  
  -- Lettonie
  IF lat BETWEEN 55.68 AND 58.09 AND lon BETWEEN 20.97 AND 28.24 THEN
    RETURN 'LV';
  END IF;
  
  -- Lituanie
  IF lat BETWEEN 53.90 AND 56.45 AND lon BETWEEN 20.94 AND 26.84 THEN
    RETURN 'LT';
  END IF;
  
  -- ===========================================
  -- EUROPE DE L'EST
  -- ===========================================
  
  -- Russie (partie européenne)
  IF lat BETWEEN 41.19 AND 81.86 AND lon BETWEEN 19.64 AND 180.00 THEN
    RETURN 'RU';
  END IF;
  
  -- Ukraine
  IF lat BETWEEN 44.39 AND 52.38 AND lon BETWEEN 22.13 AND 40.23 THEN
    RETURN 'UA';
  END IF;
  
  -- Biélorussie
  IF lat BETWEEN 51.26 AND 56.17 AND lon BETWEEN 23.18 AND 32.77 THEN
    RETURN 'BY';
  END IF;
  
  -- Moldavie
  IF lat BETWEEN 45.47 AND 48.49 AND lon BETWEEN 26.62 AND 30.14 THEN
    RETURN 'MD';
  END IF;
  
  -- ===========================================
  -- AFRIQUE DU NORD
  -- ===========================================
  
  -- Maroc
  IF lat BETWEEN 27.66 AND 35.92 AND lon BETWEEN -13.17 AND -0.99 THEN
    RETURN 'MA';
  END IF;
  
  -- Algérie
  IF lat BETWEEN 18.96 AND 37.09 AND lon BETWEEN -8.67 AND 11.98 THEN
    RETURN 'DZ';
  END IF;
  
  -- Tunisie
  IF lat BETWEEN 30.24 AND 37.54 AND lon BETWEEN 7.52 AND 11.60 THEN
    RETURN 'TN';
  END IF;
  
  -- Libye
  IF lat BETWEEN 19.50 AND 33.17 AND lon BETWEEN 9.38 AND 25.15 THEN
    RETURN 'LY';
  END IF;
  
  -- Égypte
  IF lat BETWEEN 22.00 AND 31.67 AND lon BETWEEN 24.70 AND 36.89 THEN
    RETURN 'EG';
  END IF;
  
  -- ===========================================
  -- AMÉRIQUE DU NORD
  -- ===========================================
  
  -- États-Unis (continental + Alaska + Hawaii)
  -- Continental US
  IF lat BETWEEN 24.52 AND 49.38 AND lon BETWEEN -125.00 AND -66.95 THEN
    RETURN 'US';
  END IF;
  -- Alaska
  IF lat BETWEEN 51.21 AND 71.39 AND lon BETWEEN -179.15 AND -129.98 THEN
    RETURN 'US';
  END IF;
  -- Hawaii
  IF lat BETWEEN 18.91 AND 28.40 AND lon BETWEEN -178.33 AND -154.81 THEN
    RETURN 'US';
  END IF;
  
  -- Canada
  IF lat BETWEEN 41.68 AND 83.11 AND lon BETWEEN -141.00 AND -52.62 THEN
    RETURN 'CA';
  END IF;
  
  -- Mexique
  IF lat BETWEEN 14.53 AND 32.72 AND lon BETWEEN -118.45 AND -86.71 THEN
    RETURN 'MX';
  END IF;
  
  -- ===========================================
  -- AMÉRIQUE CENTRALE & CARAÏBES
  -- ===========================================
  
  -- Cuba
  IF lat BETWEEN 19.83 AND 23.19 AND lon BETWEEN -84.96 AND -74.13 THEN
    RETURN 'CU';
  END IF;
  
  -- Jamaïque
  IF lat BETWEEN 17.70 AND 18.53 AND lon BETWEEN -78.37 AND -76.18 THEN
    RETURN 'JM';
  END IF;
  
  -- République dominicaine
  IF lat BETWEEN 17.47 AND 19.93 AND lon BETWEEN -72.00 AND -68.32 THEN
    RETURN 'DO';
  END IF;
  
  -- Porto Rico
  IF lat BETWEEN 17.93 AND 18.52 AND lon BETWEEN -67.27 AND -65.59 THEN
    RETURN 'PR';
  END IF;
  
  -- ===========================================
  -- AMÉRIQUE DU SUD
  -- ===========================================
  
  -- Brésil
  IF lat BETWEEN -33.75 AND 5.27 AND lon BETWEEN -73.99 AND -34.79 THEN
    RETURN 'BR';
  END IF;
  
  -- Argentine
  IF lat BETWEEN -55.05 AND -21.78 AND lon BETWEEN -73.56 AND -53.64 THEN
    RETURN 'AR';
  END IF;
  
  -- Chili
  IF lat BETWEEN -55.98 AND -17.50 AND lon BETWEEN -109.45 AND -66.42 THEN
    RETURN 'CL';
  END IF;
  
  -- Pérou
  IF lat BETWEEN -18.35 AND -0.04 AND lon BETWEEN -81.33 AND -68.65 THEN
    RETURN 'PE';
  END IF;
  
  -- Colombie
  IF lat BETWEEN -4.23 AND 12.46 AND lon BETWEEN -79.02 AND -66.87 THEN
    RETURN 'CO';
  END IF;
  
  -- Venezuela
  IF lat BETWEEN 0.65 AND 12.20 AND lon BETWEEN -73.35 AND -59.80 THEN
    RETURN 'VE';
  END IF;
  
  -- Équateur
  IF lat BETWEEN -5.01 AND 1.45 AND lon BETWEEN -92.01 AND -75.19 THEN
    RETURN 'EC';
  END IF;
  
  -- ===========================================
  -- ASIE
  -- ===========================================
  
  -- Japon
  IF lat BETWEEN 24.04 AND 45.55 AND lon BETWEEN 122.93 AND 153.99 THEN
    RETURN 'JP';
  END IF;
  
  -- Chine
  IF lat BETWEEN 18.16 AND 53.56 AND lon BETWEEN 73.50 AND 135.09 THEN
    RETURN 'CN';
  END IF;
  
  -- Inde
  IF lat BETWEEN 6.75 AND 35.51 AND lon BETWEEN 68.18 AND 97.40 THEN
    RETURN 'IN';
  END IF;
  
  -- Corée du Sud
  IF lat BETWEEN 33.11 AND 38.61 AND lon BETWEEN 124.61 AND 131.87 THEN
    RETURN 'KR';
  END IF;
  
  -- Thaïlande
  IF lat BETWEEN 5.61 AND 20.46 AND lon BETWEEN 97.34 AND 105.64 THEN
    RETURN 'TH';
  END IF;
  
  -- Vietnam
  IF lat BETWEEN 8.56 AND 23.39 AND lon BETWEEN 102.14 AND 109.47 THEN
    RETURN 'VN';
  END IF;
  
  -- Indonésie
  IF lat BETWEEN -11.01 AND 6.08 AND lon BETWEEN 94.97 AND 141.02 THEN
    RETURN 'ID';
  END IF;
  
  -- Malaisie
  IF lat BETWEEN 0.85 AND 7.36 AND lon BETWEEN 99.64 AND 119.27 THEN
    RETURN 'MY';
  END IF;
  
  -- Singapour
  IF lat BETWEEN 1.16 AND 1.47 AND lon BETWEEN 103.61 AND 104.04 THEN
    RETURN 'SG';
  END IF;
  
  -- Philippines
  IF lat BETWEEN 4.64 AND 21.12 AND lon BETWEEN 116.93 AND 126.60 THEN
    RETURN 'PH';
  END IF;
  
  -- ===========================================
  -- MOYEN-ORIENT
  -- ===========================================
  
  -- Turquie
  IF lat BETWEEN 35.82 AND 42.11 AND lon BETWEEN 25.66 AND 44.83 THEN
    RETURN 'TR';
  END IF;
  
  -- Émirats arabes unis
  IF lat BETWEEN 22.63 AND 26.08 AND lon BETWEEN 51.58 AND 56.38 THEN
    RETURN 'AE';
  END IF;
  
  -- Arabie saoudite
  IF lat BETWEEN 16.38 AND 32.15 AND lon BETWEEN 34.57 AND 55.67 THEN
    RETURN 'SA';
  END IF;
  
  -- Israël
  IF lat BETWEEN 29.50 AND 33.34 AND lon BETWEEN 34.27 AND 35.88 THEN
    RETURN 'IL';
  END IF;
  
  -- Liban
  IF lat BETWEEN 33.05 AND 34.69 AND lon BETWEEN 35.10 AND 36.62 THEN
    RETURN 'LB';
  END IF;
  
  -- ===========================================
  -- OCÉANIE
  -- ===========================================
  
  -- Australie
  IF lat BETWEEN -43.63 AND -10.06 AND lon BETWEEN 113.16 AND 153.64 THEN
    RETURN 'AU';
  END IF;
  
  -- Nouvelle-Zélande
  IF lat BETWEEN -47.29 AND -34.39 AND lon BETWEEN 166.42 AND 178.58 THEN
    RETURN 'NZ';
  END IF;
  
  -- ===========================================
  -- AFRIQUE SUB-SAHARIENNE (sélection)
  -- ===========================================
  
  -- Afrique du Sud
  IF lat BETWEEN -34.84 AND -22.13 AND lon BETWEEN 16.46 AND 32.89 THEN
    RETURN 'ZA';
  END IF;
  
  -- Kenya
  IF lat BETWEEN -4.68 AND 5.03 AND lon BETWEEN 33.89 AND 41.90 THEN
    RETURN 'KE';
  END IF;
  
  -- Nigeria
  IF lat BETWEEN 4.27 AND 13.89 AND lon BETWEEN 2.69 AND 14.68 THEN
    RETURN 'NG';
  END IF;
  
  -- Si aucun pays détecté, retourner NULL
  RETURN NULL;
END;
$function$;

COMMENT ON FUNCTION public.get_country_code_from_coords(geometry) IS 
  'Détecte le code pays (ISO 3166-1 alpha-2) à partir de coordonnées GPS. SÉCURISÉ avec search_path fixe.';

-- -------------------------------------------------------------------------
-- FONCTION 2: auto_populate_location_country_code
-- FIX: Ajouter SET search_path = '' et qualifier toutes les références
-- -------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.auto_populate_location_country_code()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = 'extensions, public'
AS $function$
BEGIN
  -- Si location_country_code n'est pas défini et que location_coords existe
  IF (NEW.location_country_code IS NULL OR NEW.location_country_code = '') 
     AND NEW.location_coords IS NOT NULL THEN
    NEW.location_country_code := public.get_country_code_from_coords(NEW.location_coords);
  END IF;
  
  RETURN NEW;
END;
$function$;

COMMENT ON FUNCTION public.auto_populate_location_country_code() IS 
  'Trigger pour auto-peupler location_country_code dans professional_details. SÉCURISÉ avec search_path fixe.';

-- -------------------------------------------------------------------------
-- FONCTION 3: auto_populate_fixed_location_country_code
-- FIX: Ajouter SET search_path = '' et qualifier toutes les références
-- -------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.auto_populate_fixed_location_country_code()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = 'extensions, public'
AS $function$
BEGIN
  IF (NEW.location_country_code IS NULL OR NEW.location_country_code = '') 
     AND NEW.location_coords IS NOT NULL THEN
    NEW.location_country_code := public.get_country_code_from_coords(NEW.location_coords);
  END IF;
  RETURN NEW;
END;
$function$;

COMMENT ON FUNCTION public.auto_populate_fixed_location_country_code() IS 
  'Trigger pour auto-peupler location_country_code dans professional_fixed_locations. SÉCURISÉ avec search_path fixe.';

-- =========================================================================
-- VÉRIFICATIONS POST-MIGRATION
-- =========================================================================

DO $$
DECLARE
  v_count int;
BEGIN
  -- Vérifier que les 3 fonctions ont maintenant search_path défini
  SELECT COUNT(*) INTO v_count
  FROM pg_proc p
  JOIN pg_namespace n ON p.pronamespace = n.oid
  WHERE n.nspname = 'public'
    AND p.proname IN (
      'get_country_code_from_coords',
      'auto_populate_location_country_code',
      'auto_populate_fixed_location_country_code'
    )
    AND 'search_path' = ANY(proconfig);
  
  IF v_count = 3 THEN
    RAISE NOTICE '✅ Les 3 fonctions ont maintenant search_path défini';
  ELSE
    RAISE WARNING '⚠️  Seulement % fonction(s) sur 3 ont search_path défini', v_count;
  END IF;
END$$;

-- =========================================================================
-- FIN DE LA MIGRATION 003
-- =========================================================================

RAISE NOTICE '========================================';
RAISE NOTICE '✅ MIGRATION 003 APPLIQUÉE AVEC SUCCÈS';
RAISE NOTICE '========================================';
RAISE NOTICE 'Fonctions corrigées:';
RAISE NOTICE '1. get_country_code_from_coords';
RAISE NOTICE '2. auto_populate_location_country_code';
RAISE NOTICE '3. auto_populate_fixed_location_country_code';
RAISE NOTICE 'Toutes ont maintenant SET search_path = ''''';
RAISE NOTICE '========================================';
