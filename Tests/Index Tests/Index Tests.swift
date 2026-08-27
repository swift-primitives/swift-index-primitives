import Testing

@testable import Index

private enum Bit {}
private enum Byte {}

@Suite
struct `Index Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Index Tests`.Unit {
    @Test
    func `init with valid position`() {
        let index: Index<Int> = Index(_unchecked: Ordinal(UInt(5)))

        #expect(index.position == 5)
    }

    @Test
    func `init with zero position`() {
        let index: Index<String> = Index(_unchecked: Ordinal(UInt(0)))

        #expect(index.position == 0)
    }

    @Test
    func `unchecked init bypasses validation`() {
        let index: Index<Int> = Index(_unchecked: Ordinal(42))

        #expect(index.position == 42)
    }

    @Test
    func `position property returns rawValue`() {
        let index: Index<Int> = Index(_unchecked: Ordinal(UInt(10)))

        #expect(index.position == index.underlying)
    }

    @Test
    func `indices of same type are equatable`() {
        let a: Index<Int> = Index(_unchecked: Ordinal(UInt(5)))
        let b: Index<Int> = Index(_unchecked: Ordinal(UInt(5)))
        let c: Index<Int> = Index(_unchecked: Ordinal(UInt(6)))
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `indices are comparable`() {
        let a: Index<Int> = Index(_unchecked: Ordinal(UInt(3)))
        let b: Index<Int> = Index(_unchecked: Ordinal(UInt(7)))
        #expect(a < b)
        #expect(b > a)
        #expect(a <= a)
        #expect(b >= b)
    }

    @Test
    func `indices are hashable`() {
        let a: Index<Int> = Index(_unchecked: Ordinal(UInt(5)))
        let b: Index<Int> = Index(_unchecked: Ordinal(UInt(5)))
        #expect(a.hashValue == b.hashValue)

        var set: Set<Index<Int>> = []
        set.insert(a)
        #expect(set.contains(b))
    }

    @Test
    func `different tag types are incompatible at compile time`() {
        let bitIndex: Index<Bit> = Index(_unchecked: Ordinal(UInt(5)))
        let byteIndex: Index<Byte> = Index(_unchecked: Ordinal(UInt(5)))

        #expect(bitIndex.position == byteIndex.position)

    }
}

extension `Index Tests`.`Edge Case` {
    @Test
    func `init with maximum Int position succeeds`() {
        let index: Index<Int> = Index(_unchecked: Ordinal(UInt(Int.max)))
        let expected: Index<Int> = Index(_unchecked: Ordinal(UInt(Int.max)))
        #expect(index == expected)
    }

    @Test
    func `Ordinal.Error is equatable`() {
        let a = Ordinal.Error.negativeSource(-5)
        let b = Ordinal.Error.negativeSource(-5)
        let c = Ordinal.Error.negativeSource(-10)
        #expect(a == b)
        #expect(a != c)
    }
}
