//
//  TrendingTags.swift
//  Mast
//
//  Created by Shihab Mehboob on 05/12/2019.
//  Copyright © 2019 Shihab Mehboob. All rights reserved.
//

import Foundation

public struct TrendingTags {
    /// Fetches trending tags.
    ///
    /// - Returns: Request for `[Tag]`.
    public static func all() -> Request<[Tag]> {
        return Request<[Tag]>(path: "/api/v1/trends")
    }
}

