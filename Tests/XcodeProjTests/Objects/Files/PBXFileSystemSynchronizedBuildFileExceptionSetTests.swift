import Foundation
import XCTest
@testable import XcodeProj

final class PBXFileSystemSynchronizedBuildFileExceptionSetTests: XCTestCase {
    var target: PBXTarget!
    var subject: PBXFileSystemSynchronizedBuildFileExceptionSet!

    override func setUp() {
        super.setUp()
        target = PBXTarget.fixture()
        subject = PBXFileSystemSynchronizedBuildFileExceptionSet.fixture(target: target)
    }

    override func tearDown() {
        target = nil
        subject = nil
        super.tearDown()
    }

    func test_itHasTheCorrectIsa() {
        XCTAssertEqual(PBXFileSystemSynchronizedBuildFileExceptionSet.isa, "PBXFileSystemSynchronizedBuildFileExceptionSet")
    }

    func test_equal_returnsTheCorrectValue() {
        let another = PBXFileSystemSynchronizedBuildFileExceptionSet.fixture(target: target)
        XCTAssertEqual(subject, another)

        another.platformFiltersByRelativePath = ["Sources/File.swift": ["ios"]]
        XCTAssertNotEqual(subject, another)
    }

    func test_decodingPreservesPlatformFiltersByRelativePath() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "EXCEPTION": [
                "reference": "EXCEPTION",
                "target": "TARGET",
                "platformFiltersByRelativePath": ["Sources/File.swift": ["ios", "macos"]],
            ],
        ])

        let decoded = try XcodeprojJSONDecoder().decode(
            [String: PBXFileSystemSynchronizedBuildFileExceptionSet].self,
            from: data
        )

        XCTAssertEqual(
            decoded["EXCEPTION"]?.platformFiltersByRelativePath,
            ["Sources/File.swift": ["ios", "macos"]]
        )
    }

    func test_plistValuesIncludePlatformFiltersByRelativePath() throws {
        subject.platformFiltersByRelativePath = ["Sources/File.swift": ["ios", "macos"]]

        let dictionary = try XCTUnwrap(subject.plistKeyAndValue(proj: PBXProj(), reference: "EXCEPTION").value.dictionary)

        XCTAssertEqual(
            dictionary["platformFiltersByRelativePath"],
            .dictionary([
                "Sources/File.swift": .array(["ios", "macos"]),
            ])
        )
    }

    func test_comment_describesTheSynchronizedFolderAndTarget() {
        let proj = PBXProj()
        target = PBXNativeTarget(name: "App")
        subject = PBXFileSystemSynchronizedBuildFileExceptionSet.fixture(target: target)
        let synchronizedGroup = PBXFileSystemSynchronizedRootGroup.fixture(path: "Sources", exceptions: [subject])
        proj.add(object: target)
        proj.add(object: subject)
        proj.add(object: synchronizedGroup)
        target.fileSystemSynchronizedGroups = [synchronizedGroup]

        XCTAssertEqual(subject.comment(), "Exceptions for \"Sources\" folder in \"App\" target")
    }

    func test_comment_fallsBackToIsaWithoutASynchronizedFolder() {
        XCTAssertEqual(subject.comment(), PBXFileSystemSynchronizedBuildFileExceptionSet.isa)
    }
}
