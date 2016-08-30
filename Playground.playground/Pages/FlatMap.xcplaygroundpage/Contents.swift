//: Playground - noun: a place where people can play

import UIKit
import Result
import ReactiveCocoa


let rootVC = UIViewController(nibName: nil, bundle: nil)
rootVC.view.frame = CGRect(x: 0, y: 0, width: 400, height: 400)



let button = UIButton(type: .System)
//let x = button.rac_signalForControlEvents(.TouchUpInside).toSignalProducer().discardError()
let (cogButtonSignal, observer) = SignalProducer<(), NoError>.buffer(0)

let logoutSignal = cogButtonSignal.flatMap(.Latest) { _ -> SignalProducer<(), NoError> in
    return SignalProducer { (observer, _) in
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Sign out", style: .Destructive) { _ in
            observer.sendNext()
            observer.sendCompleted()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { _ in
            observer.sendCompleted()
        })

        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
}

let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
window.rootViewController = rootVC
rootVC.view.backgroundColor = UIColor.redColor()






logoutSignal.startWithNext {
    print("sign out")
}
observer.sendNext()



func createProducer <T, U> (f: (T, U -> Void) -> Void) -> T -> SignalProducer<U, NoError> {
    return { t in
        return SignalProducer { observer, _ in
            f(t) { u in
                observer.sendNext(u)
                observer.sendCompleted()
            }
        }
    }
}

