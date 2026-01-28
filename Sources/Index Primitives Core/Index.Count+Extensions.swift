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

extension Tagged where RawValue == Cardinal.Count, Tag: ~Copyable {

    // MARK: - Compatibility Properties

    /// The underlying cardinal count.
    ///
    /// This property provides backward compatibility with code that used
    /// `count.count` on the previous nested struct implementation.
    @inlinable
    public var count: Cardinal.Count { rawValue }

    // MARK: - Construction

    /// Creates a typed count from a cardinal count.
    @inlinable
    public init(_ count: Cardinal.Count) {
        self.init(__unchecked: (), count)
    }

    /// Creates a typed count from an unsigned integer.
    @inlinable
    public init(_ rawValue: UInt) {
        self.init(__unchecked: (), Cardinal.Count(rawValue))
    }

    /// Creates a typed count from a signed integer.
    ///
    /// - Parameter rawValue: The count value. Must be non-negative.
    /// - Throws: `Cardinal.Count.Error.negativeSource` if negative.
    @inlinable
    public init(_ rawValue: Int) throws(Cardinal.Count.Error) {
        self.init(__unchecked: (), try Cardinal.Count(rawValue))
    }

    /// Creates a typed count without validation.
    ///
    /// - Parameter rawValue: Must be non-negative.
    /// - Warning: No validation is performed. Use only when the value
    ///   is known to be non-negative.
    @inlinable
    public init(__unchecked: Void, _ rawValue: Int) {
        self.init(__unchecked: (), Cardinal.Count(UInt(rawValue)))
    }
}

