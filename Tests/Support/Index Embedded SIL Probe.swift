public import Index

#if !hasFeature(Embedded) || compiler(>=6.4)

    public enum _IndexEmbeddedSILProbeTag {}

    @inlinable
    public func _indexEmbeddedSILCrashRegressionProbe(
        _: borrowing Index::Index<_IndexEmbeddedSILProbeTag>
    ) {}

#endif
