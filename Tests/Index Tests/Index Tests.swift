import Ordinal
import Tagged
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

        #expect(index.underlying == Ordinal(UInt(5)))
    }

    @Test
    func `init with zero position`() {
        let index: Index<String> = Index(_unchecked: Ordinal(UInt(0)))

        #expect(index.underlying == Ordinal(UInt(0)))
    }

    @Test
    func `unchecked init bypasses validation`() {
        let index: Index<Int> = Index(_unchecked: Ordinal(42))

        #expect(index.underlying == Ordinal(42))
    }

    @Test
    func `different tag types are incompatible at compile time`() {
        let bitIndex: Index<Bit> = Index(_unchecked: Ordinal(UInt(5)))
        let byteIndex: Index<Byte> = Index(_unchecked: Ordinal(UInt(5)))

        #expect(bitIndex.underlying == byteIndex.underlying)

    }
}

extension `Index Tests`.`Edge Case` {
    @Test
    func `init with maximum Int position succeeds`() {
        let index: Index<Int> = Index(_unchecked: Ordinal(UInt(Int.max)))
        let expected: Index<Int> = Index(_unchecked: Ordinal(UInt(Int.max)))
        #expect(index.underlying == expected.underlying)
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
