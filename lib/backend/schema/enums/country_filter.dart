// Country filter enum for feed search
enum CountryFilter {
  world('', '🌍 Monde'),
  france('FR', '🇫🇷 France'),
  belgium('BE', '🇧🇪 Belgique'),
  switzerland('CH', '🇨🇭 Suisse'),
  luxembourg('LU', '🇱🇺 Luxembourg'),
  monaco('MC', '🇲🇨 Monaco'),
  spain('ES', '🇪🇸 Espagne'),
  italy('IT', '🇮🇹 Italie'),
  germany('DE', '🇩🇪 Allemagne'),
  portugal('PT', '🇵🇹 Portugal'),
  netherlands('NL', '🇳🇱 Pays-Bas'),
  unitedKingdom('GB', '🇬🇧 Royaume-Uni'),
  ireland('IE', '🇮🇪 Irlande'),
  austria('AT', '🇦🇹 Autriche'),
  denmark('DK', '🇩🇰 Danemark'),
  sweden('SE', '🇸🇪 Suède'),
  norway('NO', '🇳🇴 Norvège'),
  finland('FI', '🇫🇮 Finlande'),
  poland('PL', '🇵🇱 Pologne'),
  czechRepublic('CZ', '🇨🇿 République tchèque'),
  greece('GR', '🇬🇷 Grèce'),
  croatia('HR', '🇭🇷 Croatie'),
  canada('CA', '🇨🇦 Canada'),
  usa('US', '🇺🇸 États-Unis'),
  mexico('MX', '🇲🇽 Mexique'),
  brazil('BR', '🇧🇷 Brésil'),
  argentina('AR', '🇦🇷 Argentine'),
  morocco('MA', '🇲🇦 Maroc'),
  tunisia('TN', '🇹🇳 Tunisie'),
  algeria('DZ', '🇩🇿 Algérie'),
  senegal('SN', '🇸🇳 Sénégal'),
  ivoryCoast('CI', '🇨🇮 Côte d\'Ivoire'),
  mauritius('MU', '🇲🇺 Maurice'),
  reunion('RE', '🇷🇪 La Réunion'),
  newCaledonia('NC', '🇳🇨 Nouvelle-Calédonie'),
  frenchPolynesia('PF', '🇵🇫 Polynésie française'),
  guadeloupe('GP', '🇬🇵 Guadeloupe'),
  martinique('MQ', '🇲🇶 Martinique'),
  guyana('GF', '🇬🇫 Guyane'),
  mayotte('YT', '🇾🇹 Mayotte');

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
