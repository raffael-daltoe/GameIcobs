cd /home/raffael/Desktop/Polytech/SEA8/archi2/icobstp3/GameIcobs/Software/demo-icobs-light-project
make clean
make all -j16
cd /home/raffael/Desktop/Polytech/SEA8/archi2/icobstp3/GameIcobs/Software/Codeloader_ubuntu
python3 code_loader.py \
        /home/raffael/Desktop/Polytech/SEA8/archi2/icobstp3/GameIcobs/Software/demo-icobs-light-project/output/demo-icobs-light.hex \
        /dev/ttyUSB3
cd /home/raffael/Desktop/Polytech/SEA8/archi2/icobstp3/GameIcobs/Software/bootloader-icobs-light-project
        