import SwiftUI

/// Maps menu item names to food category emoji for visual display.
/// Covers ~50 food categories across all major cuisines.
/// No API calls — purely local keyword matching.
enum FoodCategoryMapper {

    // MARK: - Public

    /// Returns the best-matching food emoji for a menu item name.
    static func emoji(for itemName: String) -> String {
        let name = itemName.lowercased()

        for category in categories {
            for keyword in category.keywords {
                if name.contains(keyword) {
                    return category.emoji
                }
            }
        }

        return "🍽️" // Generic plate fallback
    }

    /// Returns a background color tint for the food category.
    static func backgroundColor(for itemName: String) -> Color {
        let name = itemName.lowercased()

        for category in categories {
            for keyword in category.keywords {
                if name.contains(keyword) {
                    return category.bgColor
                }
            }
        }

        return Color.appCardSecondary
    }

    // MARK: - Categories

    private struct FoodCategory {
        let emoji: String
        let keywords: [String]
        let bgColor: Color
    }

    /// Ordered by specificity — more specific matches first, generic last.
    private static let categories: [FoodCategory] = [
        // === SPECIFIC DISHES (check first) ===

        // Pizza
        FoodCategory(emoji: "🍕", keywords: ["pizza", "margherita", "pepperoni", "calzone"], bgColor: Color.red.opacity(0.12)),

        // Burger
        FoodCategory(emoji: "🍔", keywords: ["burger", "hamburger", "cheeseburger", "smash burger", "slider"], bgColor: Color.orange.opacity(0.12)),

        // Sushi / Japanese
        FoodCategory(emoji: "🍣", keywords: ["sushi", "sashimi", "maki", "nigiri", "temaki"], bgColor: Color.pink.opacity(0.12)),
        FoodCategory(emoji: "🍱", keywords: ["bento", "teriyaki", "tempura", "katsu", "tonkatsu", "yakitori", "donburi", "udon", "soba"], bgColor: Color.red.opacity(0.10)),
        FoodCategory(emoji: "🍜", keywords: ["ramen", "pho", "noodle", "lo mein", "chow mein", "pad thai", "laksa", "udon soup"], bgColor: Color.yellow.opacity(0.12)),

        // Mexican
        FoodCategory(emoji: "🌮", keywords: ["taco", "carnitas", "al pastor", "carne asada taco"], bgColor: Color.yellow.opacity(0.12)),
        FoodCategory(emoji: "🌯", keywords: ["burrito", "wrap", "quesadilla", "enchilada", "chimichanga", "fajita"], bgColor: Color.orange.opacity(0.10)),
        FoodCategory(emoji: "🫔", keywords: ["tamale"], bgColor: Color.yellow.opacity(0.10)),
        FoodCategory(emoji: "🥑", keywords: ["guacamole", "guac", "avocado toast"], bgColor: Color.green.opacity(0.12)),

        // Indian
        FoodCategory(emoji: "🍛", keywords: ["curry", "tikka", "masala", "biryani", "dal", "daal", "paneer", "korma", "vindaloo", "tandoori", "naan", "samosa", "chana", "palak", "butter chicken", "saag"], bgColor: Color.orange.opacity(0.12)),

        // Chinese
        FoodCategory(emoji: "🥟", keywords: ["dumpling", "dim sum", "gyoza", "wonton", "potsticker", "bao", "xiaolongbao"], bgColor: Color.yellow.opacity(0.10)),
        FoodCategory(emoji: "🍚", keywords: ["fried rice", "rice bowl", "bibimbap", "poke bowl", "chirashi"], bgColor: Color.brown.opacity(0.10)),

        // Mediterranean / Middle Eastern
        FoodCategory(emoji: "🧆", keywords: ["falafel", "hummus", "shawarma", "kebab", "kabob", "gyro", "souvlaki", "pita"], bgColor: Color.green.opacity(0.10)),

        // Italian (beyond pizza)
        FoodCategory(emoji: "🍝", keywords: ["pasta", "spaghetti", "linguine", "fettuccine", "penne", "rigatoni", "lasagna", "ravioli", "gnocchi", "carbonara", "bolognese", "alfredo", "marinara", "primavera", "pesto"], bgColor: Color.red.opacity(0.10)),
        FoodCategory(emoji: "🫕", keywords: ["risotto", "arancini"], bgColor: Color.yellow.opacity(0.10)),

        // Korean
        FoodCategory(emoji: "🥘", keywords: ["bibimbap", "bulgogi", "kimchi", "japchae", "galbi", "korean bbq", "tteokbokki", "kimbap"], bgColor: Color.red.opacity(0.10)),

        // Thai
        FoodCategory(emoji: "🍲", keywords: ["tom yum", "tom kha", "green curry", "red curry", "pad see ew", "thai basil", "massaman", "panang"], bgColor: Color.green.opacity(0.10)),

        // === PROTEIN TYPES ===

        // Steak / Beef
        FoodCategory(emoji: "🥩", keywords: ["steak", "ribeye", "sirloin", "filet", "prime rib", "brisket", "beef", "tri-tip", "flank"], bgColor: Color.red.opacity(0.12)),

        // Chicken
        FoodCategory(emoji: "🍗", keywords: ["chicken", "wing", "tender", "nugget", "poultry", "rotisserie"], bgColor: Color.orange.opacity(0.10)),

        // Fish / Seafood
        FoodCategory(emoji: "🐟", keywords: ["salmon", "tuna", "fish", "cod", "tilapia", "mahi", "trout", "halibut", "bass", "snapper"], bgColor: Color.blue.opacity(0.10)),
        FoodCategory(emoji: "🍤", keywords: ["shrimp", "prawn", "lobster", "crab", "scallop", "calamari", "seafood", "clam", "mussel", "oyster"], bgColor: Color.pink.opacity(0.10)),

        // Pork
        FoodCategory(emoji: "🥓", keywords: ["bacon", "pork", "ham", "pulled pork", "ribs", "sausage", "chorizo", "bratwurst"], bgColor: Color.red.opacity(0.08)),

        // === MEAL TYPES ===

        // Salad
        FoodCategory(emoji: "🥗", keywords: ["salad", "caesar", "cobb", "garden", "greek salad", "kale", "arugula", "spinach salad"], bgColor: Color.green.opacity(0.12)),

        // Sandwich / Sub
        FoodCategory(emoji: "🥪", keywords: ["sandwich", "sub", "hoagie", "panini", "club", "blt", "grilled cheese", "monte cristo", "po boy", "melt"], bgColor: Color.yellow.opacity(0.10)),

        // Soup
        FoodCategory(emoji: "🍜", keywords: ["soup", "chowder", "bisque", "stew", "chili", "gumbo", "minestrone", "broth"], bgColor: Color.orange.opacity(0.08)),

        // Breakfast
        FoodCategory(emoji: "🥞", keywords: ["pancake", "waffle", "french toast", "crepe"], bgColor: Color.yellow.opacity(0.12)),
        FoodCategory(emoji: "🍳", keywords: ["egg", "omelet", "omelette", "frittata", "benedict", "breakfast", "brunch", "scramble"], bgColor: Color.yellow.opacity(0.10)),

        // Bowl
        FoodCategory(emoji: "🥣", keywords: ["bowl", "acai", "smoothie bowl", "grain bowl", "power bowl", "buddha bowl", "poke"], bgColor: Color.purple.opacity(0.10)),

        // === SIDES / SNACKS ===

        FoodCategory(emoji: "🍟", keywords: ["fries", "french fries", "onion rings", "tots", "wedges", "chips"], bgColor: Color.yellow.opacity(0.12)),
        FoodCategory(emoji: "🌽", keywords: ["corn", "elote"], bgColor: Color.yellow.opacity(0.10)),
        FoodCategory(emoji: "🥔", keywords: ["potato", "mashed", "baked potato", "hash brown"], bgColor: Color.brown.opacity(0.10)),
        FoodCategory(emoji: "🍞", keywords: ["bread", "toast", "garlic bread", "breadstick", "roll", "biscuit", "cornbread", "focaccia"], bgColor: Color.brown.opacity(0.10)),

        // === DESSERTS ===

        FoodCategory(emoji: "🍦", keywords: ["ice cream", "gelato", "frozen yogurt", "sundae", "milkshake", "shake"], bgColor: Color.pink.opacity(0.12)),
        FoodCategory(emoji: "🍰", keywords: ["cake", "cheesecake", "tiramisu", "brownie", "mousse", "pie", "cobbler", "tart"], bgColor: Color.pink.opacity(0.10)),
        FoodCategory(emoji: "🍩", keywords: ["donut", "doughnut", "churro", "pastry", "croissant", "muffin", "danish", "scone"], bgColor: Color.orange.opacity(0.10)),
        FoodCategory(emoji: "🍪", keywords: ["cookie", "biscotti", "macaron"], bgColor: Color.brown.opacity(0.10)),

        // === DRINKS ===

        FoodCategory(emoji: "🥤", keywords: ["smoothie", "juice", "lemonade", "iced tea", "soda", "drink", "shake", "refresher"], bgColor: Color.blue.opacity(0.10)),
        FoodCategory(emoji: "☕", keywords: ["coffee", "latte", "cappuccino", "espresso", "mocha", "americano", "macchiato", "cold brew"], bgColor: Color.brown.opacity(0.12)),
        FoodCategory(emoji: "🍵", keywords: ["tea", "matcha", "chai", "boba", "bubble tea"], bgColor: Color.green.opacity(0.10)),

        // === GENERIC FALLBACKS (checked last) ===

        FoodCategory(emoji: "🥬", keywords: ["vegetable", "veggie", "vegan", "plant-based", "tofu", "edamame"], bgColor: Color.green.opacity(0.10)),
        FoodCategory(emoji: "🍖", keywords: ["bbq", "barbecue", "grill", "grilled", "smoked", "roast"], bgColor: Color.red.opacity(0.10)),
        FoodCategory(emoji: "🧀", keywords: ["cheese", "mac and cheese", "queso", "nachos"], bgColor: Color.yellow.opacity(0.12)),
    ]
}
