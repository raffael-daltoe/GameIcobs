INSTALL_ROOT=${PWD}

sudo apt-get update

sudo apt-get install \
    make git gcc autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev \
    libgmp-dev gawk build-essential bison flex texinfo gperf libtool \
    patchutils bc zlib1g-dev libexpat-dev nodejs

if [ ! -d riscv-gnu-toolchain ]; then
    git clone https://github.com/riscv/riscv-gnu-toolchain
fi
if [ ! -d compiler ]; then

    echo "#################################################"
    echo "#                                               #"
    echo "#  GO GRAB SOME COFFEE, THIS WILL TAKE A WHILE  #"
    echo "#                                               #"
    echo "#################################################"
    echo ""
    echo "       ,.-:::///+++++//:."
    echo "   .///:-..---://+00SSYYHDHS+-"
    echo " :Y+.\`\`\`\`\`\`\`\`\`..---:/+0SYYYYHHHO."
    echo "/D-\`\`\`                  \`-:+SYSYM:"
    echo "DM.\`                         -//MH:-.."
    echo "DNMO.                         :HDOHMNNNMYO-"
    echo "DMNNNDS/-\`                -/SYS/-.\`-:++OYHMMS."
    echo "HMMNNNNNNNMDHYSS0000SSSSSS+:.\`..-+\`\`\`\`\`..-:/+S+"
    echo "HMMNNNMMMMMDDDHYYSO+/:--....\`...-+         :0/:/"
    echo "HMMNNMMMMMMDDHHYSO++/:--.......--/          -SO--"
    echo "YMMMNMMMMMMDDHHYSSO+/::--......--/          .YY0-"
    echo "YMMMMMMMMMMDDH     +/::--.....---/          /YYS-"
    echo "SMMMMMMMMMMDDH  L  +//:---....---/         /SYY0-"
    echo "OMMMMMMMMMMDDH  I  ++/::----.----:       ./+YSS:\`"
    echo "+MMMMMMMMMMDDH  R  ++/::---------:    .:++SSYO:\`"
    echo "+MMMMMMMMMMDDH  M  0+//::------:-:.-/++00SSS+-"
    echo "+MMMMMMMMMDDDH  M  0+//::------:-////+++00/-\`"
    echo "/MMMMMMMMMDDDH     0+//:::----:::\`.-:///-."
    echo "/MMMMMMMMMDDDHHYYSSO++/:::----::/\`.--.\`"
    echo ".DMMMMMMMMDDDHHYYSSO++/:::::-:::/."
    echo " -DMMMMMMMDDDHHYYSSO++//:::::::::"
    echo "  \`ODMMMMMDDDHHYYSSO++//:::::::-"
    echo "    \`:SDMDDDDHHYYSSO0+///:::-."
    echo "        ./OSHHHYYSS000+/:-."
    echo "             \`\`.....\`"
    echo ""

    cd riscv-gnu-toolchain
    git checkout 663b3852189acae826d99237cef45e629dfd6471
    ./configure \
      --prefix=${INSTALL_ROOT}/compiler \
      --disable-linux \
      --disable-gdb \
      --disable-multilib \
      --with-arch=rv32imc \
      --with-abi=ilp32 \
      --with-cmodel=medlow


    make -j8
    cd ..
fi
