import os
import io
import shutil
import sys
import zipfile

pkgdir = '/tmp/sls-py-req'
tempdir = '/tmp/_temp-sls-py-req'
requirements_zipname = '.requirements.zip'

sys.path.append(pkgdir)

if not os.path.exists(pkgdir):
    if os.path.exists(tempdir):
        shutil.rmtree(tempdir)

    default_layer_root = '/opt'
    lambda_root = os.getcwd() if os.environ.get('IS_LOCAL') == 'true' else default_layer_root
    zip_requirements = os.path.join(lambda_root, requirements_zipname)
    
    # extract zipfile in memory to /tmp dir
    print("Extracting requirements zipfile")
    zipfile.ZipFile(zip_requirements).extractall(tempdir)
    os.rename(tempdir, pkgdir)  # Atomic