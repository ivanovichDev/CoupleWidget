import CoreGraphics
import Foundation

struct NoteWallNote {
    let width: CGFloat
    let text: String
    let meta: String

    var isSmall: Bool { width == NoteWallNote.small }

    static let small: CGFloat = 120
    static let medium: CGFloat = 254

    static func small(_ text: String, _ meta: String) -> NoteWallNote {
        NoteWallNote(width: small, text: text, meta: meta)
    }

    static func medium(_ text: String, _ meta: String) -> NoteWallNote {
        NoteWallNote(width: medium, text: text, meta: meta)
    }
}

struct NoteWallRow {
    let top: CGFloat
    let left: CGFloat
    let notes: [NoteWallNote]

    var loopWidth: CGFloat {
        notes.reduce(0) { $0 + $1.width + 14 }
    }
}

extension NoteWallRow {
    static let durations: [Double] = [38, 44, 40, 48, 42, 46, 39]

    static let all: [NoteWallRow] = {
        let anna = String(localized: "From Anna")
        let you = String(localized: "From you")
        return [
            NoteWallRow(top: 6, left: -70, notes: [
                .medium(String(localized: "Good morning, sunshine. Coffee is on the stove."), anna),
                .small(String(localized: "Love you"), you),
                .medium(String(localized: "Dinner at Nonna’s on Friday, 8 PM"), anna),
                .small(String(localized: "Hugs"), you),
            ]),
            NoteWallRow(top: 140, left: -132, notes: [
                .small(String(localized: "Home by 7?"), anna),
                .medium(String(localized: "Can’t wait for tonight, I got the tickets"), you),
                .small(String(localized: "Miss you already"), anna),
                .medium(String(localized: "Saved you the last slice of cake"), anna),
            ]),
            NoteWallRow(top: 274, left: -24, notes: [
                .medium(String(localized: "You make every day better"), anna),
                .small(String(localized: "Proud of you today"), you),
                .medium(String(localized: "Good luck at the interview!"), you),
                .small(String(localized: "Call me later"), anna),
            ]),
            NoteWallRow(top: 408, left: -150, notes: [
                .small(String(localized: "Sleep well"), anna),
                .medium(String(localized: "Three years together. Still my favorite person."), anna),
                .small(String(localized: "On my way"), you),
                .medium(String(localized: "Best weekend ever"), you),
            ]),
            NoteWallRow(top: 542, left: -62, notes: [
                .medium(String(localized: "Thinking of you"), you),
                .small(String(localized: "Coffee?"), anna),
                .medium(String(localized: "Take an umbrella, it might rain"), anna),
                .small(String(localized: "See you soon"), anna),
            ]),
            NoteWallRow(top: 676, left: -132, notes: [
                .small(String(localized: "Hi, you"), you),
                .medium(String(localized: "Don’t forget your keys"), anna),
                .small(String(localized: "Text me"), anna),
                .medium(String(localized: "Can’t stop smiling today"), you),
            ]),
            NoteWallRow(top: 810, left: -40, notes: [
                .medium(String(localized: "Pick you up at 6"), you),
                .small(String(localized: "Kisses"), anna),
                .medium(String(localized: "Movie night tonight?"), anna),
                .small(String(localized: "Yes!"), you),
            ]),
        ]
    }()
}
