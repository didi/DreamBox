import os

pic_type = [
    'jpg',
    'jpeg',
    'png',
    'webp'
]


def make_count():
    text_total = 0
    pic_total = 0
    g = os.walk('./docs')
    for path, dir_list, file_list in g:
        for file_name in file_list:
            if file_name.endswith('.md'):
                full_path = path + '/' + file_name
                with open(full_path, mode='r', encoding='utf-8') as mk:
                    text_c = 0
                    pic_c = 0
                    for line in mk.readlines():
                        text_c += len(line)
                        for pt in pic_type:
                            if str(line).lower().find(pt) != -1:
                                pic_c += 1
                    print(full_path, ' >>> ', pic_c, ' >>> ', text_c)
                    text_total += text_c
                    pic_total += pic_c

    print('total:\n', 'pic:', pic_total, '\n', 'text:', text_total)


if __name__ == '__main__':
    make_count()
