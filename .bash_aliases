
export PATH=~/bin:$PATH
export USE_CCACHE=1

alias start-cm-13.0="export CM_WHICH=cm-13.0 CM_SRC=~/cyanogen && export C=~/cyanogen && cd ~/cyanogen"

start-cm-13.0

if [ -x "/usr/bin/make-3.81" ]; then
   export CM_MAKE=/usr/bin/make-3.81
else
   export CM_MAKE=make
fi

make_j_arg() {
  ncores=`cat /proc/cpuinfo  | grep 'processor[[:space:]]*:' | wc -l`
  echo "-j`expr $ncores '*' 2`"
}

export MAKEFLAGS="`make_j_arg`"

sync-cm() {
(
  cd $CM_SRC &&
  (
    echo "---- FETCHING -----" &&
    repo sync -n $* &&
    echo "----- SYNCING SOURCE ------" &&
    repo sync -l $*
  )2>&1 | tee /tmp/sync.txt
  cp /tmp/sync.txt ~/syncs-$CM_WHICH/`date +%Y%m%dT%H%M%S`
)
}

run_make() {
  if [ -d /cm-tmp/ ]; then
    export TMPDIR=/cm-tmp
  fi
  export MAKE="$CM_MAKE"
  export CCACHE_BASEDIR="$OUT"
  time $CM_MAKE `make_j_arg` $*
  ncores=`cat /proc/cpuinfo  | grep 'processor[[:space:]]*:' | wc -l`
}
