//
//  Result.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

enum Result<T> {
    case success(T)
    case error(Error)

    var value: T {
        switch self {
        case .success(let r):
            return r
        default:
            fatalError("Tried to unwrap an error result")
        }
    }
}
