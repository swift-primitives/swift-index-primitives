//// ===----------------------------------------------------------------------===//
////
//// This source file is part of the swift-primitives open source project
////
//// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-primitives project authors
//// Licensed under Apache License v2.0
////
//// See LICENSE for license information
////
//// ===----------------------------------------------------------------------===//
//
//// MARK: - Collection Extension
//
//extension Collection {
//    /// Accessor for safe collection operations that return `Optional` instead of trapping.
//    ///
//    /// Use `.safe` to access elements and ranges with bounds checking that returns
//    /// `nil` for invalid indices instead of crashing.
//    ///
//    /// ## Example
//    ///
//    /// ```swift
//    /// let array = [1, 2, 3]
//    ///
//    /// // Safe element access
//    /// let element = array.safe[1]   // Optional(2)
//    /// let missing = array.safe[10]  // nil (no crash)
//    ///
//    /// // Safe range access
//    /// let slice = array.safe[0..<2]  // Optional([1, 2])
//    /// let bad = array.safe[0..<10]   // nil (no crash)
//    /// ```
//    @inlinable
//    public var safe: Safe<Self> {
//        Safe(self)
//    }
//}
