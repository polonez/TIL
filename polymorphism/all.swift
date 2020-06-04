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

class D: C1 {
    override func f3() {
        print("D: f3")
    }

    func f4() {
        print("D: f4")
    }
}

let c1pa: PA = C1()
let c1: C1 = C1()

let c2pa: PA = C2()
let c2: C2 = C2()

let dpa: PA = D()
let dc1: C1 = D()
let d: D = D()

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
print("------")
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
print("------")
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
print("------")
