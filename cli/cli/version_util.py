def compareVersion(va: str, vb: str) -> int:
    if va is None or vb is None:
        raise Exception('version parameter can not be None')
    va_link = va.split('.')
    vb_link = vb.split('.')

    a_index = 0
    b_index = 0
    while a_index < len(va) - 1 and b_index < len(vb) - 1:
        cur_a = int(va_link[a_index])
        cur_b = int(vb_link[b_index])
        if cur_a > cur_b:
            return 1
        if cur_b > cur_a:
            return -1
        a_index += 1
        b_index += 1

    left = None
    factor = 1
    if a_index < len(va) - 1:
        left = va_link[a_index - 1:]
    if b_index < len(vb) - 1:
        left = vb_link[b_index - 1:]
        factor = -1

    if left:
        for i in left:
            if i != '0':
                return factor
    return 0
