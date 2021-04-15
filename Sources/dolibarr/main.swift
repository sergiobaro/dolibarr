import Foundation
import dolibarrLib

do {
    try Dolibarr().run(Array(CommandLine.arguments.dropFirst()))
} catch {
    print(error.localizedDescription)
}
