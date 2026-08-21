import Foundation
import XCTest

@testable import XcodeProj

final class PBXFileReferenceTests: XCTestCase {
    var subject: PBXFileReference!

    override func setUp() {
        super.setUp()
        subject = PBXFileReference(sourceTree: .absolute,
                                   name: "name",
                                   fileEncoding: 1,
                                   explicitFileType: "type",
                                   lastKnownFileType: "last",
                                   regionVariantName: "en",
                                   path: "path")
    }

    func test_init_initializesTheReferenceWithTheRightAttributes() {
        XCTAssertEqual(subject.name, "name")
        XCTAssertEqual(subject.sourceTree, .absolute)
        XCTAssertEqual(subject.fileEncoding, 1)
        XCTAssertEqual(subject.explicitFileType, "type")
        XCTAssertEqual(subject.lastKnownFileType, "last")
        XCTAssertEqual(subject.regionVariantName, "en")
        XCTAssertEqual(subject.path, "path")
    }

    func test_isa_hashTheCorrectValue() {
        XCTAssertEqual(PBXFileReference.isa, "PBXFileReference")
    }

    func test_decodingPreservesRegionVariantName() throws {
        let data = try PropertyListSerialization.data(
            fromPropertyList: [
                "reference": [
                    "sourceTree": "SOURCE_ROOT",
                    "regionVariantName": "fr",
                ],
            ],
            format: .xml,
            options: 0
        )

        let decoded = try XcodeprojPropertyListDecoder().decode(
            [String: PBXFileReference].self,
            from: data
        )

        XCTAssertEqual(decoded["reference"]?.regionVariantName, "fr")
    }

    func test_plistValuesIncludeRegionVariantName() throws {
        let value = try subject.plistKeyAndValue(proj: PBXProj(), reference: "reference").value

        XCTAssertEqual(
            value.dictionary?["regionVariantName"],
            .string(CommentedString("en"))
        )
    }

    func test_equal_returnsTheCorrectValue() {
        let another = PBXFileReference(sourceTree: .absolute,
                                       name: "name",
                                       fileEncoding: 1,
                                       explicitFileType: "type",
                                       lastKnownFileType: "last",
                                       regionVariantName: "en",
                                       path: "path")
        XCTAssertEqual(subject, another)

        another.regionVariantName = "fr"
        XCTAssertNotEqual(subject, another)
    }

    private func testDictionary() -> [String: Any] {
        [
            "name": "name",
            "sourceTree": "group",
        ]
    }
}
