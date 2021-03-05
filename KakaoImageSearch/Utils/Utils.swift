//
//  Utils.swift
//  KakaoImageSearch
//
//  Created by jc.kim on 3/6/21.
//

import Foundation

extension String {
    func currencyKR() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd\'T\'HH:mm:ss\'.000\'z"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")! as TimeZone
        
        let date = dateFormatter.date(from: self)
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "Ko_kr")
        
        return "\(dateFormatter.string(from: date!))"
    }
}
