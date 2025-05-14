//
//  String+AltCaps.swift
//  AltCaps
//
//  Created by Faraz Alam on 5/5/25.
//
// String+AltCaps.swift
// No changes here—keep this in your AltCaps (formerly TextAlternator) target.

import Foundation

extension String {
    /// Alternates alphabetic characters between lower- and uppercase,
    /// skipping non-letters (spaces/punctuation/digits remain untouched).
    var altCaps: String {
        var makeUpper = false
        return self
            .map { ch -> Character in
                guard ch.isLetter else { return ch }
                let out = makeUpper
                    ? Character(ch.uppercased())
                    : Character(ch.lowercased())
                makeUpper.toggle()
                return out
            }
            .reduce(into: "") { $0.append($1) }
    }
}
