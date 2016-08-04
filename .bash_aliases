
export PATH=~/bin:$PATH
export USE_CCACHE=1

export PATH=~/Documents/x86_64-GCC-6.1.0-android-toolchain/bin:$PATH

alias start-cm-13.0="export CM_WHICH=cm-13.0 CM_SRC=~/cyanogen && export C=~/cyanogen && cd ~/cyanogen"
alias start-rr-13.0="export RR_WHICH=rr-13.0 RR_SRC=~/resurrection/rr-13.0 && export C=~/resurrection/rr-13.0 && cd ~/resurrection/rr-13.0"


if [ -x "/usr/bin/make-3.81" ]; then
   export CM_MAKE=/usr/bin/make-3.81
else
   export CM_MAKE=make
fi


make_j_arg() {
  ncores=`cat /proc/cpuinfo  | grep 'processor[[:space:]]*:' | wc -l`
  echo "-j`expr $ncores`"
}

export MAKEFLAGS="`make_j_arg`"

sync-cm() {
(
  start-cm-13.0 &&
  cd $CM_SRC &&
  (
    echo "---- FETCHING -----" &&
    repo sync -n $* &&
    echo "----- SYNCING SOURCE ------" &&
    repo sync -l $*
  )2>&1 | tee /tmp/sync.txt
  cp /tmp/sync.txt $CM_SRC/syncs-$CM_WHICH-`date +%Y%m%dT%H%M%S`.txt
)
}

sync-rr() {
(
  start-rr-13.0 &&
  cd $RR_SRC &&
  (
    echo "---- FETCHING -----" &&
    repo sync -n $* &&
    echo "----- SYNCING SOURCE ------" &&
    repo sync -l $*
  )2>&1 | tee /tmp/sync.txt
  cp /tmp/sync.txt $RR_SRC/syncs-$RR_WHICH-`date +%Y%m%dT%H%M%S`.txt
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

build-cm() {
(
  if [ "$2" = "" ]; then
     target="$1"
  else
     target="$2"
  fi

  cd $CM_SRC && \
  . ./build/envsetup.sh && \
  breakfast $target && \
  run_make bacon  \
  
) 2>&1 | tee /tmp/build-$1.txt

}


build-rr() {
(
  if [ "$2" = "" ]; then
     target="$1"
  else
     target="$2"
  fi

  cd $RR_SRC && \
  . ./build/envsetup.sh && \
  breakfast $target && \
  run_make bacon  \
  
) 2>&1 | tee /tmp/build-$1.txt

}

build-cm-boot() {
(
  . ./build/envsetup.sh && \
  breakfast $1 && \
  run_make bootimage && \ \
) 2>&1 | tee /tmp/build-boot-$1.txt
cp /tmp/build-boot-$1.txt $CM_SRC/boot-$CM_WHICH-`date +%Y%m%dT%H%M%S`.txt
}


build-rr-boot() {
(
  . ./build/envsetup.sh && \
  breakfast $1 && \
  run_make bootimage && \ \
) 2>&1 | tee /tmp/build-boot-$1.txt
cp /tmp/build-boot-$1.txt $CM_SRC/boot-$CM_WHICH-`date +%Y%m%dT%H%M%S`.txt
}

clean-cm() {
(
  #export OUT_DIR_COMMON_BASE=/out/$1 && \
  #cd $CM_SRC && \
  . ./build/envsetup.sh && \
  run_make clean
)
}

# -------------------------

alias build-Z008='build-cm Z008'
alias build-Z008-eng='build-cm Z008 cm_Z008-eng'
alias build-Z008-boot='build-cm-boot Z008'

alias build-rr-Z00A='build-rr Z00A'
alias build-Z00A-eng='build-rr Z00A cm_Z00A-eng'
alias build-Z00A-boot='build-rr-boot Z00A'

alias build-Z00A='build-cm Z00A'
alias build-Z00A-eng='build-cm Z00A cm_Z00A-eng'
alias build-Z00A-boot='build-cm-boot Z00A'
