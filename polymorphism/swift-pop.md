## Swift: Protocol Oriented Programming

Method dispatching in Swift

```swift
protocol PA {
    // only here
    func f1()

    // have default implementations in extension
    func f2()
    func f3()
}

extension PA {
    // default implementations
    func f2() {
        print("PA: f2 default")
    }
    func f3() {
        print("PA: f3 default")
    }

    // only here
    func f4() {
        print("PA: extension f4")
    }
    func f5() {
        print("PA: extension f5")
    }
}

class C1: PA {
    // conforms to protocol
    func f1() {
        print("C1: f1")
    }
    func f3() {
        print("C1: f3")
    }

    // re-declaration of f5
    func f5() {
        print("C1: f5")
    }
}
```

```swift
let c1pa: PA = C1()
let c1: C1 = C1()

c1pa.f1()
c1pa.f2()
c1pa.f3()
c1pa.f4()
c1pa.f5()
print("------")
c1.f1()
c1.f2()
c1.f3()
c1.f4()
c1.f5()
```

### Results & comments
```
C1: f1
PA: f2 default
C1: f3
PA: extension f4
PA: extension f5 // <--- (1)
------
C1: f1
PA: f2 default
C1: f3
PA: extension f4
C1: f5 // <--- (2)
```

(1), (2) f5 works differently, since the methods declared only in the extension of the protocol are statically dispatched.
In other words, it is decided at compile time.

If we change it to `(c1 as PA).f5()` then the result will be `PA: extension f5`.

Another example:

```swift
class C2: PA {
    // conforms to protocol
    func f1() {
        print("C2: f1")
    }
}

extension C2 {
    func f3() {
        print("C2 extension f3")
    }

    func f4() {
        print("C2 extension f4")
    }

    func f5() {
        print("C2 extension f5")
    }
}
```

```swift
let c2pa: PA = C2()
let c2: C2 = C2()

c2pa.f1()
c2pa.f2()
c2pa.f3()
c2pa.f4()
c2pa.f5()
print("------")
c2.f1()
c2.f2()
c2.f3()
c2.f4()
c2.f5()
```

```
C2: f1
PA: f2 default
C2 extension f3
PA: extension f4 // <--- (3)
PA: extension f5 // <--- (3)
------
C2: f1
PA: f2 default
C2 extension f3
C2 extension f4 // <--- (3)
C2 extension f5 // <--- (3)
```

(3) again, methods declared in extension but not in protocol are dispatched ahead-of-time.

 f1 is in C2, and f3 is in C2 extension but the results are the same.
 Wherever it is declared in conforming class, it is dynamically dispatched.

```swift
class D: C1 {
    override func f3() {
        print("D: f3")
    }

    func f4() {
        print("D: f4")
    }
}
```

```swift
let dpa: PA = D()
let dc1: C1 = D()
let d: D = D()

dpa.f1()
dpa.f2()
dpa.f3()
dpa.f4()
dpa.f5()
print("------")
dc1.f1()
dc1.f2()
dc1.f3()
dc1.f4()
dc1.f5()
print("------")
d.f1()
d.f2()
d.f3()
d.f4()
d.f5()
```

```
C1: f1
PA: f2 default
D: f3 // <--- (4)
PA: extension f4 // <--- (5)
PA: extension f5 // <--- (6)
------
C1: f1
PA: f2 default
D: f3 // <--- (4)
PA: extension f4 // <--- (5)
C1: f5 // <--- (6)
------
C1: f1
PA: f2 default
D: f3 // <--- (4)
D: f4 // <--- (5)
C1: f5 // <--- (6)
```

(4) overriden method f3 is always called no matter its type
(5) f4 in D is called
(6) f5 follows the behavior of parent


### Conclusion

If we use carelly these properties, then we can improve clarity of our code.

For example, [RxSwift](https://github.com/ReactiveX/RxSwift) use a lot of these patterns.

If a method should act differently depending on its underlying type (which is not public), the method is declared in protocol so that it can be dynamically dispatched.

Otherwise, a method is declared on extension if the behavior of the method should remain the same, or doesn't need to be overridden.

[Full code](all.swift)
