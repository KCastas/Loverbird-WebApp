import 'dart:math';

class DrawingChallenges {
  static final List<String> _challenges = [
    "Draw a goofy ahh bird wearing sunglasses. 😎🦜",
    "Sketch a tiny gothic flower. 🌸🖤",
    "Doodle a parrot playing Roblox. 🎮🦜",
    "Create a crazy rainbow cat. 🌈🐱",
    "Draw freak bob!",
    "Draw a cute ghost with a top hat. 👻🎩",
    "Sketch freddy fasbear dueling a carrot.",
    "Make a gothic castle with flowers. 🏰🌹",
    "Draw a lovebird dancing to goth music. 🕺🎶",
    "Draw a colorful bird. 📱🐦",
    "Doodle a robot with a flower crown. 🤖🌼",
    "Draw a duck swimming in a pond.",
    "Draw a praying mantis, praying in church",
    "Look around you, draw the first thing that catches your eye!",
    "Draw a flock of lovebirds cruising through the skies",
  ];

  static String getRandomChallenge() {
    final random = Random();
    return _challenges[random.nextInt(_challenges.length)];
  }
}
