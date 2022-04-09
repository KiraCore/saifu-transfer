import 'dart:convert';

class EmojiCheckSum {
  static const emojis = [
    '🎪',
    '🛹',
    '🏆',
    '🏅',
    '⚽',
    '🏀',
    '🏈',
    '🎾',
    '🎯',
    '🎱',
    '🎮',
    '🎲',
    '🎤',
    '🎧',
    '🎷',
    '🎸',
    '🎹',
    '🎺',
    '🎻',
    '🥁',
    '🎬',
    '🏹',
    '🚩',
    '😃',
    '🤣',
    '😂',
    '🙂',
    '🙃',
    '😉',
    '😊',
    '😇',
    '🥰',
    '😍',
    '😘',
    '😋',
    '🤪',
    '😝',
    '🤑',
    '🤗',
    '🤔',
    '😐',
    '😶',
    '😏',
    '🙄',
    '😬',
    '😌',
    '😪',
    '😴',
    '😷',
    '🤒',
    '🤢',
    '🤮',
    '🤧',
    '🥵',
    '🥶',
    '🤯',
    '🤠',
    '🥳',
    '😎',
    '🤓',
    '🧐',
    '😮',
    '😭',
    '😱',
    '😖',
    '😤',
    '😡',
    '🤬',
    '😈',
    '💀',
    '💩',
    '🤡',
    '👻',
    '👽',
    '👾',
    '🤖',
    '💋',
    '👋',
    '✋',
    '👌',
    '🤏',
    '🤞',
    '👈',
    '👉',
    '👍',
    '👎',
    '✊',
    '👊',
    '👏',
    '🙌',
    '🤝',
    '🙏',
    '✍',
    '💪',
    '🦵',
    '🦶',
    '👂',
    '👃',
    '🧠',
    '🦷',
    '🦴',
    '👀',
    '👅',
    '👄',
    '👶',
    '👦',
    '👧',
    '👨',
    '👩',
    '👴',
    '👵',
    '🙇',
    '🤦',
    '🤷',
    '🕵',
    '💂',
    '👷',
    '🤴',
    '👸',
    '🤵',
    '👰',
    '🎅',
    '🧙',
    '🧚',
    '🧛',
    '🧜',
    '🧝',
    '🚶',
    '🏃',
    '💏',
    '👪',
    '👣',
    '☂',
    '🎃',
    '🧵',
    '🧶',
    '👓',
    '🥽',
    '🧦',
    '👗',
    '👜',
    '👑',
    '🎓',
    '💍',
    '💼',
    '🩸',
    '🌋',
    '🏠',
    '🏭',
    '🏰',
    '🗼',
    '🗽',
    '🌅',
    '🚌',
    '🚓',
    '🚕',
    '🚗',
    '🚜',
    '🛵',
    '🚲',
    '⛽',
    '🚨',
    '🚥',
    '🚧',
    '⚓',
    '⛵',
    '🚢',
    '✈',
    '🚀',
    '🌠',
    '🌌',
    '🎆',
    '💵',
    '🗿',
    '💫',
    '💦',
    '💨',
    '🐒',
    '🦍',
    '🐕',
    '🐶',
    '🦊',
    '🐱',
    '🐯',
    '🐴',
    '🦄',
    '🐷',
    '🐐',
    '🐪',
    '🐘',
    '🐭',
    '🐁',
    '🐋',
    '🐬',
    '🐟',
    '🐙',
    '🦈',
    '🌹',
    '🌻',
    '🌵',
    '🍁',
    '🍄',
    '🦀',
    '🦞',
    '🌍',
    '🌑',
    '🌙',
    '⭐',
    '☁',
    '🌈',
    '⚡',
    '🔥',
    '💧',
    '🌊',
    '✨',
    '🍉',
    '🍌',
    '🍎',
    '🍒',
    '🥕',
    '🍖',
    '🥩',
    '🍕',
    '🍩',
    '🍺',
    '🧊',
    '💣',
    '⏰',
    '🎈',
    '🎉',
    '🧸',
    '💎',
    '📻',
    '📷',
    '🔎',
    '💡',
    '📚',
    '📌',
    '📍',
    '📎',
    '📏',
    '🔒',
    '🔑',
    '🔫',
    '🧲',
    '💊',
    '💯',
    '📢',
    '🔔',
    '🎵',
    '🚸',
    '⛔',
    '🚫',
    '❓',
    '⭕',
    '❌',
  ];

  static Future<List<String>> convertToEmoji(String checkSum) async {
    List<int> encodeData = utf8.encode(checkSum);
    List<String> emojiList = [];
    String longSum = "";
    for (int i = 0; i < 6; i++) {
      longSum = longSum + EmojiCheckSum.emojis[encodeData[i]];
    }
    /*
    List<int> shortedData = encodeData.toSet().toList();
    String shortSum = "";
    for (int i = 0; i < shortedData.length; i++) {
      shortSum = shortSum + EmojiCheckSum.emojis[shortedData[i]];
    }
    */
    emojiList.add(checkSum);
    emojiList.add(longSum);
    return emojiList;
  }
}