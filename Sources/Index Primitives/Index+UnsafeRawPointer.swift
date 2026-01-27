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

// MARK: - UnsafeRawPointer + Index

extension UnsafeRawPointer {
    /// Returns a pointer offset by the specified typed byte offset.
    @inlinable
    public func advanced(
        by offset: Index_Primitives.Index<UInt8>.Offset
    ) -> Self {
        unsafe self.advanced(by: offset.rawValue)
    }
}
