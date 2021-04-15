import XCTest
@testable import dolibarrLib

class TimeSinceFormatterTests: XCTestCase {
  
  func testTimeSinceFormatter() {
    let timeString = "Thursday 15 Oct 2020 08:13"
    
    let components = DateComponents(year: 2020, month: 10, day: 15, hour: 17, minute: 30)
    let date = NSCalendar.current.date(from: components)!
    
    let result = TimeSinceFormatter().format(timeString: timeString, to: date)
    XCTAssertEqual(result, "9 hours, 17 minutes")
  }
}
