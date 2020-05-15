## Reactive Programming

Reactive programming is a programming paradigm that is usually adopted in client side software.

It helps software engineers to handle asynchronous events, and to write a program in a declarative manner with events streams.

There are some 3rd party frameworks in swift community, and RxSwift is one of the most popular one.

Apple introduced Combine framework on their SDK in 2019.

Although it can be used from iOS 13 whereas RxSwift supports from iOS 8, now Reactive programming clearly becomes the mainstream of developing client applications.


### [Nested Stream](NestedStream.swift)

This is an example that one might get easily confused.

Though the ps, the nested stream, has finished, it has p1 in its inside which is not yet completed, so p1 can still send events so that the events propagate to its subscription.

Therefore, this program outputs

```
1
2
3
completed!
```

Unfortunately, Apple does not open-source their frameworks, so instead of Combine, we can investigate RxSwift to see what's going on inside.

Below is the same program written in RxSwift which outputs the same.

[`FlatMapLatest`](https://github.com/ReactiveX/RxSwift/blob/5.1.1/RxSwift/Observables/Switch.swift#L218) in RxSwift is the corresponding operater(class) to Combine's `switchToLatest`

When it runs, it instantiate [`MapSwitchSink`](https://github.com/ReactiveX/RxSwift/blob/5.1.1/RxSwift/Observables/Switch.swift#L187), and MapSwitchSink inherits from [`SwitchSink`](https://github.com/ReactiveX/RxSwift/blob/5.1.1/RxSwift/Observables/Switch.swift#L46).

If the `SwitchSink` or `FlatMapLatest` receives at least one event, then [an inner subscription is made](https://github.com/ReactiveX/RxSwift/blob/5.1.1/RxSwift/Observables/Switch.swift#L98), and [`_hasLatest` set to true](https://github.com/ReactiveX/RxSwift/blob/5.1.1/RxSwift/Observables/Switch.swift#L80) so that [if clause](https://github.com/ReactiveX/RxSwift/blob/5.1.1/RxSwift/Observables/Switch.swift#L114) would not be executed, so the inner subscription is not disposed.

Therefore, event can propagates!

This is not commonly used patterns in practice, but it is always better to be cautious when you deal with streams.

