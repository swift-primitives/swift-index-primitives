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

// MARK: - Element Access

extension __IndexSafe {
    /// Accesses the element at the specified index, returning `nil` if out of bounds.
    ///
    /// - Parameter index: The position of the element to access.
    /// - Returns: The element at the specified index, or `nil` if the index is invalid.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let array = [1, 2, 3]
    /// array.safe[1]   // Optional(2)
    /// array.safe[10]  // nil
    /// ```
    @inlinable
    public subscript(_ index: Base.Index) -> Base.Element? {
        base.indices.contains(index) ? base[index] : nil
    }
}

// MARK: - Range Access

extension __IndexSafe {
    /// Accesses the subsequence at the specified range, returning `nil` if out of bounds.
    ///
    /// - Parameter bounds: The range of indices to access.
    /// - Returns: The subsequence at the specified range, or `nil` if the range is invalid.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let array = [1, 2, 3, 4, 5]
    /// array.safe[1..<3]  // Optional([2, 3])
    /// array.safe[0..<10] // nil
    /// ```
    @inlinable
    public subscript(_ bounds: Range<Base.Index>) -> Base.SubSequence? {
        guard bounds.lowerBound >= base.startIndex,
              bounds.upperBound <= base.endIndex else { return nil }
        return base[bounds]
    }
}

// MARK: - Integer Index Access

extension __IndexSafe where Base.Index == Int {
    /// Accesses the element at the specified integer index, returning `nil` if out of bounds.
    ///
    /// This overload safely converts arbitrary `FixedWidthInteger` types to `Int`.
    ///
    /// - Parameter index: The integer position of the element to access.
    /// - Returns: The element at the specified index, or `nil` if the index is invalid.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes: [UInt8] = [0x12, 0x34, 0x56]
    /// let offset: UInt64 = 1
    /// bytes.safe[offset]  // Optional(0x34)
    ///
    /// let huge: UInt64 = UInt64.max
    /// bytes.safe[huge]    // nil (index conversion fails)
    /// ```
    @inlinable
    public subscript<I: FixedWidthInteger>(_ index: I) -> Base.Element? {
        guard let i = Int(exactly: index),
              i >= base.startIndex,
              i < base.endIndex else { return nil }
        return base[i]
    }

    /// Accesses the subsequence at the specified integer range, returning `nil` if out of bounds.
    ///
    /// - Parameter bounds: The integer range of indices to access.
    /// - Returns: The subsequence at the specified range, or `nil` if the range is invalid.
    @inlinable
    public subscript<I: FixedWidthInteger>(_ bounds: Range<I>) -> Base.SubSequence? {
        guard let lower = Int(exactly: bounds.lowerBound),
              let upper = Int(exactly: bounds.upperBound),
              lower >= base.startIndex,
              upper <= base.endIndex else { return nil }
        return base[lower..<upper]
    }
}
