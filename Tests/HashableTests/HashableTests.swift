import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(HashableMacros)
import HashableMacros

let testMacros: [String: Macro.Type] = [
    "Hashable": HashableMacro.self
]
#endif

final class HashableTests: XCTestCase {
    func testPublicExtension() throws {
        #if canImport(HashableMacros)
        assertMacroExpansion(
            """
            @Hashable
            public class SomeClass {
                public let someProperty: Bool

                public init(someProperty: Bool) {
                    self.someProperty = someProperty
                }
            }
            """,
            expandedSource: """
            public class SomeClass {
                public let someProperty: Bool

                public init(someProperty: Bool) {
                    self.someProperty = someProperty
                }
            }

            extension SomeClass: Hashable {
                public static func == (lhs: SomeClass, rhs: SomeClass) -> Bool {
                    lhs.someProperty == rhs.someProperty
                }

                public func hash(into hasher: inout Hasher) {
                    hasher.combine(someProperty)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testInternalExtension() throws {
        #if canImport(HashableMacros)
        assertMacroExpansion(
            """
            @Hashable
            class SomeClass {
                let someProperty: Bool

                init(someProperty: Bool) {
                    self.someProperty = someProperty
                }
            }
            """,
            expandedSource: """
            class SomeClass {
                let someProperty: Bool

                init(someProperty: Bool) {
                    self.someProperty = someProperty
                }
            }

            extension SomeClass: Hashable {
                static func == (lhs: SomeClass, rhs: SomeClass) -> Bool {
                    lhs.someProperty == rhs.someProperty
                }

                func hash(into hasher: inout Hasher) {
                    hasher.combine(someProperty)
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
