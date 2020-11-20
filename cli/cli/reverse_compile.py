import logging
import base64
import json


def reverse(file_path):
    logging.debug(f'reverse compile {file_path}')
    with open(file_path, mode='rb') as f:
        base64_bytes = base64.b64decode(f.read())
        raw_json = str(base64_bytes[42:], encoding='utf-8').encode('utf-8').decode('unicode-escape')
    if raw_json is None:
        raise Exception('错误的反解析过程，请检查输入文件中是否包含DB的渲染模板数据')
    json_obj = json.loads(raw_json)
    ret = raw_json
    if 'map' in json_obj:
        proguard_key = json_obj['map']
        del json_obj['map']
        origin_obj = traversal_json_dict_with_map(proguard_key, json_obj)
        ret = json.dumps(origin_obj)
    print(ret)


def traversal_json_dict_with_map(map, obj):
    if type(obj) is dict:
        ret_dict = {}
        for k in obj:
            v = obj[k]
            if type(v) is dict:
                ret_dict[map[k] if k in map else k] = traversal_json_dict_with_map(map, v)
            elif type(v) is list:
                ret_dict[map[k] if k in map else k] = traversal_json_dict_with_map(map, v)
            else:
                ret_dict[map[k] if k in map else k] = v
    elif type(obj) is list:
        ret_dict = []
        for v in obj:
            if type(v) is dict:
                ret_dict.append(traversal_json_dict_with_map(map, v))
            else:
                ret_dict.append(v)
    else:
        raise Exception('UNLIKELY')
    return ret_dict
