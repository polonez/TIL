/// Check if the given string is palindrome
/// - Parameter string: string to check palindrome
/// - Returns: true if palindrome, otherwise false
///
/// Time complexity: O(n)
///
/// It calls itself recursively
func isPalindrome(string: String) -> Bool {
    guard string.count > 1 else { return true }
    guard string.first == string.last else { return false }
    return isPalindrome(string: String(string.dropFirst().dropLast()))
}

assert(isPalindrome(string: "aba") == true)
assert(isPalindrome(string: "abc") == false)
assert(isPalindrome(string: "abba") == true)
assert(isPalindrome(string: "abbc") == false)
assert(isPalindrome(string: "abcba") == true)
assert(isPalindrome(string: "abcbc") == false)


extension String {
    public subscript(_ i: Int) -> Character {
        return self[self.index(startIndex, offsetBy: i)]
    }
}

/// Find the longest palindrome in the given string
/// - Parameter string: string to find longest palindrome
/// - Returns: longest palindrome
///
/// Time complexity: O(n**2)
func longestPalindrome(string: String) -> String {
    var dp = [[Bool]](repeating: [Bool](repeating: false, count: string.count), count: string.count)
    for i in 0..<string.count {
        dp[i][i] = true
    }

    var start = 0
    var maxLength = 1

    for i in 0..<(string.count - 1) {
        if string[i] == string[i+1] {
            dp[i][i+1] = true
            start = i
            maxLength = 2
        }
    }

    for k in 2..<string.count {
        for i in 0..<(string.count-k) {
            let j = i + k
            if dp[i+1][j-1] && string[i] == string[j] {
                dp[i][j] = true
                if k + 1 > maxLength {
                    start = i
                    maxLength = k + 1
                }
            }
        }
    }

    return String(string.suffix(string.count - start).prefix(maxLength))
}

assert(longestPalindrome(string: "bcdcgga") == "cdc")
assert(longestPalindrome(string: "abcdcba") == "abcdcba")
assert(longestPalindrome(string: "abbabcde") == "abba")
assert(longestPalindrome(string: "abcdcef") == "cdc")
assert(longestPalindrome(string: "abbc") == "bb")
