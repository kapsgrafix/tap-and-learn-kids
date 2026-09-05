/// A single word the child can be asked to recognize (e.g. "Apple",
/// "Red", "Circle"). [audioAsset] is the narration clip played when the
/// question appears or when the child taps the replay button.
/// [imageAsset] is the illustrated artwork exported from Figma.
class GameItem {
  final String id;
  final String label;
  final String audioAsset;
  final String imageAsset;

  const GameItem({
    required this.id,
    required this.label,
    required this.audioAsset,
    required this.imageAsset,
  });
}
