public import Ordinal_Primitives
@_spi(Internal) public import Tagged_Primitives

public typealias Index<Element: ~Copyable & ~Escapable> = Tagged<Element, Ordinal>
