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

public import Cardinal_Primitives

// MARK: - Index.Count Extensions (API Compatibility)

extension Tagged where RawValue == Cardinal, Tag: ~Copyable {

    // MARK: - Compatibility Properties

    /// The underlying cardinal count.
    ///
    /// This property provides backward compatibility with code that used
    /// `count.count` on the previous nested struct implementation.
    @inlinable
    public var count: Cardinal { rawValue }

    // MARK: - Construction

    /// Creates a typed count from a cardinal count.
    @inlinable
    public init(_ count: Cardinal) {
        self.init(__unchecked: (), count)
    }

    /// Creates a typed count from an unsigned integer.
    @inlinable
    public init(_ rawValue: UInt) {
        self.init(__unchecked: (), Cardinal(rawValue))
    }

    /// Creates a typed count from a signed integer.
    ///
    /// - Parameter rawValue: The count value. Must be non-negative.
    /// - Throws: `Cardinal.Error.negativeSource` if negative.
    @inlinable
    public init(_ rawValue: Int) throws(Cardinal.Error) {
        self.init(__unchecked: (), try Cardinal(rawValue))
    }

    /// Creates a typed count without validation.
    ///
    /// - Parameter rawValue: Must be non-negative.
    /// - Warning: No validation is performed. Use only when the value
    ///   is known to be non-negative.
    @inlinable
    public init(__unchecked: Void, _ rawValue: Int) {
        self.init(__unchecked: (), Cardinal(UInt(rawValue)))
    }
}

