//
//  CalendarViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/10/24.
//

import Foundation

final class CalendarViewModel: ViewModel {
    func transform(input: Input) -> Output {
        let output = Output(
            startListFlow: Observable<Date?>(nil)
        )
        
        input.dateSelectEvent.bind { date in
            output.startListFlow.onNext(date)
        }
        
        return output
    }
}

extension CalendarViewModel {
    struct Input { 
        let dateSelectEvent: Observable<Date?>
    }
    
    struct Output { 
        let startListFlow: Observable<Date?>
    }
}
