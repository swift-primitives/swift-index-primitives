import Index
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
        let index: Index::Index<Int> = Tagged::Tagged(
            _unchecked: Ordinal::Ordinal(UInt(5))
        )

        #expect(index.underlying.rawValue == 5)
    }

    @Test
    func `init with zero position`() {
        let index: Index::Index<String> = Tagged::Tagged(
            _unchecked: Ordinal::Ordinal(UInt.zero)
        )

        #expect(index.underlying.rawValue == 0)
    }

    @Test
    func `unchecked init bypasses validation`() {
        let index: Index::Index<Int> = Tagged::Tagged(
            _unchecked: Ordinal::Ordinal(42)
        )

        #expect(index.underlying.rawValue == 42)
    }

    @Test
    func `underlying value is ordinal`() {
        let index: Index::Index<Int> = Tagged::Tagged(
            _unchecked: Ordinal::Ordinal(UInt(10))
        )

        #expect(index.underlying.rawValue == 10)
    }

    @Test
    func `different tag types are incompatible at compile time`() {
        let bitIndex: Index::Index<Bit> = Tagged::Tagged(
            _unchecked: Ordinal::Ordinal(UInt(5))
        )
        let byteIndex: Index::Index<Byte> = Tagged::Tagged(
            _unchecked: Ordinal::Ordinal(UInt(5))
        )

        #expect(bitIndex.underlying.rawValue == byteIndex.underlying.rawValue)

    }
}

extension `Index Tests`.`Edge Case` {
    @Test
    func `maximum ordinal value is preserved`() {
        let index: Index::Index<Int> = Tagged::Tagged(
            _unchecked: Ordinal::Ordinal(UInt.max)
        )
        #expect(index.underlying.rawValue == UInt.max)
    }
}
