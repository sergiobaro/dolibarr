import Foundation
import SwiftSoup

class Pages {

  static func getPage(url: URL, cookies: [HTTPCookie]) throws -> (Document, [HTTPCookie]) {
    let (data, response, error) = Requests.get(url: url, cookies: cookies)
    if let error = error {
      throw error
    }

    let html = String(data: data!, encoding: .utf8)!
    let httpResponse = response as! HTTPURLResponse
    let cookies = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String: String],
                                     for: response!.url!)
    let doc = try SwiftSoup.parse(html)

    return (doc, cookies)
  }

  @discardableResult
  static func postPage(url: URL, parameters: [String: String], cookies: [HTTPCookie]) throws -> Document {
    let (data, _, error) = try Requests.post(url: url, parameters: parameters, cookies: cookies)
    if let error = error {
      throw error
    }

    let html = String(data: data!, encoding: .utf8)!

    return try SwiftSoup.parse(html)
  }
}
