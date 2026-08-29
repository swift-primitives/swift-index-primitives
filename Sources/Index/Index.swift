public import Ordinal
public import Ordinal_Protocol
public import Tagged

public typealias Index<Element: ~Copyable & ~Escapable> =
    Tagged::Tagged<Element, Ordinal::Ordinal>
