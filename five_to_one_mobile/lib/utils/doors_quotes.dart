import 'dart:math';

class DoorsQuotes {
  static final List<String> quotes = [
    "Five to one, baby\nOne in five",
    "No one here gets out alive",
    "Gonna make it, baby\nIf we try",
    "You get yours, baby\nI'll get mine",
    "The old get old\nAnd the young get stronger",
    "They got the guns\nBut we got the numbers",
    "Gonna win, yeah\nWe're takin' over",
    "Your ballroom days are over, baby",
    "Night is drawing near",
    "Shadows of the evening\nCrawl across the years",
    "Trade in your hours\nFor a handful dimes",
    "Gonna make it, baby\nIn our prime",
  ];

  static String getRandom() {
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  static String getMotivational() {
    final motivational = [
      "Gonna make it, baby\nIf we try",
      "You get yours, baby\nI'll get mine",
      "Gonna make it, baby\nIn our prime",
      "We're takin' over",
    ];
    final random = Random();
    return motivational[random.nextInt(motivational.length)];
  }

  static String getWarning() {
    return "Trade in your hours\nFor a handful dimes";
  }
}
