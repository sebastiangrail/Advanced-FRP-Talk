//: [Previous](@previous)

import Foundation
import ReactiveCocoa
import Result

let (plusButton, plusObserver) = SignalProducer<(), NoError>.buffer(0)


var counter = 0
let counterSignal = plusButton.map { _ -> Int in
    counter += 1
    return counter
}
var disposable = counterSignal.startWithNext { (x) in
        print("first: \(x)")
}
let disp2 = counterSignal.startWithNext { (x) in
    print("second: \(x)")
}

plusObserver.sendNext()
plusObserver.sendNext()
plusObserver.sendNext()
disposable.dispose()
disp2.dispose()

print()



plusButton
    .scan(0) { sum, _ in sum + 1 }
    .startWithNext { (x) in
        print("total number of taps: \(x)")
    }

disposable = plusButton.map { 1 }
    .scan(0, +)
    .startWithNext { (x) in
        print(x)
}

plusObserver.sendNext()
plusObserver.sendNext()
plusObserver.sendNext()
disposable.dispose()




let (minusButton, minusObserver) = SignalProducer<(), NoError>.buffer(0)

SignalProducer.merge([plusButton.map { 1 }, minusButton.map { -1 }])
    .scan(0, +)
    .startWithNext { (x) in
        print(x)
    }

disposable = SignalProducer.merge([plusButton.map { 1 }, minusButton.map { -1 }])
    .scan(0, +)
    .startWithNext { (x) in
        print(x)
}

plusObserver.sendNext()
plusObserver.sendNext()
minusObserver.sendNext()
minusObserver.sendNext()
minusObserver.sendNext()
plusObserver.sendNext()
disposable.dispose()



