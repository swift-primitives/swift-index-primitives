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

// Index.Offset literal support is provided by Identity_Primitives_Test_Support.
// Since Affine.Discrete.Vector: ExpressibleByIntegerLiteral, the general Tagged
// conformance in Identity_Primitives_Test_Support applies to Tagged<Tag, Affine.Discrete.Vector>.
//
// Usage in tests:
//   let offset: Index<Tag>.Offset = 5
//   let negative: Index<Tag>.Offset = -3
