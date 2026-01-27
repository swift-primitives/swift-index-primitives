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
public import Cardinal_Primitives
@_spi(Internal) public import Identity_Primitives

// MARK: - Count * Ratio

/// Scales a count from one domain to another.
///
/// This action converts a cardinality from the source domain to the target
/// domain. The count's value is multiplied by the ratio's factor.
///
/// ## Example
///
/// ```swift
/// let bitsPerByte = Affine.Discrete.Ratio<UInt8, Bit>(8)
/// let byteCount = Index<UInt8>.Count(Cardinal.Count(10))  // 10 bytes
/// let bitCount = byteCount * bitsPerByte  // 80 bits
/// ```
///
/// ## Preconditions
///
/// - The result must be non-negative. Scaling a positive count by a negative
///   ratio will trigger a precondition failure.
///
/// - Parameters:
///   - lhs: A count in the source domain.
///   - rhs: A ratio from source to target domain.
/// - Returns: A count in the target domain with scaled value.
/// - Precondition: The scaled result must be non-negative.
@inlinable
public func * <From: ~Copyable, To: ~Copyable>(
    lhs: Index<From>.Count,
    rhs: Affine.Discrete.Ratio<From, To>
) -> Index<To>.Count {
    let result = Int(bitPattern: lhs.rawValue.rawValue) * rhs.factor
    precondition(result >= 0, "Scaled count must be non-negative")
    return Index<To>.Count(Cardinal.Count(UInt(result)))
}

/// Scales a count from one domain to another (commutative).
///
/// - Parameters:
///   - lhs: A ratio from source to target domain.
///   - rhs: A count in the source domain.
/// - Returns: A count in the target domain with scaled value.
/// - Precondition: The scaled result must be non-negative.
@inlinable
public func * <From: ~Copyable, To: ~Copyable>(
    lhs: Affine.Discrete.Ratio<From, To>,
    rhs: Index<From>.Count
) -> Index<To>.Count {
    rhs * lhs
}
