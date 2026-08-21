public import Index_Primitives

#if !hasFeature(Embedded) || compiler(>=6.4)

    public enum _IndexEmbeddedSILProbeTag {}

    @inlinable
    public func _indexEmbeddedSILCrashRegressionProbe() {
        let _: Index<_IndexEmbeddedSILProbeTag> = .zero + .zero
    }

#endif
