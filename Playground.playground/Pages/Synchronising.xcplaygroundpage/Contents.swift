//: [Previous](@previous)

import Foundation
import ReactiveCocoa
import Result

enum Either <T, U> {
    case Left(T)
    case Right(U)
}

extension SignalProducer {

    // not thread safe
    func waitFor <Value2> (other: SignalProducer<Value2, Error>) -> SignalProducer<Either<Value, Value2>, Error> {
        return SignalProducer<Either<Value, Value2>, Error> { (observer, disposable) in
            var valueQueue: [Value] = []
            var selfCompleted = false
            var otherCompleted = false
            var error: Error? = nil
            
            func completeIfAllComplete () {
                if let error = error where otherCompleted { observer.sendFailed(error) }
                else if selfCompleted && otherCompleted { observer.sendCompleted() }
            }
            
            disposable.addDisposable(self.start { event in
                switch event {
                case .Next(let value):
                    if otherCompleted {
                        observer.sendNext(.Left(value))
                    } else {
                        valueQueue.append(value)
                    }
                case .Failed(let e):
                    error = e
                    completeIfAllComplete()
                case .Completed:
                    selfCompleted = true
                    completeIfAllComplete()
                case .Interrupted: break
                observer.sendInterrupted()
                }
                })
            disposable.addDisposable(other.start { event in
                switch event {
                case .Next(let value):
                    observer.sendNext(.Right(value))
                case .Failed(let error):
                    observer.sendFailed(error)
                case .Completed:
                    otherCompleted = true
                    valueQueue.forEach { observer.sendNext(.Left($0)) }
                    valueQueue = []
                    completeIfAllComplete()
                case .Interrupted: break
                }
                })
        }
    }
    
//    func waitFor2 <Value2> (other: SignalProducer<Value2, Error>) -> SignalProducer<Either<Value, Value2>, Error> {
//        let producers = [self.map { Either.Left($0) } , other.map { Either.Right($0) }]
//        let x =  SignalProducer<SignalProducer<Either<Value, Value2>, NoError>, NoError>(values: producers)
//    }
}


let (plusButton, plusObserver) = SignalProducer<(), NoError>.buffer(0)

let (minusButton, minusObserver) = SignalProducer<(), NoError>.buffer(0)


//minusButton.waitFor(plusButton)
//    .map { x -> Int in
//        switch x {
//        case .Left: return -1
//        case .Right: return 1
//        }
//    }.scan(0, +)
//    .startWithNext { (x) in
//        print(x)
//}

let x = SignalProducer<SignalProducer<Int, NoError>, NoError>(values: [plusButton.map { 1 }, minusButton.map { -1 }.on(started: {
    print("start minus")
})])
    .flatten(.Concat)
    .scan(0, +)
    .startWithNext { (x: Int) in
        print(x)
}


plusObserver.sendNext()
plusObserver.sendNext()
minusObserver.sendNext()
minusObserver.sendNext()
minusObserver.sendNext()
plusObserver.sendNext()
plusObserver.sendCompleted()
minusObserver.sendCompleted()






