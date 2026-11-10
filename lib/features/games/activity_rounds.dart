/// Question content for the catalogue's five-round learning activities.
///
/// Each activity has its own visual cue, learning prompt, option set and answer
/// key. Dedicated drag/drop games (Shape Matching, Odd One Out and Jigsaw)
/// continue to use their own screens.
class ActivityOption {
  const ActivityOption({required this.emoji, required this.label});

  final String emoji;
  final String label;
}

class ActivityRound {
  const ActivityRound({
    required this.prompt,
    required this.cue,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String prompt;
  final String cue;
  final List<ActivityOption> options;
  final int correctIndex;
  final String explanation;
}

ActivityOption _o(String emoji, String label) =>
    ActivityOption(emoji: emoji, label: label);

ActivityRound _r(
  String prompt,
  String cue,
  List<ActivityOption> options,
  int correctIndex,
  String explanation,
) =>
    ActivityRound(
      prompt: prompt,
      cue: cue,
      options: options,
      correctIndex: correctIndex,
      explanation: explanation,
    );

/// Returns five age-friendly, deterministic rounds for [activityId].
///
/// Deterministic data makes offline play reliable and keeps answer keys
/// testable. Randomized question ordering can be layered on after progression
/// and persistence are introduced.
List<ActivityRound> activityRoundsFor(String activityId) {
  switch (activityId) {
    case 'complete_picture':
      return [
        _r('Choose the piece that completes the picture.', '🐱  Missing part?',
            [_o('🐈', 'Tail'), _o('🪽', 'Wing'), _o('🐟', 'Fin'), _o('🌿', 'Leaf')],
            0, 'A cat has a tail.'),
        _r('Choose the piece that completes the picture.', '🐘  Missing part?',
            [_o('🪽', 'Wing'), _o('🐘', 'Ear'), _o('🐘', 'Trunk'), _o('🐟', 'Fin')],
            2, 'An elephant uses its trunk to pick things up.'),
        _r('Choose the piece that completes the picture.', '🦋  Missing part?',
            [_o('🦋', 'Wing'), _o('🐘', 'Trunk'), _o('🚲', 'Wheel'), _o('🐟', 'Fin')],
            0, 'A butterfly has wings.'),
        _r('Choose the piece that completes the picture.', '🐟  Missing part?',
            [_o('🚲', 'Wheel'), _o('🪽', 'Wing'), _o('🐟', 'Fin'), _o('🐘', 'Trunk')],
            2, 'A fish uses its fins to swim.'),
        _r('Choose the piece that completes the picture.', '🌳  Missing part?',
            [_o('🍃', 'Leaf'), _o('⭐', 'Star'), _o('🐟', 'Fin'), _o('👟', 'Shoe')],
            0, 'Leaves are part of a tree.'),
      ];
    case 'shadow_matching':
      return [
        _r('Which clue matches the elephant shadow?', '🐘  Look at the outline',
            [_o('🐘', 'Trunk and big ears'), _o('🦒', 'Long neck'), _o('🐦', 'Beak and wings'), _o('🐟', 'Fins')],
            0, 'The trunk and large ears identify an elephant.'),
        _r('Which clue matches the giraffe shadow?', '🦒  Look at the outline',
            [_o('🐸', 'Strong back legs'), _o('🦒', 'Very long neck'), _o('🐢', 'Shell'), _o('🐠', 'Fins')],
            1, 'A giraffe has a very long neck.'),
        _r('Which clue matches the bird shadow?', '🐦  Look at the outline',
            [_o('🐍', 'Long body'), _o('🐘', 'Trunk'), _o('🐦', 'Beak and wings'), _o('🐌', 'Shell')],
            2, 'A bird has a beak and wings.'),
        _r('Which clue matches the turtle shadow?', '🐢  Look at the outline',
            [_o('🐰', 'Long ears'), _o('🐢', 'Hard shell'), _o('🦒', 'Long neck'), _o('🐟', 'Fins')],
            1, 'A turtle is recognized by its shell.'),
        _r('Which clue matches the rabbit shadow?', '🐰  Look at the outline',
            [_o('🐰', 'Long ears'), _o('🐘', 'Trunk'), _o('🐍', 'Scales'), _o('🦆', 'Beak')],
            0, 'A rabbit has long ears.'),
      ];
    case 'color_matching':
      return [
        _r('Find the color that matches the target.', '🔴  Target color',
            [_o('🔴', 'Red'), _o('🔵', 'Blue'), _o('🟡', 'Yellow'), _o('🟢', 'Green')],
            0, 'The target is red.'),
        _r('Find the color that matches the target.', '🔵  Target color',
            [_o('🟡', 'Yellow'), _o('🟢', 'Green'), _o('🔵', 'Blue'), _o('🔴', 'Red')],
            2, 'The target is blue.'),
        _r('Find the color that matches the target.', '🟡  Target color',
            [_o('🟡', 'Yellow'), _o('🔴', 'Red'), _o('🟢', 'Green'), _o('🔵', 'Blue')],
            0, 'The target is yellow.'),
        _r('Find the color that matches the target.', '🟢  Target color',
            [_o('🔵', 'Blue'), _o('🟡', 'Yellow'), _o('🔴', 'Red'), _o('🟢', 'Green')],
            3, 'The target is green.'),
        _r('Find the color that matches the target.', '🟣  Target color',
            [_o('🟠', 'Orange'), _o('🟣', 'Purple'), _o('🟢', 'Green'), _o('🔵', 'Blue')],
            1, 'The target is purple.'),
      ];
    case 'alphabet_matching':
      return [
        _r('Which letter starts the word Apple?', '🍎  A P P L E',
            [_o('🅰️', 'A'), _o('🅱️', 'B'), _o('©️', 'C'), _o('🅳', 'D')],
            0, 'Apple begins with the letter A.'),
        _r('Which letter starts the word Ball?', '⚽  B A L L',
            [_o('🅰️', 'A'), _o('🅱️', 'B'), _o('©️', 'C'), _o('🅳', 'D')],
            1, 'Ball begins with the letter B.'),
        _r('Which letter starts the word Cat?', '🐱  C A T',
            [_o('🅳', 'D'), _o('🅱️', 'B'), _o('©️', 'C'), _o('🅰️', 'A')],
            2, 'Cat begins with the letter C.'),
        _r('Which letter starts the word Dog?', '🐶  D O G',
            [_o('©️', 'C'), _o('🅰️', 'A'), _o('🅳', 'D'), _o('🅱️', 'B')],
            2, 'Dog begins with the letter D.'),
        _r('Which letter starts the word Elephant?', '🐘  E L E P H A N T',
            [_o('🅱️', 'B'), _o('🅴', 'E'), _o('🅳', 'D'), _o('©️', 'C')],
            1, 'Elephant begins with the letter E.'),
      ];
    case 'animal_recognition':
      return [
        _r('Which animal says “Moo”?', '🐄  Listen to the sound',
            [_o('🐄', 'Cow'), _o('🦁', 'Lion'), _o('🐱', 'Cat'), _o('🐸', 'Frog')],
            0, 'A cow says moo.'),
        _r('Which animal says “Roar”?', '🦁  Listen to the sound',
            [_o('🐑', 'Sheep'), _o('🦁', 'Lion'), _o('🐤', 'Chick'), _o('🐶', 'Dog')],
            1, 'A lion makes a roar.'),
        _r('Which animal says “Meow”?', '🐱  Listen to the sound',
            [_o('🐮', 'Cow'), _o('🐴', 'Horse'), _o('🐱', 'Cat'), _o('🦆', 'Duck')],
            2, 'A cat says meow.'),
        _r('Which animal says “Quack”?', '🦆  Listen to the sound',
            [_o('🐶', 'Dog'), _o('🐘', 'Elephant'), _o('🐑', 'Sheep'), _o('🦆', 'Duck')],
            3, 'A duck says quack.'),
        _r('Which animal says “Baa”?', '🐑  Listen to the sound',
            [_o('🐑', 'Sheep'), _o('🐱', 'Cat'), _o('🐸', 'Frog'), _o('🦁', 'Lion')],
            0, 'A sheep says baa.'),
      ];
    case 'big_small':
      return [
        _r('Which animal is bigger?', '🐘  VS  🐜',
            [_o('🐘', 'Elephant'), _o('🐜', 'Ant'), _o('🐞', 'Ladybug'), _o('🦋', 'Butterfly')],
            0, 'An elephant is much bigger than an ant.'),
        _r('Which object is smaller?', '🚌  VS  🚗',
            [_o('🚌', 'Bus'), _o('🚗', 'Car'), _o('🚂', 'Train'), _o('✈️', 'Plane')],
            1, 'A car is smaller than a bus.'),
        _r('Which animal is taller?', '🦒  VS  🐇',
            [_o('🐇', 'Rabbit'), _o('🐈', 'Cat'), _o('🦒', 'Giraffe'), _o('🐢', 'Turtle')],
            2, 'A giraffe is taller than a rabbit.'),
        _r('Which fruit is smaller?', '🍉  VS  🍇',
            [_o('🍉', 'Watermelon'), _o('🍇', 'Grape'), _o('🍍', 'Pineapple'), _o('🥭', 'Mango')],
            1, 'A grape is smaller than a watermelon.'),
        _r('Which animal is bigger?', '🐋  VS  🐬',
            [_o('🐬', 'Dolphin'), _o('🦀', 'Crab'), _o('🐠', 'Fish'), _o('🐋', 'Whale')],
            3, 'A whale is bigger than a dolphin.'),
      ];
    case 'missing_numbers':
      return [
        _r('Fill in the missing number.', '1   2   ?   4',
            [_o('3️⃣', '3'), _o('5️⃣', '5'), _o('6️⃣', '6'), _o('2️⃣', '2')],
            0, 'The number after 2 is 3.'),
        _r('Fill in the missing number.', '5   ?   7   8',
            [_o('4️⃣', '4'), _o('6️⃣', '6'), _o('9️⃣', '9'), _o('1️⃣', '1')],
            1, 'The number between 5 and 7 is 6.'),
        _r('Fill in the missing number.', '8   9   ?   11',
            [_o('1️⃣0️⃣', '10'), _o('1️⃣2️⃣', '12'), _o('7️⃣', '7'), _o('9️⃣', '9')],
            0, 'The number after 9 is 10.'),
        _r('Fill in the missing number.', '12   ?   14   15',
            [_o('1️⃣1️⃣', '11'), _o('1️⃣3️⃣', '13'), _o('1️⃣5️⃣', '15'), _o('1️⃣0️⃣', '10')],
            1, 'The number between 12 and 14 is 13.'),
        _r('Fill in the missing number.', '16   17   ?   19',
            [_o('2️⃣0️⃣', '20'), _o('1️⃣5️⃣', '15'), _o('1️⃣8️⃣', '18'), _o('1️⃣4️⃣', '14')],
            2, 'The number after 17 is 18.'),
      ];
    case 'missing_shapes':
      return [
        _r('Which shape completes the pattern?', '🔴  🔵  🔴  ?',
            [_o('🔵', 'Blue circle'), _o('🔺', 'Triangle'), _o('🟩', 'Square'), _o('⭐', 'Star')],
            0, 'The pattern alternates red, blue, red, blue.'),
        _r('Which shape completes the pattern?', '🔺  ⭐  🔺  ?',
            [_o('🟢', 'Circle'), _o('⭐', 'Star'), _o('🟥', 'Square'), _o('🔷', 'Diamond')],
            1, 'The pattern alternates triangle and star.'),
        _r('Which shape completes the pattern?', '🟩  🟩  🔵  🟩  🟩  ?',
            [_o('🔺', 'Triangle'), _o('🟩', 'Square'), _o('⭐', 'Star'), _o('🔴', 'Circle')],
            1, 'Two squares are followed by a blue circle.'),
        _r('Which shape completes the pattern?', '⭐  🔺  ⭐  🔺  ?',
            [_o('🔷', 'Diamond'), _o('🟩', 'Square'), _o('⭐', 'Star'), _o('🔴', 'Circle')],
            2, 'The pattern alternates star and triangle.'),
        _r('Which shape completes the pattern?', '🔵  🟡  🟢  🔵  🟡  ?',
            [_o('🔴', 'Red circle'), _o('🟢', 'Green circle'), _o('⭐', 'Star'), _o('🔺', 'Triangle')],
            1, 'The three-color pattern repeats.'),
      ];
    case 'find_differences':
      return [
        _r('Find the different symbol in the row.', '🍎  🍎  🍐  🍎',
            [_o('1️⃣', 'First'), _o('2️⃣', 'Second'), _o('3️⃣', 'Third'), _o('4️⃣', 'Fourth')],
            2, 'The third fruit is a pear; the others are apples.'),
        _r('Find the different symbol in the row.', '🐶  🐶  🐱  🐶',
            [_o('1️⃣', 'First'), _o('2️⃣', 'Second'), _o('3️⃣', 'Third'), _o('4️⃣', 'Fourth')],
            2, 'The third animal is a cat; the others are dogs.'),
        _r('Find the different symbol in the row.', '🔵  🔵  🔴  🔵',
            [_o('1️⃣', 'First'), _o('2️⃣', 'Second'), _o('3️⃣', 'Third'), _o('4️⃣', 'Fourth')],
            2, 'The third circle is red; the others are blue.'),
        _r('Find the different symbol in the row.', '⭐  🌙  ⭐  ⭐',
            [_o('1️⃣', 'First'), _o('2️⃣', 'Second'), _o('3️⃣', 'Third'), _o('4️⃣', 'Fourth')],
            1, 'The second symbol is a moon; the others are stars.'),
        _r('Find the different symbol in the row.', '🚗  🚗  🚕  🚗',
            [_o('1️⃣', 'First'), _o('2️⃣', 'Second'), _o('3️⃣', 'Third'), _o('4️⃣', 'Fourth')],
            2, 'The third vehicle is a taxi; the others are cars.'),
      ];
    case 'magic_counting':
      return [
        _r('How many stars can you count?', '⭐  ⭐  ⭐',
            [_o('1️⃣', '1'), _o('2️⃣', '2'), _o('3️⃣', '3'), _o('4️⃣', '4')],
            2, 'There are three stars.'),
        _r('How many apples can you count?', '🍎  🍎  🍎  🍎',
            [_o('5️⃣', '5'), _o('3️⃣', '3'), _o('4️⃣', '4'), _o('2️⃣', '2')],
            2, 'There are four apples.'),
        _r('How many fish can you count?', '🐟  🐟',
            [_o('2️⃣', '2'), _o('1️⃣', '1'), _o('3️⃣', '3'), _o('4️⃣', '4')],
            0, 'There are two fish.'),
        _r('How many balloons can you count?', '🎈  🎈  🎈  🎈  🎈',
            [_o('3️⃣', '3'), _o('5️⃣', '5'), _o('4️⃣', '4'), _o('6️⃣', '6')],
            1, 'There are five balloons.'),
        _r('How many flowers can you count?', '🌼  🌼  🌼  🌼  🌼  🌼',
            [_o('4️⃣', '4'), _o('5️⃣', '5'), _o('6️⃣', '6'), _o('7️⃣', '7')],
            2, 'There are six flowers.'),
      ];
    case 'number_sequencing':
      return [
        _r('Choose the next number in the sequence.', '1  ➜  2  ➜  3  ➜  ?',
            [_o('4️⃣', '4'), _o('5️⃣', '5'), _o('6️⃣', '6'), _o('7️⃣', '7')],
            0, 'Count forward: 1, 2, 3, 4.'),
        _r('Choose the next number in the sequence.', '4  ➜  5  ➜  6  ➜  ?',
            [_o('8️⃣', '8'), _o('7️⃣', '7'), _o('9️⃣', '9'), _o('🔟', '10')],
            1, 'Count forward: 4, 5, 6, 7.'),
        _r('Choose the next number in the sequence.', '7  ➜  8  ➜  9  ➜  ?',
            [_o('1️⃣1️⃣', '11'), _o('9️⃣', '9'), _o('🔟', '10'), _o('6️⃣', '6')],
            2, 'Count forward: 7, 8, 9, 10.'),
        _r('Choose the next number in the sequence.', '10  ➜  11  ➜  12  ➜  ?',
            [_o('1️⃣4️⃣', '14'), _o('1️⃣3️⃣', '13'), _o('1️⃣1️⃣', '11'), _o('1️⃣2️⃣', '12')],
            1, 'Count forward: 10, 11, 12, 13.'),
        _r('Choose the next number in the sequence.', '14  ➜  15  ➜  16  ➜  ?',
            [_o('1️⃣6️⃣', '16'), _o('1️⃣8️⃣', '18'), _o('1️⃣7️⃣', '17'), _o('1️⃣9️⃣', '19')],
            2, 'Count forward: 14, 15, 16, 17.'),
      ];
    case 'what_comes_next':
      return [
        _r('What comes next in the pattern?', '🐶  🐱  🐶  🐱  ?',
            [_o('🐶', 'Dog'), _o('🐱', 'Cat'), _o('🐰', 'Rabbit'), _o('🐼', 'Panda')],
            0, 'The pattern alternates dog and cat.'),
        _r('What comes next in the pattern?', '🔴  🔵  🔵  🔴  🔵  🔵  ?',
            [_o('🔵', 'Blue'), _o('🟢', 'Green'), _o('🔴', 'Red'), _o('🟡', 'Yellow')],
            2, 'The red-blue-blue pattern repeats.'),
        _r('What comes next in the pattern?', '🍎  🍌  🍎  🍌  ?',
            [_o('🍌', 'Banana'), _o('🍎', 'Apple'), _o('🍇', 'Grapes'), _o('🍊', 'Orange')],
            1, 'The pattern alternates apple and banana.'),
        _r('What comes next in the pattern?', '⭐  ⭐  🌙  ⭐  ⭐  🌙  ?',
            [_o('🌙', 'Moon'), _o('⭐', 'Star'), _o('☀️', 'Sun'), _o('🌈', 'Rainbow')],
            1, 'Two stars are followed by a moon.'),
        _r('What comes next in the pattern?', '🚗  🚌  🚕  🚗  🚌  ?',
            [_o('🚗', 'Car'), _o('🚕', 'Taxi'), _o('🚌', 'Bus'), _o('🚲', 'Bicycle')],
            1, 'The car, bus, taxi sequence repeats.'),
      ];
    default:
      return [];
  }
}
