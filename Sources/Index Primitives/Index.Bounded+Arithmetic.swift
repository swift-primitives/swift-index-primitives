//// ===----------------------------------------------------------------------===//
////
//// This source file is part of the swift-primitives open source project
////
//// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
//// Licensed under Apache License v2.0
////
//// See LICENSE for license information
////
//// ===----------------------------------------------------------------------===//
//
//// Index.Bounded Affine Arithmetic
////
//// Bounded indices follow the same affine semantics as unbounded indices,
//// but return Optional to handle out-of-bounds results.
//// See Index+Arithmetic.swift for the affine space model.
//
//// MARK: - Index.Bounded + Offset → Index.Bounded? (Point + Vector → Point?)
//
///// Advances a bounded index by an offset, returning nil if out of bounds.
/////
///// The result is `nil` if the new position would be negative or >= N.
//@inlinable
//public func + <Element: ~Copyable, let N: Int>(
//    lhs: Index<Element>.Bounded<N>,
//    rhs: Index<Element>.Offset
//) -> Index<Element>.Bounded<N>? {
//    Index<Element>.Bounded<N>(lhs.position + rhs.rawValue)
//}
//
///// Advances a bounded index by an offset (commutative), returning nil if out of bounds.
//@inlinable
//public func + <Element: ~Copyable, let N: Int>(
//    lhs: Index<Element>.Offset,
//    rhs: Index<Element>.Bounded<N>
//) -> Index<Element>.Bounded<N>? {
//    Index<Element>.Bounded<N>(lhs.rawValue + rhs.position)
//}
//
///// Retreats a bounded index by an offset, returning nil if out of bounds.
/////
///// The result is `nil` if the new position would be negative or >= N.
//@inlinable
//public func - <Element: ~Copyable, let N: Int>(
//    lhs: Index<Element>.Bounded<N>,
//    rhs: Index<Element>.Offset
//) -> Index<Element>.Bounded<N>? {
//    Index<Element>.Bounded<N>(lhs.position - rhs.rawValue)
//}
//
//// MARK: - Index.Bounded - Index.Bounded → Offset (Point - Point → Vector)
//
///// Returns the signed offset (displacement) between two bounded indices.
/////
///// The result is positive if `lhs > rhs`, negative if `lhs < rhs`.
///// This operation always succeeds since both indices are valid (affine property).
//@inlinable
//public func - <Element: ~Copyable, let N: Int>(
//    lhs: Index<Element>.Bounded<N>,
//    rhs: Index<Element>.Bounded<N>
//) -> Index<Element>.Offset {
//    Index<Element>.Offset(lhs.position - rhs.position)
//}
