/// Which of the two Home-screen activities the child picked. Both share
/// the same category-select screen; the mode decides what happens after a
/// category is chosen.
enum GameMode {
  /// "Learn the word" — an explore screen showing every item in the
  /// category at once. Tapping one just plays its word, no right/wrong.
  learn,

  /// "Guess the word" — the existing flashcard quiz flow, unchanged.
  guess,
}
