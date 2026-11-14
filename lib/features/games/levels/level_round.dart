/// Painted geometric shapes used by shape and pattern games.
enum ShapeKind {
  circle('Circle', 0),
  square('Square', 4),
  triangle('Triangle', 3),
  rectangle('Rectangle', 4),
  star('Star', 10),
  oval('Oval', 0),
  diamond('Diamond', 4),
  pentagon('Pentagon', 5),
  hexagon('Hexagon', 6),
  heart('Heart', 0);

  const ShapeKind(this.label, this.sides);

  final String label;

  /// Straight sides; 0 for curved shapes. Star outlines have ten edges.
  final int sides;
}

enum TokenKind { emoji, text, colorSwatch, shape, gap }

/// One visual element of a round: a cue item or an answer option.
///
/// [label] is always the accessible name, even when the label is visually
/// hidden (for example in recognition questions), so screen readers and
/// colour-blind players never rely on colour or picture alone.
class GameToken {
  const GameToken.emoji(
    this.value,
    this.label, {
    this.scale = 1,
    this.silhouette = false,
  }) : kind = TokenKind.emoji,
       colorValue = null,
       shape = null,
       rotation = 0;

  const GameToken.text(this.value, {String? label, this.scale = 1})
    : kind = TokenKind.text,
      label = label ?? value,
      colorValue = null,
      shape = null,
      rotation = 0,
      silhouette = false;

  const GameToken.color(this.colorValue, this.label)
    : kind = TokenKind.colorSwatch,
      value = '',
      shape = null,
      scale = 1,
      rotation = 0,
      silhouette = false;

  const GameToken.shape(
    ShapeKind this.shape,
    int this.colorValue, {
    String? label,
    this.rotation = 0,
    this.scale = 1,
  }) : kind = TokenKind.shape,
       value = '',
       label = label ?? '',
       silhouette = false;

  const GameToken.gap()
    : kind = TokenKind.gap,
      value = '?',
      label = 'missing',
      colorValue = null,
      shape = null,
      scale = 1,
      rotation = 0,
      silhouette = false;

  final TokenKind kind;
  final String value;
  final String label;
  final int? colorValue;
  final ShapeKind? shape;
  final double scale;

  /// Rotation in quarter-turn fractions (0.125 = 45°).
  final double rotation;
  final bool silhouette;

  /// Identity used to guarantee options are distinct.
  String get identity => switch (kind) {
    TokenKind.shape => 'shape:${shape!.name}:$colorValue:$rotation:$scale',
    TokenKind.colorSwatch => 'color:$colorValue',
    TokenKind.emoji => 'emoji:$value:$scale:$silhouette',
    _ => '${kind.name}:$value',
  };

  String get accessibleLabel =>
      kind == TokenKind.shape && label.isEmpty ? shape!.label : label;
}

/// How the child answers a round.
enum RoundInteraction {
  /// Tap one option.
  choose,

  /// Drag an option into the gap (tap remains an accessible alternative).
  drag,

  /// Tap the cue item that is different; options are the cue positions.
  spotInRow,

  /// Tap every option in the required order.
  order,
}

class LevelRound {
  const LevelRound({
    required this.prompt,
    required this.cue,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.interaction = RoundInteraction.choose,
    this.showOptionLabels = true,
    this.orderSolution = const [],
    this.referenceRow = const [],
  });

  final String prompt;
  final List<GameToken> cue;
  final List<GameToken> options;

  /// Correct option index; -1 for [RoundInteraction.order] rounds.
  final int correctIndex;
  final String explanation;
  final RoundInteraction interaction;

  /// False for recognition questions where the visible label would give the
  /// answer away. Labels stay available to screen readers.
  final bool showOptionLabels;

  /// Option indices in the order they must be tapped.
  final List<int> orderSolution;

  /// For spot-the-difference rounds: the unchanged picture to compare with.
  final List<GameToken> referenceRow;

  GameToken get correctOption => options[correctIndex];
}
