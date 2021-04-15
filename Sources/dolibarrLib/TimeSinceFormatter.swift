import Foundation

class TimeSinceFormatter {
  
  func format(timeString: String, to toDate: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "EEEE dd MMM yyyy HH:mm"
    
    guard let date = df.date(from: timeString) else {
      return ""
    }
    
    let cf = DateComponentsFormatter()
    cf.unitsStyle = .full
    cf.allowedUnits = [.hour, .minute]
    cf.zeroFormattingBehavior = .dropAll
    
    return cf.string(from: date, to: toDate) ?? ""
  }
}
