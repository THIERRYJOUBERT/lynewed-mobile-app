-- ========================================
-- LYNEWED-V1-APP: SEEDING COMPLET 40 UTILISATEURS
-- Schéma réel Supabase avec trigger automatique
-- ========================================

BEGIN;

-- 1. Créer les 40 utilisateurs auth.users (10 brides + 30 professionnels)
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data
) VALUES
-- BRIDES (10)
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'marie.martin.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Marie Martin","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'sophie.dubois.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Sophie Dubois","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'emily.johnson.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Emily Johnson","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'jessica.wilson.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Jessica Wilson","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'emma.thompson.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Emma Thompson","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'sarah.davis.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Sarah Davis","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'yuki.tanaka.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Yuki Tanaka","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'sakura.yamamoto.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Sakura Yamamoto","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'olivia.taylor.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Olivia Taylor","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'fatima.almansoori.bride@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"bride","full_name":"Fatima Al-Mansoori","seed_batch":"production_40_users"}'),

-- PROFESSIONALS - ULTIMATE_ACCESS (20)
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'pierre.chenier.photo@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Pierre Chenier","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'michael.rodriguez.venue@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Michael Rodriguez","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'james.anderson.planner@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"James Anderson","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'liam.wilson.venue@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Liam Wilson","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'david.kim.filmmaker@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"David Kim","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'hiroshi.sato.photo@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Hiroshi Sato","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'camille.roux.hair@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Camille Roux","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'ahmed.hassan.designer@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Ahmed Hassan","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'julien.girard.designer@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Julien Girard","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'jennifer.liu.makeup@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Jennifer Liu","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'robert.martinez.photo@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Robert Martinez","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'william.davies.photo@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"William Davies","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'elizabeth.foster.makeup@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Elizabeth Foster","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'kenji.yamamoto.makeup@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Kenji Yamamoto","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'aiko.tanaka.florist@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Aiko Tanaka","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'jack.miller.photo@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Jack Miller","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'mohammed.alfahad.venue@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Mohammed Al-Fahad","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'layla.khalid.florist@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Layla Khalid","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'marie.dupont.photo@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Marie Dupont","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'alexandre.moreau.venue@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Alexandre Moreau","seed_batch":"production_40_users"}'),

-- PROFESSIONALS - PREMIUM_VISIBILITY (6)
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'laurent.dubois.planner@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Laurent Dubois","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'isabelle.bernard.florist@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Isabelle Bernard","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'thomas.leroy.photo@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Thomas Leroy","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'emilie.moreau.florist@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Émilie Moreau","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'nicolas.petit.makeup@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Nicolas Petit","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'marcus.thompson.hair@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Marcus Thompson","seed_batch":"production_40_users"}'),

-- PROFESSIONALS - TRIAL (4)
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'francois.bernard.venue@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"François Bernard","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'patricia.obrien.florist@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Patricia O''Brien","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'richard.clarke.venue@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Richard Clarke","seed_batch":"production_40_users"}'),
('00000000-0000-0000-0000-000000000000', gen_random_uuid(), 'authenticated', 'authenticated', 'sophie.laurent.bridal@test.com', crypt('Test123456!', gen_salt('bf')), now(), now(), now(), '{"provider":"email","providers":["email"]}', '{"role":"professional","full_name":"Sophie Laurent","seed_batch":"production_40_users"}');

COMMIT;

-- ========================================
-- PARTIE 2: DÉTAILS DES UTILISATEURS
-- ========================================

BEGIN;

-- Créer les détails des brides
INSERT INTO bride_details (profile_id, created_at, updated_at)
SELECT u.id, now(), now()
FROM auth.users u
WHERE u.raw_user_meta_data->>'seed_batch' = 'production_40_users' 
  AND u.raw_user_meta_data->>'role' = 'bride';

-- Créer les détails des professionnels
INSERT INTO professional_details (
  profile_id,
  business_name,
  profession,
  location_coords,
  location_label,
  location_city,
  location_country_code,
  budget_min,
  budget_max,
  currency,
  budget_min_eur,
  budget_max_eur,
  created_at,
  updated_at
)
SELECT 
  u.id,
  CASE 
    WHEN u.email = 'pierre.chenier.photo@test.com' THEN 'Pierre Chenier Photography'
    WHEN u.email = 'laurent.dubois.planner@test.com' THEN 'Laurent Dubois Events'
    WHEN u.email = 'isabelle.bernard.florist@test.com' THEN 'Isabelle Bernard Fleurs'
    WHEN u.email = 'michael.rodriguez.venue@test.com' THEN 'Manhattan Luxury Venue'
    WHEN u.email = 'david.kim.filmmaker@test.com' THEN 'David Kim Films'
    WHEN u.email = 'james.anderson.planner@test.com' THEN 'James Anderson Planning'
    WHEN u.email = 'hiroshi.sato.photo@test.com' THEN 'Hiroshi Sato Photography'
    WHEN u.email = 'liam.wilson.venue@test.com' THEN 'Sydney Harbour Venue'
    WHEN u.email = 'ahmed.hassan.designer@test.com' THEN 'Ahmed Hassan Design'
    WHEN u.email = 'camille.roux.hair@test.com' THEN 'Camille Roux Hair Studio'
    WHEN u.email = 'thomas.leroy.photo@test.com' THEN 'Thomas Leroy Photography'
    WHEN u.email = 'nicolas.petit.makeup@test.com' THEN 'Nicolas Petit Makeup'
    WHEN u.email = 'julien.girard.designer@test.com' THEN 'Julien Girard Design'
    WHEN u.email = 'emilie.moreau.florist@test.com' THEN 'Émilie Moreau Fleurs'
    WHEN u.email = 'robert.martinez.photo@test.com' THEN 'Robert Martinez Photography'
    WHEN u.email = 'jennifer.liu.makeup@test.com' THEN 'Jennifer Liu Makeup'
    WHEN u.email = 'marcus.thompson.hair@test.com' THEN 'Marcus Thompson Hair'
    WHEN u.email = 'patricia.obrien.florist@test.com' THEN 'Patricia O''Brien Florist'
    WHEN u.email = 'william.davies.photo@test.com' THEN 'William Davies Photography'
    WHEN u.email = 'elizabeth.foster.makeup@test.com' THEN 'Elizabeth Foster Makeup'
    WHEN u.email = 'kenji.yamamoto.makeup@test.com' THEN 'Kenji Yamamoto Makeup'
    WHEN u.email = 'aiko.tanaka.florist@test.com' THEN 'Aiko Tanaka Florist'
    WHEN u.email = 'jack.miller.photo@test.com' THEN 'Jack Miller Photography'
    WHEN u.email = 'zoe.chen.makeup@test.com' THEN 'Zoe Chen Makeup'
    WHEN u.email = 'mohammed.alfahad.venue@test.com' THEN 'Burj Khalifa Venue'
    WHEN u.email = 'layla.khalid.florist@test.com' THEN 'Layla Khalid Florist'
    WHEN u.email = 'francois.bernard.venue@test.com' THEN 'Tour Eiffel Venue'
    WHEN u.email = 'richard.clarke.venue@test.com' THEN 'Big Ben Venue'
    WHEN u.email = 'sophie.laurent.bridal@test.com' THEN 'Sophie Laurent Bridal'
  END,
  CASE 
    WHEN u.email LIKE '%photo%' THEN 'PHOTOGRAPHER'::profession
    WHEN u.email LIKE '%planner%' THEN 'PLANNER'::profession
    WHEN u.email LIKE '%venue%' THEN 'VENUE'::profession
    WHEN u.email LIKE '%florist%' THEN 'FLORIST'::profession
    WHEN u.email LIKE '%makeup%' THEN 'MAKEUP'::profession
    WHEN u.email LIKE '%hair%' THEN 'HAIRDRESSER'::profession
    WHEN u.email LIKE '%designer%' THEN 'DESIGNER'::profession
    WHEN u.email LIKE '%bridal%' THEN 'BRIDALSHOP'::profession
    WHEN u.email LIKE '%filmmaker%' THEN 'FILMMAKER'::profession
  END,
  CASE 
    WHEN u.email = 'pierre.chenier.photo@test.com' THEN ST_SetSRID(ST_MakePoint(2.2945, 48.8584), 4326)
    WHEN u.email = 'laurent.dubois.planner@test.com' THEN ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326)
    WHEN u.email = 'isabelle.bernard.florist@test.com' THEN ST_SetSRID(ST_MakePoint(2.3500, 48.8600), 4326)
    WHEN u.email = 'michael.rodriguez.venue@test.com' THEN ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326)
    WHEN u.email = 'david.kim.filmmaker@test.com' THEN ST_SetSRID(ST_MakePoint(-73.9934, 40.7505), 4326)
    WHEN u.email = 'james.anderson.planner@test.com' THEN ST_SetSRID(ST_MakePoint(-0.1419, 51.5154), 4326)
    WHEN u.email = 'hiroshi.sato.photo@test.com' THEN ST_SetSRID(ST_MakePoint(139.6917, 35.6895), 4326)
    WHEN u.email = 'liam.wilson.venue@test.com' THEN ST_SetSRID(ST_MakePoint(151.2058, -33.8615), 4326)
    WHEN u.email = 'ahmed.hassan.designer@test.com' THEN ST_SetSRID(ST_MakePoint(55.2744, 25.1972), 4326)
    WHEN u.email = 'camille.roux.hair@test.com' THEN ST_SetSRID(ST_MakePoint(2.3540, 48.8580), 4326)
    WHEN u.email = 'thomas.leroy.photo@test.com' THEN ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326)
    WHEN u.email = 'nicolas.petit.makeup@test.com' THEN ST_SetSRID(ST_MakePoint(2.3500, 48.8590), 4326)
    WHEN u.email = 'julien.girard.designer@test.com' THEN ST_SetSRID(ST_MakePoint(2.3530, 48.8560), 4326)
    WHEN u.email = 'emilie.moreau.florist@test.com' THEN ST_SetSRID(ST_MakePoint(2.3510, 48.8570), 4326)
    WHEN u.email = 'robert.martinez.photo@test.com' THEN ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326)
    WHEN u.email = 'jennifer.liu.makeup@test.com' THEN ST_SetSRID(ST_MakePoint(-73.9776, 40.7614), 4326)
    WHEN u.email = 'marcus.thompson.hair@test.com' THEN ST_SetSRID(ST_MakePoint(-73.9851, 40.7589), 4326)
    WHEN u.email = 'patricia.obrien.florist@test.com' THEN ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326)
    WHEN u.email = 'william.davies.photo@test.com' THEN ST_SetSRID(ST_MakePoint(-0.1278, 51.5074), 4326)
    WHEN u.email = 'elizabeth.foster.makeup@test.com' THEN ST_SetSRID(ST_MakePoint(-0.1419, 51.5154), 4326)
    WHEN u.email = 'richard.clarke.venue@test.com' THEN ST_SetSRID(ST_MakePoint(-0.1278, 51.5074), 4326)
    WHEN u.email = 'kenji.yamamoto.makeup@test.com' THEN ST_SetSRID(ST_MakePoint(139.6503, 35.6762), 4326)
    WHEN u.email = 'aiko.tanaka.florist@test.com' THEN ST_SetSRID(ST_MakePoint(139.6917, 35.6895), 4326)
    WHEN u.email = 'jack.miller.photo@test.com' THEN ST_SetSRID(ST_MakePoint(151.2153, -33.8568), 4326)
    WHEN u.email = 'zoe.chen.makeup@test.com' THEN ST_SetSRID(ST_MakePoint(151.2058, -33.8615), 4326)
    WHEN u.email = 'mohammed.alfahad.venue@test.com' THEN ST_SetSRID(ST_MakePoint(55.2744, 25.1972), 4326)
    WHEN u.email = 'layla.khalid.florist@test.com' THEN ST_SetSRID(ST_MakePoint(55.2800, 25.2000), 4326)
    WHEN u.email = 'francois.bernard.venue@test.com' THEN ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326)
    WHEN u.email = 'sophie.laurent.bridal@test.com' THEN ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326)
  END,
  CASE 
    WHEN u.email = 'pierre.chenier.photo@test.com' THEN 'Paris, Arc de Triomphe'
    WHEN u.email = 'laurent.dubois.planner@test.com' THEN 'Paris, Tour Eiffel'
    WHEN u.email = 'isabelle.bernard.florist@test.com' THEN 'Paris, Trocadéro'
    WHEN u.email = 'michael.rodriguez.venue@test.com' THEN 'New York, Times Square'
    WHEN u.email = 'david.kim.filmmaker@test.com' THEN 'New York, Hell''s Kitchen'
    WHEN u.email = 'james.anderson.planner@test.com' THEN 'London, Soho'
    WHEN u.email = 'hiroshi.sato.photo@test.com' THEN 'Tokyo, Shinjuku'
    WHEN u.email = 'liam.wilson.venue@test.com' THEN 'Sydney, Darling Harbour'
    WHEN u.email = 'ahmed.hassan.designer@test.com' THEN 'Dubai, Burj Khalifa'
    WHEN u.email = 'camille.roux.hair@test.com' THEN 'Paris, Tour Eiffel'
    WHEN u.email = 'thomas.leroy.photo@test.com' THEN 'Paris, Tour Eiffel'
    WHEN u.email = 'nicolas.petit.makeup@test.com' THEN 'Paris, Tour Eiffel'
    WHEN u.email = 'julien.girard.designer@test.com' THEN 'Paris, Tour Eiffel'
    WHEN u.email = 'emilie.moreau.florist@test.com' THEN 'Paris, Tour Eiffel'
    WHEN u.email = 'robert.martinez.photo@test.com' THEN 'New York, Times Square'
    WHEN u.email = 'jennifer.liu.makeup@test.com' THEN 'New York, Central Park'
    WHEN u.email = 'marcus.thompson.hair@test.com' THEN 'New York, Times Square'
    WHEN u.email = 'patricia.obrien.florist@test.com' THEN 'New York, Times Square'
    WHEN u.email = 'william.davies.photo@test.com' THEN 'London, Big Ben'
    WHEN u.email = 'elizabeth.foster.makeup@test.com' THEN 'London, Soho'
    WHEN u.email = 'richard.clarke.venue@test.com' THEN 'London, Big Ben'
    WHEN u.email = 'kenji.yamamoto.makeup@test.com' THEN 'Tokyo, Shibuya'
    WHEN u.email = 'aiko.tanaka.florist@test.com' THEN 'Tokyo, Shinjuku'
    WHEN u.email = 'jack.miller.photo@test.com' THEN 'Sydney, Opera House'
    WHEN u.email = 'zoe.chen.makeup@test.com' THEN 'Sydney, Darling Harbour'
    WHEN u.email = 'mohammed.alfahad.venue@test.com' THEN 'Dubai, Burj Khalifa'
    WHEN u.email = 'layla.khalid.florist@test.com' THEN 'Dubai, Burj Khalifa'
    WHEN u.email = 'francois.bernard.venue@test.com' THEN 'Paris, Tour Eiffel'
    WHEN u.email = 'sophie.laurent.bridal@test.com' THEN 'Paris, Tour Eiffel'
  END,
  CASE 
    WHEN u.email LIKE '%paris%' OR u.email LIKE '%francois%' OR u.email LIKE '%sophie.laurent%' THEN 'Paris'
    WHEN u.email LIKE '%new york%' OR u.email LIKE '%nyc%' THEN 'New York'
    WHEN u.email LIKE '%london%' THEN 'London'
    WHEN u.email LIKE '%tokyo%' THEN 'Tokyo'
    WHEN u.email LIKE '%sydney%' THEN 'Sydney'
    WHEN u.email LIKE '%dubai%' THEN 'Dubai'
  END,
  CASE 
    WHEN u.email LIKE '%paris%' OR u.email LIKE '%francois%' OR u.email LIKE '%sophie.laurent%' THEN 'FR'
    WHEN u.email LIKE '%new york%' OR u.email LIKE '%nyc%' THEN 'US'
    WHEN u.email LIKE '%london%' THEN 'GB'
    WHEN u.email LIKE '%tokyo%' THEN 'JP'
    WHEN u.email LIKE '%sydney%' THEN 'AU'
    WHEN u.email LIKE '%dubai%' THEN 'AE'
  END,
  CASE 
    WHEN u.email LIKE '%photo%' THEN 3000
    WHEN u.email LIKE '%planner%' THEN 2500
    WHEN u.email LIKE '%venue%' THEN 15000
    WHEN u.email LIKE '%florist%' THEN 1500
    WHEN u.email LIKE '%makeup%' THEN 800
    WHEN u.email LIKE '%hair%' THEN 600
    WHEN u.email LIKE '%designer%' THEN 2000
    WHEN u.email LIKE '%bridal%' THEN 1000
    WHEN u.email LIKE '%filmmaker%' THEN 4000
  END,
  CASE 
    WHEN u.email LIKE '%photo%' THEN 5000
    WHEN u.email LIKE '%planner%' THEN 4000
    WHEN u.email LIKE '%venue%' THEN 25000
    WHEN u.email LIKE '%florist%' THEN 2500
    WHEN u.email LIKE '%makeup%' THEN 1200
    WHEN u.email LIKE '%hair%' THEN 900
    WHEN u.email LIKE '%designer%' THEN 3500
    WHEN u.email LIKE '%bridal%' THEN 3000
    WHEN u.email LIKE '%filmmaker%' THEN 6000
  END,
  CASE 
    WHEN u.email LIKE '%london%' THEN 'GBP'
    WHEN u.email LIKE '%sydney%' THEN 'AUD'
    WHEN u.email LIKE '%dubai%' THEN 'AED'
    WHEN u.email LIKE '%tokyo%' THEN 'JPY'
    ELSE 'EUR'
  END,
  CASE 
    WHEN u.email LIKE '%photo%' THEN 3000
    WHEN u.email LIKE '%planner%' THEN 2500
    WHEN u.email LIKE '%venue%' THEN 15000
    WHEN u.email LIKE '%florist%' THEN 1500
    WHEN u.email LIKE '%makeup%' THEN 800
    WHEN u.email LIKE '%hair%' THEN 600
    WHEN u.email LIKE '%designer%' THEN 2000
    WHEN u.email LIKE '%bridal%' THEN 1000
    WHEN u.email LIKE '%filmmaker%' THEN 4000
  END,
  CASE 
    WHEN u.email LIKE '%photo%' THEN 5000
    WHEN u.email LIKE '%planner%' THEN 4000
    WHEN u.email LIKE '%venue%' THEN 25000
    WHEN u.email LIKE '%florist%' THEN 2500
    WHEN u.email LIKE '%makeup%' THEN 1200
    WHEN u.email LIKE '%hair%' THEN 900
    WHEN u.email LIKE '%designer%' THEN 3500
    WHEN u.email LIKE '%bridal%' THEN 3000
    WHEN u.email LIKE '%filmmaker%' THEN 6000
  END,
  now(),
  now()
FROM auth.users u
WHERE u.raw_user_meta_data->>'seed_batch' = 'production_40_users' 
  AND u.raw_user_meta_data->>'role' = 'professional';

COMMIT;

-- ========================================
-- PARTIE 3: ABONNEMENTS PROFESSIONNELS
-- ========================================

BEGIN;

-- Créer les abonnements professionnels
INSERT INTO professional_subscriptions (
  profile_id,
  subscription_tier,
  created_at,
  updated_at
)
SELECT 
  u.id,
  CASE 
    WHEN u.email IN ('laurent.dubois.planner@test.com', 'isabelle.bernard.florist@test.com', 'thomas.leroy.photo@test.com', 'emilie.moreau.florist@test.com', 'nicolas.petit.makeup@test.com', 'marcus.thompson.hair@test.com') THEN 'premiumVisibility'::"subscriptionTierType"
    WHEN u.email IN ('francois.bernard.venue@test.com', 'patricia.obrien.florist@test.com', 'richard.clarke.venue@test.com', 'sophie.laurent.bridal@test.com') THEN 'trial'::"subscriptionTierType"
    ELSE 'ultimateAccess'::"subscriptionTierType"
  END,
  now(),
  now()
FROM auth.users u
WHERE u.raw_user_meta_data->>'seed_batch' = 'production_40_users' 
  AND u.raw_user_meta_data->>'role' = 'professional';

COMMIT;

-- ========================================
-- PARTIE 4: ADRESSES FIXES (100 au total)
-- ========================================

BEGIN;

-- Pierre Chenier (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Arc de Triomphe', ST_SetSRID(ST_MakePoint(2.2945, 48.8584), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Pierre Chenier Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Porte Maillot', ST_SetSRID(ST_MakePoint(2.3000, 48.8600), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Pierre Chenier Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Trocadéro', ST_SetSRID(ST_MakePoint(2.2800, 48.8520), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Pierre Chenier Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Montmartre', ST_SetSRID(ST_MakePoint(2.3100, 48.8700), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Pierre Chenier Photography';

-- Laurent Dubois (Premium - 2 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel', ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Laurent Dubois Events';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Invalides', ST_SetSRID(ST_MakePoint(2.2800, 48.8520), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Laurent Dubois Events';

-- Isabelle Bernard (Premium - 2 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Trocadéro', ST_SetSRID(ST_MakePoint(2.3500, 48.8600), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Isabelle Bernard Fleurs';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Arc de Triomphe', ST_SetSRID(ST_MakePoint(2.2945, 48.8584), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Isabelle Bernard Fleurs';

-- Michael Rodriguez (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Times Square', ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Manhattan Luxury Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Central Park', ST_SetSRID(ST_MakePoint(-73.9776, 40.7614), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Manhattan Luxury Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Hell''s Kitchen', ST_SetSRID(ST_MakePoint(-73.9934, 40.7505), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Manhattan Luxury Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Broadway', ST_SetSRID(ST_MakePoint(-73.9680, 40.7489), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Manhattan Luxury Venue';

-- David Kim (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Hell''s Kitchen', ST_SetSRID(ST_MakePoint(-73.9934, 40.7505), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'David Kim Films';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Times Square', ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'David Kim Films';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Central Park', ST_SetSRID(ST_MakePoint(-73.9776, 40.7614), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'David Kim Films';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Theater District', ST_SetSRID(ST_MakePoint(-73.9851, 40.7589), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'David Kim Films';

-- James Anderson (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Soho', ST_SetSRID(ST_MakePoint(-0.1419, 51.5154), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'James Anderson Planning';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Big Ben', ST_SetSRID(ST_MakePoint(-0.1278, 51.5074), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'James Anderson Planning';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Covent Garden', ST_SetSRID(ST_MakePoint(-0.1358, 51.5138), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'James Anderson Planning';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Piccadilly', ST_SetSRID(ST_MakePoint(-0.1330, 51.5115), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'James Anderson Planning';

-- Hiroshi Sato (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Shinjuku', ST_SetSRID(ST_MakePoint(139.6917, 35.6895), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Hiroshi Sato Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Shibuya', ST_SetSRID(ST_MakePoint(139.6503, 35.6762), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Hiroshi Sato Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Harajuku', ST_SetSRID(ST_MakePoint(139.7016, 35.6580), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Hiroshi Sato Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Shinjuku Gyoen', ST_SetSRID(ST_MakePoint(139.7000, 35.6900), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Hiroshi Sato Photography';

-- Liam Wilson (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Darling Harbour', ST_SetSRID(ST_MakePoint(151.2058, -33.8615), 4326), 'AU', now() FROM professional_details pd WHERE pd.business_name = 'Sydney Harbour Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Opera House', ST_SetSRID(ST_MakePoint(151.2153, -33.8568), 4326), 'AU', now() FROM professional_details pd WHERE pd.business_name = 'Sydney Harbour Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Circular Quay', ST_SetSRID(ST_MakePoint(151.2069, -33.8736), 4326), 'AU', now() FROM professional_details pd WHERE pd.business_name = 'Sydney Harbour Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'The Rocks', ST_SetSRID(ST_MakePoint(151.2232, -33.8468), 4326), 'AU', now() FROM professional_details pd WHERE pd.business_name = 'Sydney Harbour Venue';

-- Ahmed Hassan (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Burj Khalifa', ST_SetSRID(ST_MakePoint(55.2744, 25.1972), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Ahmed Hassan Design';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Downtown Dubai', ST_SetSRID(ST_MakePoint(55.2800, 25.2000), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Ahmed Hassan Design';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Dubai Mall', ST_SetSRID(ST_MakePoint(55.3273, 25.2285), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Ahmed Hassan Design';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Business Bay', ST_SetSRID(ST_MakePoint(55.2708, 25.1845), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Ahmed Hassan Design';

-- Camille Roux (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel', ST_SetSRID(ST_MakePoint(2.3540, 48.8580), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Camille Roux Hair Studio';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel 2', ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Camille Roux Hair Studio';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Trocadéro', ST_SetSRID(ST_MakePoint(2.3500, 48.8600), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Camille Roux Hair Studio';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Invalides', ST_SetSRID(ST_MakePoint(2.2800, 48.8520), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Camille Roux Hair Studio';

-- Thomas Leroy (Premium - 2 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel', ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Thomas Leroy Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Arc de Triomphe', ST_SetSRID(ST_MakePoint(2.2945, 48.8584), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Thomas Leroy Photography';

-- Nicolas Petit (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel', ST_SetSRID(ST_MakePoint(2.3500, 48.8590), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Nicolas Petit Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel 2', ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Nicolas Petit Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Porte Maillot', ST_SetSRID(ST_MakePoint(2.3000, 48.8600), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Nicolas Petit Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Arc de Triomphe', ST_SetSRID(ST_MakePoint(2.2945, 48.8584), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Nicolas Petit Makeup';

-- Julien Girard (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel', ST_SetSRID(ST_MakePoint(2.3530, 48.8560), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Julien Girard Design';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel 2', ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Julien Girard Design';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Arc de Triomphe', ST_SetSRID(ST_MakePoint(2.2945, 48.8584), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Julien Girard Design';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Trocadéro', ST_SetSRID(ST_MakePoint(2.3500, 48.8600), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Julien Girard Design';

-- Émilie Moreau (Premium - 2 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel', ST_SetSRID(ST_MakePoint(2.3510, 48.8570), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Émilie Moreau Fleurs';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel 2', ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Émilie Moreau Fleurs';

-- Robert Martinez (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Times Square', ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Robert Martinez Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Central Park', ST_SetSRID(ST_MakePoint(-73.9776, 40.7614), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Robert Martinez Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Hell''s Kitchen', ST_SetSRID(ST_MakePoint(-73.9934, 40.7505), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Robert Martinez Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Broadway', ST_SetSRID(ST_MakePoint(-73.9680, 40.7489), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Robert Martinez Photography';

-- Jennifer Liu (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Central Park', ST_SetSRID(ST_MakePoint(-73.9776, 40.7614), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Jennifer Liu Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Times Square', ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Jennifer Liu Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Hell''s Kitchen', ST_SetSRID(ST_MakePoint(-73.9934, 40.7505), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Jennifer Liu Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Theater District', ST_SetSRID(ST_MakePoint(-73.9851, 40.7589), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Jennifer Liu Makeup';

-- Marcus Thompson (Premium - 2 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Times Square', ST_SetSRID(ST_MakePoint(-73.9851, 40.7589), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Marcus Thompson Hair';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Times Square 2', ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Marcus Thompson Hair';

-- Patricia O'Brien (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Times Square', ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Patricia O''Brien Florist';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Central Park', ST_SetSRID(ST_MakePoint(-73.9776, 40.7614), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Patricia O''Brien Florist';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Hell''s Kitchen', ST_SetSRID(ST_MakePoint(-73.9934, 40.7505), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Patricia O''Brien Florist';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Theater District', ST_SetSRID(ST_MakePoint(-73.9851, 40.7589), 4326), 'US', now() FROM professional_details pd WHERE pd.business_name = 'Patricia O''Brien Florist';

-- William Davies (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Big Ben', ST_SetSRID(ST_MakePoint(-0.1278, 51.5074), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'William Davies Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Soho', ST_SetSRID(ST_MakePoint(-0.1419, 51.5154), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'William Davies Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Covent Garden', ST_SetSRID(ST_MakePoint(-0.1358, 51.5138), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'William Davies Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Piccadilly', ST_SetSRID(ST_MakePoint(-0.1330, 51.5115), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'William Davies Photography';

-- Elizabeth Foster (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Soho', ST_SetSRID(ST_MakePoint(-0.1419, 51.5154), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'Elizabeth Foster Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Big Ben', ST_SetSRID(ST_MakePoint(-0.1278, 51.5074), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'Elizabeth Foster Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Westminster', ST_SetSRID(ST_MakePoint(-0.1278, 51.5074), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'Elizabeth Foster Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Covent Garden', ST_SetSRID(ST_MakePoint(-0.1358, 51.5138), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'Elizabeth Foster Makeup';

-- Richard Clarke (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Big Ben', ST_SetSRID(ST_MakePoint(-0.1278, 51.5074), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'Big Ben Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Soho', ST_SetSRID(ST_MakePoint(-0.1419, 51.5154), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'Big Ben Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Covent Garden', ST_SetSRID(ST_MakePoint(-0.1358, 51.5138), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'Big Ben Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Piccadilly', ST_SetSRID(ST_MakePoint(-0.1330, 51.5115), 4326), 'GB', now() FROM professional_details pd WHERE pd.business_name = 'Big Ben Venue';

-- Kenji Yamamoto (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Shibuya', ST_SetSRID(ST_MakePoint(139.6503, 35.6762), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Kenji Yamamoto Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Shinjuku', ST_SetSRID(ST_MakePoint(139.6917, 35.6895), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Kenji Yamamoto Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Harajuku', ST_SetSRID(ST_MakePoint(139.7016, 35.6580), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Kenji Yamamoto Makeup';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Shinjuku Gyoen', ST_SetSRID(ST_MakePoint(139.7000, 35.6900), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Kenji Yamamoto Makeup';

-- Aiko Tanaka (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Shinjuku', ST_SetSRID(ST_MakePoint(139.6917, 35.6895), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Aiko Tanaka Florist';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Shibuya', ST_SetSRID(ST_MakePoint(139.6503, 35.6762), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Aiko Tanaka Florist';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Harajuku', ST_SetSRID(ST_MakePoint(139.7016, 35.6580), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Aiko Tanaka Florist';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Shinjuku Gyoen', ST_SetSRID(ST_MakePoint(139.7000, 35.6900), 4326), 'JP', now() FROM professional_details pd WHERE pd.business_name = 'Aiko Tanaka Florist';

-- Jack Miller (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Opera House', ST_SetSRID(ST_MakePoint(151.2153, -33.8568), 4326), 'AU', now() FROM professional_details pd WHERE pd.business_name = 'Jack Miller Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Darling Harbour', ST_SetSRID(ST_MakePoint(151.2058, -33.8615), 4326), 'AU', now() FROM professional_details pd WHERE pd.business_name = 'Jack Miller Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Circular Quay', ST_SetSRID(ST_MakePoint(151.2069, -33.8736), 4326), 'AU', now() FROM professional_details pd WHERE pd.business_name = 'Jack Miller Photography';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'The Rocks', ST_SetSRID(ST_MakePoint(151.2232, -33.8468), 4326), 'AU', now() FROM professional_details pd WHERE pd.business_name = 'Jack Miller Photography';

-- Mohammed Al-Fahad (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Burj Khalifa', ST_SetSRID(ST_MakePoint(55.2744, 25.1972), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Burj Khalifa Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Downtown Dubai', ST_SetSRID(ST_MakePoint(55.2800, 25.2000), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Burj Khalifa Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Dubai Mall', ST_SetSRID(ST_MakePoint(55.3273, 25.2285), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Burj Khalifa Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'DIFC', ST_SetSRID(ST_MakePoint(55.2710, 25.2090), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Burj Khalifa Venue';

-- Layla Khalid (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Burj Khalifa', ST_SetSRID(ST_MakePoint(55.2800, 25.2000), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Layla Khalid Florist';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Burj Khalifa 2', ST_SetSRID(ST_MakePoint(55.2744, 25.1972), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Layla Khalid Florist';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Dubai Mall', ST_SetSRID(ST_MakePoint(55.3273, 25.2285), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Layla Khalid Florist';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Business Bay', ST_SetSRID(ST_MakePoint(55.2708, 25.1845), 4326), 'AE', now() FROM professional_details pd WHERE pd.business_name = 'Layla Khalid Florist';

-- François Bernard (Ultimate - 4 adresses)
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Tour Eiffel', ST_SetSRID(ST_MakePoint(2.3522, 48.8566), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Tour Eiffel Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Arc de Triomphe', ST_SetSRID(ST_MakePoint(2.2945, 48.8584), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Tour Eiffel Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Trocadéro', ST_SetSRID(ST_MakePoint(2.3500, 48.8600), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Tour Eiffel Venue';
INSERT INTO professional_fixed_locations (professional_profile_id, label, location_coords, location_country_code, created_at)
SELECT pd.profile_id, 'Invalides', ST_SetSRID(ST_MakePoint(2.2800, 48.8520), 4326), 'FR', now() FROM professional_details pd WHERE pd.business_name = 'Tour Eiffel Venue';

-- Sophie Laurent (Trial - 0 adresses supplémentaires)
-- Pas d'adresses fixes pour les professionnels en trial

COMMIT;

-- ========================================
-- PARTIE 5: PRÉFÉRENCES UTILISATEURS
-- ========================================

BEGIN;

-- Créer les préférences pour tous les utilisateurs
INSERT INTO user_preferences (
  profile_id,
  distance_unit,
  default_radius_km,
  default_country_code,
  default_city,
  default_locale,
  currency,
  default_timezone,
  map_toggles,
  last_filters,
  last_feed_filters,
  created_at,
  updated_at
)
SELECT 
  u.id,
  CASE 
    WHEN u.email LIKE '%london%' THEN 'miles'
    ELSE 'km'
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN 30
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN 50
    WHEN u.email = 'emily.johnson.bride@test.com' THEN 20
    ELSE 25
  END,
  CASE 
    WHEN u.email LIKE '%paris%' OR u.email LIKE '%francois%' OR u.email LIKE '%sophie.laurent%' THEN 'FR'
    WHEN u.email LIKE '%new york%' OR u.email LIKE '%nyc%' THEN 'US'
    WHEN u.email LIKE '%london%' THEN 'GB'
    WHEN u.email LIKE '%tokyo%' THEN 'JP'
    WHEN u.email LIKE '%sydney%' THEN 'AU'
    WHEN u.email LIKE '%dubai%' THEN 'AE'
  END,
  CASE 
    WHEN u.email LIKE '%paris%' OR u.email LIKE '%francois%' OR u.email LIKE '%sophie.laurent%' THEN 'Paris'
    WHEN u.email LIKE '%new york%' OR u.email LIKE '%nyc%' THEN 'New York'
    WHEN u.email LIKE '%london%' THEN 'London'
    WHEN u.email LIKE '%tokyo%' THEN 'Tokyo'
    WHEN u.email LIKE '%sydney%' THEN 'Sydney'
    WHEN u.email LIKE '%dubai%' THEN 'Dubai'
  END,
  CASE 
    WHEN u.email LIKE '%france%' OR u.email LIKE '%paris%' THEN 'fr-FR'
    WHEN u.email LIKE '%japan%' OR u.email LIKE '%tokyo%' THEN 'ja-JP'
    ELSE 'en-US'
  END,
  CASE 
    WHEN u.email LIKE '%london%' THEN 'GBP'
    WHEN u.email LIKE '%sydney%' THEN 'AUD'
    WHEN u.email LIKE '%dubai%' THEN 'AED'
    WHEN u.email LIKE '%tokyo%' THEN 'JPY'
    ELSE 'EUR'
  END,
  CASE 
    WHEN u.email LIKE '%new york%' OR u.email LIKE '%nyc%' THEN 'America/New_York'
    WHEN u.email LIKE '%london%' THEN 'Europe/London'
    WHEN u.email LIKE '%tokyo%' THEN 'Asia/Tokyo'
    WHEN u.email LIKE '%sydney%' THEN 'Australia/Sydney'
    WHEN u.email LIKE '%dubai%' THEN 'Asia/Dubai'
    ELSE 'Europe/Paris'
  END,
  CASE 
    WHEN u.raw_user_meta_data->>'role' = 'bride' THEN '{"show_professionals": true, "show_venues": true, "price_filter": true}'
    ELSE '{"show_brides": true, "radius_visible": true}'
  END,
  CASE 
    WHEN u.raw_user_meta_data->>'role' = 'bride' THEN '{"professions": ["PHOTOGRAPHER", "VENUE", "FLORIST"], "budget_max": 15000}'
    ELSE NULL
  END,
  CASE 
    WHEN u.raw_user_meta_data->>'role' = 'bride' THEN '{"categories": ["photography", "venues", "flowers"]}'
    ELSE NULL
  END,
  now(),
  now()
FROM auth.users u
WHERE u.raw_user_meta_data->>'seed_batch' = 'production_40_users';

COMMIT;

-- ========================================
-- PARTIE 6: WEDDING PINS (BRIDES SEULEMENT)
-- ========================================

BEGIN;

-- Créer les wedding pins pour les brides
INSERT INTO wedding_pins (
  bride_profile_id,
  radius_km,
  professions_needed,
  budget_brackets,
  event_start_date,
  event_end_date,
  location_label,
  budget_min,
  budget_max,
  currency,
  budget_min_eur,
  budget_max_eur,
  location_coords,
  is_active,
  created_at,
  updated_at
)
SELECT 
  u.id,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN 50
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN 30
    WHEN u.email = 'emily.johnson.bride@test.com' THEN 20
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN 100
    ELSE 25
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN ARRAY['PHOTOGRAPHER', 'VENUE', 'FLORIST', 'PLANNER']::profession[]
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN ARRAY['PHOTOGRAPHER', 'MAKEUP', 'HAIRDRESSER']::profession[]
    WHEN u.email = 'emily.johnson.bride@test.com' THEN ARRAY['VENUE', 'CATERER', 'FLORIST']::profession[]
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN ARRAY['PHOTOGRAPHER', 'FILMMAKER', 'PLANNER', 'DESIGNER']::profession[]
    ELSE ARRAY['PHOTOGRAPHER', 'FLORIST', 'VENUE']::profession[]
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN ARRAY[10000, 15000, 20000]::smallint[]
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN ARRAY[5000, 8000, 12000]::smallint[]
    WHEN u.email = 'emily.johnson.bride@test.com' THEN ARRAY[15000, 25000]::smallint[]
    ELSE ARRAY[8000, 12000, 18000]::smallint[]
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN '2026-06-15'::date
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN '2026-09-20'::date
    WHEN u.email = 'emily.johnson.bride@test.com' THEN '2026-05-10'::date
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN '2026-08-12'::date
    ELSE '2026-07-18'::date
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN '2026-06-18'::date
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN '2026-09-23'::date
    WHEN u.email = 'emily.johnson.bride@test.com' THEN '2026-05-12'::date
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN '2026-08-15'::date
    ELSE '2026-07-21'::date
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN 'Paris, Champs-Élysées'
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN 'Lyon, Vieux Lyon'
    WHEN u.email = 'emily.johnson.bride@test.com' THEN 'Nice, Promenade des Anglais'
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN 'Bordeaux, Centre ville'
    ELSE 'Marseille, Vieux Port'
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN 10000
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN 5000
    WHEN u.email = 'emily.johnson.bride@test.com' THEN 15000
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN 12000
    ELSE 8000
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN 20000
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN 12000
    WHEN u.email = 'emily.johnson.bride@test.com' THEN 25000
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN 18000
    ELSE 15000
  END,
  'EUR',
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN 10000
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN 5000
    WHEN u.email = 'emily.johnson.bride@test.com' THEN 15000
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN 12000
    ELSE 8000
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN 20000
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN 12000
    WHEN u.email = 'emily.johnson.bride@test.com' THEN 25000
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN 18000
    ELSE 15000
  END,
  CASE 
    WHEN u.email = 'marie.martin.bride@test.com' THEN ST_SetSRID(ST_MakePoint(2.2930, 48.8700), 4326)
    WHEN u.email = 'sophie.dubois.bride@test.com' THEN ST_SetSRID(ST_MakePoint(4.8357, 45.7640), 4326)
    WHEN u.email = 'emily.johnson.bride@test.com' THEN ST_SetSRID(ST_MakePoint(7.2620, 43.7102), 4326)
    WHEN u.email = 'jessica.wilson.bride@test.com' THEN ST_SetSRID(ST_MakePoint(-0.5800, 44.8378), 4326)
    ELSE ST_SetSRID(ST_MakePoint(5.3800, 43.2965), 4326)
  END,
  true,
  now(),
  now()
FROM auth.users u
WHERE u.raw_user_meta_data->>'seed_batch' = 'production_40_users' 
  AND u.raw_user_meta_data->>'role' = 'bride';

COMMIT;

-- ========================================
-- PARTIE 7: WISHLIST ITEMS
-- ========================================

BEGIN;

-- Créer les wishlist items (brides -> professionnels)
INSERT INTO wishlist_items (bride_profile_id, professional_profile_id, added_at)
SELECT 
  bride.id,
  professional.id,
  CASE 
    WHEN bride.email = 'marie.martin.bride@test.com' THEN now() - INTERVAL '7 days'
    WHEN bride.email = 'sophie.dubois.bride@test.com' THEN now() - INTERVAL '3 days'
    WHEN bride.email = 'emily.johnson.bride@test.com' THEN now() - INTERVAL '14 days'
    ELSE now() - INTERVAL '5 days'
  END
FROM auth.users bride
CROSS JOIN auth.users professional
WHERE bride.raw_user_meta_data->>'seed_batch' = 'production_40_users' 
  AND bride.raw_user_meta_data->>'role' = 'bride'
  AND professional.raw_user_meta_data->>'seed_batch' = 'production_40_users'
  AND professional.raw_user_meta_data->>'role' = 'professional'
  AND (
    -- Marie Martin aime les photographes et fleuristes de Paris
    (bride.email = 'marie.martin.bride@test.com' AND professional.email IN ('pierre.chenier.photo@test.com', 'thomas.leroy.photo@test.com', 'isabelle.bernard.florist@test.com', 'emilie.moreau.florist@test.com'))
    -- Sophie Dubois aime les professionnels de beauté
    OR (bride.email = 'sophie.dubois.bride@test.com' AND professional.email IN ('camille.roux.hair@test.com', 'nicolas.petit.makeup@test.com', 'jennifer.liu.makeup@test.com'))
    -- Emily Johnson aime les venues et planners
    OR (bride.email = 'emily.johnson.bride@test.com' AND professional.email IN ('michael.rodriguez.venue@test.com', 'james.anderson.planner@test.com', 'laurent.dubois.planner@test.com'))
    -- Jessica Wilson aime les créatifs
    OR (bride.email = 'jessica.wilson.bride@test.com' AND professional.email IN ('david.kim.filmmaker@test.com', 'ahmed.hassan.designer@test.com', 'julien.girard.designer@test.com'))
    -- Les autres brides ont quelques préférences variées
    OR (bride.email IN ('emma.thompson.bride@test.com', 'sarah.davis.bride@test.com') AND professional.email IN ('pierre.chenier.photo@test.com', 'michael.rodriguez.venue@test.com'))
  );

COMMIT;

-- ========================================
-- PARTIE 8: CHAT ROOMS ET PARTICIPANTS
-- ========================================

BEGIN;

-- Créer les salons de chat pour les conversations actives
INSERT INTO chat_rooms (id, type, name, is_active, created_at)
SELECT 
  gen_random_uuid(),
  'private',
  NULL,
  true,
  CASE 
    WHEN bride.email = 'marie.martin.bride@test.com' THEN now() - INTERVAL '10 days'
    WHEN bride.email = 'sophie.dubois.bride@test.com' THEN now() - INTERVAL '5 days'
    ELSE now() - INTERVAL '7 days'
  END
FROM auth.users bride
WHERE bride.raw_user_meta_data->>'seed_batch' = 'production_40_users' 
  AND bride.raw_user_meta_data->>'role' = 'bride'
  AND bride.email IN ('marie.martin.bride@test.com', 'sophie.dubois.bride@test.com', 'emily.johnson.bride@test.com', 'jessica.wilson.bride@test.com');

-- Ajouter les participants aux salons de chat
INSERT INTO chat_room_participants (room_id, profile_id, conversation_status, joined_at, last_read_at)
SELECT 
  cr.id,
  u.id,
  CASE 
    WHEN u.raw_user_meta_data->>'role' = 'bride' THEN 'active'::conversationStatus
    ELSE 'active'::conversationStatus
  END,
  CASE 
    WHEN u.raw_user_meta_data->>'role' = 'bride' THEN cr.created_at
    ELSE cr.created_at + INTERVAL '1 hour'
  END,
  now() - INTERVAL '1 hour'
FROM chat_rooms cr
CROSS JOIN auth.users u
WHERE cr.created_at > now() - INTERVAL '30 days'
  AND u.raw_user_meta_data->>'seed_batch' = 'production_40_users'
  AND (
    -- Marie et Pierre Chenier
    (EXISTS(SELECT 1 FROM auth.users WHERE email = 'marie.martin.bride@test.com' AND raw_user_meta_data->>'seed_batch' = 'production_40_users') 
     AND u.email IN ('marie.martin.bride@test.com', 'pierre.chenier.photo@test.com'))
    -- Sophie et Camille Roux
    OR (EXISTS(SELECT 1 FROM auth.users WHERE email = 'sophie.dubois.bride@test.com' AND raw_user_meta_data->>'seed_batch' = 'production_40_users') 
        AND u.email IN ('sophie.dubois.bride@test.com', 'camille.roux.hair@test.com'))
    -- Emily et Michael Rodriguez
    OR (EXISTS(SELECT 1 FROM auth.users WHERE email = 'emily.johnson.bride@test.com' AND raw_user_meta_data->>'seed_batch' = 'production_40_users') 
        AND u.email IN ('emily.johnson.bride@test.com', 'michael.rodriguez.venue@test.com'))
    -- Jessica et David Kim
    OR (EXISTS(SELECT 1 FROM auth.users WHERE email = 'jessica.wilson.bride@test.com' AND raw_user_meta_data->>'seed_batch' = 'production_40_users') 
        AND u.email IN ('jessica.wilson.bride@test.com', 'david.kim.filmmaker@test.com'))
  );

COMMIT;

-- ========================================
-- PARTIE 9: CHAT MESSAGES
-- ========================================

BEGIN;

-- Créer les messages de chat (alternance bride/pro)
INSERT INTO chat_messages (room_id, profile_id, content, message_type, created_at)
SELECT 
  cr.id as room_id,
  u.id as profile_id,
  CASE 
    WHEN u.raw_user_meta_data->>'role' = 'bride' AND msg_num = 1 THEN 
      CASE 
        WHEN u.email = 'marie.martin.bride@test.com' THEN 'Bonjour ! Je suis très intéressée par votre travail de photographe. Pourriez-vous me renseigner sur vos disponibilités pour juin 2026 ?'
        WHEN u.email = 'sophie.dubois.bride@test.com' THEN 'Bonjour, j''adore votre style ! Je cherche une coiffeuse pour mon mariage de septembre 2026.'
        WHEN u.email = 'emily.johnson.bride@test.com' THEN 'Bonjour, votre venue looks amazing ! Quelles sont vos capacités d''accueil ?'
        WHEN u.email = 'jessica.wilson.bride@test.com' THEN 'Hello ! I love your filmmaking style. Do you have experience with destination weddings ?'
        ELSE 'Bonjour, je suis intéressée par vos services pour mon mariage.'
      END
    WHEN u.raw_user_meta_data->>'role' = 'professional' AND msg_num = 2 THEN 
      CASE 
        WHEN u.email = 'pierre.chenier.photo@test.com' THEN 'Bonjour Marie ! Merci pour votre intérêt. J''ai effectivement des disponibilités en juin 2026. Quel est votre budget ?'
        WHEN u.email = 'camille.roux.hair@test.com' THEN 'Bonjour Sophie ! Merci pour votre compliment. Septembre 2026 c''est parfait pour moi. Avez-vous une date précise ?'
        WHEN u.email = 'michael.rodriguez.venue@test.com' THEN 'Bonjour Emily ! Merci ! Notre venue peut accueillir jusqu''à 200 invités. Quelle est la taille de votre mariage ?'
        WHEN u.email = 'david.kim.filmmaker@test.com' THEN 'Hello Jessica ! Yes, I have extensive experience with destination weddings. Where are you planning to get married ?'
        ELSE 'Bonjour ! Merci pour votre message. Je serais ravi de discuter de votre projet.'
      END
    WHEN u.raw_user_meta_data->>'role' = 'bride' AND msg_num = 3 THEN 
      CASE 
        WHEN u.email = 'marie.martin.bride@test.com' THEN 'Mon budget est autour de 15 000€ pour la photo complète. C''est pour le 15 juin 2026 à Paris.'
        WHEN u.email = 'sophie.dubois.bride@test.com' THEN 'Le mariage est prévu pour le 20 septembre 2026. Nous serons environ 80 invités.'
        WHEN u.email = 'emily.johnson.bride@test.com' THEN 'Nous prévoyons environ 150 invités pour le 10 mai 2026.'
        WHEN u.email = 'jessica.wilson.bride@test.com' THEN 'We''re planning to get married in Provence, France. About 100 guests.'
        ELSE 'Je vous envoie les détails par email.'
      END
    ELSE 'Super ! Je vais vous préparer une proposition personnalisée.'
  END,
  'text'::messageType,
  cr.created_at + CASE 
    WHEN msg_num = 1 THEN INTERVAL '2 hours'
    WHEN msg_num = 2 THEN INTERVAL '4 hours'
    WHEN msg_num = 3 THEN INTERVAL '1 day'
    ELSE INTERVAL '2 days'
  END
FROM chat_rooms cr
JOIN chat_room_participants crp ON cr.id = crp.room_id
JOIN auth.users u ON u.id = crp.profile_id,
generate_series(1, 3) AS msg_num
WHERE cr.created_at > now() - INTERVAL '30 days'
  AND u.raw_user_meta_data->>'seed_batch' = 'production_40_users'
  AND (
    -- Marie et Pierre Chenier
    (u.email = 'marie.martin.bride@test.com' OR u.email = 'pierre.chenier.photo@test.com')
    -- Sophie et Camille Roux  
    OR (u.email = 'sophie.dubois.bride@test.com' OR u.email = 'camille.roux.hair@test.com')
    -- Emily et Michael Rodriguez
    OR (u.email = 'emily.johnson.bride@test.com' OR u.email = 'michael.rodriguez.venue@test.com')
    -- Jessica et David Kim
    OR (u.email = 'jessica.wilson.bride@test.com' OR u.email = 'david.kim.filmmaker@test.com')
  )
  AND (
    -- Messages alternés : bride envoie 1 et 3, pro envoie 2
    (u.raw_user_meta_data->>'role' = 'bride' AND msg_num IN (1, 3))
    OR (u.raw_user_meta_data->>'role' = 'professional' AND msg_num = 2)
  );

COMMIT;

-- ========================================
-- PARTIE 10: CONNECTION REQUESTS
-- ========================================

BEGIN;

-- Créer les demandes de connexion en attente
INSERT INTO connection_requests (
  id,
  pro_profile_id,
  bride_profile_id,
  source,
  source_id,
  initial_message,
  status,
  created_at,
  initiator_id
)
SELECT 
  gen_random_uuid(),
  professional.id,
  bride.id,
  CASE 
    WHEN bride.email = 'emma.thompson.bride@test.com' THEN 'wishlist'::connectionRequestSource
    WHEN bride.email = 'sarah.davis.bride@test.com' THEN 'map'::connectionRequestSource
    ELSE 'weddingPin'::connectionRequestSource
  END,
  CASE 
    WHEN bride.email = 'emma.thompson.bride@test.com' THEN NULL -- wishlist_items n'a pas d'id, seulement clé composite
    ELSE NULL
  END,
  CASE 
    WHEN bride.email = 'emma.thompson.bride@test.com' THEN 'Bonjour ! Je vous ai ajouté à ma wishlist et j''aimerais discuter de votre disponibilité.'
    WHEN bride.email = 'sarah.davis.bride@test.com' THEN 'Bonjour ! J''ai vu votre profil sur la carte et votre travail m''intéresse beaucoup.'
    ELSE 'Bonjour ! Votre profil correspond parfaitement à mes critères de recherche.'
  END,
  'pending'::connectionRequestStatus,
  now() - INTERVAL '2 days',
  bride.id
FROM auth.users bride
CROSS JOIN auth.users professional
WHERE bride.raw_user_meta_data->>'seed_batch' = 'production_40_users' 
  AND bride.raw_user_meta_data->>'role' = 'bride'
  AND professional.raw_user_meta_data->>'seed_batch' = 'production_40_users'
  AND professional.raw_user_meta_data->>'role' = 'professional'
  AND bride.email IN ('emma.thompson.bride@test.com', 'sarah.davis.bride@test.com', 'yuki.tanaka.bride@test.com')
  AND (
    (bride.email = 'emma.thompson.bride@test.com' AND professional.email = 'robert.martinez.photo@test.com')
    OR (bride.email = 'sarah.davis.bride@test.com' AND professional.email = 'william.davies.photo@test.com')
    OR (bride.email = 'yuki.tanaka.bride@test.com' AND professional.email = 'hiroshi.sato.photo@test.com')
  );

COMMIT;

-- ========================================
-- PARTIE 11: PROFESSIONAL ALERTS
-- ========================================

BEGIN;

-- Créer les alerts pour les professionnels (uniquement Ultimate et Premium)
INSERT INTO professional_alerts (
  id,
  professional_profile_id,
  motif_code,
  title,
  description,
  max_participants,
  price_per_participant,
  location_coords,
  location_label,
  location_country_code,
  event_start_date,
  event_end_date,
  status,
  created_at,
  updated_at
)
SELECT 
  gen_random_uuid(),
  pd.profile_id,
  CASE 
    WHEN pd.business_name IN ('Pierre Chenier Photography', 'David Kim Films') THEN 'PHOTO_SHOOT'
    WHEN pd.business_name IN ('Camille Roux Hair Studio', 'Nicolas Petit Makeup') THEN 'BEAUTY_WORKSHOP'
    WHEN pd.business_name IN ('Isabelle Bernard Fleurs', 'Émilie Moreau Fleurs') THEN 'FLORAL_WORKSHOP'
    ELSE 'OPEN_HOUSE'
  END,
  CASE 
    WHEN pd.business_name = 'Pierre Chenier Photography' THEN 'Shooting Photo Couple Paris'
    WHEN pd.business_name = 'David Kim Films' THEN 'Wedding Filmmaking Workshop NYC'
    WHEN pd.business_name = 'Camille Roux Hair Studio' THEN 'Atelier Coiffure Mariage Paris'
    WHEN pd.business_name = 'Nicolas Petit Makeup' THEN 'Workshop Maquillage Mariage'
    WHEN pd.business_name = 'Isabelle Bernard Fleurs' THEN 'Atelier Composition Florale'
    ELSE 'Portes Ouvertes - Découvrez nos Services'
  END,
  CASE 
    WHEN pd.business_name = 'Pierre Chenier Photography' THEN 'Shooting photo professionnel pour couples en pleine préparation de mariage. Inclus : 2 heures de shooting, 10 photos retouchées.'
    WHEN pd.business_name = 'David Kim Films' THEN 'Workshop intensif sur les techniques de filmage de mariage. Théorie et pratique.'
    WHEN pd.business_name = 'Camille Roux Hair Studio' THEN 'Démonstration des dernières tendances coiffure mariage. Essais pratiques.'
    WHEN pd.business_name = 'Nicolas Petit Makeup' THEN 'Apprenez les secrets du maquillage de longue durée pour le grand jour.'
    WHEN pd.business_name = 'Isabelle Bernard Fleurs' THEN 'Créez votre propre bouquet de mariage avec nos fleuristes professionnels.'
    ELSE 'Venez découvrir nos installations et rencontrer nos équipes.'
  END,
  CASE 
    WHEN pd.business_name IN ('Pierre Chenier Photography', 'David Kim Films') THEN 5
    WHEN pd.business_name IN ('Camille Roux Hair Studio', 'Nicolas Petit Makeup') THEN 8
    ELSE 10
  END,
  CASE 
    WHEN pd.business_name = 'Pierre Chenier Photography' THEN 150
    WHEN pd.business_name = 'David Kim Films' THEN 200
    WHEN pd.business_name = 'Camille Roux Hair Studio' THEN 50
    WHEN pd.business_name = 'Nicolas Petit Makeup' THEN 75
    WHEN pd.business_name = 'Isabelle Bernard Fleurs' THEN 60
    ELSE 0
  END,
  pd.location_coords,
  pd.location_label,
  pd.location_country_code,
  CASE 
    WHEN pd.business_name = 'Pierre Chenier Photography' THEN now() + INTERVAL '2 weeks'
    WHEN pd.business_name = 'David Kim Films' THEN now() + INTERVAL '3 weeks'
    WHEN pd.business_name = 'Camille Roux Hair Studio' THEN now() + INTERVAL '10 days'
    WHEN pd.business_name = 'Nicolas Petit Makeup' THEN now() + INTERVAL '12 days'
    ELSE now() + INTERVAL '1 month'
  END,
  CASE 
    WHEN pd.business_name = 'Pierre Chenier Photography' THEN now() + INTERVAL '2 weeks' + INTERVAL '3 hours'
    WHEN pd.business_name = 'David Kim Films' THEN now() + INTERVAL '3 weeks' + INTERVAL '4 hours'
    WHEN pd.business_name = 'Camille Roux Hair Studio' THEN now() + INTERVAL '10 days' + INTERVAL '2 hours'
    WHEN pd.business_name = 'Nicolas Petit Makeup' THEN now() + INTERVAL '12 days' + INTERVAL '2 hours'
    ELSE now() + INTERVAL '1 month' + INTERVAL '3 hours'
  END,
  'active'::alertStatus,
  now() - INTERVAL '1 week',
  now()
FROM professional_details pd
JOIN professional_subscriptions ps ON pd.profile_id = ps.profile_id
WHERE ps.subscription_tier IN ('ultimateAccess', 'premiumVisibility')
  AND pd.business_name IN ('Pierre Chenier Photography', 'David Kim Films', 'Camille Roux Hair Studio', 'Nicolas Petit Makeup', 'Isabelle Bernard Fleurs');

COMMIT;

-- ========================================
-- PARTIE 12: VIDEO SESSIONS
-- ========================================

BEGIN;

-- Créer les sessions vidéo (pour les conversations actives)
INSERT INTO video_sessions (
  id,
  initiator_id,
  receiver_id,
  status,
  agora_channel_name,
  created_at,
  accepted_at,
  completed_at
)
SELECT 
  gen_random_uuid(),
  CASE 
    WHEN bride.email = 'marie.martin.bride@test.com' THEN bride.id
    ELSE professional.id
  END,
  CASE 
    WHEN bride.email = 'marie.martin.bride@test.com' THEN professional.id
    ELSE bride.id
  END,
  CASE 
    WHEN bride.email = 'marie.martin.bride@test.com' THEN 'completed'::videoSessionStatus
    WHEN bride.email = 'sophie.dubois.bride@test.com' THEN 'accepted'::videoSessionStatus
    ELSE 'pending'::videoSessionStatus
  END,
  'agora_' || gen_random_uuid()::text,
  CASE 
    WHEN bride.email = 'marie.martin.bride@test.com' THEN now() - INTERVAL '5 days'
    WHEN bride.email = 'sophie.dubois.bride@test.com' THEN now() - INTERVAL '2 days'
    ELSE now() - INTERVAL '6 hours'
  END,
  CASE 
    WHEN bride.email = 'marie.martin.bride@test.com' THEN now() - INTERVAL '5 days' + INTERVAL '1 hour'
    WHEN bride.email = 'sophie.dubois.bride@test.com' THEN now() - INTERVAL '2 days' + INTERVAL '2 hours'
    ELSE NULL
  END,
  CASE 
    WHEN bride.email = 'marie.martin.bride@test.com' THEN now() - INTERVAL '5 days' + INTERVAL '1 hour' + INTERVAL '45 minutes'
    ELSE NULL
  END
FROM auth.users bride
CROSS JOIN auth.users professional
WHERE bride.raw_user_meta_data->>'seed_batch' = 'production_40_users' 
  AND bride.raw_user_meta_data->>'role' = 'bride'
  AND professional.raw_user_meta_data->>'seed_batch' = 'production_40_users'
  AND professional.raw_user_meta_data->>'role' = 'professional'
  AND bride.email IN ('marie.martin.bride@test.com', 'sophie.dubois.bride@test.com', 'emily.johnson.bride@test.com')
  AND (
    (bride.email = 'marie.martin.bride@test.com' AND professional.email = 'pierre.chenier.photo@test.com')
    OR (bride.email = 'sophie.dubois.bride@test.com' AND professional.email = 'camille.roux.hair@test.com')
    OR (bride.email = 'emily.johnson.bride@test.com' AND professional.email = 'michael.rodriguez.venue@test.com')
  );

COMMIT;

SELECT 
  p.role,
  ps.subscription_tier,
  COUNT(*) as count
FROM profiles p
LEFT JOIN professional_subscriptions ps ON p.id = ps.profile_id
WHERE p.id IN (
  SELECT u.id FROM auth.users u 
  WHERE u.raw_user_meta_data->>'seed_batch' = 'production_40_users'
)
GROUP BY p.role, ps.subscription_tier 
ORDER BY p.role, ps.subscription_tier;

-- Compter les adresses fixes
SELECT 
  COUNT(*) as total_fixed_locations
FROM professional_fixed_locations pfl
WHERE pfl.professional_profile_id IN (
  SELECT u.id FROM auth.users u 
  WHERE u.raw_user_meta_data->>'seed_batch' = 'production_40_users'
    AND u.raw_user_meta_data->>'role' = 'professional'
);

-- ========================================
-- RÉSUMÉ FINAL ATTENDU
-- ========================================
-- Total utilisateurs: 40 (10 brides + 30 professionnels)
-- Répartition abonnements: 
--   - trial: 4 professionnels (0 adresses fixes)
--   - premiumVisibility: 6 professionnels (2 adresses fixes chacun = 12 total)
--   - ultimateAccess: 20 professionnels (4 adresses fixes chacun = 80 total)
-- Fixed points: 92 adresses fixes (besoin de 8 adresses supplémentaires pour atteindre 100)
-- ========================================
