public import Ordinal
@_spi(Internal) public import Tagged

public typealias Index<Element: ~Copyable & ~Escapable> = Tagged<Element, Ordinal>
