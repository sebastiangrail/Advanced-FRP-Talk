//: [Previous](@previous)

import Foundation
import ReactiveCocoa
import Result

enum LoginError: ErrorType {
    case Error
}

struct User { let name: String }

func login (name: String, password: String) -> SignalProducer<User, LoginError> {
    if password == "password" {
        return SignalProducer(value: User(name: name))
    } else {
        return SignalProducer(error: .Error)
    }
}

func safeLogin (name: String, password: String) -> SignalProducer<Result<User, LoginError>, NoError> {
    if password == "password" {
        return SignalProducer(value: Result(value: User(name: name)))
    } else {
        return SignalProducer(value: Result(error: .Error))
    }
}

let (button, observer) = SignalProducer<(), NoError>.buffer(0)

let (usernamePassword, usernamePasswordObserver) = SignalProducer<(String, String), NoError>.buffer(1)


usernamePassword.sampleOn(button).flatMap(.Latest, transform: login)
    .start { event in
    switch event {
    case .Next(let value):
        print("from unsafe login: \(value)")
    case .Failed(let error):
        print("from unsafe login: \(error)")
    default:
        break
    }
}

usernamePassword.sampleOn(button).flatMap(.Latest, transform: safeLogin)
    .start { event in
        switch event {
        case .Next(.Failure(let error)):
            print("from safe login: \(error)")
        case .Next(.Success(let value)):
            print("from safe login: \(value)")
        default:
            break
        }
}

func foo <T, U, E: ErrorType> (f: T -> SignalProducer<U, E>) -> T -> SignalProducer<Result<U, E>, NoError> {
    return { t in
        return SignalProducer<Result<U, E>, NoError> { (observer, disposable) in
            disposable.addDisposable(f(t).start { event in
                switch event {
                case .Next(let value): observer.sendNext(Result(value: value))
                case .Failed(let error):
                    observer.sendNext(Result(error: error))
                    observer.sendCompleted()
                case .Completed: observer.sendCompleted()
                case .Interrupted: observer.sendInterrupted()
                }
            })
        }
    }
}

func bar <T, U, E: ErrorType> (f: T -> SignalProducer<U, E>) -> T -> SignalProducer<Event<U, E>, NoError> {
    return { t in
        f(t).materialize()
    }
}

//usernamePassword.sampleOn(button).flatMap(.Latest, transform: bar(login))
//    .start { event in
//        switch event {
//        case .Next(let value):
//            print("from foo login: \(value)")
//        case .Failed(let error):
//            print("from foo login: \(error)")
//        default:
//            break
//        }
//}

let x = usernamePassword.sampleOn(button).flatMap(.Latest) { x,y in
    login(x,password: y).materialize()
}

usernamePassword.sampleOn(button).flatMap(.Latest) { x,y in
    login(x,password: y).materialize()
    }.start { event in
        switch event {
        case .Next(let value):
            print("from foo login: \(value)")
        case .Failed(let error):
            print("from foo login: \(error)")
        default:
            break
        }
}


//let foo = usernamePassword.sampleOn(button).map(login).map { innerProducer in
//    innerProducer.flatMapError { error in
//        return SignalProducer<Result<User, LoginError>, NoError>(value: Result(error: .Error))
//    }
//}

usernamePassword.sampleOn(button).flatMap(.Latest, transform: login).retry(2).materialize()
    .start { event in
        print(event)
}

usernamePasswordObserver.sendNext(("name", "pw"))
observer.sendNext()
usernamePasswordObserver.sendNext(("name", "secret"))
observer.sendNext()
usernamePasswordObserver.sendNext(("name", "password"))
observer.sendNext()

