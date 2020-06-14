def next_permutation(seq):
    """(stateless) next permutation O(n)"""
    pos = 0
    for idx in range(len(seq)-1, -1, -1):
        subseq = seq[idx:]
        if is_decreasing(subseq):
            pos = idx
        else:
            break

    subseq = seq[pos:]

    if pos == 0:
        """ done """
        return None

    m_idx = find_next(seq[pos-1], subseq) + pos
    # swap
    t = seq[pos - 1]
    seq[pos - 1] = seq[m_idx]
    seq[m_idx] = t

    for idx, item in enumerate(reversed(seq[pos:])):
        seq[idx+pos] = item

    return seq

def find_next(num, seq):
    m = 10000
    m_idx = 0
    for idx, item in enumerate(seq):
        if item > num and item < m:
            m = item
            m_idx = idx
    return m_idx

def is_decreasing(seq):
    last = seq[0] + 1
    for item in seq:
        if last > item:
            last = item
        else:
            return False
    return True

test_input = list(range(1, 5))
seq = sorted(test_input)

while seq:
    print(seq)
    seq = next_permutation(seq)
