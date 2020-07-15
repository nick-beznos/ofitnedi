import XCTest
@testable import Identifo

final class IdentifoTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Identifo().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
