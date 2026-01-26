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

import Cyclic_Primitives
@_spi(Internal) import Identity_Primitives

// MARK: - Typealias

extension Tagged where RawValue == Affine.Discrete.Position, Tag: ~Copyable {
    /// `Index<Tag>.Static<N>` = `Tagged<Tag, Cyclic.Group<N>.Element>`
    public typealias Static<let N: Int> = Tagged<Tag, Cyclic.Group<N>.Element>
}

// MARK: - Operators (Tagged + Tagged)

public func + <Tag: ~Copyable, let N: Int>(
    lhs: Tagged<Tag, Cyclic.Group<N>.Element>,
    rhs: Tagged<Tag, Cyclic.Group<N>.Element>
) -> Tagged<Tag, Cyclic.Group<N>.Element> {
    Tagged(__unchecked: (), lhs.rawValue + rhs.rawValue)
}

public func - <Tag: ~Copyable, let N: Int>(
    lhs: Tagged<Tag, Cyclic.Group<N>.Element>,
    rhs: Tagged<Tag, Cyclic.Group<N>.Element>
) -> Tagged<Tag, Cyclic.Group<N>.Element> {
    Tagged(__unchecked: (), lhs.rawValue - rhs.rawValue)
}

public func += <Tag: ~Copyable, let N: Int>(
    lhs: inout Tagged<Tag, Cyclic.Group<N>.Element>,
    rhs: Tagged<Tag, Cyclic.Group<N>.Element>
) { lhs = lhs + rhs }

public func -= <Tag: ~Copyable, let N: Int>(
    lhs: inout Tagged<Tag, Cyclic.Group<N>.Element>,
    rhs: Tagged<Tag, Cyclic.Group<N>.Element>
) { lhs = lhs - rhs }

// MARK: - Operators (Tagged + Element) — enables .zero/.one syntax

public func + <Tag: ~Copyable, let N: Int>(
    lhs: Tagged<Tag, Cyclic.Group<N>.Element>,
    rhs: Cyclic.Group<N>.Element
) -> Tagged<Tag, Cyclic.Group<N>.Element> {
    Tagged(__unchecked: (), lhs.rawValue + rhs)
}

public func - <Tag: ~Copyable, let N: Int>(
    lhs: Tagged<Tag, Cyclic.Group<N>.Element>,
    rhs: Cyclic.Group<N>.Element
) -> Tagged<Tag, Cyclic.Group<N>.Element> {
    Tagged(__unchecked: (), lhs.rawValue - rhs)
}

public func += <Tag: ~Copyable, let N: Int>(
    lhs: inout Tagged<Tag, Cyclic.Group<N>.Element>,
    rhs: Cyclic.Group<N>.Element
) { lhs = Tagged(__unchecked: (), lhs.rawValue + rhs) }

public func -= <Tag: ~Copyable, let N: Int>(
    lhs: inout Tagged<Tag, Cyclic.Group<N>.Element>,
    rhs: Cyclic.Group<N>.Element
) { lhs = Tagged(__unchecked: (), lhs.rawValue - rhs) }

// MARK: - Construction

extension Tagged where Tag: ~Copyable {
    public init<let N: Int>(_ position: Int) throws(StaticError<N>)
    where RawValue == Cyclic.Group<N>.Element {
        do {
            self.init(__unchecked: (), try Cyclic.Group<N>.Element(position))
        } catch {
            throw .outOfBounds(position)
        }
    }

    public init<let N: Int>(__unchecked position: Int)
    where RawValue == Cyclic.Group<N>.Element {
        self.init(__unchecked: (), Cyclic.Group<N>.Element(__unchecked: (), position))
    }
}

// MARK: - Error

public enum StaticError<let N: Int>: Error, Hashable, Sendable {
    case outOfBounds(Int)
}
