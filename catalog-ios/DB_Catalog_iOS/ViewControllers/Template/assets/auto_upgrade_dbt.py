# keep dbt file in assets & excute script as:
# python3.8 auto_upgrade_dbt.py

import os
from shutil import copyfile
import hashlib
from functools import partial


def file_md5(path):
    with open(path, mode='rb') as f:
        d = hashlib.md5()
        for buf in iter(partial(f.read, 128), b''):
            d.update(buf)
        return d.hexdigest()


def check_dmb_cli_exist():
    code = os.system('dmb-cli -v')
    if code == 0:
        print('CLI has been installed.')
        return True
    print(f'error occurs: {code}')
    return False


def get_all_origin_dbt():
    g = os.walk('.')
    dbt_list = {}
    source_dsl = {}
    origin_xmls = {}
    # find origin DSL xml
    for path, dir_list, file_list in g:
        for f in file_list:
            file_path = path+'/'+f
            if 'android' in file_path and 'intermediates' in file_path:
                continue
            if 'cli' in file_path:
                continue
            if f.endswith('.xml'):
                hit = False
                with open(file_path, mode='r', encoding='utf-8') as raw_xml:
                    first_line = True
                    for l in raw_xml.readlines():
                        if first_line and l.startswith('<dbl'):
                            hit = True
                            break
                if hit:
                    # print(f'Hit DSL at {file_path}')
                    raw_name = f[:len(f)-4]
                    source_dsl[raw_name] = file_path
                    origin_xmls[file_path] = raw_name
    # print(raw_dsl_names)
    # check whether the xmls in the same key got one md5
    for file_path in origin_xmls:
        a_key = origin_xmls[file_path]
        for inter_file_path in origin_xmls:
            if origin_xmls[inter_file_path] == a_key:
                a_md5 = file_md5(file_path)
                b_md5 = file_md5(inter_file_path)
                if a_md5 != b_md5:
                    # raise Exception(f'MD5 not match.\n {file_path}\n vs \n{inter_file_path}')
                    print(f'MD5 not match.\n {file_path}\n vs \n{inter_file_path}')
    
    # second to find the dbt file to be replace
    sg = os.walk('.')
    for path, dir_list, file_list in sg:
        for f in file_list:
            file_path = path+'/'+f
            if f.endswith('.dbt'):
                for raw in source_dsl:
                    if f == f'local.{raw}.dbt':
                        dbt_list[file_path] = raw

    print(f'--------------{len(dbt_list)}---------------------------')
    for k in dbt_list:
        print(f'{k} --->>> {dbt_list[k]}')

    print(f'--------------{len(source_dsl)}---------------------------')

    for k in source_dsl:
        print(f'{k} --->>> {source_dsl[k]}')

    re_compile(source_dsl, dbt_list)


def re_compile(source_dsl, target_path):
    tmp_dbt = 'tmp_dbt_file'
    try:
        for source in source_dsl:
            cmd = f'dmb-cli --onlystr {source_dsl[source]} > {tmp_dbt}'
            print(f'run: {cmd}')
            code = os.system(cmd)
            if code != 0:
                raise Exception('Build error, please make it right.')
            for t in target_path:
                source_key = target_path[t]
                if source_key == source:
                    copyfile(tmp_dbt, t)
                    # print(f'going to copy to {t}')
    finally:
        os.remove(tmp_dbt)


if __name__ == "__main__":
    if not check_dmb_cli_exist():
        print('Please check whether CLI installed.')
        exit(-1)
    get_all_origin_dbt()
