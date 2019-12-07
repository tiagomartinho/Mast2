//
//  Tag.swift
//  MastodonKit
//
//  Created by Ornithologist Coder on 4/9/17.
//  Copyright © 2017 MastodonKit. All rights reserved.
//

import Foundation

public class Tag: Codable {
    /// The hashtag, not including the preceding #.
    public let name: String
    /// The URL of the hashtag.
    public let url: String
    /// The history of the hashtag.
    public let history: [TagHistory]?
}

public class TagHistory: Codable {
    /// The hashtag uses.
    public let day: String
    /// The hashtag uses.
    public let uses: String
    /// The hashtag accounts.
    public let accounts: String
}
