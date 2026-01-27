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

// MARK: - MutableSpan + Index.Count

extension MutableSpan where Element: ~Copyable {
    /// Creates a mutable span from a start address and typed count.
    ///
    /// - Parameters:
    ///   - start: A pointer to the start of the span.
    ///   - count: The number of elements in the span as a typed count.
    /// - Warning: The caller must ensure lifetime safety.
    @_lifetime(immortal)
    @inlinable
    public init(
        _unsafeStart start: UnsafeMutablePointer<Element>,
        count: Index_Primitives.Index<Element>.Count
    ) {
        let span = unsafe MutableSpan(_unsafeStart: start, count: Int(count.count.rawValue))
        self = unsafe _overrideLifetime(span, borrowing: ())
    }
}
