import SwiftUI

/// Maps menu item names to food category emoji and AI image generation prompts.
/// Covers ~50 food categories across all major cuisines.
/// No API calls — purely local keyword matching.
enum FoodCategoryMapper {

    // MARK: - Public

    /// Returns the best-matching food emoji for a menu item name.
    static func emoji(for itemName: String) -> String {
        findCategory(for: itemName)?.emoji ?? "🍽️"
    }

    /// Returns a background color tint for the food category.
    static func backgroundColor(for itemName: String) -> Color {
        findCategory(for: itemName)?.bgColor ?? Color.appCardSecondary
    }

    /// Returns a stable category key for caching (e.g. "pizza", "curry", "burger").
    /// Similar items map to the same key so they share a generated image.
    static func categoryKey(for itemName: String) -> String {
        findCategory(for: itemName)?.key ?? "generic_plate"
    }

    /// Returns a prompt for AI image generation for this food category.
    static func imagePrompt(for itemName: String) -> String {
        findCategory(for: itemName)?.imagePrompt
            ?? "A beautifully plated restaurant dish, professional food photography, overhead shot, clean white plate"
    }

    // MARK: - Lookup

    private static func findCategory(for itemName: String) -> FoodCategory? {
        let name = itemName.lowercased()
        for category in categories {
            for keyword in category.keywords {
                if name.contains(keyword) {
                    return category
                }
            }
        }
        return nil
    }

    // MARK: - Categories

    private struct FoodCategory {
        let key: String
        let emoji: String
        let keywords: [String]
        let bgColor: Color
        let imagePrompt: String
    }

    /// Ordered by specificity — more specific matches first, generic last.
    private static let categories: [FoodCategory] = [
        // === SPECIFIC DISHES (check first) ===

        // Pizza
        FoodCategory(key: "pizza", emoji: "🍕", keywords: ["pizza", "margherita", "pepperoni", "calzone"], bgColor: Color.red.opacity(0.12),
                     imagePrompt: "A freshly baked pizza with melted cheese and toppings on a wooden board, professional food photography, overhead shot, warm lighting"),

        // Burger
        FoodCategory(key: "burger", emoji: "🍔", keywords: ["burger", "hamburger", "cheeseburger", "smash burger", "slider"], bgColor: Color.orange.opacity(0.12),
                     imagePrompt: "A juicy gourmet cheeseburger with lettuce, tomato, and melted cheese on a brioche bun, professional food photography, side angle"),

        // Sushi / Japanese
        FoodCategory(key: "sushi", emoji: "🍣", keywords: ["sushi", "sashimi", "maki", "nigiri", "temaki"], bgColor: Color.pink.opacity(0.12),
                     imagePrompt: "An elegant sushi platter with assorted nigiri and maki rolls on a black slate plate, professional food photography"),
        FoodCategory(key: "japanese", emoji: "🍱", keywords: ["bento", "teriyaki", "tempura", "katsu", "tonkatsu", "yakitori", "donburi", "udon", "soba"], bgColor: Color.red.opacity(0.10),
                     imagePrompt: "A teriyaki chicken bowl with steamed rice and vegetables, professional food photography, overhead shot"),
        FoodCategory(key: "noodle_soup", emoji: "🍜", keywords: ["ramen", "pho", "noodle", "lo mein", "chow mein", "pad thai", "laksa", "udon soup"], bgColor: Color.yellow.opacity(0.12),
                     imagePrompt: "A steaming bowl of ramen with rich broth, noodles, soft-boiled egg, and green onions, professional food photography"),

        // Mexican
        FoodCategory(key: "taco", emoji: "🌮", keywords: ["taco", "carnitas", "al pastor", "carne asada taco"], bgColor: Color.yellow.opacity(0.12),
                     imagePrompt: "Authentic street-style tacos with cilantro, onion, and lime on a colorful plate, professional food photography"),
        FoodCategory(key: "burrito", emoji: "🌯", keywords: ["burrito", "wrap", "quesadilla", "enchilada", "chimichanga", "fajita"], bgColor: Color.orange.opacity(0.10),
                     imagePrompt: "A large burrito cut in half showing rice, beans, meat, and cheese filling, professional food photography"),
        FoodCategory(key: "tamale", emoji: "🫔", keywords: ["tamale"], bgColor: Color.yellow.opacity(0.10),
                     imagePrompt: "Traditional tamales unwrapped from corn husks on a plate, professional food photography"),
        FoodCategory(key: "guacamole", emoji: "🥑", keywords: ["guacamole", "guac", "avocado toast"], bgColor: Color.green.opacity(0.12),
                     imagePrompt: "Fresh guacamole in a stone mortar with tortilla chips, professional food photography, overhead shot"),

        // Indian
        FoodCategory(key: "curry", emoji: "🍛", keywords: ["curry", "tikka", "masala", "biryani", "dal", "daal", "paneer", "korma", "vindaloo", "tandoori", "naan", "samosa", "chana", "palak", "butter chicken", "saag"], bgColor: Color.orange.opacity(0.12),
                     imagePrompt: "A rich butter chicken curry with basmati rice and warm naan bread, professional food photography, warm golden lighting"),

        // Chinese
        FoodCategory(key: "dumpling", emoji: "🥟", keywords: ["dumpling", "dim sum", "gyoza", "wonton", "potsticker", "bao", "xiaolongbao"], bgColor: Color.yellow.opacity(0.10),
                     imagePrompt: "Steamed dumplings in a bamboo basket with dipping sauce, professional food photography, overhead shot"),
        FoodCategory(key: "rice_dish", emoji: "🍚", keywords: ["fried rice", "rice bowl", "bibimbap", "poke bowl", "chirashi"], bgColor: Color.brown.opacity(0.10),
                     imagePrompt: "A colorful poke bowl with fresh fish, rice, avocado, and edamame, professional food photography, overhead shot"),

        // Mediterranean / Middle Eastern
        FoodCategory(key: "mediterranean", emoji: "🧆", keywords: ["falafel", "hummus", "shawarma", "kebab", "kabob", "gyro", "souvlaki", "pita"], bgColor: Color.green.opacity(0.10),
                     imagePrompt: "A Mediterranean plate with falafel, hummus, pita bread, and fresh vegetables, professional food photography"),

        // Italian (beyond pizza)
        FoodCategory(key: "pasta", emoji: "🍝", keywords: ["pasta", "spaghetti", "linguine", "fettuccine", "penne", "rigatoni", "lasagna", "ravioli", "gnocchi", "carbonara", "bolognese", "alfredo", "marinara", "primavera", "pesto"], bgColor: Color.red.opacity(0.10),
                     imagePrompt: "A plate of pasta with rich sauce, freshly grated parmesan, and basil garnish, professional food photography"),
        FoodCategory(key: "risotto", emoji: "🫕", keywords: ["risotto", "arancini"], bgColor: Color.yellow.opacity(0.10),
                     imagePrompt: "Creamy mushroom risotto in a wide bowl with parmesan shavings, professional food photography"),

        // Korean
        FoodCategory(key: "korean", emoji: "🥘", keywords: ["bibimbap", "bulgogi", "kimchi", "japchae", "galbi", "korean bbq", "tteokbokki", "kimbap"], bgColor: Color.red.opacity(0.10),
                     imagePrompt: "A sizzling Korean bibimbap with vegetables, beef, and a fried egg in a hot stone bowl, professional food photography"),

        // Thai
        FoodCategory(key: "thai", emoji: "🍲", keywords: ["tom yum", "tom kha", "green curry", "red curry", "pad see ew", "thai basil", "massaman", "panang"], bgColor: Color.green.opacity(0.10),
                     imagePrompt: "A fragrant Thai green curry with coconut milk, vegetables, and jasmine rice, professional food photography"),

        // === PROTEIN TYPES ===

        // Steak / Beef
        FoodCategory(key: "steak", emoji: "🥩", keywords: ["steak", "ribeye", "sirloin", "filet", "prime rib", "brisket", "beef", "tri-tip", "flank"], bgColor: Color.red.opacity(0.12),
                     imagePrompt: "A perfectly seared steak with grill marks, sliced to show medium-rare interior, with asparagus, professional food photography"),

        // Chicken
        FoodCategory(key: "chicken", emoji: "🍗", keywords: ["chicken", "wing", "tender", "nugget", "poultry", "rotisserie"], bgColor: Color.orange.opacity(0.10),
                     imagePrompt: "Grilled chicken breast with herbs, sliced on a plate with vegetables, professional food photography"),

        // Fish / Seafood
        FoodCategory(key: "fish", emoji: "🐟", keywords: ["salmon", "tuna", "fish", "cod", "tilapia", "mahi", "trout", "halibut", "bass", "snapper"], bgColor: Color.blue.opacity(0.10),
                     imagePrompt: "Pan-seared salmon fillet with crispy skin, lemon, and fresh herbs on a white plate, professional food photography"),
        FoodCategory(key: "shrimp", emoji: "🍤", keywords: ["shrimp", "prawn", "lobster", "crab", "scallop", "calamari", "seafood", "clam", "mussel", "oyster"], bgColor: Color.pink.opacity(0.10),
                     imagePrompt: "Garlic butter shrimp on a plate with lemon wedges and fresh parsley, professional food photography"),

        // Pork
        FoodCategory(key: "pork", emoji: "🥓", keywords: ["bacon", "pork", "ham", "pulled pork", "ribs", "sausage", "chorizo", "bratwurst"], bgColor: Color.red.opacity(0.08),
                     imagePrompt: "Slow-cooked BBQ pulled pork on a plate with coleslaw, professional food photography"),

        // === MEAL TYPES ===

        // Salad
        FoodCategory(key: "salad", emoji: "🥗", keywords: ["salad", "caesar", "cobb", "garden", "greek salad", "kale", "arugula", "spinach salad"], bgColor: Color.green.opacity(0.12),
                     imagePrompt: "A fresh Caesar salad with crisp romaine, croutons, parmesan, and dressing in a large bowl, professional food photography"),

        // Sandwich / Sub
        FoodCategory(key: "sandwich", emoji: "🥪", keywords: ["sandwich", "sub", "hoagie", "panini", "club", "blt", "grilled cheese", "monte cristo", "po boy", "melt"], bgColor: Color.yellow.opacity(0.10),
                     imagePrompt: "A stacked deli sandwich cut in half showing layers of meat, cheese, and vegetables, professional food photography"),

        // Soup
        FoodCategory(key: "soup", emoji: "🍜", keywords: ["soup", "chowder", "bisque", "stew", "chili", "gumbo", "minestrone", "broth"], bgColor: Color.orange.opacity(0.08),
                     imagePrompt: "A hearty bowl of soup with fresh herbs and crusty bread on the side, professional food photography, overhead shot"),

        // Breakfast
        FoodCategory(key: "pancakes", emoji: "🥞", keywords: ["pancake", "waffle", "french toast", "crepe"], bgColor: Color.yellow.opacity(0.12),
                     imagePrompt: "A stack of fluffy pancakes with maple syrup, butter, and fresh berries, professional food photography"),
        FoodCategory(key: "breakfast", emoji: "🍳", keywords: ["egg", "omelet", "omelette", "frittata", "benedict", "breakfast", "brunch", "scramble"], bgColor: Color.yellow.opacity(0.10),
                     imagePrompt: "A breakfast plate with scrambled eggs, toast, avocado, and bacon, professional food photography, overhead shot"),

        // Bowl
        FoodCategory(key: "bowl", emoji: "🥣", keywords: ["bowl", "acai", "smoothie bowl", "grain bowl", "power bowl", "buddha bowl", "poke"], bgColor: Color.purple.opacity(0.10),
                     imagePrompt: "A colorful acai bowl topped with granola, fresh fruit, and coconut flakes, professional food photography, overhead shot"),

        // === SIDES / SNACKS ===

        FoodCategory(key: "fries", emoji: "🍟", keywords: ["fries", "french fries", "onion rings", "tots", "wedges", "chips"], bgColor: Color.yellow.opacity(0.12),
                     imagePrompt: "Golden crispy french fries in a basket with ketchup, professional food photography"),
        FoodCategory(key: "corn", emoji: "🌽", keywords: ["corn", "elote"], bgColor: Color.yellow.opacity(0.10),
                     imagePrompt: "Mexican elote street corn with mayo, cheese, and chili powder, professional food photography"),
        FoodCategory(key: "potato", emoji: "🥔", keywords: ["potato", "mashed", "baked potato", "hash brown"], bgColor: Color.brown.opacity(0.10),
                     imagePrompt: "A loaded baked potato with sour cream, chives, and butter, professional food photography"),
        FoodCategory(key: "bread", emoji: "🍞", keywords: ["bread", "toast", "garlic bread", "breadstick", "roll", "biscuit", "cornbread", "focaccia"], bgColor: Color.brown.opacity(0.10),
                     imagePrompt: "Warm garlic bread slices with melted butter and herbs, professional food photography"),

        // === DESSERTS ===

        FoodCategory(key: "ice_cream", emoji: "🍦", keywords: ["ice cream", "gelato", "frozen yogurt", "sundae", "milkshake", "shake"], bgColor: Color.pink.opacity(0.12),
                     imagePrompt: "Scoops of artisan ice cream in a bowl with toppings and a waffle cone, professional food photography"),
        FoodCategory(key: "cake", emoji: "🍰", keywords: ["cake", "cheesecake", "tiramisu", "brownie", "mousse", "pie", "cobbler", "tart"], bgColor: Color.pink.opacity(0.10),
                     imagePrompt: "A slice of rich chocolate cake with ganache and fresh berries on a plate, professional food photography"),
        FoodCategory(key: "pastry", emoji: "🍩", keywords: ["donut", "doughnut", "churro", "pastry", "croissant", "muffin", "danish", "scone"], bgColor: Color.orange.opacity(0.10),
                     imagePrompt: "Fresh glazed donuts and pastries on a wooden board, professional food photography"),
        FoodCategory(key: "cookie", emoji: "🍪", keywords: ["cookie", "biscotti", "macaron"], bgColor: Color.brown.opacity(0.10),
                     imagePrompt: "Warm chocolate chip cookies on a cooling rack, professional food photography"),

        // === DRINKS ===

        FoodCategory(key: "cold_drink", emoji: "🥤", keywords: ["smoothie", "juice", "lemonade", "iced tea", "soda", "drink", "shake", "refresher"], bgColor: Color.blue.opacity(0.10),
                     imagePrompt: "A fresh fruit smoothie in a tall glass with a straw and fresh fruit garnish, professional food photography"),
        FoodCategory(key: "coffee", emoji: "☕", keywords: ["coffee", "latte", "cappuccino", "espresso", "mocha", "americano", "macchiato", "cold brew"], bgColor: Color.brown.opacity(0.12),
                     imagePrompt: "A latte with beautiful latte art in a ceramic cup on a wooden table, professional food photography"),
        FoodCategory(key: "tea", emoji: "🍵", keywords: ["tea", "matcha", "chai", "boba", "bubble tea"], bgColor: Color.green.opacity(0.10),
                     imagePrompt: "A matcha latte with latte art in a ceramic cup, professional food photography"),

        // === GENERIC FALLBACKS (checked last) ===

        FoodCategory(key: "vegetable", emoji: "🥬", keywords: ["vegetable", "veggie", "vegan", "plant-based", "tofu", "edamame"], bgColor: Color.green.opacity(0.10),
                     imagePrompt: "A colorful roasted vegetable plate with tofu, professional food photography, overhead shot"),
        FoodCategory(key: "bbq", emoji: "🍖", keywords: ["bbq", "barbecue", "grill", "grilled", "smoked", "roast"], bgColor: Color.red.opacity(0.10),
                     imagePrompt: "Smoked BBQ ribs with sauce on a cutting board, professional food photography"),
        FoodCategory(key: "cheese", emoji: "🧀", keywords: ["cheese", "mac and cheese", "queso", "nachos"], bgColor: Color.yellow.opacity(0.12),
                     imagePrompt: "Creamy mac and cheese in a cast iron skillet with golden breadcrumb topping, professional food photography"),
    ]
}
