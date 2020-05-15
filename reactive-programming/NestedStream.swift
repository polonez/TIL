/*

*/

import Combine

func combine() {
    let ps = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
    let p1 = PassthroughSubject<Int, Never>()
    let p2 = PassthroughSubject<Int, Never>()

    var cancelBag = [AnyCancellable]()

    ps.switchToLatest()
        .sink(receiveCompletion: { (_) in
            print("completed!")
        }, receiveValue: {
            print($0)
        })
        .store(in: &cancelBag)

    ps.send(p1)
    p1.send(1)
    p1.send(2)

    ps.send(completion: .finished)
    p1.send(3)
    p2.send(4)

    p1.send(completion: .finished)
    p1.send(5)
    p2.send(6)
}

combine()


//import RxSwift
//
//func rx() {
//    let disposeBag = DisposeBag()
//
//    let ps = PublishSubject<PublishSubject<Int>>()
//    let p1 = PublishSubject<Int>()
//    let p2 = PublishSubject<Int>()
//
//    ps.flatMapLatest { $0 }
//        .subscribe(onNext: { print($0) }, onCompleted: { print("completed") })
//        .disposed(by: disposeBag)
//
//    ps.onNext(p1)
//    p1.onNext(1)
//    p2.onNext(2)
//
//    ps.onCompleted()
//    p1.onNext(3)
//    p2.onNext(4)
//
//    p1.onCompleted()
//    p1.onNext(5)
//    p2.onNext(6)
//}
//
//rx()
