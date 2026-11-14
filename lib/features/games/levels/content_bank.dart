/// Curated, offline educational content shared by the level generators.
///
/// Facts are tagged explicitly so generators can exclude distractors that
/// would also be a correct answer.
library;

class Animal {
  const Animal(
    this.emoji,
    this.name, {
    this.sound,
    this.homes = const {},
    required this.size,
    this.traits = const {},
  });

  final String emoji;
  final String name;
  final String? sound;
  final Set<String> homes;

  /// Rough real-world size rank: 1 tiny … 10 enormous.
  final int size;

  /// Conservative facts only: flies, swims, six_legs, eight_legs, no_legs,
  /// lays_eggs, feathers, stripes, long_neck, trunk, shell, insect.
  final Set<String> traits;
}

const kAnimals = <Animal>[
  Animal('🐶', 'Dog', sound: 'Woof', size: 4),
  Animal('🐱', 'Cat', sound: 'Meow', size: 3),
  Animal('🐄', 'Cow', sound: 'Moo', homes: {'farm'}, size: 7),
  Animal('🐑', 'Sheep', sound: 'Baa', homes: {'farm'}, size: 5),
  Animal('🐷', 'Pig', sound: 'Oink', homes: {'farm'}, size: 5),
  Animal(
    '🦆',
    'Duck',
    sound: 'Quack',
    homes: {'pond', 'farm'},
    size: 3,
    traits: {'flies', 'swims', 'lays_eggs', 'feathers'},
  ),
  Animal(
    '🐓',
    'Rooster',
    sound: 'Cock-a-doodle-doo',
    homes: {'farm'},
    size: 3,
    traits: {'lays_eggs', 'feathers'},
  ),
  Animal('🦁', 'Lion', sound: 'Roar', homes: {'savanna'}, size: 7),
  Animal(
    '🐸',
    'Frog',
    sound: 'Ribbit',
    homes: {'pond'},
    size: 2,
    traits: {'swims', 'lays_eggs'},
  ),
  Animal('🐴', 'Horse', sound: 'Neigh', homes: {'farm'}, size: 7),
  Animal(
    '🐝',
    'Bee',
    sound: 'Buzz',
    homes: {'hive'},
    size: 1,
    traits: {'flies', 'six_legs', 'insect', 'lays_eggs', 'stripes'},
  ),
  Animal(
    '🐍',
    'Snake',
    sound: 'Hiss',
    size: 4,
    traits: {'no_legs', 'lays_eggs'},
  ),
  Animal(
    '🦉',
    'Owl',
    sound: 'Hoot',
    homes: {'tree'},
    size: 3,
    traits: {'flies', 'lays_eggs', 'feathers'},
  ),
  Animal(
    '🐘',
    'Elephant',
    sound: 'Trumpet',
    homes: {'savanna'},
    size: 9,
    traits: {'trunk'},
  ),
  Animal('🐭', 'Mouse', sound: 'Squeak', size: 1),
  Animal('🐺', 'Wolf', sound: 'Howl', homes: {'forest'}, size: 5),
  Animal('🐒', 'Monkey', homes: {'tree', 'jungle'}, size: 4),
  Animal('🐻', 'Bear', sound: 'Growl', homes: {'forest', 'cave'}, size: 8),
  Animal(
    '🐔',
    'Hen',
    sound: 'Cluck',
    homes: {'farm'},
    size: 3,
    traits: {'lays_eggs', 'feathers'},
  ),
  Animal('🐬', 'Dolphin', homes: {'ocean'}, size: 7, traits: {'swims'}),
  Animal(
    '🐟',
    'Fish',
    homes: {'ocean', 'pond'},
    size: 2,
    traits: {'swims', 'lays_eggs'},
  ),
  Animal(
    '🐢',
    'Turtle',
    homes: {'ocean', 'pond'},
    size: 4,
    traits: {'swims', 'lays_eggs', 'shell'},
  ),
  Animal('🐇', 'Rabbit', size: 2),
  Animal('🦒', 'Giraffe', homes: {'savanna'}, size: 9, traits: {'long_neck'}),
  Animal('🦓', 'Zebra', homes: {'savanna'}, size: 7, traits: {'stripes'}),
  Animal(
    '🐧',
    'Penguin',
    homes: {'ice', 'ocean'},
    size: 4,
    traits: {'swims', 'lays_eggs', 'feathers'},
  ),
  Animal('🐫', 'Camel', homes: {'desert'}, size: 8),
  Animal('🐳', 'Whale', homes: {'ocean'}, size: 10, traits: {'swims'}),
  Animal(
    '🐜',
    'Ant',
    homes: {'anthill'},
    size: 1,
    traits: {'six_legs', 'insect', 'lays_eggs'},
  ),
  Animal('🕷️', 'Spider', size: 1, traits: {'eight_legs', 'lays_eggs'}),
  Animal(
    '🦋',
    'Butterfly',
    size: 1,
    traits: {'flies', 'six_legs', 'insect', 'lays_eggs'},
  ),
  Animal('🐌', 'Snail', size: 1, traits: {'shell', 'no_legs', 'lays_eggs'}),
  Animal('🐿️', 'Squirrel', homes: {'tree'}, size: 2),
  Animal('🦊', 'Fox', homes: {'forest', 'den'}, size: 4),
  Animal('🐐', 'Goat', homes: {'farm'}, size: 5),
  Animal('🦀', 'Crab', homes: {'ocean'}, size: 2, traits: {'shell'}),
  Animal('🐙', 'Octopus', homes: {'ocean'}, size: 4, traits: {'swims'}),
];

const kHomes = <String, (String, String)>{
  'farm': ('🚜', 'farm'),
  'pond': ('💧', 'pond'),
  'hive': ('🍯', 'hive'),
  'tree': ('🌳', 'tree'),
  'ocean': ('🌊', 'ocean'),
  'savanna': ('🌾', 'grassland'),
  'ice': ('🧊', 'icy land'),
  'desert': ('🏜️', 'desert'),
  'forest': ('🌲', 'forest'),
  'burrow': ('🕳️', 'burrow'),
};

const kTraitQuestions = <String, String>{
  'flies': 'Which animal can fly?',
  'six_legs': 'Which animal has six legs?',
  'eight_legs': 'Which animal has eight legs?',
  'feathers': 'Which animal has feathers?',
  'shell': 'Which animal has a shell?',
  'long_neck': 'Which animal has a very long neck?',
  'trunk': 'Which animal has a trunk?',
  'stripes': 'Which animal has stripes?',
};

/// Objects whose colour is reliable across emoji fonts.
class ColoredThing {
  const ColoredThing(this.emoji, this.name, this.color);

  final String emoji;
  final String name;
  final String color;
}

const kColorValues = <String, int>{
  'red': 0xFFE53935,
  'blue': 0xFF1E88E5,
  'yellow': 0xFFFDD835,
  'green': 0xFF43A047,
  'orange': 0xFFFB8C00,
  'purple': 0xFF8E24AA,
  'pink': 0xFFF06292,
  'brown': 0xFF795548,
  'black': 0xFF212121,
  'white': 0xFFFAFAFA,
  'grey': 0xFF9E9E9E,
};

/// Colours introduced tier by tier.
const kColorTiers = <List<String>>[
  ['red', 'blue', 'yellow', 'green'],
  ['orange', 'purple'],
  ['pink', 'brown'],
  ['black', 'white'],
];

const kColoredThings = <ColoredThing>[
  ColoredThing('🍎', 'Apple', 'red'),
  ColoredThing('🍓', 'Strawberry', 'red'),
  ColoredThing('🚒', 'Fire engine', 'red'),
  ColoredThing('🍒', 'Cherries', 'red'),
  ColoredThing('🍌', 'Banana', 'yellow'),
  ColoredThing('🍋', 'Lemon', 'yellow'),
  ColoredThing('🐥', 'Chick', 'yellow'),
  ColoredThing('🌽', 'Corn', 'yellow'),
  ColoredThing('🥦', 'Broccoli', 'green'),
  ColoredThing('🐸', 'Frog', 'green'),
  ColoredThing('🥒', 'Cucumber', 'green'),
  ColoredThing('🍀', 'Clover', 'green'),
  ColoredThing('👖', 'Jeans', 'blue'),
  ColoredThing('💧', 'Water drop', 'blue'),
  ColoredThing('🐳', 'Whale', 'blue'),
  ColoredThing('🍊', 'Orange', 'orange'),
  ColoredThing('🥕', 'Carrot', 'orange'),
  ColoredThing('🎃', 'Pumpkin', 'orange'),
  ColoredThing('🍇', 'Grapes', 'purple'),
  ColoredThing('🍆', 'Eggplant', 'purple'),
  ColoredThing('🐷', 'Pig', 'pink'),
  ColoredThing('🌸', 'Blossom', 'pink'),
  ColoredThing('🎀', 'Ribbon', 'pink'),
  ColoredThing('🐻', 'Bear', 'brown'),
  ColoredThing('🍫', 'Chocolate', 'brown'),
  ColoredThing('🥔', 'Potato', 'brown'),
  ColoredThing('🎩', 'Top hat', 'black'),
  ColoredThing('🎱', 'Pool ball', 'black'),
  ColoredThing('☁️', 'Cloud', 'white'),
  ColoredThing('⛄', 'Snowman', 'white'),
  ColoredThing('🥚', 'Egg', 'white'),
];

/// Primary/secondary colour mixing facts (paint mixing).
const kColorMixes = <(String, String, String)>[
  ('red', 'yellow', 'orange'),
  ('blue', 'yellow', 'green'),
  ('red', 'blue', 'purple'),
  ('red', 'white', 'pink'),
  ('black', 'white', 'grey'),
];

/// Picture words for phonics. Words are upper-case and pictured clearly.
const kPictureWords = <(String, String)>[
  ('🍎', 'APPLE'),
  ('🐜', 'ANT'),
  ('⚽', 'BALL'),
  ('🚌', 'BUS'),
  ('🐝', 'BEE'),
  ('🐱', 'CAT'),
  ('🚗', 'CAR'),
  ('🐶', 'DOG'),
  ('🦆', 'DUCK'),
  ('🥚', 'EGG'),
  ('🐘', 'ELEPHANT'),
  ('🐟', 'FISH'),
  ('🐸', 'FROG'),
  ('🐐', 'GOAT'),
  ('🍇', 'GRAPES'),
  ('🎩', 'HAT'),
  ('🐔', 'HEN'),
  ('🍦', 'ICE CREAM'),
  ('🧃', 'JUICE'),
  ('🦘', 'KANGAROO'),
  ('🔑', 'KEY'),
  ('🦁', 'LION'),
  ('🍃', 'LEAF'),
  ('🌙', 'MOON'),
  ('🥛', 'MILK'),
  ('🔟', 'TEN'),
  ('👃', 'NOSE'),
  ('🦉', 'OWL'),
  ('🐙', 'OCTOPUS'),
  ('🐷', 'PIG'),
  ('🖊️', 'PEN'),
  ('👸', 'QUEEN'),
  ('🐇', 'RABBIT'),
  ('💍', 'RING'),
  ('☀️', 'SUN'),
  ('⭐', 'STAR'),
  ('🌳', 'TREE'),
  ('🚆', 'TRAIN'),
  ('☂️', 'UMBRELLA'),
  ('🚐', 'VAN'),
  ('🎻', 'VIOLIN'),
  ('⌚', 'WATCH'),
  ('🕸️', 'WEB'),
  ('🧶', 'YARN'),
  ('🦓', 'ZEBRA'),
  ('🐻', 'BEAR'),
  ('🛏️', 'BED'),
  ('🧦', 'SOCK'),
  ('🐮', 'COW'),
  ('🍰', 'CAKE'),
  ('🥁', 'DRUM'),
  ('🧸', 'TEDDY'),
];

/// Letters children commonly confuse; used as hard distractors.
const kLookalikeLetters = <String, String>{
  'B': 'DPR',
  'D': 'BPO',
  'P': 'BRQ',
  'Q': 'OGP',
  'M': 'NW',
  'N': 'MH',
  'W': 'MV',
  'E': 'FB',
  'F': 'EP',
  'C': 'GO',
  'G': 'CQ',
  'O': 'QC',
  'I': 'LT',
  'L': 'IT',
  'U': 'VJ',
  'V': 'UY',
};

/// Things that belong together (A goes with B).
const kPairs = <(String, String, String, String, String)>[
  ('🔒', 'Lock', '🔑', 'Key', 'A key opens a lock.'),
  ('🐶', 'Dog', '🦴', 'Bone', 'Dogs love to chew bones.'),
  ('🐰', 'Rabbit', '🥕', 'Carrot', 'Rabbits like to munch carrots.'),
  ('🐵', 'Monkey', '🍌', 'Banana', 'Monkeys enjoy bananas.'),
  ('🐝', 'Bee', '🌻', 'Flower', 'Bees visit flowers.'),
  ('🌧️', 'Rain', '☂️', 'Umbrella', 'An umbrella keeps rain off.'),
  ('🎂', 'Cake', '🕯️', 'Candle', 'Birthday cakes have candles.'),
  ('🎨', 'Paint', '🖌️', 'Brush', 'We paint with a brush.'),
  ('🐄', 'Cow', '🥛', 'Milk', 'Cows give us milk.'),
  ('🐔', 'Hen', '🥚', 'Egg', 'Hens lay eggs.'),
  ('🐑', 'Sheep', '🧶', 'Wool', 'Wool comes from sheep.'),
  ('🎁', 'Gift', '🎀', 'Ribbon', 'Gifts are tied with a ribbon.'),
  ('🏰', 'Castle', '👑', 'Crown', 'Kings and queens in castles wear crowns.'),
  ('⚽', 'Ball', '🥅', 'Goal', 'We kick the ball into the goal.'),
  ('🧦', 'Sock', '👟', 'Shoe', 'Socks go inside shoes.'),
  ('✉️', 'Letter', '📮', 'Post box', 'Letters go in a post box.'),
  ('🔦', 'Torch', '🔋', 'Battery', 'A torch needs a battery.'),
  ('🌱', 'Plant', '💧', 'Water', 'Plants need water to grow.'),
  ('🍞', 'Bread', '🧀', 'Cheese', 'A cheese sandwich uses bread.'),
  ('🎣', 'Fishing rod', '🐟', 'Fish', 'A fishing rod catches fish.'),
  ('🚗', 'Car', '⛽', 'Fuel', 'Cars need fuel.'),
  ('🥄', 'Spoon', '🥣', 'Bowl', 'We eat from a bowl with a spoon.'),
  ('🎻', 'Violin', '🎵', 'Music', 'A violin makes music.'),
  ('🐼', 'Panda', '🎋', 'Bamboo', 'Pandas eat bamboo.'),
  ('🧤', 'Gloves', '🧣', 'Scarf', 'Gloves and a scarf keep us warm.'),
  ('✏️', 'Pencil', '📒', 'Notebook', 'We write in a notebook with a pencil.'),
];

/// Category membership for Odd One Out. Categories that overlap are never
/// mixed in the same round.
const kCategories = <String, List<(String, String)>>{
  'fruits': [
    ('🍎', 'Apple'),
    ('🍌', 'Banana'),
    ('🍇', 'Grapes'),
    ('🍊', 'Orange'),
    ('🍓', 'Strawberry'),
    ('🍍', 'Pineapple'),
    ('🍉', 'Watermelon'),
    ('🍐', 'Pear'),
    ('🥭', 'Mango'),
    ('🍒', 'Cherries'),
  ],
  'vegetables': [
    // Root and leaf vegetables only, so no item is botanically a fruit.
    ('🥕', 'Carrot'), ('🥦', 'Broccoli'), ('🥔', 'Potato'), ('🥬', 'Lettuce'),
    ('🍠', 'Sweet potato'),
  ],
  'vehicles': [
    ('🚗', 'Car'),
    ('🚌', 'Bus'),
    ('🚲', 'Bicycle'),
    ('🚂', 'Train'),
    ('✈️', 'Plane'),
    ('🚢', 'Ship'),
    ('🚜', 'Tractor'),
    ('🚁', 'Helicopter'),
  ],
  'farm animals': [
    ('🐄', 'Cow'),
    ('🐷', 'Pig'),
    ('🐑', 'Sheep'),
    ('🐔', 'Hen'),
    ('🐴', 'Horse'),
    ('🐐', 'Goat'),
  ],
  'sea creatures': [
    ('🐟', 'Fish'),
    ('🐙', 'Octopus'),
    ('🐳', 'Whale'),
    ('🦀', 'Crab'),
    ('🐬', 'Dolphin'),
    ('🦈', 'Shark'),
  ],
  'insects': [
    ('🐝', 'Bee'),
    ('🐜', 'Ant'),
    ('🦋', 'Butterfly'),
    ('🐞', 'Ladybird'),
    ('🦗', 'Cricket'),
  ],
  'clothes': [
    ('👕', 'T-shirt'),
    ('👖', 'Jeans'),
    ('🧦', 'Socks'),
    ('🧢', 'Cap'),
    ('👗', 'Dress'),
    ('🧥', 'Coat'),
    ('🧣', 'Scarf'),
  ],
  'instruments': [
    ('🎸', 'Guitar'),
    ('🥁', 'Drum'),
    ('🎹', 'Piano'),
    ('🎺', 'Trumpet'),
    ('🎻', 'Violin'),
  ],
  'weather': [
    ('☀️', 'Sun'),
    ('🌧️', 'Rain'),
    ('❄️', 'Snow'),
    ('🌈', 'Rainbow'),
    ('⛈️', 'Storm'),
    ('🌬️', 'Wind'),
  ],
  'sports balls': [
    ('⚽', 'Football'),
    ('🏀', 'Basketball'),
    ('🎾', 'Tennis ball'),
    ('🏐', 'Volleyball'),
    ('🏈', 'Rugby ball'),
  ],
  'tools': [
    ('🔨', 'Hammer'),
    ('🔧', 'Spanner'),
    ('⛏️', 'Pick'),
    ('✂️', 'Scissors'),
  ],
};

/// Pairs of categories that are close (hard) for higher tiers.
const kCloseCategories = <(String, String)>[
  ('fruits', 'vegetables'),
  ('farm animals', 'sea creatures'),
  ('insects', 'sea creatures'),
  ('clothes', 'sports balls'),
  ('instruments', 'tools'),
];

/// Objects with a reliable real-world size rank (1 tiny … 10 enormous).
const kSizedThings = <(String, String, int)>[
  ('🐜', 'Ant', 1),
  ('🐞', 'Ladybird', 1),
  ('🍇', 'Grape', 1),
  ('🐭', 'Mouse', 2),
  ('🍎', 'Apple', 2),
  ('⚽', 'Ball', 3),
  ('🐱', 'Cat', 3),
  ('🐶', 'Dog', 4),
  ('🍉', 'Watermelon', 4),
  ('🚲', 'Bicycle', 5),
  ('🐴', 'Horse', 6),
  ('🚗', 'Car', 6),
  ('🐘', 'Elephant', 8),
  ('🚌', 'Bus', 8),
  ('🏠', 'House', 9),
  ('🐳', 'Whale', 9),
  ('🚢', 'Ship', 10),
  ('✈️', 'Plane', 9),
  ('🏔️', 'Mountain', 10),
  ('🦒', 'Giraffe', 8),
];

/// Same-family emoji that look alike; harder rows in Find Differences and
/// Shadow Matching. Each inner list is one look-alike family.
const kLookalikeFamilies = <List<(String, String)>>[
  [('🐶', 'Dog'), ('🐺', 'Wolf'), ('🦊', 'Fox')],
  [('🐱', 'Cat'), ('🐯', 'Tiger'), ('🦁', 'Lion')],
  [('🐘', 'Elephant'), ('🦏', 'Rhino'), ('🦛', 'Hippo')],
  [('🍎', 'Apple'), ('🍅', 'Tomato'), ('🍑', 'Peach')],
  [('🍋', 'Lemon'), ('🍌', 'Banana'), ('🌽', 'Corn')],
  [('🚗', 'Car'), ('🚕', 'Taxi'), ('🚙', 'Jeep')],
  [('🐢', 'Turtle'), ('🐌', 'Snail'), ('🦀', 'Crab')],
  [('🐰', 'Rabbit'), ('🐭', 'Mouse'), ('🐹', 'Hamster')],
  [('🦆', 'Duck'), ('🐔', 'Hen'), ('🐦', 'Bird')],
  [('🌳', 'Tree'), ('🌲', 'Pine tree'), ('🌴', 'Palm tree')],
  [('⭐', 'Star'), ('🌟', 'Glowing star'), ('✨', 'Sparkles')],
  [('🐄', 'Cow'), ('🐂', 'Ox'), ('🐃', 'Buffalo')],
  [('🐟', 'Fish'), ('🐠', 'Tropical fish'), ('🐡', 'Blowfish')],
  [('🌕', 'Full moon'), ('🌝', 'Moon face'), ('🌖', 'Waning moon')],
  [('🙂', 'Smile'), ('😀', 'Grin'), ('😊', 'Happy')],
  [('🎈', 'Balloon'), ('🔴', 'Red circle'), ('🍒', 'Cherries')],
];

/// Easy, clearly different emoji for early levels.
const kDistinctItems = <(String, String)>[
  ('🍎', 'Apple'),
  ('🐶', 'Dog'),
  ('🚗', 'Car'),
  ('⭐', 'Star'),
  ('🌸', 'Flower'),
  ('⚽', 'Ball'),
  ('🐟', 'Fish'),
  ('🎈', 'Balloon'),
  ('🌙', 'Moon'),
  ('🍌', 'Banana'),
  ('🐱', 'Cat'),
  ('🏠', 'House'),
  ('🦋', 'Butterfly'),
  ('🧸', 'Teddy'),
  ('🚀', 'Rocket'),
  ('🍦', 'Ice cream'),
  ('🐘', 'Elephant'),
  ('🌳', 'Tree'),
  ('🎁', 'Gift'),
  ('☀️', 'Sun'),
];

/// Pattern tokens for What Comes Next.
const kPatternItems = <(String, String)>[
  ('🐶', 'Dog'),
  ('🐱', 'Cat'),
  ('🍎', 'Apple'),
  ('🍌', 'Banana'),
  ('⭐', 'Star'),
  ('🌙', 'Moon'),
  ('🚗', 'Car'),
  ('🚌', 'Bus'),
  ('🌸', 'Flower'),
  ('🍃', 'Leaf'),
  ('🐟', 'Fish'),
  ('🐸', 'Frog'),
  ('☀️', 'Sun'),
  ('☁️', 'Cloud'),
  ('🎈', 'Balloon'),
  ('🎁', 'Gift'),
];
