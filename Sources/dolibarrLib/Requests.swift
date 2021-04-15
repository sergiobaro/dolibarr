import Foundation
import SwiftSoup

class Requests {

  typealias RequestResult = (Data?, URLResponse?, Error?)

  static func get(url: URL, cookies: [HTTPCookie]) -> RequestResult {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
    request.allHTTPHeaderFields = cookieHeaders
    request.addValue("text/html", forHTTPHeaderField: "Accept")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36", forHTTPHeaderField: "User-Agent")

    return sync(request: request)
  }

  static func post(url: URL, parameters: [String: String], cookies: [HTTPCookie]) throws -> RequestResult {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
    request.allHTTPHeaderFields = cookieHeaders
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.addValue("text/html", forHTTPHeaderField: "Accept")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36", forHTTPHeaderField: "User-Agent")

    request.httpBody = parameters.map { "\($0)=\($1)" }
      .joined(separator: "&")
      .data(using: .utf8)

    return sync(request: request)
  }

  static private func sync(request: URLRequest) -> RequestResult {
    var result: (Data?, URLResponse?, Error?)

    let semaphore = DispatchSemaphore(value: 0)

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      result = (data, response, error)
      semaphore.signal()
    }
    task.resume()

    semaphore.wait()

    return result
  }
}
