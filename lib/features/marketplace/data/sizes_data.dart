/// Size guide data for the marketplace listing form.
///
/// Contains size options for dresses and shoes with international equivalents.
library;

/// Represents a size option with a value for storage and a label for display.
class SizeOption {
  /// Creates a size option.
  const SizeOption({required this.value, required this.label});

  /// The value stored in the database (e.g., 'XS', '36').
  final String value;

  /// The display label with international equivalents (e.g., 'XS (EU 32-34 / US 0-2)').
  final String label;
}

/// Available dress sizes with international equivalents.
const List<SizeOption> dressSizes = [
  SizeOption(value: 'XS', label: 'XS (EU 32-34 / US 0-2)'),
  SizeOption(value: 'S', label: 'S (EU 36-38 / US 4-6)'),
  SizeOption(value: 'M', label: 'M (EU 40-42 / US 8-10)'),
  SizeOption(value: 'L', label: 'L (EU 44-46 / US 12-14)'),
  SizeOption(value: 'XL', label: 'XL (EU 48-50 / US 16-18)'),
];

/// Available shoe sizes with international equivalents.
const List<SizeOption> shoeSizes = [
  SizeOption(value: '35', label: '35 (US 4 / UK 2.5)'),
  SizeOption(value: '36', label: '36 (US 5 / UK 3.5)'),
  SizeOption(value: '37', label: '37 (US 6 / UK 4.5)'),
  SizeOption(value: '38', label: '38 (US 7 / UK 5.5)'),
  SizeOption(value: '39', label: '39 (US 8 / UK 6.5)'),
  SizeOption(value: '40', label: '40 (US 9 / UK 7.5)'),
  SizeOption(value: '41', label: '41 (US 10 / UK 8.5)'),
  SizeOption(value: '42', label: '42 (US 11 / UK 9.5)'),
];

/// Returns the appropriate size list for the given category.
List<SizeOption> getSizesForCategory(String category) {
  switch (category) {
    case 'dress':
      return dressSizes;
    case 'shoes':
      return shoeSizes;
    default:
      return dressSizes;
  }
}

/// Valid sleeve length options for dresses.
const List<String> sleeveLengthOptions = [
  'long',
  '3-4',
  'short',
  'cap',
  'sleeveless',
  'strapless',
];

/// Display labels for sleeve length options.
const Map<String, String> sleeveLengthLabels = {
  'long': 'Long',
  '3-4': '3/4 Length',
  'short': 'Short',
  'cap': 'Cap',
  'sleeveless': 'Sleeveless',
  'strapless': 'Strapless',
};

/// Valid condition options for listings.
const List<String> conditionOptions = [
  'new',
  'excellent',
  'good',
  'fair',
];

/// Display labels for condition options.
const Map<String, String> conditionLabels = {
  'new': 'New',
  'excellent': 'Excellent',
  'good': 'Good',
  'fair': 'Fair',
};

/// Valid listing categories.
const List<String> categoryOptions = ['dress', 'shoes'];

/// Display labels for categories.
const Map<String, String> categoryLabels = {
  'dress': 'Dress',
  'shoes': 'Shoes',
};
