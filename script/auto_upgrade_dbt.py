import os
from shutil import copyfile


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
    # find origin DSL xml
    for path, dir_list, file_list in g:
        for f in file_list:
            file_path = path+'/'+f
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
    # print(raw_dsl_names)
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
