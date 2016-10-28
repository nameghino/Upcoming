//
//  JSONDecoder.swift
//  Upcoming
//
//  Created by Nico Ameghino on 10/28/16.
//  Copyright © 2016 BlueTrail Software. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String : Any]

public func decode<T>(_ k: String, _ d: [String : Any]) throws -> T  {
    guard let v = d[k] else {
        throw JSONDecodableError.keyNotFound(k)
    }

    guard let r = v as? T else {
        throw JSONDecodableError.unexpectedValueType("\(T.self)", key: k)
    }
    return r
}

public func decodeOptional<T>(_ k: String, _ d: [String : Any]) throws -> T? {
    return d[k] as? T
}

/// Read as "take <key> from <dictionary>"
precedencegroup DecoderPrecedence {
    higherThan: CastingPrecedence
}

infix operator <- : DecoderPrecedence
infix operator <~ : DecoderPrecedence

func <-<T>(lhs: String, rhs: [String : Any]) throws -> T {
    return try decode(lhs, rhs)
}

func <~<T>(lhs: String, rhs: [String : Any]) throws -> T? {
    return try decodeOptional(lhs, rhs)
}

protocol JSONDecodable {
    associatedtype Container
    init(container: Container) throws
}

enum JSONDecodableError: Error {
    case keyNotFound(String)
    case unexpectedValueType(String, key: String)
}
