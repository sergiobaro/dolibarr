import Foundation

struct HistoryEntry {
  let name: String
  let start: String
  let end: String
  let commentEntry: String
  let commentOut: String
}

class HistoryTable {

  private let columnMargin = 3
  private let entries: [HistoryEntry]
  private var headers = ["Name", "Start Date", "End Date", "Comment Entry", "Comment Out"]
  private var columnWidths: [Int]
  private let entryKeyPaths: [KeyPath<HistoryEntry, String>] = [\.name, \.start, \.end, \.commentEntry, \.commentOut]

  init(entries: [HistoryEntry]) {
    self.entries = entries
    self.columnWidths = Array<Int>(repeating: 0, count: headers.count)
    calculateColumnWidths()
  }

  func printTable() {
    printRow(values: headers)
    entries.forEach { printEntry($0) }
  }

  private func printEntry(_ entry: HistoryEntry) {
    let values = entryKeyPaths.map({ entry[keyPath: $0] })
    printRow(values: values)
  }

  private func printRow(values: [String]) {
    for (index, value) in values.enumerated() {
      let width = columnWidths[index]
      let string = value.padding(toLength: width, withPad: " ", startingAt: 0)
      print(string, terminator: "")
    }
    print()
  }

  private func calculateColumnWidths() {
    for (index, keyPath) in entryKeyPaths.enumerated() {
      let allValues = entries.map({ $0[keyPath: keyPath] }) + [headers[index]]
      columnWidths[index] = (allValues.map({ $0.count }).max() ?? 0) + columnMargin
    }
  }
}
