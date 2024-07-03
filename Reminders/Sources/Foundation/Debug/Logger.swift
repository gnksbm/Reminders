//
//  Logger.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import Foundation
import OSLog
/**
 파일명, 줄번호, 함수명이 포함된 출력문을 남겨 print()보다 명확한 디버깅 가능
 - debugging
    - 일반적인 디버깅을 위한 함수
 - error
    - Error 타입을 인자로 받아 에러 상황을 출력
    - 추가 인자도 함께 사용 가능
 - retainCount
    - class 객체의 참조 카운트 출력
 */
enum Logger {
    private static var logger = OSLog(
        subsystem: .bundleIdentifier,
        category: "Default"
    )
    
    static func debug(
        _ content: Any,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        os_log(
            """
            📍 %{public}@ at line %{public}d - %{public}@ 📍
            🔵 %{public}@ 🔵
            """,
            log: logger,
            type: .debug,
            file, line, function, String(describing: content)
        )
    }
    
    static func error(
        _ error: Error,
        with: Any? = nil,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        if let with {
            os_log(
                """
                📍 %{public}@ at line %{public}d - %{public}@ 📍
                🔴 %{public}@
                %{public}@ 🔴
                """,
                log: logger,
                type: .error,
                file, line, function, String(describing: error),
                String(describing: with)
            )
        } else {
            os_log(
                """
                📍 %{public}@ at line %{public}d - %{public}@ 📍
                🔴 %{public}@ 🔴
                """,
                log: logger,
                type: .error,
                file, line, function, String(describing: error)
            )
        }
    }
    
    static func retainCount(
        _ target: AnyObject,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function
    ) {
        let retainCount = CFGetRetainCount(target)
        os_log(
            """
            📍 %{public}@ at line %{public}d - %{public}@ 📍
            ➡️ %{public}@'s Retain Count: %{public}ld ⬅️
            """,
            log: logger,
            type: .debug,
            file, line, function, String(describing: target), retainCount
        )
    }
}

