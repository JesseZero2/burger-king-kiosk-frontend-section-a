
class Product {
  final int id;
  final String category;
  final String name;
  final double price;
  final String image;

  Product({
    required this.id,
    required String category,
    required this.name,
    required this.price,
    required this.image,
  }) : category = _normalizeCategory(category);
}

String _normalizeCategory(String value) {
  final normalized = value.trim().toLowerCase();

  if (normalized.contains('breakfast'))                                    return 'all_day_breakfast';
  if (normalized.contains('cafe') ||
      normalized.contains('café') ||
      normalized.contains('coffee'))                                       return 'bk_cafe';
  if (normalized.contains('rice'))                                         return 'chicken_rice_meals';
  if (normalized.contains('chicken'))                                      return 'chicken_king';
  if (normalized.contains('dessert') || normalized.contains('sundae'))    return 'dessert';
  if (normalized.contains('drink') ||
      normalized.contains('beverage') ||
      normalized.contains('float'))                                        return 'drinks';
  if (normalized.contains('featured') || normalized.contains('popular'))  return 'featured';
  if (normalized.contains('flame') ||
      normalized.contains('cheese') ||
      normalized.contains('cheeseburger'))                                 return 'flame_grilled_cheeseburger';
  if (normalized.contains('group'))                                        return 'group_meals';
  if (normalized.contains('saver') || normalized.contains('bundle'))      return 'king_savers_bundles';
  if (normalized.contains('king') && normalized.contains('special'))      return 'king_specials';
  if (normalized.contains('plant') || normalized.contains('vegan'))       return 'plant_based_whopper';
  if (normalized.contains('side'))                                         return 'ultimate_sidekings';
  if (normalized.contains('x-tra') ||
      normalized.contains('xtra') ||
      normalized.contains('long'))                                         return 'xtra_long_chicken';
  if (normalized.contains('whopper') || normalized.contains('burger'))    return 'whopper';

  return normalized.replaceAll(' ', '_');
}