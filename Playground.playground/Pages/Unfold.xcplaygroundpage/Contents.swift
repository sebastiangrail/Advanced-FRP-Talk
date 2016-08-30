//: [Previous](@previous)

import Foundation
import ReactiveCocoa
import Result

extension SignalProducer {
    func startWith(value: Value) -> SignalProducer {
        return SignalProducer { observer, disposable in
            observer.sendNext(value)
            disposable.addDisposable(self.start(observer))
        }
    }
}

func unfold <T, U, E: ErrorType> (f: T -> SignalProducer<(U, T), E>, initial: T) -> SignalProducer<U, E> {
    return f(initial).flatMap(.Concat) {
        return unfold(f, initial: $1).startWith($0)
    }
}

func foo (x: Int) -> SignalProducer<(String, Int), NoError> {
    return SignalProducer { observer, _ in
        if x >= 3 {
            observer.sendCompleted()
        }
        Double(arc4random_uniform(100))/100
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(arc4random_uniform(100))/100 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            observer.sendNext(("seed \(x) (first):  \(x+1)", x+1))
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(arc4random_uniform(100))/100 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                observer.sendNext(("seed \(x) (second): \(x+2)", x+2))
                observer.sendCompleted()
            }
        }
        
    }
}

unfold(foo, initial: 0).start { event in
    switch event {
    case .Next(let value): print(value)
    case .Completed: print("completed")
    default: break
    }
}
import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//0 -> [0]
//Int32.max
