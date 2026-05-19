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

/// Phantom tag for the cross-module SIL probe below.
public enum _IndexEmbeddedSILProbeTag {}

/// Cross-module regression probe for the Swift 6.3.2 Wasm SDK Embedded
/// `MandatoryPerformanceOptimizations` crash on the
/// `+ <T> (Tagged<T, Ordinal>, Tagged<T, Cardinal>) -> Tagged<T, Ordinal>`
/// operator (defined in `swift-ordinal-primitives`, invoked from a
/// downstream consumer module compiled under Embedded).
///
/// The arithmetic `Index<T>.zero + Index<T>.Count.zero` exercises the
/// operator at a cross-module call site. When the upstream workaround
/// in `swift-ordinal-primitives` (let-binding restructure of the body)
/// is regressed, this probe surfaces the crash in this package's own
/// Embedded Wasm SDK CI job — *before* it manifests in downstream
/// consumers (cyclic, vector, array, etc.).
///
/// Tracking: `swift-institute/Issues/swift-issue-embedded-wasm-mandatory-perf-crash/`.
@inlinable
public func _indexEmbeddedSILCrashRegressionProbe() {
    let _: Index<_IndexEmbeddedSILProbeTag> = .zero + .zero
}
