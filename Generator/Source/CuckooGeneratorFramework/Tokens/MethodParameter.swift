//
//  MethodParameter.swift
//  CuckooGenerator
//
//  Created by Filip Dolnik on 30.05.16.
//  Copyright © 2016 Brightify. All rights reserved.
//

public struct MethodParameter: Token, Equatable {
    public var label: String?
    public var name: String
    public var type: String
    public var range: CountableRange<Int>
    public var nameRange: CountableRange<Int>
    public var isInout: Bool
    
    public var labelAndName: String {
        if let label = label {
            return label != name ? "\(label) \(name)" : name
        } else {
            return "_ \(name)"
        }
    }
    
    public var typeWithoutAttributes: String {
        return type.replacingOccurrences(of: "@escaping", with: "").replacingOccurrences(of: "@autoclosure", with: "").trimmed
    }

    public func isEqual(to other: Token) -> Bool {
        guard let other = other as? MethodParameter else { return false }
        return self.name == other.name && self.type == other.type && self.label == other.label
    }
    
    public var isClosure: Bool {        
        return typeWithoutAttributes.hasPrefix("(") && typeWithoutAttributes.range(of: "->") != nil
    }

    public var closureParamCount: Int {
        // make sure that the parameter is a closure and that it's not just an empty `() -> ...` closure
        guard isClosure && !"^\\s*\\(\\s*\\)".regexMatches(typeWithoutAttributes) else { return 0 }

        var parenLevel = 0
        var parameterCount = 1
        for character in typeWithoutAttributes {
            switch character {
            case "(", "<":
                parenLevel += 1
            case ")", ">":
                parenLevel -= 1
            case ",":
                parameterCount += parenLevel == 1 ? 1 : 0
            default:
                break
            }
            if parenLevel == 0 {
                break
            }
        }

        return parameterCount
    }
    
    public var isEscaping: Bool {
        return isClosure && (type.hasPrefix("@escaping") || type.hasSuffix(")?"))
    }
    
    public func serialize() -> [String : Any] {
        return [
            "label": label ?? "",
            "name": name,
            "type": type,
            "labelAndName": labelAndName,
            "typeWithoutAttributes": typeWithoutAttributes,
            "isClosure": isClosure,
            "isEscaping": isEscaping
        ]
    }
}

public func ==(lhs: MethodParameter, rhs: MethodParameter) -> Bool {
    return lhs.isEqual(to: rhs)
}

import Foundation

extension String {
    func regexMatches(_ source: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: self)
        return regex.firstMatch(in: source, range: NSRange(location: 0, length: source.count)) != nil
    }
}
