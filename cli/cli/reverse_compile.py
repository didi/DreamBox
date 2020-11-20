import logging
import base64


def reverse(file_path):
    logging.debug(f'reverse compile {file_path}')
    with open(file_path, mode='rb') as f:
        base64_bytes = base64.b64decode(f.read())
        raw_json = str(base64_bytes[42:], encoding='utf-8')
        print(raw_json.encode('utf-8').decode('unicode-escape'))
