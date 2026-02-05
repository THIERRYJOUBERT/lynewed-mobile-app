/// Predefined brand lists for the marketplace listing form.
///
/// Contains popular wedding dress and bridal shoe brands for autocomplete.
/// Users can also enter custom brands not in the list.
library;

/// Popular wedding dress designer brands.
const List<String> popularWeddingDressBrands = [
  'Vera Wang',
  'Monique Lhuillier',
  'Oscar de la Renta',
  'Carolina Herrera',
  'Marchesa',
  'Elie Saab',
  'Zuhair Murad',
  'Pronovias',
  'Rosa Clara',
  'Maggie Sottero',
  'Allure Bridals',
  'Mori Lee',
  'Justin Alexander',
  'Stella York',
  'Essense of Australia',
  "David's Bridal",
  'BHLDN',
  'Delphine Manivet',
  'Laure de Sagazan',
  'Other / Unknown',
];

/// Popular bridal shoe brands.
const List<String> popularBridalShoeBrands = [
  'Jimmy Choo',
  'Manolo Blahnik',
  'Badgley Mischka',
  'Bella Belle',
  'Rachel Simpson',
  'Charlotte Mills',
  'Emmy London',
  'Freya Rose',
  'Stuart Weitzman',
  'Louboutin',
  'Aquazzura',
  'Other / Unknown',
];

/// Returns the appropriate brand list for the given category.
List<String> getBrandsForCategory(String category) {
  switch (category) {
    case 'dress':
      return popularWeddingDressBrands;
    case 'shoes':
      return popularBridalShoeBrands;
    default:
      return popularWeddingDressBrands;
  }
}
