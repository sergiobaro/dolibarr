import Foundation

enum Command: String {
  case signin
  case signout
  case history
}

class Args {

  func parse(_ args: [String]) -> Command? {
    guard let command = args.first else {
      return nil
    }

    return Command(rawValue: command)
  }
}
