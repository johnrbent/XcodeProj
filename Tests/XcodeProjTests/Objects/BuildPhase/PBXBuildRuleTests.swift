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
}
