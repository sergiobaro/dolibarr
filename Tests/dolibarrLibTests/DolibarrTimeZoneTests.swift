import XCTest
@testable import dolibarrLib

class DolibarrTimeZoneTests: XCTestCase {

  func testCurrentTimeZone() throws {
    let tz = DolibarrTimeZone(timeZone: Calendar.current.timeZone)

    XCTAssertEqual(tz.timeZoneIdentifier, "Europe/Madrid")
    XCTAssertEqual(tz.timeZoneOffset, 1)
    XCTAssertFalse(tz.isDSTObserved)

    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd'T'hh:mm:ss'Z'"

    XCTAssertEqual(df.string(from: tz.dstFirstSwitch), "2020-03-29T03:00:00Z")
    XCTAssertEqual(df.string(from: tz.dstSecondSwitch), "2020-10-25T02:00:00Z")
  }
}
