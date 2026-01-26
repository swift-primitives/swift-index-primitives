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
public import Index_Primitives
@_spi(Internal) public import Identity_Primitives

/// Test support: Adds `ExpressibleByIntegerLiteral` conformance to `Index<Tag>`.
///
/// This conformance is available only for test targets. Production code should use
/// the throwing initializer `init(_:)` to construct indices.
///
/// - Warning: Traps on invalid values. Use only in tests.
extension Tagged: ExpressibleByIntegerLiteral
where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    public init(integerLiteral value: Int) {
        do {
            self = try Self(value)
        } catch {
            preconditionFailure("Index literal \(value) is negative")
        }
    }
}
