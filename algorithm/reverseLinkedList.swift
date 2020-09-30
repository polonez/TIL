class Node<T> {
    let item: T
    var next: Node<T>?

    init(item: T) {
        self.item = item
    }

    init(item: T, next: Node<T>) {
        self.item = item
        self.next = next
    }
}

var head = Node(item: 1)
head.next = Node(item: 2)
head.next?.next = Node(item: 3)
head.next?.next?.next = Node(item: 4)
head.next?.next?.next?.next = Node(item: 5)

func reverse<T>(head: Node<T>) -> Node<T> {
    var now: Node<T> = head
    var prior: Node<T>? = nil
    while let next = now.next {
        now.next = prior
        prior = now
        now = next
    }
    now.next = prior
    return now
}

func reverse<T>(current: Node<T>, prev: Node<T>?) -> Node<T> {
    if let next = current.next {
        current.next = prev
        let ret = reverse(current: next, prev: current)
        ret.next = current
        return current
    }
    return current
}

//head = reverse(current: head, prev: nil)

head = reverse(head: head)
print(head.item)
print(head.next?.item)
print(head.next?.next?.item)
print(head.next?.next?.next?.item)
print(head.next?.next?.next?.next?.item)
