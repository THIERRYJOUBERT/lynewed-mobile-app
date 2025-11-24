// Country filter enum for feed search
enum CountryFilter {
  world('', 'World'),
  france('FR', 'France'),
  belgium('BE', 'Belgium'),
  switzerland('CH', 'Switzerland'),
  luxembourg('LU', 'Luxembourg'),
  monaco('MC', 'Monaco'),
  spain('ES', 'Spain'),
  italy('IT', 'Italy'),
  germany('DE', 'Germany'),
  portugal('PT', 'Portugal'),
  netherlands('NL', 'Netherlands'),
  unitedKingdom('GB', 'United Kingdom'),
  ireland('IE', 'Ireland'),
  austria('AT', 'Austria'),
  denmark('DK', 'Denmark'),
  sweden('SE', 'Sweden'),
  norway('NO', 'Norway'),
  finland('FI', 'Finland'),
  poland('PL', 'Poland'),
  czechRepublic('CZ', 'Czech Republic'),
  greece('GR', 'Greece'),
  croatia('HR', 'Croatia'),
  canada('CA', 'Canada'),
  usa('US', 'United States'),
  mexico('MX', 'Mexico'),
  brazil('BR', 'Brazil'),
  argentina('AR', 'Argentina'),
  morocco('MA', 'Morocco'),
  tunisia('TN', 'Tunisia'),
  algeria('DZ', 'Algeria'),
  senegal('SN', 'Senegal'),
  ivoryCoast('CI', 'Ivory Coast'),
  mauritius('MU', 'Mauritius'),
  reunion('RE', 'Reunion'),
  newCaledonia('NC', 'New Caledonia'),
  frenchPolynesia('PF', 'French Polynesia'),
  guadeloupe('GP', 'Guadeloupe'),
  martinique('MQ', 'Martinique'),
  guyana('GF', 'French Guiana'),
  mayotte('YT', 'Mayotte');

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
}
