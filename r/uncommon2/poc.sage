from multiprocessing import Pool
from Crypto.Util.number import long_to_bytes as lb, bytes_to_long as bl
import os

def gen_n(_):
    _p = random_prime(_ub, lbound=_lb, proof=False)
    _q = random_prime(1 << 200, proof=False)
    N = _p * _q
    return N

def reseed(_):
    set_random_seed()

size = 1 << 7
_f1 = randint(0, 1 << 80)
_f2 = bl(os.urandom(16))
_seed = (_f1 << 232) + (_f2 << 104)
_ub = _seed + (1 << 104)
_lb = _seed

threads = 64
_pool = Pool(processes=threads)
_pool.map(reseed, range(size))
data = sorted(_pool.map(gen_n, range(size)))
_pool.close()
_pool.join()

if __name__ == "__main__":
    n = 512
    t = 208
    K = int(2^(n - t + .5))
    size2 = size * (size + 1) // 2
    M = Matrix(ZZ, size, size + size2)
    for i in range(size):
        M[i, i] = K
    col = size
    for i in range(size - 1, -1, -1):
        row = size - 1 - i
        for j in range(i):
            M[row, col] = data[row + j + 1]
            M[row + j + 1, col] = -data[row]
            col += 1

    res = M.LLL()
    once = False
    for i in range(size):
        q = abs(int(res[i][0]) // K)
        if GCD(q, data[i]) != 1 and q != 0:
            n = data[i] // q
            f2 = (n >> 104) & (2^128 - 1)
            assert f2 == _f2
            once = True
            break
    assert once
