import Foundation

struct DolibarrTimeZone {

  let timeZoneIdentifier: String
  let timeZoneOffset: Int // standard offset in hours (when not in DST)
  let isDSTObserved: Bool // if DST is being observed now
  let dstFirstSwitch: Date
  let dstSecondSwitch: Date

  init() {
    self.init(timeZone: Calendar.current.timeZone)
  }

  init(timeZone: TimeZone) {
    let currentYear = Calendar.current.component(.year, from: Date())
    let firstDayOfTheYear = Calendar.current.date(from: DateComponents(timeZone: timeZone, year:currentYear, month: 1, day: 1))!
    
    self.timeZoneIdentifier = timeZone.identifier

    self.timeZoneOffset = timeZone.secondsFromGMT(for: firstDayOfTheYear) / 3600
    self.isDSTObserved = timeZone.isDaylightSavingTime()

    self.dstFirstSwitch = timeZone.nextDaylightSavingTimeTransition(after: firstDayOfTheYear)!
    self.dstSecondSwitch = timeZone.nextDaylightSavingTimeTransition(after: self.dstFirstSwitch)!
  }

  var asDictionary: [String: String] {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd'T'hh:mm:ss'Z'"

    return [
      "tz": String(timeZoneOffset),
      "tz_string": timeZoneIdentifier,
      "dst_observed": isDSTObserved ? "1" : "0",
      "dst_first": df.string(from: dstFirstSwitch),
      "dst_second": df.string(from: dstSecondSwitch)
    ]
  }
}
