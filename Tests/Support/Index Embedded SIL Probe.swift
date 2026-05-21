// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-primitives open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Index_Primitives

// Guard the probe out of Embedded builds on Swift 6.3.x where the documented
// MandatoryPerformanceOptimizations crash manifests; restore automatically on
// Swift 6.4+ where the upstream bug is fixed (verified 6.4-dev nightly Embedded
// clean per `swift-institute/Issues/swift-issue-embedded-wasm-mandatory-perf-crash/
// INVESTIGATION-ARC.md`). [PKG-BUILD-007]
#if !hasFeature(Embedded) || compiler(>=6.4)

/// Phantom tag for the cross-module SIL probe below.
public enum _IndexEmbeddedSILProbeTag {}

/// Cross-module regression probe for the Swift 6.3.2 Wasm SDK Embedded
/// `MandatoryPerformanceOptimizations` crash on the
/// `+ <T> (Tagged<T, Ordinal>, Tagged<T, Cardinal>) -> Tagged<T, Ordinal>`
/// operator (defined in `swift-ordinal-primitives`, invoked from a
/// downstream consumer module compiled under Embedded).
///
/// The arithmetic `Index<T>.zero + Index<T>.Count.zero` exercises the
/// operator at a cross-module call site. On Swift 6.4+ this probe is
/// active under Embedded and validates that the upstream fix holds; on
/// Swift 6.3.x the probe is guarded out of Embedded only — it still runs
/// on macOS / Linux / Windows / non-Embedded toolchains.
///
/// Tracking: `swift-institute/Issues/swift-issue-embedded-wasm-mandatory-perf-crash/`.
@inlinable
public func _indexEmbeddedSILCrashRegressionProbe() {
    let _: Index<_IndexEmbeddedSILProbeTag> = .zero + .zero
}

#endif
