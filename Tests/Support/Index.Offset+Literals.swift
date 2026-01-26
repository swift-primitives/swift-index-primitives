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

public import Index_Primitives
@_spi(Internal) public import Identity_Primitives

/// Test support: Adds `ExpressibleByIntegerLiteral` conformance to `Index<Tag>.Offset`.
///
/// This conformance is available only for test targets. Production code should use
/// `init(_:)` to construct offsets.
extension Tagged.Offset: ExpressibleByIntegerLiteral
where RawValue == Ordinal.Position, Tag: ~Copyable {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}
