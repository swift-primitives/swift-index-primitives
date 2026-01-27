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
@_spi(Internal) public import Identity_Primitives

// MARK: - Offset * Ratio

/// Scales an offset from one domain to another.
///
/// This is the fundamental action of a ratio on a vector. The offset's
/// magnitude is multiplied by the ratio's factor, and the domain changes
/// from `From` to `To`.
///
/// ## Example
///
/// ```swift
/// let bitsPerByte = Affine.Discrete.Ratio<UInt8, Bit>(8)
/// let byteOffset = Index<UInt8>.Offset(2)  // 2 bytes forward
/// let bitOffset = byteOffset * bitsPerByte  // 16 bits forward
/// ```
///
/// ## Mathematical Model
///
/// In affine geometry, ratios act on vectors (displacements), not on points
/// (positions). This operator implements that action:
/// - Input: offset in domain `From`
/// - Output: offset in domain `To` with scaled magnitude
///
/// - Parameters:
///   - lhs: An offset in the source domain.
///   - rhs: A ratio from source to target domain.
/// - Returns: An offset in the target domain with scaled magnitude.
@inlinable
public func * <From: ~Copyable, To: ~Copyable>(
    lhs: Index<From>.Offset,
    rhs: Affine.Discrete.Ratio<From, To>
) -> Index<To>.Offset {
    Index<To>.Offset(Affine.Discrete.Vector(lhs.rawValue.rawValue * rhs.factor))
}

/// Scales an offset from one domain to another (commutative).
///
/// - Parameters:
///   - lhs: A ratio from source to target domain.
///   - rhs: An offset in the source domain.
/// - Returns: An offset in the target domain with scaled magnitude.
@inlinable
public func * <From: ~Copyable, To: ~Copyable>(
    lhs: Affine.Discrete.Ratio<From, To>,
    rhs: Index<From>.Offset
) -> Index<To>.Offset {
    rhs * lhs
}
