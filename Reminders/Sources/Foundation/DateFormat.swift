//
//  DateFormat.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import Foundation
/**
 DateFormatter를 매번 초기화 해서 사용하면 리소스가 많이 소모되기에
 공통된 설정의 DateFormatter는 캐시하여 사용하기 위한 객체
 - DateFormatter의 Format을 원시값으로 가진 열거형을 정의
 - 정의한 열거형으로 캐시된 DateFormatter를 사용해 변환해주는 String, Date의 확장 메서드 사용
 */
enum DateFormat: String {
    private static var cachedStorage = [DateFormat: DateFormatter]()
    
    case todoOutput = "yyyy.MM.dd (E)"
    
    var formatter: DateFormatter {
        if let formatter = Self.cachedStorage[self] {
            return formatter
        } else {
            let newFormatter = DateFormatter()
            newFormatter.dateFormat = rawValue
            newFormatter.locale = Locale(identifier: "ko_KR")
            Self.cachedStorage[self] = newFormatter
            return newFormatter
        }
    }
}

extension String {
    func formatted(dateFormat: DateFormat) -> Date? {
        dateFormat.formatter.date(from: self)
    }
    
    func formatted(input: DateFormat, output: DateFormat) -> String? {
        input.formatter.date(from: self)?.formatted(dateFormat: output)
    }
}

extension Date {
    func formatted(dateFormat: DateFormat) -> String {
        dateFormat.formatter.string(from: self)
    }
}

