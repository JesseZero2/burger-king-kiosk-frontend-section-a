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

  if (normalized.contains('breakfast')) return 'all_day_breakfast';
  if (normalized.contains('cafe') || normalized.contains('café') || normalized.contains('coffee')) return 'bk_cafe';
  if (normalized.contains('rice')) return 'chicken_rice_meals';
  if (normalized.contains('chicken')) return 'chicken_king';
  if (normalized.contains('dessert') || normalized.contains('sundae')) return 'dessert';
  if (normalized.contains('drink') || normalized.contains('beverage') || normalized.contains('float')) return 'drinks';
  if (normalized.contains('featured') || normalized.contains('popular')) return 'featured';
  if (normalized.contains('flame') || normalized.contains('cheese') || normalized.contains('cheeseburger')) return 'flame_grilled_cheeseburger';
  if (normalized.contains('group')) return 'group_meals';
  if (normalized.contains('saver') || normalized.contains('bundle')) return 'king_savers_bundles';
  if (normalized.contains('king') && normalized.contains('special')) return 'king_specials';
  if (normalized.contains('plant') || normalized.contains('vegan')) return 'plant_based_whopper';
  if (normalized.contains('side')) return 'ultimate_sidekings';
  if (normalized.contains('x-tra') || normalized.contains('xtra') || normalized.contains('long')) return 'xtra_long_chicken';
  if (normalized.contains('whopper') || normalized.contains('burger')) return 'whopper';

  return normalized.replaceAll(' ', '_');
}

List<Product> mockProducts = [
  Product(id: 1, category: 'whopper', name: 'Whopper', price: 249, image: 'assets/products/whopper/whopper.webp'),
  Product(id: 2, category: 'whopper', name: 'Whopper Jr.', price: 149, image: 'assets/products/whopper/whopper_jr.webp'),
  Product(id: 3, category: 'whopper', name: '4-Cheese Whopper', price: 269, image: 'assets/products/whopper/4_cheese_whopper.webp'),
  Product(id: 4, category: 'whopper', name: '4-Cheese Whopper Jr.', price: 169, image: 'assets/products/whopper/4_cheese_whopper_jr.webp'),

  Product(id: 5, category: 'featured', name: 'Angriest Whopper', price: 279, image: 'assets/products/featured/angriest_whopper.webp'),
  Product(id: 6, category: 'featured', name: 'Angriest 4-Cheese Whopper', price: 299, image: 'assets/products/featured/angriest_4-cheese_whopper.webp'),
  Product(id: 7, category: 'featured', name: 'Angriest X-tra Long Chicken', price: 229, image: 'assets/products/featured/angriest_x-tra_long_chicken.webp'),
  Product(id: 8, category: 'featured', name: 'Large Iced Matcha Espresso', price: 129, image: 'assets/products/featured/large_iced_matcha_espresso.webp'),

  Product(id: 9, category: 'plant_based_whopper', name: 'Plant-Based Whopper', price: 259, image: 'assets/products/plant_based_whopper/plant_based_whopper.webp'),
  Product(id: 10, category: 'plant_based_whopper', name: 'Plant-Based Whopper Jr.', price: 159, image: 'assets/products/plant_based_whopper/plant_based_whopper_jr.webp'),

  Product(id: 11, category: 'chicken_king', name: 'Chicken King', price: 189, image: 'assets/products/chicken_king/chicken_king.webp'),
  Product(id: 12, category: 'chicken_king', name: 'Spicy Chicken King', price: 199, image: 'assets/products/chicken_king/spicy_chicken_king.webp'),
  Product(id: 13, category: 'chicken_king', name: 'BLT Spicy Chicken King', price: 219, image: 'assets/products/chicken_king/blt_spicy_chicken_king.webp'),

  Product(id: 14, category: 'xtra_long_chicken', name: 'X-tra Long Chicken Sandwich', price: 189, image: 'assets/products/xtra_long_chicken/xtra_long_chicken_sandwich.webp'),
  Product(id: 15, category: 'xtra_long_chicken', name: 'X-tra Long Chicken Jr. Sandwich', price: 139, image: 'assets/products/xtra_long_chicken/xtra_long_chicken_jr_sandwich.webp'),

  Product(id: 16, category: 'flame_grilled_cheeseburger', name: 'Flame-Grilled Burger', price: 99, image: 'assets/products/flame_grilled_cheeseburger/flamed_grilled_burger.webp'),
  Product(id: 17, category: 'flame_grilled_cheeseburger', name: 'Flame-Grilled Cheeseburger', price: 119, image: 'assets/products/flame_grilled_cheeseburger/flamed_grilled_cheese_burger.webp'),
  Product(id: 18, category: 'flame_grilled_cheeseburger', name: 'Flame-Grilled Double Cheeseburger', price: 159, image: 'assets/products/flame_grilled_cheeseburger/flamed_grilled_double_cheese_burger.webp'),
  Product(id: 19, category: 'flame_grilled_cheeseburger', name: 'Flame-Grilled BBQ Burger', price: 129, image: 'assets/products/flame_grilled_cheeseburger/flamed_grilled_bbq_burger.webp'),
  Product(id: 20, category: 'flame_grilled_cheeseburger', name: 'Flame-Grilled BBQ Bacon Cheeseburger', price: 169, image: 'assets/products/flame_grilled_cheeseburger/flamed_grilled_bbq_bacon_cheese_burger.webp'),

  Product(id: 21, category: 'king_specials', name: 'Quarter Pound King', price: 249, image: 'assets/products/king_specials/quarter_pound_king.webp'),
  Product(id: 22, category: 'king_specials', name: 'Bacon King', price: 269, image: 'assets/products/king_specials/bacon_king.webp'),
  Product(id: 23, category: 'king_specials', name: 'Bacon King Jr.', price: 169, image: 'assets/products/king_specials/bacon_king_jr.webp'),
  Product(id: 24, category: 'king_specials', name: 'BBQ Bacon King', price: 279, image: 'assets/products/king_specials/bbq_bacon_king.webp'),
  Product(id: 25, category: 'king_specials', name: 'BBQ Bacon King Jr.', price: 179, image: 'assets/products/king_specials/bbq_bacon_king_jr.webp'),
  Product(id: 26, category: 'king_specials', name: 'Mushroom Swiss King', price: 259, image: 'assets/products/king_specials/mushroom_swiss_king.webp'),
  Product(id: 27, category: 'king_specials', name: 'Mushroom Swiss King Jr.', price: 169, image: 'assets/products/king_specials/mushroom_swiss_king_jr.webp'),

  Product(id: 28, category: 'chicken_rice_meals', name: 'Smoky BBQ Chicken Fillet', price: 129, image: 'assets/products/chicken_rice_meals/smoky_bbq_chicken_fillet.webp'),
  Product(id: 29, category: 'chicken_rice_meals', name: 'Mushroom Gravy Chicken Fillet', price: 129, image: 'assets/products/chicken_rice_meals/mushroom_gravy_chicken_fillet.webp'),
  Product(id: 30, category: 'chicken_rice_meals', name: 'Creamy Chicken Fillet', price: 129, image: 'assets/products/chicken_rice_meals/creamy_chicken_filler.webp'),

  Product(id: 31, category: 'all_day_breakfast', name: 'Hash Bites', price: 79, image: 'assets/products/all_day_breakfast/hash_bites.webp'),
  Product(id: 32, category: 'all_day_breakfast', name: 'Breakfast Sausage Bowl', price: 129, image: 'assets/products/all_day_breakfast/breakfast_sausage_bowl.webp'),
  Product(id: 33, category: 'all_day_breakfast', name: 'BK Waffle Sausage King with Egg', price: 169, image: 'assets/products/all_day_breakfast/bk_waffle_sausage_king_with_egg.webp'),
  Product(id: 34, category: 'all_day_breakfast', name: 'BK Waffle Sausage King with Cheese', price: 159, image: 'assets/products/all_day_breakfast/bk_waffle_sausage_king_with_cheese.webp'),
  Product(id: 35, category: 'all_day_breakfast', name: '2pc BK Waffle with Maple', price: 99, image: 'assets/products/all_day_breakfast/2pc_bkwaffle_with_maple.webp'),
  Product(id: 36, category: 'all_day_breakfast', name: '2pc BK Waffle and Chicken', price: 149, image: 'assets/products/all_day_breakfast/2pc_bkwaffle_and_chicken.webp'),
  Product(id: 37, category: 'all_day_breakfast', name: '2pc BK Waffle with Maple and Sausage', price: 139, image: 'assets/products/all_day_breakfast/2pc_bkwaffle_with_maple_and_sausage.webp'),
  Product(id: 38, category: 'all_day_breakfast', name: '2pc Waffles with Nutella Solo', price: 119, image: 'assets/products/all_day_breakfast/2pc_waffles_with_nutella_solo.webp'),
  Product(id: 39, category: 'all_day_breakfast', name: '2pc Waffles with Nutella Combo', price: 159, image: 'assets/products/all_day_breakfast/2pc_waffles_with_nutella_combo.webp'),

  Product(id: 40, category: 'ultimate_sidekings', name: 'Thick Cut Fries', price: 89, image: 'assets/products/ultimate_sidekings/thick_cut_fries.webp'),
  Product(id: 41, category: 'ultimate_sidekings', name: 'King’s Bucket Thick Fries', price: 189, image: 'assets/products/ultimate_sidekings/kings_bucket_thick_fries.webp'),
  Product(id: 42, category: 'ultimate_sidekings', name: 'Onion Rings', price: 89, image: 'assets/products/ultimate_sidekings/onion_rings.webp'),
  Product(id: 43, category: 'ultimate_sidekings', name: 'King’s Bucket Onion Rings', price: 189, image: 'assets/products/ultimate_sidekings/kings_bucket_onion_rings.webp'),
  Product(id: 44, category: 'ultimate_sidekings', name: 'Hash Bites', price: 79, image: 'assets/products/ultimate_sidekings/hash_bites.webp'),
  Product(id: 45, category: 'ultimate_sidekings', name: 'King’s Bucket Hash Bites', price: 189, image: 'assets/products/ultimate_sidekings/kings_bucket_hash_bites.webp'),
  Product(id: 46, category: 'ultimate_sidekings', name: '4pc Chicken Nuggets', price: 89, image: 'assets/products/ultimate_sidekings/4pc_chicken_nuggets.webp'),
  Product(id: 47, category: 'ultimate_sidekings', name: '6pc Chicken Nuggets', price: 119, image: 'assets/products/ultimate_sidekings/6pc_chicken_nuggets.webp'),
  Product(id: 48, category: 'ultimate_sidekings', name: '10pc Chicken Nuggets', price: 169, image: 'assets/products/ultimate_sidekings/10pc_chicken_nuggets.webp'),
  Product(id: 49, category: 'ultimate_sidekings', name: 'Angry Dip', price: 25, image: 'assets/products/ultimate_sidekings/angry_dip.webp'),
  Product(id: 50, category: 'ultimate_sidekings', name: 'Smoky BBQ Dip', price: 25, image: 'assets/products/ultimate_sidekings/smoky_bbq_dip.webp'),

  Product(id: 51, category: 'bk_cafe', name: 'Roast Coffee', price: 79, image: 'assets/products/bk_cafe/roast_coffee.webp'),
  Product(id: 52, category: 'bk_cafe', name: 'Iced Matcha Espresso', price: 119, image: 'assets/products/bk_cafe/iced_matcha_espresso.webp'),
  Product(id: 53, category: 'bk_cafe', name: 'Iced Mocha Coffee', price: 109, image: 'assets/products/bk_cafe/iced_mocha_coffee.webp'),
  Product(id: 54, category: 'bk_cafe', name: 'Iced Vanilla Coffee', price: 109, image: 'assets/products/bk_cafe/iced_vanilla_coffee.webp'),
  Product(id: 55, category: 'bk_cafe', name: 'Iced Salted Caramel', price: 109, image: 'assets/products/bk_cafe/iced_salted_caramel.webp'),
  Product(id: 56, category: 'bk_cafe', name: 'Vanilla Affogato', price: 99, image: 'assets/products/bk_cafe/vanilla_affogato.webp'),
  Product(id: 57, category: 'bk_cafe', name: 'Mocha Affogato', price: 99, image: 'assets/products/bk_cafe/mocha_affogato.webp'),
  Product(id: 58, category: 'bk_cafe', name: 'Iced Matcha Espresso Affogato', price: 129, image: 'assets/products/bk_cafe/iced_matcha_espresso.affogato.webp'),
  Product(id: 59, category: 'bk_cafe', name: 'Iced Salted Caramel Affogato', price: 129, image: 'assets/products/bk_cafe/iced_salted_caramel_affogato.webp'),
  Product(id: 60, category: 'bk_cafe', name: 'Sweet Black Affogato Style', price: 99, image: 'assets/products/bk_cafe/sweet_black_affogato_style.webp'),

  Product(id: 61, category: 'drinks', name: 'Coke Original Taste', price: 59, image: 'assets/products/drinks/coke_original_taste.webp'),
  Product(id: 62, category: 'drinks', name: 'Iced Tea', price: 59, image: 'assets/products/drinks/iced_tea.webp'),
  Product(id: 63, category: 'drinks', name: 'Float', price: 79, image: 'assets/products/drinks/float.webp'),
  Product(id: 64, category: 'drinks', name: 'Rootbeer Float', price: 89, image: 'assets/products/drinks/rootbeer_float.webp'),

  Product(id: 65, category: 'dessert', name: 'Chocolate Sundae', price: 69, image: 'assets/products/dessert/chocolate_sundae.webp'),
  Product(id: 66, category: 'dessert', name: 'Caramel Sundae', price: 69, image: 'assets/products/dessert/caramel_sundae.webp'),
  Product(id: 67, category: 'dessert', name: 'Caramel Espresso Sundae', price: 79, image: 'assets/products/dessert/caramel_espresso_sundae.webp'),
  Product(id: 68, category: 'dessert', name: 'BK Sundae with Nutella', price: 89, image: 'assets/products/dessert/bk_sundae_with_nutella.webp'),

  Product(id: 69, category: 'group_meals', name: 'King Feast Mix n Feast for 2', price: 499, image: 'assets/products/group_meals/king_feast_mix_n_feast_for_2.webp'),
  Product(id: 70, category: 'group_meals', name: 'King Feast Mix n Feast for 3', price: 699, image: 'assets/products/group_meals/king_feast_mix_n_feast_for_3.webp'),
  Product(id: 71, category: 'group_meals', name: 'King Feast Mix n Feast for 4', price: 899, image: 'assets/products/group_meals/king_feast_mix_n_feast_for_4.webp'),

  Product(id: 72, category: 'king_savers_bundles', name: '199 King Savers Bundles', price: 199, image: 'assets/products/king_savers_bundles/199_king_savers_bundles.webp'),
  Product(id: 73, category: 'king_savers_bundles', name: '299 King Savers Bundles', price: 299, image: 'assets/products/king_savers_bundles/299_king_savers_bundles.webp'),
];