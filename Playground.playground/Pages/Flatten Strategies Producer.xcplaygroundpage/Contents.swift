//: [Previous](@previous)

import Foundation
import Result
import ReactiveCocoa

var str = "Hello, playground"

func dispatchAfter (n: NSTimeInterval, _ block: () -> Void) {
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(n * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue(), block)
}

import XCPlayground
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let firstProducer = SignalProducer<String, NoError> { observer, _ in
    print("starting first")
    dispatchAfter(0.1) {
        print("sending first:1")
        observer.sendNext("1")
        dispatchAfter(0.5) {
            print("sending first:2")
            observer.sendNext("2")
            dispatchAfter(1.2) {
                print("sending first:3")
                observer.sendNext("3")
                print("completing first")
                observer.sendCompleted()
            }
        }
    }
}

let secondProducer = SignalProducer<String, NoError> { observer, _ in
    print("starting second")
    print("sending second:a")
    observer.sendNext("a")
    dispatchAfter(0.2) {
        print("sending second:b")
        observer.sendNext("b")
        dispatchAfter(1.2) {
            print("sending second:c")
            observer.sendNext("c")
            print("completing second")
            observer.sendCompleted()
        }
    }
}

let outerProducer = SignalProducer<SignalProducer<String, NoError>, NoError> { observer, _ in
    print("starting outer")
    print("sending first")
    observer.sendNext(firstProducer)
    dispatchAfter(0.9) {
        print("sending second")
        observer.sendNext(secondProducer)
    }
}

outerProducer.flatten(.Latest).startWithNext { x in
    print(x)
}