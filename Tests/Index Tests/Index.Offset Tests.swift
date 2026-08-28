import Index_Test_Support
import Testing

@testable import Index

private enum Numbers {}

@Suite
struct `Index Offset Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Index Offset Tests`.Unit {
    @Test
    func `init with positive value`() {
        let offset: Index<Numbers>.Offset = 5
        #expect(offset == 5)
    }

    @Test
    func `init with negative value`() {
        let offset: Index<Numbers>.Offset = -3
        #expect(offset == -3)
    }

    @Test
    func `init with zero`() {
        let offset: Index<Numbers>.Offset = 0
        #expect(offset == 0)
    }

    @Test
    func `ExpressibleByIntegerLiteral`() {
        let offset: Index<Numbers>.Offset = 42
        #expect(offset == 42)

        let negative: Index<Numbers>.Offset = -10
        #expect(negative == -10)
    }

    @Test
    func `offsets are equatable`() {
        let a: Index<Numbers>.Offset = 5
        let b: Index<Numbers>.Offset = 5
        let c: Index<Numbers>.Offset = -5
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `offsets are comparable`() {
        let negative: Index<Numbers>.Offset = -10
        let zero: Index<Numbers>.Offset = 0
        let positive: Index<Numbers>.Offset = 10

        #expect(negative < zero)
        #expect(zero < positive)
        #expect(negative < positive)
        #expect(positive > zero)
    }

    @Test
    func `offsets are hashable`() {
        let a: Index<Numbers>.Offset = 5
        let b: Index<Numbers>.Offset = 5
        #expect(a.hashValue == b.hashValue)

        var set: Set<Index<Numbers>.Offset> = []
        set.insert(a)
        #expect(set.contains(b))
    }
}

extension `Index Offset Tests`.`Edge Case` {
    @Test
    func `maximum Int offset`() {
        let offset = Index<Numbers>.Offset(Int.max)

        #expect(offset.vector.rawValue == Int.max)
    }

    @Test
    func `minimum Int offset`() {
        let offset = Index<Numbers>.Offset(Int.min)

        #expect(offset.vector.rawValue == Int.min)
    }
}
