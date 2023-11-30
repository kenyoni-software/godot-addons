extends RefCounted

const BitStream := preload("bit_stream.gd")
const ReedSolomon := preload("reed_solomon.gd")
const ShiftJIS := preload("shift_jis.gd")

## Encoding Mode
enum Mode {
    ## 0001
    NUMERIC = 1,
    ## 0010
    ALPHANUMERIC = 2,
    ## 0100
    BYTE = 4,
    ## 1000
    KANJI = 8
}

## Error Correction
enum ErrorCorrection {
    LOW = 1,
    MEDIUM = 0,
    QUARTILE = 3,
    HIGH = 2
}

## Extended Channel Interpretation
enum ECI {
    CODE_PAGE_437 = 2,
    ISO_8859_1 = 3,
    ISO_8859_2 = 4,
    ISO_8859_3 = 5,
    ISO_8859_4 = 6,
    ISO_8859_5 = 7,
    ISO_8859_6 = 8,
    ISO_8859_7 = 9,
    ISO_8859_8 = 10,
    ISO_8859_9 = 11,
    ISO_8859_10 = 12,
    ISO_8859_11 = 13,
    ISO_8859_12 = 14,
    ISO_8859_13 = 15,
    ISO_8859_14 = 16,
    ISO_8859_15 = 17,
    ISO_8859_16 = 18,
    SHIFT_JIS = 20,
    WINDOWS_1250 = 21,
    WINDOWS_1251 = 22,
    WINDOWS_1252 = 23,
    WINDOWS_1256 = 24,
    UTF_16 = 25,
    UTF_8 = 26,
    US_ASCII = 27,
    BIG_5 = 28,
    GB_18030 = 29,
    EUC_KR = 30
}

const _DATA_CAPACITY: Array[Dictionary] = [
    # 1
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 41, Mode.ALPHANUMERIC: 25, Mode.BYTE: 17, Mode.KANJI: 10 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 34, Mode.ALPHANUMERIC: 20, Mode.BYTE: 14, Mode.KANJI: 8 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 27, Mode.ALPHANUMERIC: 16, Mode.BYTE: 11, Mode.KANJI: 7 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 17, Mode.ALPHANUMERIC: 10, Mode.BYTE: 7, Mode.KANJI: 4 },
    },
    # 2
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 77, Mode.ALPHANUMERIC: 47, Mode.BYTE: 32, Mode.KANJI: 20 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 63, Mode.ALPHANUMERIC: 38, Mode.BYTE: 26, Mode.KANJI: 16 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 48, Mode.ALPHANUMERIC: 29, Mode.BYTE: 20, Mode.KANJI: 12 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 34, Mode.ALPHANUMERIC: 20, Mode.BYTE: 14, Mode.KANJI: 8 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 127, Mode.ALPHANUMERIC: 77, Mode.BYTE: 53, Mode.KANJI: 32 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 101, Mode.ALPHANUMERIC: 61, Mode.BYTE: 42, Mode.KANJI: 26 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 77, Mode.ALPHANUMERIC: 47, Mode.BYTE: 32, Mode.KANJI: 20 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 58, Mode.ALPHANUMERIC: 35, Mode.BYTE: 24, Mode.KANJI: 15 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 187, Mode.ALPHANUMERIC: 114, Mode.BYTE: 78, Mode.KANJI: 48 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 149, Mode.ALPHANUMERIC: 90, Mode.BYTE: 62, Mode.KANJI: 38 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 111, Mode.ALPHANUMERIC: 67, Mode.BYTE: 46, Mode.KANJI: 28 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 82, Mode.ALPHANUMERIC: 50, Mode.BYTE: 34, Mode.KANJI: 21 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 255, Mode.ALPHANUMERIC: 154, Mode.BYTE: 106, Mode.KANJI: 65 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 202, Mode.ALPHANUMERIC: 122, Mode.BYTE: 84, Mode.KANJI: 52 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 144, Mode.ALPHANUMERIC: 87, Mode.BYTE: 60, Mode.KANJI: 37 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 106, Mode.ALPHANUMERIC: 64, Mode.BYTE: 44, Mode.KANJI: 27 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 322, Mode.ALPHANUMERIC: 195, Mode.BYTE: 134, Mode.KANJI: 82 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 255, Mode.ALPHANUMERIC: 154, Mode.BYTE: 106, Mode.KANJI: 65 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 178, Mode.ALPHANUMERIC: 108, Mode.BYTE: 74, Mode.KANJI: 45 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 139, Mode.ALPHANUMERIC: 84, Mode.BYTE: 58, Mode.KANJI: 36 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 370, Mode.ALPHANUMERIC: 224, Mode.BYTE: 154, Mode.KANJI: 95 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 293, Mode.ALPHANUMERIC: 178, Mode.BYTE: 122, Mode.KANJI: 75 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 207, Mode.ALPHANUMERIC: 125, Mode.BYTE: 86, Mode.KANJI: 53 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 154, Mode.ALPHANUMERIC: 93, Mode.BYTE: 64, Mode.KANJI: 39 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 461, Mode.ALPHANUMERIC: 279, Mode.BYTE: 192, Mode.KANJI: 118 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 365, Mode.ALPHANUMERIC: 221, Mode.BYTE: 152, Mode.KANJI: 93 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 259, Mode.ALPHANUMERIC: 157, Mode.BYTE: 108, Mode.KANJI: 66 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 202, Mode.ALPHANUMERIC: 122, Mode.BYTE: 84, Mode.KANJI: 52 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 552, Mode.ALPHANUMERIC: 335, Mode.BYTE: 230, Mode.KANJI: 141 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 432, Mode.ALPHANUMERIC: 262, Mode.BYTE: 180, Mode.KANJI: 111 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 312, Mode.ALPHANUMERIC: 189, Mode.BYTE: 130, Mode.KANJI: 80 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 235, Mode.ALPHANUMERIC: 143, Mode.BYTE: 98, Mode.KANJI: 60 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 652, Mode.ALPHANUMERIC: 395, Mode.BYTE: 271, Mode.KANJI: 167 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 513, Mode.ALPHANUMERIC: 311, Mode.BYTE: 213, Mode.KANJI: 131 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 364, Mode.ALPHANUMERIC: 221, Mode.BYTE: 151, Mode.KANJI: 93 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 288, Mode.ALPHANUMERIC: 174, Mode.BYTE: 119, Mode.KANJI: 74 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 772, Mode.ALPHANUMERIC: 468, Mode.BYTE: 321, Mode.KANJI: 198 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 604, Mode.ALPHANUMERIC: 366, Mode.BYTE: 251, Mode.KANJI: 155 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 427, Mode.ALPHANUMERIC: 259, Mode.BYTE: 177, Mode.KANJI: 109 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 331, Mode.ALPHANUMERIC: 200, Mode.BYTE: 137, Mode.KANJI: 85 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 883, Mode.ALPHANUMERIC: 535, Mode.BYTE: 367, Mode.KANJI: 226 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 691, Mode.ALPHANUMERIC: 419, Mode.BYTE: 287, Mode.KANJI: 177 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 489, Mode.ALPHANUMERIC: 296, Mode.BYTE: 203, Mode.KANJI: 125 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 374, Mode.ALPHANUMERIC: 227, Mode.BYTE: 155, Mode.KANJI: 96 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 1022, Mode.ALPHANUMERIC: 619, Mode.BYTE: 425, Mode.KANJI: 262 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 796, Mode.ALPHANUMERIC: 483, Mode.BYTE: 331, Mode.KANJI: 204 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 580, Mode.ALPHANUMERIC: 352, Mode.BYTE: 241, Mode.KANJI: 149 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 427, Mode.ALPHANUMERIC: 259, Mode.BYTE: 177, Mode.KANJI: 109 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 1101, Mode.ALPHANUMERIC: 667, Mode.BYTE: 458, Mode.KANJI: 282 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 871, Mode.ALPHANUMERIC: 528, Mode.BYTE: 362, Mode.KANJI: 223 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 621, Mode.ALPHANUMERIC: 376, Mode.BYTE: 258, Mode.KANJI: 159 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 468, Mode.ALPHANUMERIC: 283, Mode.BYTE: 194, Mode.KANJI: 120 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 1250, Mode.ALPHANUMERIC: 758, Mode.BYTE: 520, Mode.KANJI: 320 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 991, Mode.ALPHANUMERIC: 600, Mode.BYTE: 412, Mode.KANJI: 254 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 703, Mode.ALPHANUMERIC: 426, Mode.BYTE: 292, Mode.KANJI: 180 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 530, Mode.ALPHANUMERIC: 321, Mode.BYTE: 220, Mode.KANJI: 136 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 1408, Mode.ALPHANUMERIC: 854, Mode.BYTE: 586, Mode.KANJI: 361 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 1082, Mode.ALPHANUMERIC: 656, Mode.BYTE: 450, Mode.KANJI: 277 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 775, Mode.ALPHANUMERIC: 470, Mode.BYTE: 322, Mode.KANJI: 198 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 602, Mode.ALPHANUMERIC: 365, Mode.BYTE: 250, Mode.KANJI: 154 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 1548, Mode.ALPHANUMERIC: 938, Mode.BYTE: 644, Mode.KANJI: 397 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 1212, Mode.ALPHANUMERIC: 734, Mode.BYTE: 504, Mode.KANJI: 310 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 876, Mode.ALPHANUMERIC: 531, Mode.BYTE: 364, Mode.KANJI: 224 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 674, Mode.ALPHANUMERIC: 408, Mode.BYTE: 280, Mode.KANJI: 173 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 1725, Mode.ALPHANUMERIC: 1046, Mode.BYTE: 718, Mode.KANJI: 442 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 1346, Mode.ALPHANUMERIC: 816, Mode.BYTE: 560, Mode.KANJI: 345 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 948, Mode.ALPHANUMERIC: 574, Mode.BYTE: 394, Mode.KANJI: 243 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 746, Mode.ALPHANUMERIC: 452, Mode.BYTE: 310, Mode.KANJI: 191 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 1903, Mode.ALPHANUMERIC: 1153, Mode.BYTE: 792, Mode.KANJI: 488 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 1500, Mode.ALPHANUMERIC: 909, Mode.BYTE: 624, Mode.KANJI: 384 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 1063, Mode.ALPHANUMERIC: 644, Mode.BYTE: 442, Mode.KANJI: 272 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 813, Mode.ALPHANUMERIC: 493, Mode.BYTE: 338, Mode.KANJI: 208 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 2061, Mode.ALPHANUMERIC: 1249, Mode.BYTE: 858, Mode.KANJI: 528 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 1600, Mode.ALPHANUMERIC: 970, Mode.BYTE: 666, Mode.KANJI: 410 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 1159, Mode.ALPHANUMERIC: 702, Mode.BYTE: 482, Mode.KANJI: 297 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 919, Mode.ALPHANUMERIC: 557, Mode.BYTE: 382, Mode.KANJI: 235 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 2232, Mode.ALPHANUMERIC: 1352, Mode.BYTE: 929, Mode.KANJI: 572 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 1708, Mode.ALPHANUMERIC: 1035, Mode.BYTE: 711, Mode.KANJI: 438 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 1224, Mode.ALPHANUMERIC: 742, Mode.BYTE: 509, Mode.KANJI: 314 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 969, Mode.ALPHANUMERIC: 587, Mode.BYTE: 403, Mode.KANJI: 248 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 2409, Mode.ALPHANUMERIC: 1460, Mode.BYTE: 1003, Mode.KANJI: 618 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 1872, Mode.ALPHANUMERIC: 1134, Mode.BYTE: 779, Mode.KANJI: 480 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 1358, Mode.ALPHANUMERIC: 823, Mode.BYTE: 565, Mode.KANJI: 348 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1056, Mode.ALPHANUMERIC: 640, Mode.BYTE: 439, Mode.KANJI: 270 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 2620, Mode.ALPHANUMERIC: 1588, Mode.BYTE: 1091, Mode.KANJI: 672 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 2059, Mode.ALPHANUMERIC: 1248, Mode.BYTE: 857, Mode.KANJI: 528 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 1468, Mode.ALPHANUMERIC: 890, Mode.BYTE: 611, Mode.KANJI: 376 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1108, Mode.ALPHANUMERIC: 672, Mode.BYTE: 461, Mode.KANJI: 284 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 2812, Mode.ALPHANUMERIC: 1704, Mode.BYTE: 1171, Mode.KANJI: 721 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 2188, Mode.ALPHANUMERIC: 1326, Mode.BYTE: 911, Mode.KANJI: 561 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 1588, Mode.ALPHANUMERIC: 963, Mode.BYTE: 661, Mode.KANJI: 407 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1228, Mode.ALPHANUMERIC: 744, Mode.BYTE: 511, Mode.KANJI: 315 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 3057, Mode.ALPHANUMERIC: 1853, Mode.BYTE: 1273, Mode.KANJI: 784 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 2395, Mode.ALPHANUMERIC: 1451, Mode.BYTE: 997, Mode.KANJI: 614 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 1718, Mode.ALPHANUMERIC: 1041, Mode.BYTE: 715, Mode.KANJI: 440 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1286, Mode.ALPHANUMERIC: 779, Mode.BYTE: 535, Mode.KANJI: 330 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 3283, Mode.ALPHANUMERIC: 1990, Mode.BYTE: 1367, Mode.KANJI: 842 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 2544, Mode.ALPHANUMERIC: 1542, Mode.BYTE: 1059, Mode.KANJI: 652 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 1804, Mode.ALPHANUMERIC: 1094, Mode.BYTE: 751, Mode.KANJI: 462 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1425, Mode.ALPHANUMERIC: 864, Mode.BYTE: 593, Mode.KANJI: 365 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 3514, Mode.ALPHANUMERIC: 2132, Mode.BYTE: 1465, Mode.KANJI: 902 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 2701, Mode.ALPHANUMERIC: 1637, Mode.BYTE: 1125, Mode.KANJI: 692 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 1933, Mode.ALPHANUMERIC: 1172, Mode.BYTE: 805, Mode.KANJI: 496 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1501, Mode.ALPHANUMERIC: 910, Mode.BYTE: 625, Mode.KANJI: 385 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 3669, Mode.ALPHANUMERIC: 2223, Mode.BYTE: 1528, Mode.KANJI: 940 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 2857, Mode.ALPHANUMERIC: 1732, Mode.BYTE: 1190, Mode.KANJI: 732 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 2085, Mode.ALPHANUMERIC: 1263, Mode.BYTE: 868, Mode.KANJI: 534 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1581, Mode.ALPHANUMERIC: 958, Mode.BYTE: 658, Mode.KANJI: 405 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 3909, Mode.ALPHANUMERIC: 2369, Mode.BYTE: 1628, Mode.KANJI: 1002 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 3035, Mode.ALPHANUMERIC: 1839, Mode.BYTE: 1264, Mode.KANJI: 778 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 2181, Mode.ALPHANUMERIC: 1322, Mode.BYTE: 908, Mode.KANJI: 559 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1677, Mode.ALPHANUMERIC: 1016, Mode.BYTE: 698, Mode.KANJI: 430 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 4158, Mode.ALPHANUMERIC: 2520, Mode.BYTE: 1732, Mode.KANJI: 1066 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 3289, Mode.ALPHANUMERIC: 1994, Mode.BYTE: 1370, Mode.KANJI: 843 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 2358, Mode.ALPHANUMERIC: 1429, Mode.BYTE: 982, Mode.KANJI: 604 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1782, Mode.ALPHANUMERIC: 1080, Mode.BYTE: 742, Mode.KANJI: 457 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 4417, Mode.ALPHANUMERIC: 2677, Mode.BYTE: 1840, Mode.KANJI: 1132 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 3486, Mode.ALPHANUMERIC: 2113, Mode.BYTE: 1452, Mode.KANJI: 894 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 2473, Mode.ALPHANUMERIC: 1499, Mode.BYTE: 1030, Mode.KANJI: 634 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 1897, Mode.ALPHANUMERIC: 1150, Mode.BYTE: 790, Mode.KANJI: 486 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 4686, Mode.ALPHANUMERIC: 2840, Mode.BYTE: 1952, Mode.KANJI: 1201 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 3693, Mode.ALPHANUMERIC: 2238, Mode.BYTE: 1538, Mode.KANJI: 947 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 2670, Mode.ALPHANUMERIC: 1618, Mode.BYTE: 1112, Mode.KANJI: 684 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 2022, Mode.ALPHANUMERIC: 1226, Mode.BYTE: 842, Mode.KANJI: 518 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 4965, Mode.ALPHANUMERIC: 3009, Mode.BYTE: 2068, Mode.KANJI: 1273 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 3909, Mode.ALPHANUMERIC: 2369, Mode.BYTE: 1628, Mode.KANJI: 1002 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 2805, Mode.ALPHANUMERIC: 1700, Mode.BYTE: 1168, Mode.KANJI: 719 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 2157, Mode.ALPHANUMERIC: 1307, Mode.BYTE: 898, Mode.KANJI: 553 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 5253, Mode.ALPHANUMERIC: 3183, Mode.BYTE: 2188, Mode.KANJI: 1347 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 4134, Mode.ALPHANUMERIC: 2506, Mode.BYTE: 1722, Mode.KANJI: 1060 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 2949, Mode.ALPHANUMERIC: 1787, Mode.BYTE: 1228, Mode.KANJI: 756 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 2301, Mode.ALPHANUMERIC: 1394, Mode.BYTE: 958, Mode.KANJI: 590 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 5529, Mode.ALPHANUMERIC: 3351, Mode.BYTE: 2303, Mode.KANJI: 1417 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 4343, Mode.ALPHANUMERIC: 2632, Mode.BYTE: 1809, Mode.KANJI: 1113 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 3081, Mode.ALPHANUMERIC: 1867, Mode.BYTE: 1283, Mode.KANJI: 790 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 2361, Mode.ALPHANUMERIC: 1431, Mode.BYTE: 983, Mode.KANJI: 605 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 5836, Mode.ALPHANUMERIC: 3537, Mode.BYTE: 2431, Mode.KANJI: 1496 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 4588, Mode.ALPHANUMERIC: 2780, Mode.BYTE: 1911, Mode.KANJI: 1176 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 3244, Mode.ALPHANUMERIC: 1966, Mode.BYTE: 1351, Mode.KANJI: 832 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 2524, Mode.ALPHANUMERIC: 1530, Mode.BYTE: 1051, Mode.KANJI: 647 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 6153, Mode.ALPHANUMERIC: 3729, Mode.BYTE: 2563, Mode.KANJI: 1577 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 4775, Mode.ALPHANUMERIC: 2894, Mode.BYTE: 1989, Mode.KANJI: 1224 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 3417, Mode.ALPHANUMERIC: 2071, Mode.BYTE: 1423, Mode.KANJI: 876 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 2625, Mode.ALPHANUMERIC: 1591, Mode.BYTE: 1093, Mode.KANJI: 673 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 6479, Mode.ALPHANUMERIC: 3927, Mode.BYTE: 2699, Mode.KANJI: 1661 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 5039, Mode.ALPHANUMERIC: 3054, Mode.BYTE: 2099, Mode.KANJI: 1292 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 3599, Mode.ALPHANUMERIC: 2181, Mode.BYTE: 1499, Mode.KANJI: 923 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 2735, Mode.ALPHANUMERIC: 1658, Mode.BYTE: 1139, Mode.KANJI: 701 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 6743, Mode.ALPHANUMERIC: 4087, Mode.BYTE: 2809, Mode.KANJI: 1729 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 5313, Mode.ALPHANUMERIC: 3220, Mode.BYTE: 2213, Mode.KANJI: 1362 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 3791, Mode.ALPHANUMERIC: 2298, Mode.BYTE: 1579, Mode.KANJI: 972 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 2927, Mode.ALPHANUMERIC: 1774, Mode.BYTE: 1219, Mode.KANJI: 750 },
    },
    {
        ErrorCorrection.LOW: { Mode.NUMERIC: 7089, Mode.ALPHANUMERIC: 4296, Mode.BYTE: 2953, Mode.KANJI: 1817 },
        ErrorCorrection.MEDIUM: { Mode.NUMERIC: 5596, Mode.ALPHANUMERIC: 3391, Mode.BYTE: 2331, Mode.KANJI: 1435 },
        ErrorCorrection.QUARTILE: { Mode.NUMERIC: 3993, Mode.ALPHANUMERIC: 2420, Mode.BYTE: 1663, Mode.KANJI: 1024 },
        ErrorCorrection.HIGH: { Mode.NUMERIC: 3057, Mode.ALPHANUMERIC: 1852, Mode.BYTE: 1273, Mode.KANJI: 784 }
    },
]

const _ALPHANUMERIC_CHARACTERS: Dictionary = {
    "0" : 0,
    "1" : 1,
    "2" : 2,
    "3" : 3,
    "4" : 4,
    "5" : 5,
    "6" : 6,
    "7" : 7,
    "8" : 8,
    "9" : 9,
    "A" : 10,
    "B" : 11,
    "C" : 12,
    "D" : 13,
    "E" : 14,
    "F" : 15,
    "G" : 16,
    "H" : 17,
    "I" : 18,
    "J" : 19,
    "K" : 20,
    "L" : 21,
    "M" : 22,
    "N" : 23,
    "O" : 24,
    "P" : 25,
    "Q" : 26,
    "R" : 27,
    "S" : 28,
    "T" : 29,
    "U" : 30,
    "V" : 31,
    "W" : 32,
    "X" : 33,
    "Y" : 34,
    "Z" : 35,
    " " : 36,
    "$" : 37,
    "%" : 38,
    "*" : 39,
    "+" : 40,
    "-" : 41,
    "." : 42,
    "/" : 43,
    ":" : 44,
}

## https://www.thonky.com/qr-code-tutorial/error-correction-table
## [total data codewords, EC codewords per block, number of blocks in group 1, number of data codewords in group 1 blocks, number of blocks in group 2, number of data codewords in group 2 blocks]
const _ERROR_CORRECTION: Array = [
    # 1
    {
        ErrorCorrection.LOW: [19, 7, 1, 19, 0, 0],
        ErrorCorrection.MEDIUM: [16, 10, 1, 16, 0, 0],
        ErrorCorrection.QUARTILE: [13, 13, 1, 13, 0, 0],
        ErrorCorrection.HIGH: [9, 17, 1, 9, 0, 0],
    },
    # 2
    {
        ErrorCorrection.LOW: [34, 10, 1, 34, 0, 0],
        ErrorCorrection.MEDIUM: [28, 16, 1, 28, 0, 0],
        ErrorCorrection.QUARTILE: [22, 22, 1, 22, 0, 0],
        ErrorCorrection.HIGH: [16, 28, 1, 16, 0, 0],
    },
    # 3
    {
        ErrorCorrection.LOW: [55, 15, 1, 55, 0, 0],
        ErrorCorrection.MEDIUM: [44, 26, 1, 44, 0, 0],
        ErrorCorrection.QUARTILE: [34, 18, 2, 17, 0, 0],
        ErrorCorrection.HIGH: [26, 22, 2, 13, 0, 0],
    },
    # 4
    {
        ErrorCorrection.LOW: [80, 20, 1, 80, 0, 0],
        ErrorCorrection.MEDIUM: [64, 18, 2, 32, 0, 0],
        ErrorCorrection.QUARTILE: [48, 26, 2, 24, 0, 0],
        ErrorCorrection.HIGH: [36, 16, 4, 9, 0, 0],
    },
    # 5
    {
        ErrorCorrection.LOW: [108, 26, 1, 108, 0, 0],
        ErrorCorrection.MEDIUM: [86, 24, 2, 43, 0, 0],
        ErrorCorrection.QUARTILE: [62, 18, 2, 15, 2, 16],
        ErrorCorrection.HIGH: [46, 22, 2, 11, 2, 12],
    },
    # 6
    {
        ErrorCorrection.LOW: [136, 18, 2, 68, 0, 0],
        ErrorCorrection.MEDIUM: [108, 16, 4, 27, 0, 0],
        ErrorCorrection.QUARTILE: [76, 24, 4, 19, 0, 0],
        ErrorCorrection.HIGH: [60, 28, 4, 15, 0, 0],
    },
    # 7
    {
        ErrorCorrection.LOW: [156, 20, 2, 78, 0, 0],
        ErrorCorrection.MEDIUM: [124, 18, 4, 31, 0, 0],
        ErrorCorrection.QUARTILE: [88, 18, 2, 14, 4, 15],
        ErrorCorrection.HIGH: [66, 26, 4, 13, 1, 14],
    },
    # 8
    {
        ErrorCorrection.LOW: [194, 24, 2, 97, 0, 0],
        ErrorCorrection.MEDIUM: [154, 22, 2, 38, 2, 39],
        ErrorCorrection.QUARTILE: [110, 22, 4, 18, 2, 19],
        ErrorCorrection.HIGH: [86, 26, 4, 14, 2, 15],
    },
    # 9
    {
        ErrorCorrection.LOW: [232, 30, 2, 116, 0, 0],
        ErrorCorrection.MEDIUM: [182, 22, 3, 36, 2, 37],
        ErrorCorrection.QUARTILE: [132, 20, 4, 16, 4, 17],
        ErrorCorrection.HIGH: [100, 24, 4, 12, 4, 13],
    },
    # 10
    {
        ErrorCorrection.LOW: [274, 18, 2, 68, 2, 69],
        ErrorCorrection.MEDIUM: [216, 26, 4, 43, 1, 44],
        ErrorCorrection.QUARTILE: [154, 24, 6, 19, 2, 20],
        ErrorCorrection.HIGH: [122, 28, 6, 15, 2, 16],
    },
    # 11
    {
        ErrorCorrection.LOW: [324, 20, 4, 81, 0, 0],
        ErrorCorrection.MEDIUM: [254, 30, 1, 50, 4, 51],
        ErrorCorrection.QUARTILE: [180, 28, 4, 22, 4, 23],
        ErrorCorrection.HIGH: [140, 24, 3, 12, 8, 13],
    },
    # 12
    {
        ErrorCorrection.LOW: [370, 24, 2, 92, 2, 93],
        ErrorCorrection.MEDIUM: [290, 22, 6, 36, 2, 37],
        ErrorCorrection.QUARTILE: [206, 26, 4, 20, 6, 21],
        ErrorCorrection.HIGH: [158, 28, 7, 14, 4, 15],
    },
    # 13
    {
        ErrorCorrection.LOW: [428, 26, 4, 107, 0, 0],
        ErrorCorrection.MEDIUM: [334, 22, 8, 37, 1, 38],
        ErrorCorrection.QUARTILE: [244, 24, 8, 20, 4, 21],
        ErrorCorrection.HIGH: [180, 22, 12, 11, 4, 12],
    },
    # 14
    {
        ErrorCorrection.LOW: [461, 30, 3, 115, 1, 116],
        ErrorCorrection.MEDIUM: [365, 24, 4, 40, 5, 41],
        ErrorCorrection.QUARTILE: [261, 20, 11, 16, 5, 17],
        ErrorCorrection.HIGH: [197, 24, 11, 12, 5, 13],
    },
    # 15
    {
        ErrorCorrection.LOW: [523, 22, 5, 87, 1, 88],
        ErrorCorrection.MEDIUM: [415, 24, 5, 41, 5, 42],
        ErrorCorrection.QUARTILE: [295, 30, 5, 24, 7, 25],
        ErrorCorrection.HIGH: [223, 24, 11, 12, 7, 13],
    },
    # 16
    {
        ErrorCorrection.LOW: [589, 24, 5, 98, 1, 99],
        ErrorCorrection.MEDIUM: [453, 28, 7, 45, 3, 46],
        ErrorCorrection.QUARTILE: [325, 24, 15, 19, 2, 20],
        ErrorCorrection.HIGH: [253, 30, 3, 15, 13, 16],
    },
    # 17
    {
        ErrorCorrection.LOW: [647, 28, 1, 107, 5, 108],
        ErrorCorrection.MEDIUM: [507, 28, 10, 46, 1, 47],
        ErrorCorrection.QUARTILE: [367, 28, 1, 22, 15, 23],
        ErrorCorrection.HIGH: [283, 28, 2, 14, 17, 15],
    },
    # 18
    {
        ErrorCorrection.LOW: [721, 30, 5, 120, 1, 121],
        ErrorCorrection.MEDIUM: [563, 26, 9, 43, 4, 44],
        ErrorCorrection.QUARTILE: [397, 28, 17, 22, 1, 23],
        ErrorCorrection.HIGH: [313, 28, 2, 14, 19, 15],
    },
    # 19
    {
        ErrorCorrection.LOW: [795, 28, 3, 113, 4, 114],
        ErrorCorrection.MEDIUM: [627, 26, 3, 44, 11, 45],
        ErrorCorrection.QUARTILE: [445, 26, 17, 21, 4, 22],
        ErrorCorrection.HIGH: [341, 26, 9, 13, 16, 14],
    },
    # 20
    {
        ErrorCorrection.LOW: [861, 28, 3, 107, 5, 108],
        ErrorCorrection.MEDIUM: [669, 26, 3, 41, 13, 42],
        ErrorCorrection.QUARTILE: [485, 30, 15, 24, 5, 25],
        ErrorCorrection.HIGH: [385, 28, 15, 15, 10, 16],
    },
    # 21
    {
        ErrorCorrection.LOW: [932, 28, 4, 116, 4, 117],
        ErrorCorrection.MEDIUM: [714, 26, 17, 42, 0, 0],
        ErrorCorrection.QUARTILE: [512, 28, 17, 22, 6, 23],
        ErrorCorrection.HIGH: [406, 30, 19, 16, 6, 17],
    },
    # 22
    {
        ErrorCorrection.LOW: [1006, 28, 2, 111, 7, 112],
        ErrorCorrection.MEDIUM: [782, 28, 17, 46, 0, 0],
        ErrorCorrection.QUARTILE: [568, 30, 7, 24, 16, 25],
        ErrorCorrection.HIGH: [442, 24, 34, 13, 0, 0],
    },
    # 23
    {
        ErrorCorrection.LOW: [1094, 30, 4, 121, 5, 122],
        ErrorCorrection.MEDIUM: [860, 28, 4, 47, 14, 48],
        ErrorCorrection.QUARTILE: [614, 30, 11, 24, 14, 25],
        ErrorCorrection.HIGH: [464, 30, 16, 15, 14, 16],
    },
    # 24
    {
        ErrorCorrection.LOW: [1174, 30, 6, 117, 4, 118],
        ErrorCorrection.MEDIUM: [914, 28, 6, 45, 14, 46],
        ErrorCorrection.QUARTILE: [664, 30, 11, 24, 16, 25],
        ErrorCorrection.HIGH: [514, 30, 30, 16, 2, 17],
    },
    # 25
    {
        ErrorCorrection.LOW: [1276, 26, 8, 106, 4, 107],
        ErrorCorrection.MEDIUM: [1000, 28, 8, 47, 13, 48],
        ErrorCorrection.QUARTILE: [718, 30, 7, 24, 22, 25],
        ErrorCorrection.HIGH: [538, 30, 22, 15, 13, 16],
    },
    # 26
    {
        ErrorCorrection.LOW: [1370, 28, 10, 114, 2, 115],
        ErrorCorrection.MEDIUM: [1062, 28, 19, 46, 4, 47],
        ErrorCorrection.QUARTILE: [754, 28, 28, 22, 6, 23],
        ErrorCorrection.HIGH: [596, 30, 33, 16, 4, 17],
    },
    # 27
    {
        ErrorCorrection.LOW: [1468, 30, 8, 122, 4, 123],
        ErrorCorrection.MEDIUM: [1128, 28, 22, 45, 3, 46],
        ErrorCorrection.QUARTILE: [808, 30, 8, 23, 26, 24],
        ErrorCorrection.HIGH: [628, 30, 12, 15, 28, 16],
    },
    # 28
    {
        ErrorCorrection.LOW: [1531, 30, 3, 117, 10, 118],
        ErrorCorrection.MEDIUM: [1193, 28, 3, 45, 23, 46],
        ErrorCorrection.QUARTILE: [871, 30, 4, 24, 31, 25],
        ErrorCorrection.HIGH: [661, 30, 11, 15, 31, 16],
    },
    # 29
    {
        ErrorCorrection.LOW: [1631, 30, 7, 116, 7, 117],
        ErrorCorrection.MEDIUM: [1267, 28, 21, 45, 7, 46],
        ErrorCorrection.QUARTILE: [911, 30, 1, 23, 37, 24],
        ErrorCorrection.HIGH: [701, 30, 19, 15, 26, 16],
    },
    # 30
    {
        ErrorCorrection.LOW: [1735, 30, 5, 115, 10, 116],
        ErrorCorrection.MEDIUM: [1373, 28, 19, 47, 10, 48],
        ErrorCorrection.QUARTILE: [985, 30, 15, 24, 25, 25],
        ErrorCorrection.HIGH: [745, 30, 23, 15, 25, 16],
    },
    # 31
    {
        ErrorCorrection.LOW: [1843, 30, 13, 115, 3, 116],
        ErrorCorrection.MEDIUM: [1455, 28, 2, 46, 29, 47],
        ErrorCorrection.QUARTILE: [1033, 30, 42, 24, 1, 25],
        ErrorCorrection.HIGH: [793, 30, 23, 15, 28, 16],
    },
    # 32
    {
        ErrorCorrection.LOW: [1955, 30, 17, 115, 0, 0],
        ErrorCorrection.MEDIUM: [1541, 28, 10, 46, 23, 47],
        ErrorCorrection.QUARTILE: [1115, 30, 10, 24, 35, 25],
        ErrorCorrection.HIGH: [845, 30, 19, 15, 35, 16],
    },
    # 33
    {
        ErrorCorrection.LOW: [2071, 30, 17, 115, 1, 116],
        ErrorCorrection.MEDIUM: [1631, 28, 14, 46, 21, 47],
        ErrorCorrection.QUARTILE: [1171, 30, 29, 24, 19, 25],
        ErrorCorrection.HIGH: [901, 30, 11, 15, 46, 16],
    },
    # 34
    {
        ErrorCorrection.LOW: [2191, 30, 13, 115, 6, 116],
        ErrorCorrection.MEDIUM: [1725, 28, 14, 46, 23, 47],
        ErrorCorrection.QUARTILE: [1231, 30, 44, 24, 7, 25],
        ErrorCorrection.HIGH: [961, 30, 59, 16, 1, 17],
    },
    # 35
    {
        ErrorCorrection.LOW: [2306, 30, 12, 121, 7, 122],
        ErrorCorrection.MEDIUM: [1812, 28, 12, 47, 26, 48],
        ErrorCorrection.QUARTILE: [1286, 30, 39, 24, 14, 25],
        ErrorCorrection.HIGH: [986, 30, 22, 15, 41, 16],
    },
    # 36
    {
        ErrorCorrection.LOW: [2434, 30, 6, 121, 14, 122],
        ErrorCorrection.MEDIUM: [1914, 28, 6, 47, 34, 48],
        ErrorCorrection.QUARTILE: [1354, 30, 46, 24, 10, 25],
        ErrorCorrection.HIGH: [1054, 30, 2, 15, 64, 16],
    },
    # 37
    {
        ErrorCorrection.LOW: [2566, 30, 17, 122, 4, 123],
        ErrorCorrection.MEDIUM: [1992, 28, 29, 46, 14, 47],
        ErrorCorrection.QUARTILE: [1426, 30, 49, 24, 10, 25],
        ErrorCorrection.HIGH: [1096, 30, 24, 15, 46, 16],
    },
    # 38
    {
        ErrorCorrection.LOW: [2702, 30, 4, 122, 18, 123],
        ErrorCorrection.MEDIUM: [2102, 28, 13, 46, 32, 47],
        ErrorCorrection.QUARTILE: [1502, 30, 48, 24, 14, 25],
        ErrorCorrection.HIGH: [1142, 30, 42, 15, 32, 16],
    },
    # 39
    {
        ErrorCorrection.LOW: [2812, 30, 20, 117, 4, 118],
        ErrorCorrection.MEDIUM: [2216, 28, 40, 47, 7, 48],
        ErrorCorrection.QUARTILE: [1582, 30, 43, 24, 22, 25],
        ErrorCorrection.HIGH: [1222, 30, 10, 15, 67, 16],
    },
    # 40
    {
        ErrorCorrection.LOW: [2956, 30, 19, 118, 6, 119],
        ErrorCorrection.MEDIUM: [2334, 28, 18, 47, 31, 48],
        ErrorCorrection.QUARTILE: [1666, 30, 34, 24, 34, 25],
        ErrorCorrection.HIGH: [1276, 30, 20, 15, 61, 16],
    },
]

## sorted by version
const _ALIGNMENT_PATTERN_POSITIONS: Array = [
    [],
    [6, 18],
    [6, 22],
    [6, 26],
    [6, 30],
    [6, 34],
    [6, 22, 38],
    [6, 24, 42],
    [6, 26, 46],
    [6, 28, 50],
    [6, 30, 54],
    [6, 32, 58],
    [6, 34, 62],
    [6, 26, 46, 66],
    [6, 26, 48, 70],
    [6, 26, 50, 74],
    [6, 30, 54, 78],
    [6, 30, 56, 82],
    [6, 30, 58, 86],
    [6, 34, 62, 90],
    [6, 28, 50, 72, 94],
    [6, 26, 50, 74, 98],
    [6, 30, 54, 78, 102],
    [6, 28, 54, 80, 106],
    [6, 32, 58, 84, 110],
    [6, 30, 58, 86, 114],
    [6, 34, 62, 90, 118],
    [6, 26, 50, 74, 98, 122],
    [6, 30, 54, 78, 102, 126],
    [6, 26, 52, 78, 104, 130],
    [6, 30, 56, 82, 108, 134],
    [6, 34, 60, 86, 112, 138],
    [6, 30, 58, 86, 114, 142],
    [6, 34, 62, 90, 118, 146],
    [6, 30, 54, 78, 102, 126, 150],
    [6, 24, 50, 76, 102, 128, 154],
    [6, 28, 54, 80, 106, 132, 158],
    [6, 32, 58, 84, 110, 136, 162],
    [6, 26, 54, 82, 110, 138, 166],
    [6, 30, 58, 86, 114, 142, 170],
]

## remainder bits after structured data bits
const _REMAINDER_BITS: Array = [ 0, 7, 7, 7, 7, 7, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4,4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 0, 0, 0, 0, 0, 0 ]

static var _number_rx: RegEx = RegEx.new()
static var _alphanumeric_rx: RegEx = RegEx.new()

## cached qr data
var _cached_qr: PackedByteArray = []

## this can be either a String or PackedByteArray, based on the current encoding mode
var _input_data: Variant = "":
    get = get_input_data
## Encoding Mode
var mode: Mode = Mode.NUMERIC:
    set = set_mode
## Error Correction
var error_correction: ErrorCorrection = ErrorCorrection.LOW:
    set = set_error_correction
## Set to true if you want to specify an ECI value.
var use_eci: bool = false:
    set = set_use_eci
## Extended Channel Interpretation (ECI) Value. Is only used if `use_eci` is true.
var eci_value: int = ECI.ISO_8859_1:
    set = set_eci_value
## Use automatically the smallest version
var auto_version: bool = true:
    set = set_auto_version
## Version
## Will be changed on encoding to the used version if auto_version is true
var version: int = 1:
    set = set_version
var auto_mask_pattern: bool = true:
    set = set_auto_mask_pattern
## Will be changed on encoding to the used mask pattern if auto_mask_pattern is true
var mask_pattern: int = 0:
    set = set_mask_pattern

func set_auto_version(new_auto_version: bool) -> void:
    if new_auto_version == auto_version:
        return
    auto_version = new_auto_version
    self._clear_cache()

func set_version(new_version: int) -> void:
    if new_version == version:
        return
    version = clampi(new_version, 1, 40)
    self._clear_cache()

func set_error_correction(new_error_correction: ErrorCorrection) -> void:
    if new_error_correction == error_correction:
        return
    error_correction = new_error_correction
    self._clear_cache()

func set_mode(new_mode: Mode) -> void:
    if new_mode == mode:
        return
    mode = new_mode

    match mode:
        Mode.NUMERIC, Mode.ALPHANUMERIC, Mode.KANJI:
            self._input_data = ""
        Mode.BYTE:
            self._input_data = PackedByteArray()
    self._clear_cache()

func set_use_eci(new_use_eci: bool) -> void:
    if new_use_eci == use_eci:
        return
    use_eci = new_use_eci
    self._clear_cache()

func set_eci_value(new_eci_value: int) -> void:
    if new_eci_value == eci_value:
        return
    eci_value = new_eci_value
    self._clear_cache()

func set_auto_mask_pattern(new_auto_mask_pattern: bool) -> void:
    if new_auto_mask_pattern == auto_mask_pattern:
        return
    auto_mask_pattern = new_auto_mask_pattern
    self._clear_cache()

func set_mask_pattern(new_mask_pattern: int) -> void:
    if new_mask_pattern == mask_pattern:
        return
    mask_pattern = clampi(new_mask_pattern, 0, 7)
    self._clear_cache()

## return the data which was put in
func get_input_data() -> Variant:
    return _input_data


## get module count of one axis
func get_module_count() -> int:
    return _calc_module_count(self.version)

## returns ONE minimum version which fits the data
## the returned version is just an approach
## returns -1 if too huge
func calc_min_version() -> int:
    var input_size: int = self._get_input_data_size()
    for idx: int in range(_DATA_CAPACITY.size()):
        var cap: int = _DATA_CAPACITY[idx][self.error_correction][self.mode]
        if self.eci_value != ECI.ISO_8859_1:
            # subtract roughly eci header size
            cap -= 4
        if input_size <= cap:
            return idx + 1
    return -1

static func _get_alphanumeric_number(char: String) -> int:
    return _ALPHANUMERIC_CHARACTERS[char]

# functions are adapted to our starting point 0, 0
static func _mask_pattern_fns() -> Array[Callable]:
    return [
        func (pos: Vector2i) -> bool: return (pos.x + pos.y) % 2 == 0,
        func (pos: Vector2i) -> bool: return pos.y % 2 == 0,
        func (pos: Vector2i) -> bool: return pos.x % 3 == 0,
        func (pos: Vector2i) -> bool: return (pos.x + pos.y) % 3 == 0,
        func (pos: Vector2i) -> bool: return (pos.x / 3 + pos.y / 2) % 2 == 0,
        func (pos: Vector2i) -> bool: return (pos.x * pos.y % 2) + (pos.x * pos.y) % 3 == 0,
        func (pos: Vector2i) -> bool: return ((pos.x * pos.y % 2) + (pos.x * pos.y) % 3) % 2 == 0,
        func (pos: Vector2i) -> bool: return (((pos.x + pos.y) % 2) + (pos.x * pos.y) % 3) % 2 == 0,
    ]

# helper function check if a bit is set
static func _get_state(value: int, idx: int) -> bool:
    return (value & (1 << idx))

func _get_data_codeword_count() -> int:
    return _ERROR_CORRECTION[self.version - 1][self.error_correction][0]

func _get_ec_codeword_count() -> int:
    return _ERROR_CORRECTION[self.version - 1][self.error_correction][1]

func _get_ec_block_count(group: int) -> int:
    return _ERROR_CORRECTION[self.version - 1][self.error_correction][2 + (group - 1) * 2]

func _get_ec_block_codeword_count(group: int) -> int:
    return _ERROR_CORRECTION[self.version - 1][self.error_correction][3 + (group - 1) * 2]

static func _calc_module_count(version: int) -> int:
    return 21 + 4 * (version - 1)

func _get_allignment_pattern_positions() -> Array[Vector2i]:
    var module_count: int = self.get_module_count()
    var positions: Array[Vector2i] = []
    for row: int in _ALIGNMENT_PATTERN_POSITIONS[self.version - 1]:
        for col: int in _ALIGNMENT_PATTERN_POSITIONS[self.version - 1]:
            # do not overlap finder positions
            if row - 2 < 8 && col - 2 < 8 || \
                row > module_count - 8 && col - 2 < 8 || \
                row - 2 < 8 && col > module_count - 8:
                continue
            positions.append(Vector2i(row, col))
    return positions

static func _get_remainder_bits(version: int) -> int:
    return _REMAINDER_BITS[version - 1]

func _get_input_data_size() -> int:
    match typeof(self._input_data):
        TYPE_STRING:
            return self._input_data.length()
        TYPE_PACKED_BYTE_ARRAY:
            return self._input_data.size()
    return 0

func _get_char_count_size() -> int:
    if self.version < 10:
        match self.mode:
            Mode.NUMERIC:
                return 10
            Mode.ALPHANUMERIC:
                return 9
            Mode.BYTE:
                return 8
            Mode.KANJI:
                return 8
    elif self.version < 27:
        match self.mode:
            Mode.NUMERIC:
                return 12
            Mode.ALPHANUMERIC:
                return 11
            Mode.BYTE:
                return 16
            Mode.KANJI:
                return 10
    else:
        match self.mode:
            Mode.NUMERIC:
                return 14
            Mode.ALPHANUMERIC:
                return 13
            Mode.BYTE:
                return 16
            Mode.KANJI:
                return 12
    return 0

static func _static_init() -> void:
    # TODO: static init is not called in editor if not @tool
    if _number_rx == null:
        _number_rx = RegEx.new()
    # TODO: static init is not called in editor if not @tool
    if _alphanumeric_rx == null:
        _alphanumeric_rx = RegEx.new()

    _number_rx.compile("[^\\d]*")
    _alphanumeric_rx.compile("[^0-9A-Z $%*+\\-.\\/:]*")

func _init(error_correction_: ErrorCorrection = ErrorCorrection.LOW) -> void:
    self.error_correction = error_correction_

    # TODO: static init is not called in editor if not @tool
    if Engine.is_editor_hint():
        _static_init()

## generate an QR code image
func generate_image(module_px_size: int = 1, light_module_color: Color = Color.WHITE, dark_module_color: Color = Color.BLACK, quiet_zone_size: int = 4) -> Image:
    module_px_size = maxi(1, module_px_size)
    quiet_zone_size = maxi(0, quiet_zone_size)

    var qr_code: PackedByteArray = self.encode()

    var module_count: int = self.get_module_count()
    var image_size: int = (module_count + 2 * quiet_zone_size) * module_px_size
    var image: Image = Image.create(image_size, image_size, false, Image.FORMAT_RGB8)
    image.fill(light_module_color)

    for y: int in range(module_count):
        for x: int in range(module_count):
            var color: Color = Color.PINK
            match qr_code[x + y * module_count]:
                0:
                    color = light_module_color
                1:
                    color = dark_module_color
            for offset_x: int in range(module_px_size):
                for offset_y: int in range(module_px_size):
                    image.set_pixel((x + quiet_zone_size) * module_px_size + offset_x, (y + quiet_zone_size) * module_px_size + offset_y, color)

    return image

func put_numeric(number: String) -> void:
    if self.mode != Mode.NUMERIC || number != self._input_data:
        self._clear_cache()
    self.mode = Mode.NUMERIC
    self._input_data = _number_rx.sub(number, "", true)

func put_alphanumeric(text: String) -> void:
    if self.mode != Mode.ALPHANUMERIC || text != self._input_data:
        self._clear_cache()
    self.mode = Mode.ALPHANUMERIC
    self._input_data = _alphanumeric_rx.sub(text, "", true)

func put_byte(data: PackedByteArray) -> void:
    if self.mode != Mode.BYTE || data != self._input_data:
        self._clear_cache()
    self.mode = Mode.BYTE
    self._input_data = data

func put_kanji(data: String) -> void:
    if self.mode != Mode.KANJI || data != self._input_data:
        self._clear_cache()
    self.mode = Mode.KANJI
    self._input_data = ShiftJIS.get_string_from_shift_jis_2004(ShiftJIS.to_shift_jis_2004_buffer(data))

## returns row by row
## to get row size use get_module_count
func encode() -> PackedByteArray:
    if !self._cached_qr.is_empty():
        return self._cached_qr.duplicate()

    if self.auto_version:
        self.version = self.calc_min_version()

    var data_stream: BitStream = self._encode_data()
    var err_correction: Array = self._error_correction(data_stream)
    var structured_data: BitStream = self._structure_data(data_stream, err_correction)
    var qr_data: PackedByteArray = self._place_modules(structured_data)
    qr_data = self._mask_qr(qr_data)

    self._cached_qr = qr_data.duplicate()

    return qr_data

func _encode_data() -> BitStream:
    var stream: BitStream = BitStream.new()

    # add ECI header
    if self.use_eci:
        stream.append(0b0111, 4)
        if self.eci_value <= 127:
            stream.append(0, 1)
            stream.append(self.eci_value, 7)
        elif self.eci_value <= 16383:
            stream.append(0b10, 2)
            stream.append(self.eci_value, 14)
        else:
            stream.append(0b110, 3)
            stream.append(self.eci_value, 21)

    # add mode
    stream.append(int(self.mode), 4)

    # add character count indicator
    stream.append(self._get_input_data_size(), self._get_char_count_size())

    # add encoded data
    match self.mode:
        Mode.NUMERIC:
            self._encode_numeric(stream)
        Mode.ALPHANUMERIC:
            self._encode_alphanumeric(stream)
        Mode.BYTE:
            self._encode_byte(stream)
        Mode.KANJI:
            self._encode_kanji(stream)

    # add terminator
    var required_bytes: int = self._get_data_codeword_count()
    var terminator_size: int = mini(8 * required_bytes - stream.size(), 4)
    stream.append(0, terminator_size)

    # add bits to multiple of 8
    stream.append(0, (8 - stream.size() % 8) % 8)

    # pad bytes to capacity
    var missing_bytes = required_bytes - stream.size() / 8
    for idx: int in range(missing_bytes):
        if idx % 2 == 0:
            stream.append(236, 8)
        else:
            stream.append(17, 8)

    return stream

func _clear_cache() -> void:
    self._cached_qr.clear()

func _encode_numeric(stream: BitStream) -> void:
    assert(typeof(self._input_data) == TYPE_STRING)
    const GROUP_SIZE: int = 3

    for idx: int in range(ceili(self._input_data.length() / float(GROUP_SIZE))):
        var chars: String = self._input_data.substr(idx * GROUP_SIZE, GROUP_SIZE)
        var number: int = chars.to_int()
        var bit_count: int = 0
        match chars.length():
            3:
                bit_count = 10
            2:
                bit_count = 7
            1:
                bit_count = 4
        stream.append(number, bit_count)

func _encode_alphanumeric(stream: BitStream) -> void:
    assert(typeof(self._input_data) == TYPE_STRING)
    const GROUP_SIZE: int = 2

    for idx: int in range(ceili(self._input_data.length() / float(GROUP_SIZE))):
        var chars: String = self._input_data.substr(idx * GROUP_SIZE, GROUP_SIZE)
        var number: int = _get_alphanumeric_number(chars[0])
        if chars.length() == 2:
            number = 45 * number + _get_alphanumeric_number(chars[1])
            stream.append(number, 11)
        else:
            stream.append(number, 6)

func _encode_byte(stream: BitStream) -> void:
    assert(typeof(self._input_data) == TYPE_PACKED_BYTE_ARRAY)

    for val: int in self._input_data:
        stream.append(val, 8)

func _encode_kanji(stream: BitStream) -> void:
    assert(typeof(self._input_data) == TYPE_STRING)

    var jis_bytes: PackedByteArray = ShiftJIS.to_shift_jis_2004_buffer(self._input_data)
    for idx: int in range(jis_bytes.size() / 2):
        var value = jis_bytes.decode_u16(idx * 2)
        if value >= 0x8140 && value <= 0x9FFC:
            value = value - 0x8140
        elif value >= 0xE040 && value <= 0xEBBF:
            value = value - 0xC140
        value = ((value & 0xFF00) >> 8) * 0xC0 + (value & 0x00FF)
        stream.append(value, 13)

# returns an array of PackedByteArray's, structured as Group, Block [G1B1, G1B2, G1B3, G2B1, G2B2, ...]
func _error_correction(stream: BitStream) -> Array[PackedByteArray]:
    var data: PackedByteArray = stream.to_byte_array()

    var ec_words: int = self._get_ec_codeword_count()
    var group_blocks: PackedByteArray = [
        self._get_ec_block_count(1),
        self._get_ec_block_count(2),
    ]
    var group_codewords: PackedByteArray = [
        self._get_ec_block_codeword_count(1),
        self._get_ec_block_codeword_count(2),
    ]
    var groups: int = 1
    if group_blocks[1] > 0:
        groups += 1

    var err_corr: Array[PackedByteArray] = []
    for group_idx: int in range(groups):
        var block_size: int = group_codewords[group_idx]
        for block_idx: int in range(group_blocks[group_idx]):
            var start_idx: int = 0
            # add offset to current group
            for group_off: int in range(group_idx):
                start_idx += group_blocks[group_off] * group_codewords[group_off]
            start_idx = start_idx + block_idx * block_size
            var cur_data: PackedByteArray = data.slice(start_idx, start_idx + block_size)
            err_corr.append(ReedSolomon.encode(cur_data, ec_words))

    return err_corr

func _structure_data(data_stream: BitStream, err_correction: Array[PackedByteArray]) -> BitStream:
    if err_correction.size() == 1:
        var res: BitStream = data_stream.duplicate()
        res.append_byte_array(err_correction[0])
        # append remainder bits
        res.append(0, _get_remainder_bits(self.version))
        return res

    var res: BitStream = BitStream.new()
    var data_arr: PackedByteArray = data_stream.to_byte_array()
    var group_blocks: PackedByteArray = [
        self._get_ec_block_count(1),
        self._get_ec_block_count(2),
    ]
    var group_codewords: Array[int] = [
        self._get_ec_block_codeword_count(1),
        self._get_ec_block_codeword_count(2),
    ]
    var groups: int = 1
    if group_blocks[1] > 0:
        groups += 1

    # interleave data code words
    var max_code_words: int = group_codewords.max()
    for codeword_idx: int in range(max_code_words):
        for group_idx: int in range(groups):
            # if current group/block has not this much codewords skip
            if codeword_idx >= group_codewords[group_idx]:
                continue
            var group_offset: int = 0
            for group_off: int in range(group_idx):
                group_offset += group_blocks[group_off] * group_codewords[group_off]
            for block_idx: int in range(group_blocks[group_idx]):
                var idx: int = group_offset + codeword_idx + block_idx * group_codewords[group_idx]
                res.append(data_arr[idx], 8)

    # interleave error code words
    for word_idx: int in range(self._get_ec_codeword_count()):
        for block: int in range(err_correction.size()):
            res.append(err_correction[block][word_idx], 8)

    # append remainder bits
    res.append(0, _get_remainder_bits(self.version))

    return res

# pos is upper left black corner
# 7 x 7 size
static func _place_finder(data: PackedByteArray, module_count: int, pos: Vector2i) -> void:
    for row: int in range(7):
        for col: int in range(7):
            data[(pos.x + row) + (pos.y + col) * module_count] = 1
    for idx: int in range(5):
        data[(pos.x + 1 + idx) + (pos.y + 1) * module_count] = 0
        data[(pos.x + 1 + idx) + (pos.y + 5) * module_count] = 0
    for idx: int in range(3):
        data[(pos.x + 1) + (pos.y + 2 + idx) * module_count] = 0
        data[(pos.x + 5) + (pos.y + 2 + idx) * module_count] = 0

# pos is center
# 5 x 5 size
static func _place_align_pattern(data: PackedByteArray, module_count: int, pos: Vector2i) -> void:
    for row: int in range(5):
        for col: int in range(5):
            data[(pos.x - 2 + row) + (pos.y - 2 + col) * module_count] = 1
    for idx: int in range(3):
        data[(pos.x - 1 + idx) + (pos.y - 1) * module_count] = 0
        data[(pos.x - 1 + idx) + (pos.y + 1) * module_count] = 0
    data[(pos.x - 1) + (pos.y) * module_count] = 0
    data[(pos.x + 1) + (pos.y) * module_count] = 0

static func _place_separators(data: PackedByteArray, module_count: int) -> void:
    for idx: int in range(8):
        # upper left
        data[idx + 7 * module_count] = 0
        data[7 + idx * module_count] = 0
        # lower left
        data[idx + (module_count - 8) * module_count] = 0
        data[(module_count - 8) + idx * module_count] = 0
        # upper right
        data[(module_count - idx - 1) + 7 * module_count] = 0
        data[7 + (module_count - idx - 1) * module_count] = 0

static func _place_timing_patterns(data: PackedByteArray, module_count: int) -> void:
    for idx: int in range(module_count - 6 * 2):
        data[6 + idx + 6 * module_count] = (idx + 1) % 2
        data[6 + (6 + idx) * module_count] = (idx + 1) % 2

static func _is_data_module(module_count: int, alignment_pattern_pos: Array[Vector2i], pos: Vector2i) -> bool:
    # finder with separation and format information area: upper left finder, upper right finder, lower left finder
    # dark module is also included
    if (pos.x <= 8 && pos.y <= 8) || (pos.x >= (module_count - 8) && pos.y <= 8) || (pos.x <= 8 && pos.y >= (module_count - 8)):
        return false
    # timing pattern
    if pos.x == 6 || pos.y == 6:
        return false
    # version information area
    # for version >= 7, upper and lower
    # this check, will also success if it is in a finder area
    if module_count >= 45 && ((pos.x >= module_count - 11 && pos.y <= 5) || (pos.x <= 5 && pos.y >= module_count - 11)):
        return false

    # check if in alignment pattern
    for align_pos: Vector2i in alignment_pattern_pos:
        if pos.x >= align_pos.x - 2 && pos.x <= align_pos.x + 2 && pos.y >= align_pos.y - 2 && pos.y <= align_pos.y + 2:
            return false

    return true

static func _place_data(data: PackedByteArray, module_count: int, alignment_pattern_pos: Array[Vector2i], structured_data: BitStream) -> void:
    var data_idx: int = 0
    # base column where to go up or down
    var base_col: int = module_count - 1
    var upwards: bool = true

    while base_col > 0:
        # skip vertical timing pattern
        if base_col == 6:
            base_col -= 1

        for row: int in range(module_count):
            if upwards:
                row = module_count - 1 - row
            for offset: int in range(2):
                var pos: Vector2i = Vector2i(base_col - offset, row)
                if _is_data_module(module_count, alignment_pattern_pos, pos):
                    data[pos.x + pos.y * module_count] = int(structured_data.get_bit(data_idx))
                    data_idx += 1

        base_col -= 2
        upwards = !upwards

    # all data modules placed
    assert(data_idx == structured_data.size(), "failed to place all data (%d of %d)" % [data_idx, structured_data.size()])

static func _calc_mask_rating(data: PackedByteArray, module_count: int) -> int:
    var rating: int = 0

    # condition 1
    # horizontal
    for y: int in range(module_count):
        var count: int = 0
        var block_value: int = 0
        for x: int in range(module_count):
            var cur_value: int = data[x + y * module_count]
            if cur_value == block_value:
                count += 1
            else:
                if count >= 5:
                    rating += count - 2
                count = 1
                block_value = cur_value
        if count >= 5:
            rating += count - 2
    # vertical
    for x: int in range(module_count):
        var count: int = 0
        var block_value: int = 0
        for y: int in range(module_count):
            var cur_value: int = data[x + y * module_count]
            if cur_value == block_value:
                count += 1
            else:
                if count >= 5:
                    rating += count - 2
                count = 1
                block_value = cur_value
        if count >= 5:
            rating += count - 2

    # condition 2
    for x: int in range(module_count - 1):
        for y: int in range(module_count - 1):
            var val: int = data[x + y * module_count] + data[x + 1 + y * module_count] + data[x + (y + 1) * module_count] + data[x + 1 + (y + 1) * module_count]
            if val == 0 or val == 4:
                rating += 3

    # condition 3
    for y: int in range(module_count):
        for x: int in range(module_count - 6):
            var start_idx: int = x + y * module_count
            if (!data[start_idx]
                && data[start_idx + 1]
                && !data[start_idx + 2]
                && !data[start_idx + 3]
                && !data[start_idx + 4]
                && data[start_idx + 5]
                && !data[start_idx + 6]):
                    if x >= 4 && data[start_idx - 1] && data[start_idx - 2] && data[start_idx - 3] && data[start_idx - 4]:
                        rating += 40
                    if x <= (module_count - 10) && data[start_idx + 7] && data[start_idx + 8] && data[start_idx + 9] && data[start_idx + 10]:
                        rating += 40

    for x: int in range(module_count):
        for y: int in range(module_count - 6):
            if (!data[x + y * module_count]
                && data[x + (y + 1) * module_count]
                && !data[x + (y + 2) * module_count]
                && !data[x + (y + 3) * module_count]
                && !data[x + (y + 4) * module_count]
                && data[x + (y + 5) * module_count]
                && !data[x + (y + 6) * module_count]):
                    if y >= 4 && data[x + (y - 1) * module_count] && data[x + (y - 2) * module_count] && data[x + (y - 3) * module_count] && data[x + (y - 4) * module_count]:
                        rating += 40
                    if y <= (module_count - 11) && data[x + (y + 7) * module_count] && data[x + (y + 8) * module_count] && data[x + (y + 9) * module_count] && data[x + (y + 10) * module_count]:
                        rating += 40

    # condition 4
    var dark_mods: int = data.count(0)
    var ratio: float = dark_mods / float(module_count * module_count)
    var percent: int = int((ratio * 100) - 50)
    rating += absi(percent) / 5 * 10
    return rating

static func _place_format(qr_data: PackedByteArray, module_count: int, error_corr: ErrorCorrection, mask_pattern_val: int) -> void:
    var base_code: int = (int(error_corr) << 3) | mask_pattern_val

    var code: int = base_code
    for _idx: int in range(10):
        code = (code << 1) ^ ((code >> 9) * 0x537)
    code = (base_code << 10 | code) ^ 0x5412

    # upper left finder
    for idx: int in range(8):
        # skip timing pattern
        var pos: int = idx
        if idx > 5:
            pos += 1
        # horizontal
        qr_data[pos + 8 * module_count] = int(_get_state(code, 14 - idx))
        # vertical
        qr_data[8 + pos * module_count] = int(_get_state(code, idx))
    # lower left finder
    for idx: int in range(7):
        qr_data[8 + (module_count - 1 - idx) * module_count] = int(_get_state(code, 14 - idx))
    # upper right finder
    for idx: int in range(8):
        qr_data[(module_count - 1 - idx) + 8 * module_count] = int(_get_state(code, idx))

static func _place_version(qr_data: PackedByteArray, version: int) -> void:
    if version < 7:
        return

    var code: int = version
    for _idx: int in range(12):
        code = (code << 1) ^ ((code >> 11) * 0x1F25)
    code = version << 12 | code

    var module_count: int = _calc_module_count(version)
    for idx: int in range(18):
        var x: int = idx / 3
        var y: int = module_count - 11 + idx % 3
        qr_data[x + y * module_count] = int(_get_state(code, idx))
        qr_data[y + x * module_count] = int(_get_state(code, idx))

# returns qr module data, ordered by rows
# (col/x, row/y)       | index
# (0, 0) (1, 0) (2, 0) | 0, 1, 2
# (0, 1) (1, 1) (2, 1) | 3, 4, 5
# (0, 2) (1, 2) (2, 2) | 6, 7, 8
func _place_modules(structured_data: BitStream) -> PackedByteArray:
    var qr_data: PackedByteArray = PackedByteArray()
    var module_count: int = self.get_module_count()
    qr_data.resize(module_count * module_count)

    # place upper left finder
    _place_finder(qr_data, module_count, Vector2i(0, 0))
    # place lower left finder
    _place_finder(qr_data, module_count, Vector2i(0, module_count - 7))
    # place upper right finder
    _place_finder(qr_data, module_count, Vector2i(module_count - 7, 0))
    _place_separators(qr_data, module_count)

    var alignment_pattern_pos: Array[Vector2i] = self._get_allignment_pattern_positions()
    for pos: Vector2i in alignment_pattern_pos:
        _place_align_pattern(qr_data, module_count, pos)

    _place_timing_patterns(qr_data, module_count)

    # dark module
    qr_data[8 + (module_count - 8) * module_count] = 1

    # place data
    _place_data(qr_data, module_count, alignment_pattern_pos, structured_data)

    return qr_data

static func _mask(qr_data: PackedByteArray, module_count: int, alignment_pattern_pos: Array[Vector2i], mask_pattern: int) -> void:
    var mask_fn: Callable = _mask_pattern_fns()[mask_pattern]

    for x: int in range(module_count):
        for y: int in range(module_count):
            var pos: Vector2i = Vector2i(x, y)
            if _is_data_module(module_count, alignment_pattern_pos, pos):
                var idx: int = x + y * module_count
                qr_data[idx] = int(mask_fn.call(pos)) ^ qr_data[idx]

# return mask pattern number
func _get_best_qr_mask(masked_qrs: Array[PackedByteArray], module_count: int) -> int:
    var min_idx: int = 0
    # integer max
    var cur_min_value: int = 9223372036854775807
    for idx: int in range(masked_qrs.size()):
        var rating: int = _calc_mask_rating(masked_qrs[idx], module_count)
        if rating < cur_min_value:
            min_idx = idx
            cur_min_value = rating

    return min_idx

func _mask_qr(qr_data: PackedByteArray) -> PackedByteArray:
    var module_count: int = self.get_module_count()
    var alignment_pattern_pos: Array[Vector2i] = self._get_allignment_pattern_positions()

    # apply mask pattern
    if !self.auto_mask_pattern:
        _mask(qr_data, module_count, alignment_pattern_pos, self.mask_pattern)
        _place_format(qr_data, module_count, self.error_correction, self.mask_pattern)
        _place_version(qr_data, self.version)

        return qr_data

    # get best mask pattern
    var masked_qr: Array[PackedByteArray] = []
    var mask_fns: Array[Callable] = _mask_pattern_fns()

    for pattern_idx: int in range(mask_fns.size()):
        var cur_qr: PackedByteArray = qr_data.duplicate()
        _mask(cur_qr, module_count, alignment_pattern_pos, pattern_idx)
        # normally the format version is applied AFTER getting the best pattern, but will produce worse qr codes
        _place_format(cur_qr, module_count, self.error_correction, pattern_idx)
        _place_version(cur_qr, self.version)
        masked_qr.append(cur_qr)
    var best_mask: int = _get_best_qr_mask(masked_qr, module_count)
    self.mask_pattern = best_mask
    qr_data = masked_qr[best_mask]

    return qr_data

#### DEVEL TOOLS

static func _print_qr(data: PackedByteArray, module_count: int) -> void:
    for y: int in range(module_count):
        var row: String = ""
        for x: int in range(module_count):
            var value: int = data[y * module_count + x]
            match value:
                0:
                    row += "⬜"
                1:
                    row += "⬛"
                2:
                    row += "🟨"
                3:
                    row += "🟦"
                _:
                    row += "🟥"
        print(row)

static func _bin_to_string(value: int, bits: int = 8) -> String:
    var val: String = ""
    for idx: int in range(bits):
        if idx % 4 == 0:
            val = " " + val
        val = str(int(bool(value & (1 << idx)))) + val
    return val.strip_edges()

static func _arr_to_string(arr: PackedByteArray) -> String:
    var val: String = ""
    for byte: int in arr:
        val += "[" + _bin_to_string(byte, 8) + "] "
    return val.strip_edges()
