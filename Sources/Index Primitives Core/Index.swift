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

public import Ordinal_Primitives
@_spi(Internal) public import Identity_Primitives

/// A phantom-typed index for type-safe collection access.
///
/// `Index<Element>` wraps `Ordinal` with a phantom type
/// that prevents indices from different collections being confused.
///
/// ## Type Safety
///
/// ```swift
/// let bitIndex: Index<Bit> = try Index(5)
/// let byteIndex: Index<Byte> = try Index(5)
/// // bitIndex == byteIndex  // Compile error - different types
/// ```
///
/// ## Arithmetic
///
/// Index supports affine arithmetic with `Index<Element>.Offset`:
///
/// ```swift
/// let idx: Index<Bit> = try Index(5)
/// let offset = Index<Bit>.Offset(3)
/// let newIdx = try idx + offset  // Index<Bit> at position 8
/// let distance = newIdx - idx    // Offset of 3
/// ```
public typealias Index<Element: ~Copyable> = Tagged<Element, Ordinal>
