import Foundation
import SwiftSoup

enum DolibarrError: LocalizedError {
  case wrongArgs
  case loginFailure
  case formNotFound(String)
  case alreadySignedIn(String)
  case alreadySignedOut

  var errorDescription: String? {
    switch self {
    case .wrongArgs:
      return "Usage: dolibarr (signin|signout|history)"
    case .loginFailure:
      return "Login has failed"
    case let .formNotFound(form):
      return "Form \(form) not found"
    case let .alreadySignedIn(date):
      let timeSince = TimeSinceFormatter().format(timeString: date, to: Date())
      return "You already signed in on '\(date)' (\(timeSince) ago)"
    case .alreadySignedOut:
      return "You already signed out"
    }
  }
}

struct DolibarrForm {
  let action: String
  let parameters: [String: String]
  let buttonTitle: String
}

public class Dolibarr {

  private static let username = "<<YOUR USERNAME>>"
  private static let password = "<<YOUR PASSWORD>>"

  private static let domain = "https://innocv.on.dolicloud.com"
  private static let loginPath = "/index.php"
  private static let scorePath = "/pointage/pointagetop_page.php?idmenu=26217&mainmenu=pointage"
  private static let historyPath = "/pointage/historique_page.php"

  private var cookies = [HTTPCookie]()

  public init() { }

  public func run(_ args: [String]) throws {
    guard let command = Args().parse(args) else {
      throw DolibarrError.wrongArgs
    }

    try login(username: Self.username, password: Self.password)

    switch command {
    case .signin:
      try signin()
    case .signout:
      try signout()
    case .history:
      try history()
    }
  }

  private func login(username: String, password: String) throws {
    let (loginPage, cookies) = try Pages.getPage(url: URL(string: Self.domain + Self.loginPath)!,
                                                 cookies: [])

    self.cookies = cookies

    let form = try findForm(page: loginPage, form: "form#login")
    var parameters = form.parameters
    parameters["username"] = username.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    parameters["password"] = password.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    parameters.merge(DolibarrTimeZone().asDictionary, uniquingKeysWith: { (_, new) in new })
    

    let menuPage = try Pages.postPage(url: URL(string: Self.domain + form.action)!,
                                      parameters: parameters,
                                      cookies: cookies)

    if try menuPage.select("form#login").count > 0 {
      throw DolibarrError.loginFailure
    }
  }

  private func signin() throws {
    let (scorePage, _) = try Pages.getPage(url: URL(string: Self.domain + Self.scorePath)!,
                                           cookies: cookies)

    let form = try findForm(page: scorePage, form: "form[name=\"crea_pointage\"]")
    if form.buttonTitle.lowercased() == "sign out" {
      let signInDate = try scorePage.select("form[name=\"crea_pointage\"] table tr td")[1].text()
      throw DolibarrError.alreadySignedIn(signInDate)
    }

    let comment = askForComment()
    var parameters = form.parameters
    if !comment.isEmpty {
      parameters["comment"] = comment
    }

    let signInPage = try Pages.postPage(url: URL(string: Self.domain + form.action)!,
                                        parameters: parameters,
                                        cookies: self.cookies)

    let signInDate = try signInPage.select("form[name=\"crea_pointage\"] table tr td")[1].text()
    print("Signed in successfully: '\(signInDate)'")
  }

  private func signout() throws {
    let (scorePage, _) = try Pages.getPage(url: URL(string: Self.domain + Self.scorePath)!,
                                           cookies: cookies)

    let form = try findForm(page: scorePage, form: "form[name=\"crea_pointage\"]")
    if form.buttonTitle.lowercased() == "sign in" {
      throw DolibarrError.alreadySignedOut
    }

    let comment = askForComment()
    var parameters = form.parameters
    if !comment.isEmpty {
      parameters["comment"] = comment
    }

    try Pages.postPage(url: URL(string: Self.domain + form.action)!,
                       parameters: parameters,
                       cookies: self.cookies)
  }

  private func history() throws {
    let (historyPage, _) = try Pages.getPage(url: URL(string: Self.domain + Self.historyPath)!,
                                             cookies: cookies)

    let rows = try historyPage.select("table.tagtable.liste tr.oddeven")

    let history: [HistoryEntry] = try rows.map { row in
      let cells = try row.select("td")

      return HistoryEntry(name: try cells.text(at: 0),
                          start: try cells.text(at: 1),
                          end: try cells.text(at: 2),
                          commentEntry: try cells.text(at: 3),
                          commentOut: try cells.text(at: 4))
    }

    let table = HistoryTable(entries: history)
    table.printTable()
  }

  private func findForm(page: Document, form: String) throws -> DolibarrForm {
    guard let formTag = try page.select(form).first() else {
      throw DolibarrError.formNotFound(form)
    }

    let action = try formTag.attr("action")

    var parameters = [String: String]()
    var buttonTitle = ""

    for input in try page.select("\(form) input") {
      let type = try input.attr("type")
      if type == "submit" {
        buttonTitle = try input.attr("value").trimmingCharacters(in: .whitespacesAndNewlines)
      }

      let name = try input.attr("name")
      let value = try input.attr("value")

      if !name.isEmpty && !value.isEmpty {
        parameters[name] = value
      }
    }

    return DolibarrForm(action: action, parameters: parameters, buttonTitle: buttonTitle)
  }

  private func askForComment() -> String {
    print("Do you want to add a comment (enter for empty): ", terminator: "")
    return readLine() ?? ""
  }
}

extension SwiftSoup.Elements {

  func text(at index: Int) throws -> String {
    guard self.indices.contains(index) else { return "" }

    return try self[index].text().trimmingCharacters(in: .whitespaces)
  }
}
