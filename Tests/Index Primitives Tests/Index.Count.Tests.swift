import Testing

@testable import Index_Primitives

typealias ExperimentalCount<Tag: ~Copyable> = Tagged<Tag, Cardinal>

extension Tagged where Underlying == Cardinal, Tag: ~Copyable {

    init(experimentUInt rawValue: UInt) {
        self.init(_unchecked: Cardinal(rawValue))
    }

    init(experimentInt rawValue: Int) throws(Cardinal.Error) {
        self.init(_unchecked: try Cardinal(rawValue))
    }

    static var experimentZero: Self {
        Self(_unchecked: Cardinal.zero)
    }

    static var experimentOne: Self {
        Self(_unchecked: Cardinal.one)
    }

    static func experimentAdd(_ lhs: Self, _ rhs: Self) -> Self {
        Self(_unchecked: lhs.underlying + rhs.underlying)
    }
}

@Suite
struct `Index Count Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Index Count Tests`.Unit {

    @Test
    func `Construction from UInt`() {
        let count = ExperimentalCount<Int>(experimentUInt: 42)
        #expect(count.underlying == 42)
    }

    @Test
    func `Construction from Int`() throws(Cardinal.Error) {
        let count = try ExperimentalCount<Int>(experimentInt: 42)
        #expect(count.underlying == 42)
    }

    @Test
    func `Construction from negative Int throws`() {
        #expect(throws: Cardinal.Error.self) {
            _ = try ExperimentalCount<Int>(experimentInt: -1)
        }
    }

    @Test
    func `Static constants`() {
        #expect(ExperimentalCount<Int>.experimentZero.underlying == 0)
        #expect(ExperimentalCount<Int>.experimentOne.underlying == 1)
    }

    @Test
    func `Equality (free from Tagged)`() {
        let a = ExperimentalCount<Int>(experimentUInt: 5)
        let b = ExperimentalCount<Int>(experimentUInt: 5)
        let c = ExperimentalCount<Int>(experimentUInt: 10)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Comparison (free from Tagged)`() {
        let small = ExperimentalCount<Int>(experimentUInt: 5)
        let large = ExperimentalCount<Int>(experimentUInt: 10)

        #expect(small < large)
        #expect(large > small)
        #expect(small <= small)
        #expect(small >= small)
    }

    @Test
    func `Hashable (free from Tagged)`() {
        let a = ExperimentalCount<Int>(experimentUInt: 42)
        let b = ExperimentalCount<Int>(experimentUInt: 42)

        #expect(a.hashValue == b.hashValue)

        var set = Set<ExperimentalCount<Int>>()
        set.insert(a)
        #expect(set.contains(b))
    }

    @Test
    func `Arithmetic`() {
        let a = ExperimentalCount<Int>(experimentUInt: 5)
        let b = ExperimentalCount<Int>(experimentUInt: 10)

        let sum = ExperimentalCount<Int>.experimentAdd(a, b)
        #expect(sum.underlying == 15)
    }

    @Test
    func `retag() - THE KEY BENEFIT`() {
        let intCount = ExperimentalCount<Int>(experimentUInt: 42)

        let stringCount: ExperimentalCount<String> = intCount.retag(String.self)

        #expect(stringCount.underlying == 42)
    }

    @Test
    func `map() - transform raw value`() {
        let count = ExperimentalCount<Int>(experimentUInt: 5)

        let doubled = count.map { Cardinal($0.rawValue * 2) }

        #expect(doubled.underlying == 10)
    }

    @Test
    func `Cross-domain conversion via retag`() {
        let sourceCount = ExperimentalCount<Int>(experimentUInt: 100)

        let destCount: ExperimentalCount<String> = sourceCount.retag()

        #expect(destCount.underlying == 100)
    }

    @Test
    func `Phantom type safety preserved`() {
        let intCount = ExperimentalCount<Int>(experimentUInt: 5)
        let stringCount = ExperimentalCount<String>(experimentUInt: 5)

        let retagged: ExperimentalCount<String> = intCount.retag()
        #expect(retagged == stringCount)
    }
}
