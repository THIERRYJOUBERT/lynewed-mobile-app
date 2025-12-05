// Country filter enum for feed search - Complete world list with search aliases
enum CountryFilter {
  // Special
  world('', 'World'),
  
  // Europe
  albania('AL', 'Albania'),
  andorra('AD', 'Andorra'),
  austria('AT', 'Austria'),
  belarus('BY', 'Belarus'),
  belgium('BE', 'Belgium'),
  bosniaHerzegovina('BA', 'Bosnia and Herzegovina'),
  bulgaria('BG', 'Bulgaria'),
  croatia('HR', 'Croatia'),
  cyprus('CY', 'Cyprus'),
  czechRepublic('CZ', 'Czech Republic'),
  denmark('DK', 'Denmark'),
  estonia('EE', 'Estonia'),
  finland('FI', 'Finland'),
  france('FR', 'France'),
  germany('DE', 'Germany'),
  greece('GR', 'Greece'),
  hungary('HU', 'Hungary'),
  iceland('IS', 'Iceland'),
  ireland('IE', 'Ireland'),
  italy('IT', 'Italy'),
  kosovo('XK', 'Kosovo'),
  latvia('LV', 'Latvia'),
  liechtenstein('LI', 'Liechtenstein'),
  lithuania('LT', 'Lithuania'),
  luxembourg('LU', 'Luxembourg'),
  malta('MT', 'Malta'),
  moldova('MD', 'Moldova'),
  monaco('MC', 'Monaco'),
  montenegro('ME', 'Montenegro'),
  netherlands('NL', 'Netherlands'),
  northMacedonia('MK', 'North Macedonia'),
  norway('NO', 'Norway'),
  poland('PL', 'Poland'),
  portugal('PT', 'Portugal'),
  romania('RO', 'Romania'),
  russia('RU', 'Russia'),
  sanMarino('SM', 'San Marino'),
  serbia('RS', 'Serbia'),
  slovakia('SK', 'Slovakia'),
  slovenia('SI', 'Slovenia'),
  spain('ES', 'Spain'),
  sweden('SE', 'Sweden'),
  switzerland('CH', 'Switzerland'),
  ukraine('UA', 'Ukraine'),
  unitedKingdom('GB', 'United Kingdom'),
  vatican('VA', 'Vatican City'),
  
  // North America
  canada('CA', 'Canada'),
  usa('US', 'United States'),
  mexico('MX', 'Mexico'),
  
  // Central America & Caribbean
  bahamas('BS', 'Bahamas'),
  barbados('BB', 'Barbados'),
  belize('BZ', 'Belize'),
  costaRica('CR', 'Costa Rica'),
  cuba('CU', 'Cuba'),
  dominica('DM', 'Dominica'),
  dominicanRepublic('DO', 'Dominican Republic'),
  elSalvador('SV', 'El Salvador'),
  grenada('GD', 'Grenada'),
  guatemala('GT', 'Guatemala'),
  haiti('HT', 'Haiti'),
  honduras('HN', 'Honduras'),
  jamaica('JM', 'Jamaica'),
  nicaragua('NI', 'Nicaragua'),
  panama('PA', 'Panama'),
  puertoRico('PR', 'Puerto Rico'),
  trinidadTobago('TT', 'Trinidad and Tobago'),
  
  // South America
  argentina('AR', 'Argentina'),
  bolivia('BO', 'Bolivia'),
  brazil('BR', 'Brazil'),
  chile('CL', 'Chile'),
  colombia('CO', 'Colombia'),
  ecuador('EC', 'Ecuador'),
  guyana('GY', 'Guyana'),
  paraguay('PY', 'Paraguay'),
  peru('PE', 'Peru'),
  suriname('SR', 'Suriname'),
  uruguay('UY', 'Uruguay'),
  venezuela('VE', 'Venezuela'),
  
  // Africa
  algeria('DZ', 'Algeria'),
  angola('AO', 'Angola'),
  benin('BJ', 'Benin'),
  botswana('BW', 'Botswana'),
  burkinaFaso('BF', 'Burkina Faso'),
  burundi('BI', 'Burundi'),
  cameroon('CM', 'Cameroon'),
  capeVerde('CV', 'Cape Verde'),
  centralAfricanRepublic('CF', 'Central African Republic'),
  chad('TD', 'Chad'),
  comoros('KM', 'Comoros'),
  congoDRC('CD', 'DR Congo'),
  congoRepublic('CG', 'Republic of Congo'),
  ivoryCoast('CI', 'Ivory Coast'),
  djibouti('DJ', 'Djibouti'),
  egypt('EG', 'Egypt'),
  equatorialGuinea('GQ', 'Equatorial Guinea'),
  eritrea('ER', 'Eritrea'),
  eswatini('SZ', 'Eswatini'),
  ethiopia('ET', 'Ethiopia'),
  gabon('GA', 'Gabon'),
  gambia('GM', 'Gambia'),
  ghana('GH', 'Ghana'),
  guinea('GN', 'Guinea'),
  guineaBissau('GW', 'Guinea-Bissau'),
  kenya('KE', 'Kenya'),
  lesotho('LS', 'Lesotho'),
  liberia('LR', 'Liberia'),
  libya('LY', 'Libya'),
  madagascar('MG', 'Madagascar'),
  malawi('MW', 'Malawi'),
  mali('ML', 'Mali'),
  mauritania('MR', 'Mauritania'),
  mauritius('MU', 'Mauritius'),
  morocco('MA', 'Morocco'),
  mozambique('MZ', 'Mozambique'),
  namibia('NA', 'Namibia'),
  niger('NE', 'Niger'),
  nigeria('NG', 'Nigeria'),
  rwanda('RW', 'Rwanda'),
  saoTomePrincipe('ST', 'Sao Tome and Principe'),
  senegal('SN', 'Senegal'),
  seychelles('SC', 'Seychelles'),
  sierraLeone('SL', 'Sierra Leone'),
  somalia('SO', 'Somalia'),
  southAfrica('ZA', 'South Africa'),
  southSudan('SS', 'South Sudan'),
  sudan('SD', 'Sudan'),
  tanzania('TZ', 'Tanzania'),
  togo('TG', 'Togo'),
  tunisia('TN', 'Tunisia'),
  uganda('UG', 'Uganda'),
  zambia('ZM', 'Zambia'),
  zimbabwe('ZW', 'Zimbabwe'),
  
  // Middle East
  bahrain('BH', 'Bahrain'),
  iran('IR', 'Iran'),
  iraq('IQ', 'Iraq'),
  israel('IL', 'Israel'),
  jordan('JO', 'Jordan'),
  kuwait('KW', 'Kuwait'),
  lebanon('LB', 'Lebanon'),
  oman('OM', 'Oman'),
  palestine('PS', 'Palestine'),
  qatar('QA', 'Qatar'),
  saudiArabia('SA', 'Saudi Arabia'),
  syria('SY', 'Syria'),
  turkey('TR', 'Turkey'),
  uae('AE', 'United Arab Emirates'),
  yemen('YE', 'Yemen'),
  
  // Asia
  afghanistan('AF', 'Afghanistan'),
  armenia('AM', 'Armenia'),
  azerbaijan('AZ', 'Azerbaijan'),
  bangladesh('BD', 'Bangladesh'),
  bhutan('BT', 'Bhutan'),
  brunei('BN', 'Brunei'),
  cambodia('KH', 'Cambodia'),
  china('CN', 'China'),
  georgia('GE', 'Georgia'),
  hongKong('HK', 'Hong Kong'),
  indonesia('ID', 'Indonesia'),
  japan('JP', 'Japan'),
  kazakhstan('KZ', 'Kazakhstan'),
  kyrgyzstan('KG', 'Kyrgyzstan'),
  laos('LA', 'Laos'),
  macau('MO', 'Macau'),
  malaysia('MY', 'Malaysia'),
  maldives('MV', 'Maldives'),
  mongolia('MN', 'Mongolia'),
  myanmar('MM', 'Myanmar'),
  nepal('NP', 'Nepal'),
  northKorea('KP', 'North Korea'),
  pakistan('PK', 'Pakistan'),
  philippines('PH', 'Philippines'),
  singapore('SG', 'Singapore'),
  southKorea('KR', 'South Korea'),
  sriLanka('LK', 'Sri Lanka'),
  taiwan('TW', 'Taiwan'),
  tajikistan('TJ', 'Tajikistan'),
  thailand('TH', 'Thailand'),
  timorLeste('TL', 'Timor-Leste'),
  turkmenistan('TM', 'Turkmenistan'),
  uzbekistan('UZ', 'Uzbekistan'),
  vietnam('VN', 'Vietnam'),
  
  // Oceania
  australia('AU', 'Australia'),
  fiji('FJ', 'Fiji'),
  kiribati('KI', 'Kiribati'),
  marshallIslands('MH', 'Marshall Islands'),
  micronesia('FM', 'Micronesia'),
  nauru('NR', 'Nauru'),
  newZealand('NZ', 'New Zealand'),
  palau('PW', 'Palau'),
  papuaNewGuinea('PG', 'Papua New Guinea'),
  samoa('WS', 'Samoa'),
  solomonIslands('SB', 'Solomon Islands'),
  tonga('TO', 'Tonga'),
  tuvalu('TV', 'Tuvalu'),
  vanuatu('VU', 'Vanuatu'),
  
  // French Overseas
  frenchGuiana('GF', 'French Guiana'),
  frenchPolynesia('PF', 'French Polynesia'),
  guadeloupe('GP', 'Guadeloupe'),
  martinique('MQ', 'Martinique'),
  mayotte('YT', 'Mayotte'),
  newCaledonia('NC', 'New Caledonia'),
  reunion('RE', 'Reunion'),
  saintBarthelemy('BL', 'Saint Barthelemy'),
  saintMartin('MF', 'Saint Martin'),
  saintPierreMiquelon('PM', 'Saint Pierre and Miquelon'),
  wallisAndFutuna('WF', 'Wallis and Futuna'),
  
  // 🇮🇳 India - only visible to Indian users
  india('IN', 'India');

  const CountryFilter(this.code, this.displayName);

  final String code;
  final String displayName;

  static CountryFilter fromCode(String? code) {
    if (code == null || code.isEmpty) return CountryFilter.world;
    return CountryFilter.values.firstWhere(
      (c) => c.code == code,
      orElse: () => CountryFilter.world,
    );
  }

  bool get isWorld => this == CountryFilter.world;
  
  /// Check if this is India
  bool get isIndia => this == CountryFilter.india;
  
  /// Get countries available for GLOBAL market (excludes India)
  static List<CountryFilter> get globalMarketCountries {
    return CountryFilter.values.where((c) => c != CountryFilter.india).toList();
  }
  
  /// Get countries available for IN market (only India, no world option)
  static List<CountryFilter> get indiaMarketCountries {
    return [CountryFilter.india];
  }
  
  /// Search aliases for multi-language/synonym search
  List<String> get searchAliases {
    switch (this) {
      case CountryFilter.world:
        return ['world', 'monde', 'mundial', 'all', 'tous', 'global', 'worldwide'];
      case CountryFilter.usa:
        return ['usa', 'us', 'united states', 'america', 'états-unis', 'etats-unis', 'états unis', 'etats unis', 'eeuu', 'estados unidos', 'amerique', 'amérique'];
      case CountryFilter.unitedKingdom:
        return ['uk', 'gb', 'united kingdom', 'great britain', 'england', 'britain', 'royaume-uni', 'royaume uni', 'angleterre', 'grande bretagne'];
      case CountryFilter.uae:
        return ['uae', 'emirates', 'united arab emirates', 'dubai', 'abu dhabi', 'émirats', 'emirats'];
      case CountryFilter.france:
        return ['france', 'fr', 'francia', 'frankreich'];
      case CountryFilter.germany:
        return ['germany', 'deutschland', 'allemagne', 'alemania'];
      case CountryFilter.spain:
        return ['spain', 'españa', 'espagne', 'espana'];
      case CountryFilter.italy:
        return ['italy', 'italia', 'italie'];
      case CountryFilter.netherlands:
        return ['netherlands', 'holland', 'pays-bas', 'pays bas', 'hollande', 'holanda'];
      case CountryFilter.belgium:
        return ['belgium', 'belgique', 'belgie', 'belgien'];
      case CountryFilter.switzerland:
        return ['switzerland', 'suisse', 'schweiz', 'svizzera', 'suiza'];
      case CountryFilter.portugal:
        return ['portugal'];
      case CountryFilter.austria:
        return ['austria', 'autriche', 'österreich', 'osterreich'];
      case CountryFilter.greece:
        return ['greece', 'grèce', 'grece', 'hellas', 'grecia'];
      case CountryFilter.poland:
        return ['poland', 'pologne', 'polska', 'polonia'];
      case CountryFilter.czechRepublic:
        return ['czech', 'czechia', 'czech republic', 'tchéquie', 'tchequie', 'république tchèque'];
      case CountryFilter.hungary:
        return ['hungary', 'hongrie', 'magyarország', 'hungria'];
      case CountryFilter.romania:
        return ['romania', 'roumanie', 'rumania'];
      case CountryFilter.sweden:
        return ['sweden', 'suède', 'suede', 'sverige'];
      case CountryFilter.norway:
        return ['norway', 'norvège', 'norvege', 'norge'];
      case CountryFilter.denmark:
        return ['denmark', 'danemark', 'danmark'];
      case CountryFilter.finland:
        return ['finland', 'finlande', 'suomi'];
      case CountryFilter.ireland:
        return ['ireland', 'irlande', 'eire'];
      case CountryFilter.russia:
        return ['russia', 'russie', 'россия', 'rusia'];
      case CountryFilter.ukraine:
        return ['ukraine', 'україна'];
      case CountryFilter.turkey:
        return ['turkey', 'turquie', 'türkiye', 'turkiye', 'turquia'];
      case CountryFilter.canada:
        return ['canada', 'kanada'];
      case CountryFilter.mexico:
        return ['mexico', 'mexique', 'méxico'];
      case CountryFilter.brazil:
        return ['brazil', 'brésil', 'bresil', 'brasil'];
      case CountryFilter.argentina:
        return ['argentina', 'argentine'];
      case CountryFilter.colombia:
        return ['colombia', 'colombie'];
      case CountryFilter.chile:
        return ['chile', 'chili'];
      case CountryFilter.peru:
        return ['peru', 'pérou', 'perou'];
      case CountryFilter.australia:
        return ['australia', 'australie', 'oz', 'aussie'];
      case CountryFilter.newZealand:
        return ['new zealand', 'nouvelle-zélande', 'nouvelle zelande', 'nz', 'kiwi'];
      case CountryFilter.japan:
        return ['japan', 'japon', 'nippon', '日本'];
      case CountryFilter.china:
        return ['china', 'chine', '中国', 'zhongguo'];
      case CountryFilter.southKorea:
        return ['south korea', 'korea', 'corée du sud', 'coree', 'corea'];
      case CountryFilter.thailand:
        return ['thailand', 'thaïlande', 'thailande'];
      case CountryFilter.vietnam:
        return ['vietnam', 'viêt nam', 'viet nam'];
      case CountryFilter.indonesia:
        return ['indonesia', 'indonésie', 'indonesie'];
      case CountryFilter.malaysia:
        return ['malaysia', 'malaisie'];
      case CountryFilter.singapore:
        return ['singapore', 'singapour'];
      case CountryFilter.philippines:
        return ['philippines', 'filipinas'];
      case CountryFilter.india:
        return ['india', 'inde', 'bharat', 'hindustan'];
      case CountryFilter.pakistan:
        return ['pakistan'];
      case CountryFilter.bangladesh:
        return ['bangladesh'];
      case CountryFilter.sriLanka:
        return ['sri lanka', 'ceylon', 'ceylan'];
      case CountryFilter.nepal:
        return ['nepal', 'népal'];
      case CountryFilter.egypt:
        return ['egypt', 'égypte', 'egypte', 'misr'];
      case CountryFilter.morocco:
        return ['morocco', 'maroc', 'marruecos'];
      case CountryFilter.southAfrica:
        return ['south africa', 'afrique du sud', 'sudáfrica'];
      case CountryFilter.nigeria:
        return ['nigeria', 'nigéria'];
      case CountryFilter.kenya:
        return ['kenya'];
      case CountryFilter.ghana:
        return ['ghana'];
      case CountryFilter.senegal:
        return ['senegal', 'sénégal'];
      case CountryFilter.ivoryCoast:
        return ['ivory coast', "côte d'ivoire", 'cote divoire', 'costa de marfil'];
      case CountryFilter.algeria:
        return ['algeria', 'algérie', 'algerie'];
      case CountryFilter.tunisia:
        return ['tunisia', 'tunisie'];
      case CountryFilter.saudiArabia:
        return ['saudi arabia', 'arabie saoudite', 'saudi', 'ksa'];
      case CountryFilter.israel:
        return ['israel', 'israël'];
      case CountryFilter.lebanon:
        return ['lebanon', 'liban', 'lubnan'];
      case CountryFilter.jordan:
        return ['jordan', 'jordanie'];
      case CountryFilter.qatar:
        return ['qatar'];
      case CountryFilter.kuwait:
        return ['kuwait', 'koweït', 'koweit'];
      case CountryFilter.bahrain:
        return ['bahrain', 'bahreïn', 'bahrein'];
      case CountryFilter.oman:
        return ['oman'];
      case CountryFilter.hongKong:
        return ['hong kong', 'hongkong', 'hk'];
      case CountryFilter.taiwan:
        return ['taiwan', 'taïwan'];
      case CountryFilter.macau:
        return ['macau', 'macao'];
      // French overseas
      case CountryFilter.reunion:
        return ['reunion', 'réunion', 'la réunion'];
      case CountryFilter.martinique:
        return ['martinique'];
      case CountryFilter.guadeloupe:
        return ['guadeloupe'];
      case CountryFilter.frenchGuiana:
        return ['french guiana', 'guyane', 'guyane française'];
      case CountryFilter.mayotte:
        return ['mayotte'];
      case CountryFilter.newCaledonia:
        return ['new caledonia', 'nouvelle-calédonie', 'nouvelle caledonie'];
      case CountryFilter.frenchPolynesia:
        return ['french polynesia', 'polynésie française', 'polynesie', 'tahiti'];
      case CountryFilter.saintBarthelemy:
        return ['saint barthelemy', 'st barts', 'saint barth'];
      case CountryFilter.saintMartin:
        return ['saint martin', 'st martin'];
      default:
        return [displayName.toLowerCase()];
    }
  }
  
  /// Check if this country matches a search query (checks name, code, and aliases)
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase().trim();
    
    // Check display name
    if (displayName.toLowerCase().contains(q)) return true;
    
    // Check country code
    if (code.toLowerCase() == q) return true;
    
    // Check aliases
    for (final alias in searchAliases) {
      if (alias.contains(q)) return true;
    }
    
    return false;
  }
  
  /// Filter countries by search query
  static List<CountryFilter> search(String query, {bool excludeIndia = true}) {
    final countries = excludeIndia ? globalMarketCountries : CountryFilter.values.toList();
    if (query.isEmpty) return countries;
    return countries.where((c) => c.matchesSearch(query)).toList();
  }
}
