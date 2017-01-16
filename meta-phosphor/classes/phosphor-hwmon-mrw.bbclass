#Common code to generate the hwmon conf files from the MRW.
#Can be pulled in on a per system basis.

DEPENDS += "mrw-perl-tools-native mrw-native"

do_compile_append() {
    ${STAGING_BINDIR_NATIVE}/perl-native/perl \
        ${STAGING_BINDIR_NATIVE}/hwmon.pl \
        -x ${STAGING_DATADIR_NATIVE}/obmc-mrw/${MACHINE}.xml
}

def find_conf_files():
    from fnmatch import fnmatch
    myfiles = []

    #These conf files generated by hwmon.pl are in
    #subdirectories which we need to preserve the path to.
    for root, dirs, files in os.walk("./"):
        for name in files:
            if fnmatch(name, "*.conf"):
                myfiles.append(os.path.join(root, name))

    return  myfiles

python install_conf_files() {
    from shutil import copy

    files = find_conf_files()

    install_dir = os.path.join(d.getVar("D", True),
                               "etc", "default", "obmc", "hwmon")
    for f in files:
        dest = os.path.join(install_dir, f)
        parent = os.path.dirname(dest)
        if not os.path.exists(parent):
            os.makedirs(parent)

        copy(f, dest)
}

do_install[postfuncs] += "install_conf_files"
