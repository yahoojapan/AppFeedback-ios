import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AppFeedback_iosTests.allTests),
    ]
}
#endif
