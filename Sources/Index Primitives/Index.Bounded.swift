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

import Affine_Primitives
@_spi(Internal) import Identity_Primitives

extension Tagged where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// A bounded, phantom-typed index in {0, 1, ..., N-1}.
    ///
    /// `Index<Element>.Bounded<N>` combines phantom typing with compile-time
    /// bounds, making out-of-bounds access unrepresentable in the type system.
    ///
    /// ## Type Safety
    ///
    /// ```swift
    /// let idx = try Index<Int>.Bounded<5>(3)
    /// // idx.rawValue is guaranteed to be in 0..<5
    /// ```
    ///
    /// ## Integer Literals
    ///
    /// Use literals for ergonomic access (traps on invalid):
    /// ```swift
    /// let valid: Index<Int>.Bounded<5> = 3   // OK
    /// let invalid: Index<Int>.Bounded<5> = 10  // Traps
    /// ```
    ///
    /// Use `try` for throwing validation.
    public struct Bounded<let N: Int>: Sendable, Hashable, Comparable, ExpressibleByIntegerLiteral {
        /// The underlying bounded position, guaranteed to be in 0..<N.
        public let bounded: Affine.Discrete.Bounded<N>

        /// The underlying position value, guaranteed to be in 0..<N.
        @inlinable
        public var rawValue: Int { bounded.rawValue }

        /// Creates a bounded index from an integer.
        ///
        /// - Parameter position: The position value.
        /// - Throws: `Error.outOfBounds` if `position < 0` or `position >= N`.
        @inlinable
        public init(_ position: Int) throws(Error) {
            guard position >= 0, position < N else { throw .outOfBounds(position) }
            self.bounded = Affine.Discrete.Bounded<N>(__unchecked: position)
        }

        /// Creates a bounded index from an `Affine.Discrete.Bounded<N>`.
        @inlinable
        public init(_ bounded: Affine.Discrete.Bounded<N>) {
            self.bounded = bounded
        }

        /// Creates a bounded index without bounds checking.
        @inlinable
        public init(__unchecked: Void, _ position: Int) {
            self.bounded = Affine.Discrete.Bounded<N>(__unchecked: position)
        }

        /// Creates from integer literal. Traps on invalid values.
        @inlinable
        public init(integerLiteral value: Int) {
            guard value >= 0, value < N else {
                preconditionFailure("Index literal \(value) out of bounds for Bounded<\(N)>")
            }
            self.bounded = Affine.Discrete.Bounded<N>(__unchecked: value)
        }

        /// Number of valid index values for this type.
        @inlinable
        public static var count: Int { N }

        /// The next index value, or `nil` if at maximum.
        @inlinable
        public func successor() -> Self? {
            let next = rawValue + 1
            guard next < N else { return nil }
            return Self(__unchecked: (), next)
        }

        /// The previous index value, or `nil` if at minimum.
        @inlinable
        public func predecessor() -> Self? {
            let prev = rawValue - 1
            guard prev >= 0 else { return nil }
            return Self(__unchecked: (), prev)
        }

        /// Returns an index offset by the given signed amount, or `nil` if out of bounds.
        @inlinable
        public func offset(by delta: Int) -> Self? {
            let result = rawValue + delta
            guard result >= 0, result < N else { return nil }
            return Self(__unchecked: (), result)
        }

        /// Returns an index offset by the given amount, clamped to valid bounds.
        @inlinable
        public func clamped(by delta: Int) -> Self {
            let result = rawValue + delta
            if result < 0 { return Self(__unchecked: (), 0) }
            if result >= N { return Self(__unchecked: (), N - 1) }
            return Self(__unchecked: (), result)
        }

        /// The signed distance from this index to another.
        @inlinable
        public func distance(to other: Self) -> Int {
            other.rawValue - rawValue
        }

        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.bounded < rhs.bounded
        }
    }
}

// MARK: - Bounded.Error

extension Tagged.Bounded where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// Error thrown when bounded index construction fails.
    public enum Error: Swift.Error, Hashable, Sendable {
        /// The provided value was outside the valid range `0..<N`.
        case outOfBounds(Int)
    }
}

// MARK: - Conversion to Unbounded

extension Tagged.Bounded where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// Converts to an unbounded `Index<Tag>`.
    ///
    /// This conversion is always safe since bounded indices are
    /// always non-negative and valid.
    @inlinable
    public var unbounded: Index<Tag> {
        Index<Tag>(__unchecked: rawValue)
    }
}

// MARK: - Conversion from Unbounded

extension Tagged where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// Attempts to convert to a bounded index.
    ///
    /// - Returns: The bounded index, or `nil` if out of bounds.
    @inlinable
    public func bounded<let N: Int>() -> Bounded<N>? {
        let value = position.rawValue
        guard value >= 0, value < N else { return nil }
        return Bounded<N>(__unchecked: (), value)
    }
}

// MARK: - CustomStringConvertible

extension Tagged.Bounded: CustomStringConvertible where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    public var description: String {
        "Index<\(Tag.self)>.Bounded<\(N)>(\(rawValue))"
    }
}
