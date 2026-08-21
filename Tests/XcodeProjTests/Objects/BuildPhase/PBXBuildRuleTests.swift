import Foundation
@testable import XcodeProj
import XCTest

final class PBXBuildRuleTests: XCTestCase {
    var subject: PBXBuildRule!

    override func setUp() {
        super.setUp()
        subject = PBXBuildRule(compilerSpec: "spec",
                               fileType: "type",
                               isEditable: true,
                               filePatterns: "pattern",
                               name: "rule",
                               outputFiles: ["a", "b"],
                               outputFilesCompilerFlags: ["-1", "-2"],
                               script: "script",
                               runOncePerArchitecture: false)
    }

    func test_init_initializesTheBuildRuleWithTheRightAttributes() {
        XCTAssertEqual(subject.compilerSpec, "spec")
        XCTAssertEqual(subject.filePatterns, "pattern")
        XCTAssertEqual(subject.fileType, "type")
        XCTAssertEqual(subject.isEditable, true)
        XCTAssertEqual(subject.name, "rule")
        XCTAssertEqual(subject.outputFiles, ["a", "b"])
        XCTAssertNil(subject.inputFileListPaths)
        XCTAssertNil(subject.outputFileListPaths)
        XCTAssertEqual(subject.outputFilesCompilerFlags ?? [], ["-1", "-2"])
        XCTAssertEqual(subject.script, "script")
        XCTAssertEqual(subject.runOncePerArchitecture, false)
    }

    func test_isa_returnsTheCorrectValue() {
        XCTAssertEqual(PBXBuildRule.isa, "PBXBuildRule")
    }

    func test_equal_shouldReturnTheCorrectValue() {
        let another = PBXBuildRule(compilerSpec: "spec",
                                   fileType: "type",
                                   isEditable: true,
                                   filePatterns: "pattern",
                                   name: "rule",
                                   outputFiles: ["a", "b"],
                                   outputFilesCompilerFlags: ["-1", "-2"],
                                   script: "script",
                                   runOncePerArchitecture: false)
        XCTAssertEqual(subject, another)
    }

    func test_decodingAcceptsScalarScript() throws {
        let buildRule = try decodeBuildRule(script: "echo scalar")

        // Xcode's ordinary PBX spelling remains a single
        // scalar string and must not gain a newline during semantic decoding.
        XCTAssertEqual(buildRule.script, "echo scalar")
    }

    func test_decodingAcceptsScriptLineArray() throws {
        let buildRule = try decodeBuildRule(
            script: ["echo first", "", "echo last", ""]
        )

        // cargo-xcode writes PBXBuildRule.script as an
        // array. Xcode treats it as lines, including its final line boundary
        // and any authored trailing empty line.
        XCTAssertEqual(buildRule.script, "echo first\n\necho last\n\n")
    }

    func test_decodingRejectsInvalidScriptArrayElements() throws {
        XCTAssertThrowsError(try decodeBuildRule(script: ["echo valid", 42]))
    }

    func test_plistValuesOmitAbsentFileListPaths() throws {
        let dictionary = try XCTUnwrap(subject.plistKeyAndValue(proj: PBXProj(), reference: "RULE").value.dictionary)

        XCTAssertNil(dictionary["inputFileListPaths"])
        XCTAssertNil(dictionary["outputFileListPaths"])
    }

    func test_plistValuesPreservePresentFileListPaths() throws {
        subject.inputFileListPaths = []
        subject.outputFileListPaths = ["$(SRCROOT)/outputs.xcfilelist"]

        let dictionary = try XCTUnwrap(subject.plistKeyAndValue(proj: PBXProj(), reference: "RULE").value.dictionary)

        XCTAssertEqual(dictionary["inputFileListPaths"], .array([]))
        XCTAssertEqual(
            dictionary["outputFileListPaths"],
            .array([.string(CommentedString("$(SRCROOT)/outputs.xcfilelist"))])
        )
    }

    private func decodeBuildRule(script: Any) throws -> PBXBuildRule {
        let data = try JSONSerialization.data(
            withJSONObject: ["BUILD_RULE": [
                "reference": "BUILD_RULE",
                "compilerSpec": "com.apple.compilers.proxy.script",
                "fileType": "pattern.proxy",
                "isEditable": "0",
                "script": script,
            ]],
            options: []
        )
        let rules = try XcodeprojJSONDecoder().decode(
            [String: PBXBuildRule].self,
            from: data
        )
        guard let rule = rules["BUILD_RULE"] else {
            throw CocoaError(.coderValueNotFound)
        }
        return rule
    }
}
