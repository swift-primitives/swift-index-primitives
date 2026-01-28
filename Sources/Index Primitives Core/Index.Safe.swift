// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

/// Accessor for safe index operations. All subscripts return `Optional`,
/// returning `nil` for out-of-bounds access instead of trapping.
///
/// Accessed via the `.safe` property on any `Collection`.
///
/// ## Example
///
/// ```swift
/// let array = [1, 2, 3]
/// array.safe[1]   // Optional(2)
/// array.safe[10]  // nil
/// ```
public struct Safe<Base: Swift.Collection> {
    @usableFromInline
    let base: Base

    @usableFromInline
    init(_ base: Base) {
        self.base = base
    }
}

extension Safe: Sendable where Base: Sendable {}
