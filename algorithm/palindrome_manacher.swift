func modifiedString(string: String) -> [Character] {
    var ret = [Character](repeating: "#", count: 2 * string.count + 1)
    for i in 0..<string.count {
        ret[2 * i + 1] = string[i]
    }
    return ret
}

extension Array where Element == Character {
    subscript(safe index: Int) -> Character? {
        if 0 <= index && index < self.count {
            return self[index]
        }
        return nil
    }
}

/// Find the longest palindrome substring from the given string
/// - Parameter string: string to find longest palindome substring
/// - Returns: longest palindome substring
///
/// To find even length of palindrome substring, '#' Characters are added to the beginning, end, and between the Characters.
/// If there are more than one longest palindrome substring, returns the first one (with lower index)
///
/// Time complexity: O(n) (Manacher's algorithm)
func manacher(string: String) -> String {
    let str = modifiedString(string: string)
    var lps = [Int](repeating: 0, count: str.count)

    var r = -1
    var p = -1
    var lpsCenter = -1
    var maxRadius = -1
    for i in 0..<str.count {
        if r >= i {
            lps[i] = min(r - i, lps[2 * p - i])
        } else {
            lps[i] = 0
        }
        while let l = str[safe: i - lps[i] - 1], let r = str[safe: i + lps[i] + 1], l == r {
            lps[i] += 1
        }
        if i + lps[i] > r {
            r = i + lps[i]
            p = i
        }
        if lps[i] > maxRadius {
            maxRadius = lps[i]
            lpsCenter = i
        }
    }
    let e = str[lpsCenter-maxRadius...lpsCenter+maxRadius]
    return String(e.filter { $0 != "#" })
}

print(manacher(string: "bcdcgga"))
print(manacher(string: "abcdcba"))
print(manacher(string: "abbabcde"))
print(manacher(string: "abcdcef"))
print(manacher(string: "abbc"))
print(manacher(string: "abcd"))
