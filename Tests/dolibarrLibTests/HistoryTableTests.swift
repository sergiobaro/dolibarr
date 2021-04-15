import XCTest
@testable import dolibarrLib

class HistoryTableTests: XCTestCase {

  func testHistoryTable() {
    let entries = [HistoryEntry(name: "name", start: "start", end: "end", commentEntry: "", commentOut: "")]

    XCTAssertNoThrow(HistoryTable(entries: entries).printTable())
  }
}
