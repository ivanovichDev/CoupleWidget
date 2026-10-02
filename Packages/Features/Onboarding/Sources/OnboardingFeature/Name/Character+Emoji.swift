extension Character {
    var isEmojiSymbol: Bool {
        unicodeScalars.contains { scalar in
            scalar.properties.isEmojiPresentation
                || scalar.value == 0xFE0F
                || (scalar.properties.isEmoji && scalar.value >= 0x203C)
        }
    }
}
