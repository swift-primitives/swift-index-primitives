// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Affine_Primitives
public import Comparison_Primitives
public import Equation_Primitives
@_spi(Internal) public import Identity_Primitives

// Equation.Protocol conformance required by Comparison.Protocol
extension Tagged: @retroactive Equation.`Protocol`
where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    @inlinable
    public static func == (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

extension Tagged: @retroactive Comparison.`Protocol`
where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    @inlinable
    public static func < (lhs: borrowing Self, rhs: borrowing Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
