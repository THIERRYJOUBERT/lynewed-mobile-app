/// Country center coordinates for map display
/// 
/// When a wedding is created with only a country (no specific address),
/// these coordinates are used to place the marker on the map.
/// 
/// Coordinates are approximate geographic centers of each country.
library;

/// Map of country ISO2 codes to their center coordinates [latitude, longitude]
const Map<String, List<double>> countryCoordinates = {
  // Europe
  'AL': [41.1533, 20.1683],    // Albania
  'AD': [42.5063, 1.5218],     // Andorra
  'AT': [47.5162, 14.5501],    // Austria
  'BY': [53.7098, 27.9534],    // Belarus
  'BE': [50.5039, 4.4699],     // Belgium
  'BA': [43.9159, 17.6791],    // Bosnia and Herzegovina
  'BG': [42.7339, 25.4858],    // Bulgaria
  'HR': [45.1000, 15.2000],    // Croatia
  'CY': [35.1264, 33.4299],    // Cyprus
  'CZ': [49.8175, 15.4730],    // Czech Republic
  'DK': [56.2639, 9.5018],     // Denmark
  'EE': [58.5953, 25.0136],    // Estonia
  'FI': [61.9241, 25.7482],    // Finland
  'FR': [46.2276, 2.2137],     // France
  'DE': [51.1657, 10.4515],    // Germany
  'GR': [39.0742, 21.8243],    // Greece
  'HU': [47.1625, 19.5033],    // Hungary
  'IS': [64.9631, -19.0208],   // Iceland
  'IE': [53.1424, -7.6921],    // Ireland
  'IT': [41.8719, 12.5674],    // Italy
  'XK': [42.6026, 20.9030],    // Kosovo
  'LV': [56.8796, 24.6032],    // Latvia
  'LI': [47.1660, 9.5554],     // Liechtenstein
  'LT': [55.1694, 23.8813],    // Lithuania
  'LU': [49.8153, 6.1296],     // Luxembourg
  'MT': [35.9375, 14.3754],    // Malta
  'MD': [47.4116, 28.3699],    // Moldova
  'MC': [43.7384, 7.4246],     // Monaco
  'ME': [42.7087, 19.3744],    // Montenegro
  'NL': [52.1326, 5.2913],     // Netherlands
  'MK': [41.5124, 21.7453],    // North Macedonia
  'NO': [60.4720, 8.4689],     // Norway
  'PL': [51.9194, 19.1451],    // Poland
  'PT': [39.3999, -8.2245],    // Portugal
  'RO': [45.9432, 24.9668],    // Romania
  'RU': [61.5240, 105.3188],   // Russia
  'SM': [43.9424, 12.4578],    // San Marino
  'RS': [44.0165, 21.0059],    // Serbia
  'SK': [48.6690, 19.6990],    // Slovakia
  'SI': [46.1512, 14.9955],    // Slovenia
  'ES': [40.4637, -3.7492],    // Spain
  'SE': [60.1282, 18.6435],    // Sweden
  'CH': [46.8182, 8.2275],     // Switzerland
  'UA': [48.3794, 31.1656],    // Ukraine
  'GB': [55.3781, -3.4360],    // United Kingdom
  'VA': [41.9029, 12.4534],    // Vatican City
  
  // North America
  'CA': [56.1304, -106.3468],  // Canada
  'US': [37.0902, -95.7129],   // United States
  'MX': [23.6345, -102.5528],  // Mexico
  
  // Central America & Caribbean
  'BS': [25.0343, -77.3963],   // Bahamas
  'BB': [13.1939, -59.5432],   // Barbados
  'BZ': [17.1899, -88.4976],   // Belize
  'CR': [9.7489, -83.7534],    // Costa Rica
  'CU': [21.5218, -77.7812],   // Cuba
  'DM': [15.4150, -61.3710],   // Dominica
  'DO': [18.7357, -70.1627],   // Dominican Republic
  'SV': [13.7942, -88.8965],   // El Salvador
  'GD': [12.1165, -61.6790],   // Grenada
  'GT': [15.7835, -90.2308],   // Guatemala
  'HT': [18.9712, -72.2852],   // Haiti
  'HN': [15.2000, -86.2419],   // Honduras
  'JM': [18.1096, -77.2975],   // Jamaica
  'NI': [12.8654, -85.2072],   // Nicaragua
  'PA': [8.5380, -80.7821],    // Panama
  'PR': [18.2208, -66.5901],   // Puerto Rico
  'TT': [10.6918, -61.2225],   // Trinidad and Tobago
  
  // South America
  'AR': [-38.4161, -63.6167],  // Argentina
  'BO': [-16.2902, -63.5887],  // Bolivia
  'BR': [-14.2350, -51.9253],  // Brazil
  'CL': [-35.6751, -71.5430],  // Chile
  'CO': [4.5709, -74.2973],    // Colombia
  'EC': [-1.8312, -78.1834],   // Ecuador
  'GY': [4.8604, -58.9302],    // Guyana
  'PY': [-23.4425, -58.4438],  // Paraguay
  'PE': [-9.1900, -75.0152],   // Peru
  'SR': [3.9193, -56.0278],    // Suriname
  'UY': [-32.5228, -55.7658],  // Uruguay
  'VE': [6.4238, -66.5897],    // Venezuela
  
  // Africa
  'DZ': [28.0339, 1.6596],     // Algeria
  'AO': [-11.2027, 17.8739],   // Angola
  'BJ': [9.3077, 2.3158],      // Benin
  'BW': [-22.3285, 24.6849],   // Botswana
  'BF': [12.2383, -1.5616],    // Burkina Faso
  'BI': [-3.3731, 29.9189],    // Burundi
  'CM': [7.3697, 12.3547],     // Cameroon
  'CV': [16.5388, -23.0418],   // Cape Verde
  'CF': [6.6111, 20.9394],     // Central African Republic
  'TD': [15.4542, 18.7322],    // Chad
  'KM': [-11.6455, 43.3333],   // Comoros
  'CG': [-0.2280, 15.8277],    // Congo
  'CD': [-4.0383, 21.7587],    // DR Congo
  'DJ': [11.8251, 42.5903],    // Djibouti
  'EG': [26.8206, 30.8025],    // Egypt
  'GQ': [1.6508, 10.2679],     // Equatorial Guinea
  'ER': [15.1794, 39.7823],    // Eritrea
  'SZ': [-26.5225, 31.4659],   // Eswatini
  'ET': [9.1450, 40.4897],     // Ethiopia
  'GA': [-0.8037, 11.6094],    // Gabon
  'GM': [13.4432, -15.3101],   // Gambia
  'GH': [7.9465, -1.0232],     // Ghana
  'GN': [9.9456, -9.6966],     // Guinea
  'GW': [11.8037, -15.1804],   // Guinea-Bissau
  'CI': [7.5400, -5.5471],     // Ivory Coast
  'KE': [-0.0236, 37.9062],    // Kenya
  'LS': [-29.6100, 28.2336],   // Lesotho
  'LR': [6.4281, -9.4295],     // Liberia
  'LY': [26.3351, 17.2283],    // Libya
  'MG': [-18.7669, 46.8691],   // Madagascar
  'MW': [-13.2543, 34.3015],   // Malawi
  'ML': [17.5707, -3.9962],    // Mali
  'MR': [21.0079, -10.9408],   // Mauritania
  'MU': [-20.3484, 57.5522],   // Mauritius
  'MA': [31.7917, -7.0926],    // Morocco
  'MZ': [-18.6657, 35.5296],   // Mozambique
  'NA': [-22.9576, 18.4904],   // Namibia
  'NE': [17.6078, 8.0817],     // Niger
  'NG': [9.0820, 8.6753],      // Nigeria
  'RW': [-1.9403, 29.8739],    // Rwanda
  'ST': [0.1864, 6.6131],      // Sao Tome and Principe
  'SN': [14.4974, -14.4524],   // Senegal
  'SC': [-4.6796, 55.4920],    // Seychelles
  'SL': [8.4606, -11.7799],    // Sierra Leone
  'SO': [5.1521, 46.1996],     // Somalia
  'ZA': [-30.5595, 22.9375],   // South Africa
  'SS': [6.8770, 31.3070],     // South Sudan
  'SD': [12.8628, 30.2176],    // Sudan
  'TZ': [-6.3690, 34.8888],    // Tanzania
  'TG': [8.6195, 0.8248],      // Togo
  'TN': [33.8869, 9.5375],     // Tunisia
  'UG': [1.3733, 32.2903],     // Uganda
  'ZM': [-13.1339, 27.8493],   // Zambia
  'ZW': [-19.0154, 29.1549],   // Zimbabwe
  
  // Middle East
  'BH': [26.0667, 50.5577],    // Bahrain
  'IR': [32.4279, 53.6880],    // Iran
  'IQ': [33.2232, 43.6793],    // Iraq
  'IL': [31.0461, 34.8516],    // Israel
  'JO': [30.5852, 36.2384],    // Jordan
  'KW': [29.3117, 47.4818],    // Kuwait
  'LB': [33.8547, 35.8623],    // Lebanon
  'OM': [21.4735, 55.9754],    // Oman
  'PS': [31.9522, 35.2332],    // Palestine
  'QA': [25.3548, 51.1839],    // Qatar
  'SA': [23.8859, 45.0792],    // Saudi Arabia
  'SY': [34.8021, 38.9968],    // Syria
  'TR': [38.9637, 35.2433],    // Turkey
  'AE': [23.4241, 53.8478],    // UAE
  'YE': [15.5527, 48.5164],    // Yemen
  
  // Asia
  'AF': [33.9391, 67.7100],    // Afghanistan
  'AM': [40.0691, 45.0382],    // Armenia
  'AZ': [40.1431, 47.5769],    // Azerbaijan
  'BD': [23.6850, 90.3563],    // Bangladesh
  'BT': [27.5142, 90.4336],    // Bhutan
  'BN': [4.5353, 114.7277],    // Brunei
  'KH': [12.5657, 104.9910],   // Cambodia
  'CN': [35.8617, 104.1954],   // China
  'GE': [42.3154, 43.3569],    // Georgia
  'HK': [22.3193, 114.1694],   // Hong Kong
  'IN': [20.5937, 78.9629],    // India
  'ID': [-0.7893, 113.9213],   // Indonesia
  'JP': [36.2048, 138.2529],   // Japan
  'KZ': [48.0196, 66.9237],    // Kazakhstan
  'KG': [41.2044, 74.7661],    // Kyrgyzstan
  'LA': [19.8563, 102.4955],   // Laos
  'MO': [22.1987, 113.5439],   // Macau
  'MY': [4.2105, 101.9758],    // Malaysia
  'MV': [3.2028, 73.2207],     // Maldives
  'MN': [46.8625, 103.8467],   // Mongolia
  'MM': [21.9162, 95.9560],    // Myanmar
  'NP': [28.3949, 84.1240],    // Nepal
  'KP': [40.3399, 127.5101],   // North Korea
  'PK': [30.3753, 69.3451],    // Pakistan
  'PH': [12.8797, 121.7740],   // Philippines
  'SG': [1.3521, 103.8198],    // Singapore
  'KR': [35.9078, 127.7669],   // South Korea
  'LK': [7.8731, 80.7718],     // Sri Lanka
  'TW': [23.6978, 120.9605],   // Taiwan
  'TJ': [38.8610, 71.2761],    // Tajikistan
  'TH': [15.8700, 100.9925],   // Thailand
  'TL': [-8.8742, 125.7275],   // Timor-Leste
  'TM': [38.9697, 59.5563],    // Turkmenistan
  'UZ': [41.3775, 64.5853],    // Uzbekistan
  'VN': [14.0583, 108.2772],   // Vietnam
  
  // Oceania
  'AU': [-25.2744, 133.7751],  // Australia
  'FJ': [-17.7134, 178.0650],  // Fiji
  'KI': [-3.3704, -168.7340], // Kiribati
  'MH': [7.1315, 171.1845],    // Marshall Islands
  'FM': [7.4256, 150.5508],    // Micronesia
  'NR': [-0.5228, 166.9315],   // Nauru
  'NZ': [-40.9006, 174.8860],  // New Zealand
  'PW': [7.5150, 134.5825],    // Palau
  'PG': [-6.3150, 143.9555],   // Papua New Guinea
  'WS': [-13.7590, -172.1046], // Samoa
  'SB': [-9.6457, 160.1562],   // Solomon Islands
  'TO': [-21.1790, -175.1982], // Tonga
  'TV': [-7.1095, 177.6493],   // Tuvalu
  'VU': [-15.3767, 166.9592],  // Vanuatu
  
  // French Overseas
  'GF': [3.9339, -53.1258],    // French Guiana
  'PF': [-17.6797, -149.4068], // French Polynesia
  'GP': [16.2650, -61.5510],   // Guadeloupe
  'MQ': [14.6415, -61.0242],   // Martinique
  'YT': [-12.8275, 45.1662],   // Mayotte
  'NC': [-20.9043, 165.6180],  // New Caledonia
  'RE': [-21.1151, 55.5364],   // Reunion
  'BL': [17.9000, -62.8333],   // Saint Barthelemy
  'MF': [18.0708, -63.0501],   // Saint Martin
  'PM': [46.9419, -56.2711],   // Saint Pierre and Miquelon
  'WF': [-13.7687, -177.1561], // Wallis and Futuna
};

/// Get center coordinates for a country by ISO2 code
/// Returns [latitude, longitude] or null if not found
List<double>? getCountryCenter(String? countryCode) {
  if (countryCode == null || countryCode.isEmpty) return null;
  return countryCoordinates[countryCode.toUpperCase()];
}

/// Get latitude for a country by ISO2 code
double? getCountryLatitude(String? countryCode) {
  final coords = getCountryCenter(countryCode);
  return coords?[0];
}

/// Get longitude for a country by ISO2 code
double? getCountryLongitude(String? countryCode) {
  final coords = getCountryCenter(countryCode);
  return coords?[1];
}
