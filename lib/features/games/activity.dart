class Activity {
  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.colorValue,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final int colorValue;
}

const starterActivities = <Activity>[
  Activity(id: 'complete_picture', title: 'Complete Picture', description: 'Find the missing part', emoji: '🧩', colorValue: 0xFFFFD36E),
  Activity(id: 'shadow_matching', title: 'Shadow Matching', description: 'Match each shadow', emoji: '🌙', colorValue: 0xFFB7A8F5),
  Activity(id: 'color_matching', title: 'Color Matching', description: 'Find the same colors', emoji: '🎨', colorValue: 0xFFFFA98F),
  Activity(id: 'shape_matching', title: 'Shape Matching', description: 'Match shapes together', emoji: '🔷', colorValue: 0xFF8FD8F4),
  Activity(id: 'alphabet_matching', title: 'Alphabet Matching', description: 'Connect letters and pictures', emoji: '🔤', colorValue: 0xFF9DE2C2),
  Activity(id: 'animal_recognition', title: 'Animal Recognition', description: 'Meet animal friends', emoji: '🦁', colorValue: 0xFFFFC77C),
  Activity(id: 'odd_one_out', title: 'Odd One Out', description: 'Spot what is different', emoji: '🕵️', colorValue: 0xFFC8B7F7),
  Activity(id: 'big_small', title: 'Big & Small', description: 'Compare sizes', emoji: '🐘', colorValue: 0xFF8FD8F4),
  Activity(id: 'missing_numbers', title: 'Missing Numbers', description: 'Complete the number line', emoji: '🔢', colorValue: 0xFFFFD36E),
  Activity(id: 'missing_shapes', title: 'Missing Shapes', description: 'Finish the pattern', emoji: '🔺', colorValue: 0xFF9DE2C2),
  Activity(id: 'find_differences', title: 'Find Differences', description: 'Look closely', emoji: '🔍', colorValue: 0xFFFFA98F),
  Activity(id: 'magic_counting', title: 'Magic Counting', description: 'Count and discover', emoji: '✨', colorValue: 0xFFC8B7F7),
  Activity(id: 'number_sequencing', title: 'Number Sequencing', description: 'Put numbers in order', emoji: '🔢', colorValue: 0xFF8FD8F4),
  Activity(id: 'what_comes_next', title: 'What Comes Next', description: 'Continue the sequence', emoji: '➡️', colorValue: 0xFF9DE2C2),
  Activity(id: 'jigsaw_puzzles', title: 'Jigsaw Puzzles', description: 'Build the whole picture', emoji: '🧩', colorValue: 0xFFFFD36E),
];
