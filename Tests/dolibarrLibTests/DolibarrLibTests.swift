import XCTest
@testable import dolibarrLib

class DolibarrLibTests: XCTestCase {

  func test_signin() throws {
    try Dolibarr().run(["signin"])
  }

  func test_signout() throws {
    try Dolibarr().run(["signout"])
  }

  func test_history() throws {
    try Dolibarr().run(["history"])
  }
}
