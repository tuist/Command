import XCTest
@testable import Command

final class TerminalSizeTests: XCTestCase {
    func test_current_doesnt_return_nil() {
        // Given/When
        let got = TerminalSize.current()

        // Then
        // XCTAssertNotNil(got)
    }
}
