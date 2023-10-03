# log -> exponent/antilog
static var _anti_log_table: PackedByteArray = []
# exponent/antilog -> log
static var _log_table: PackedByteArray = []

static func _static_init() -> void:
    _create_log_anti_log_tables()

static func _anti_log(degree: int) -> int:
    var res: int = 1
    var alpha: int = 2

    while degree != 0:
        if degree & 1 == 1:
            res = mul(res, alpha)
        degree = degree >> 1
        alpha = mul(alpha, alpha)

    return res

static func _create_log_anti_log_tables() -> void:
    _anti_log_table.resize(256)
    _anti_log_table.fill(0)
    _log_table.resize(256)
    _log_table.fill(0)
    for degree: int in range(0, 256):
        var value: int = _anti_log(degree)
        _anti_log_table[degree] = value
        _log_table[value] = degree % 255

# Russian Peasant Multiplication algorithm, adapted to reed solomon
static func mul(lhs: int, rhs: int) -> int:
    var res: int = 0
    while rhs > 0:
        if rhs & 1:
            res = res ^ lhs
        lhs = lhs << 1  # lhs * 2
        rhs = rhs >> 1  # rhs / 2
        if lhs & 256:
            lhs = lhs ^ 0x11D
    return res

static func generator_polynom(size: int) -> PackedByteArray:
    var res: PackedByteArray = []
    res.resize(size + 1)
    res.fill(0)
    res[0] = 1

    var a_j: int = 1
    for exp: int in range(0, size):
        var cur_val: int = a_j
        for cur_exp: int in range(1, exp + 1):
            var old_res: int = res[cur_exp]
            res[cur_exp] = cur_val ^ old_res
            cur_val = mul(old_res, a_j)
        res[exp + 1] = cur_val

        a_j = mul(a_j, 0x02)
    return res

static func encode(data: PackedByteArray, code_words: int) -> PackedByteArray:
    assert(len(data) + code_words <= 255, "message to encode is to long")
    var gen_poly: PackedByteArray = generator_polynom(code_words)
    var enc_msg: PackedByteArray = []
    enc_msg.resize(len(data) + len(gen_poly) - 1)
    enc_msg.fill(0)

    for idx: int in range(len(data)):
        enc_msg[idx] = data[idx]

    for idx: int in range(len(data)):
        var coef: int = enc_msg[idx]
        for p_idx: int in range(1, len(gen_poly)):
            enc_msg[idx+p_idx] ^= mul(gen_poly[p_idx], coef)

    return enc_msg.slice(len(data))
