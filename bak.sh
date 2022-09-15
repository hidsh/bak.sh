#!/bin/sh
#
# Filename: bak.sh
# Last modified: Sat Jul 24 2004 19:21:58 LMT
#
# description:
#   backup a file to FILE.bak or FILE.orig
#   also revert from FILE.bak or FILE.orig
#
#   this script also allows to backup directories.
#
# install:
#   1) put this script into where you like
#     $ cp bak.sh ~/sh/
#   2) create sym-link
#     $ ln -s ~/sh/bak.sh ~/bin/bak
#
# usage:
#        bak [-b|-o] FILE
#        bak [-r|-fr] [FILE.bak|FILE.orig]
#
# options:
#          -b  backup to .bak   (default)
#          -o  backup to .orig
#          -r  revert from .bak or .orig
#          -fr force revert

################## FUNCTIONS ###################################
# error process
error()
{
    echo "USAGE: `basename $0` [-b|-o] file"
    echo "       `basename $0` [-r|-fr] [file.bak|file.orig]"
    echo "  Backup a file to FILE.bak or FILE.orig"
    echo "  Revert a file from FILE.bak or FILE.orig"
    echo ""
    echo "  -b    backup to .bak   (default)"
    echo "  -o    backup to .orig"
    echo "  -r    revert from .bak or .orig"
    echo "  -fr   force revert"
    echo ""
    exit 1;
}

# backup to .bak or .orig
backup()
{
    FILENAME=$DISTDIR"/"$FILENAME

    # if bak-file is already existed, added inclemental suffix.
    i=0
    tmp=$EXT
    while [ -e $FILENAME$EXT ]; do
	i=`expr $i + 1`
	EXT=`echo $tmp$i`
    done

    # backup process
    cp $CPOPT $FILENAME $FILENAME$EXT
    if [ $? -ne 0 ]; then
        echo "  Error occured.";
        exit 1;
    fi

    echo "  Backed up: $FILENAME -> $FILENAME$EXT"
}

# revert from .bak or .orig
revert()
{
    # is not extension .bak or .orig? do nothing and exit
    if [ ! `echo $EXT | grep "^.bak"` ] && [ ! `echo $EXT | grep "^.orig"` ]; then
	EXT=""
    fi
    [ -z $EXT ] && { echo "  $FILENAME is not a backup."; exit 1; }

    FILENAME=$DISTDIR"/"$FILENAME
    DISTNAME=$DISTDIR"/"`basename $FILENAME $EXT`

    # .bak or .orig exists already? do nothing and exit
    if [ $OPT = "-r" ] && [ -e $DISTNAME ]; then
	echo "  $DISTNAME already exists."
	echo "  if you want to FORCE revert, you can use \"-fr\" option."
	exit 1
    fi

    # revert process
    if cp $COPT $FILENAME $DISTNAME; then
	echo "  revert: $FILENAME -> $DISTNAME"
    #rm $FILENAME
    else { echo "  error occured."; exit 1; }
    fi
}

# return last extension of filename
get_ext()
{
    echo "."${1##*.}
}

################## FUNCTIONS END ###############################

################## MAIN ########################################
# check requirements(external programs)
EXTPGM=""
for loop in $EXTPGM; do
    path=`which $loop`
    [ -z $path ] && { echo "\"$loop\" is not found."; exit 1; }
    [ -x $path ] || { echo "\"$loop\" is not executable."; exit 1; }
done

# should be 1<=args<=2, otherwise error
[ $# -lt 1 ] || [ $# -gt 2 ] && error

# case of args=1, it should be a file name or directory name. otherwise error
if [ $# -eq 1 ]; then
    arg=$1
    echo $arg
    if [ $arg == '.' ]; then
        FILENAME=`basename \`pwd $arg\``
        cd ..
    else
        [ `echo $arg | grep '^-'` ] && error || FILENAME=$arg
    fi
fi

# case of args=2, get option and filename
if [ $# -eq 2 ]; then
    [ `echo $1 | grep '^-'` ] && OPT=$1 || error
    [ `echo $2 | grep '^-'` ] && error || FILENAME=`echo $2 | sed 's/\/$//'`
fi

# validate filename and distination-directory
[ -z $FILENAME ] && { echo "  file-name is not specified."; exit 1; }
[ -e $FILENAME ] || { echo "  \"$FILENAME\" is not found."; exit 1; }
[ -L $FILENAME ] && { echo "  \"$FILENAME\" is a symlink."; exit 1; }

DISTDIR=`dirname $FILENAME`
[ -w $DISTDIR ] || { echo "  \"$DISTDIR\" is not writable."; exit 1; }
[ -d $FILENAME ] && {
    CPOPT="-a"
    # remove last slash(/)
    FILENAME=`echo $FILENAME | sed 's/\/$//g'`
}

# do backup or revert according to options
if [ -z $OPT ] || [ $OPT = "-b" ]; then { EXT=".bak"; backup; }
elif [ $OPT = "-o" ]; then { EXT=".orig"; backup; }
elif [ $OPT = "-r" ] || [ $OPT = "-fr" ]; then
    EXT=`get_ext $FILENAME`
    revert
else { echo "  invalid ption. use [-b|-o|-r|-fr]."; exit 1; }
fi

################## MAIN END ####################################

################## bak.sh ends here ############################
