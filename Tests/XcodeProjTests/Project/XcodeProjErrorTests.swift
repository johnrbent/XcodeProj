import PathKit
import XCTest
@testable import XcodeProj

final class XcodeProjErrorTests: XCTestCase {
    func test_errorDescriptionMatchesDescription() {
        let errors: [XCodeProjError] = [
            .notFound(path: Path("/project")),
            .pbxprojNotFound(path: Path("/project")),
            .xcworkspaceNotFound(path: Path("/project")),
        ]

        for error in errors {
            XCTAssertEqual(error.errorDescription, error.description)
        }
    }
}
