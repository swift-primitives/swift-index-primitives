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

// Index.Count literal support is provided by Identity_Primitives_Test_Support.
// Since Cardinal.Count: ExpressibleByIntegerLiteral, the general Tagged conformance
// in Identity_Primitives_Test_Support applies to Tagged<Tag, Cardinal.Count>.
//
// Usage in tests:
//   let count: Index<Tag>.Count = 10
