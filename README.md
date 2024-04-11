# Introduction
This project revives the iconic PACMAN game, adapting it to run on modern embedded systems while employing the ICOBS architecture. The main challenge was to implement efficient software and hardware integration, ensuring smooth gameplay on limited system resources.

# Software Layer
The game is developed in C, featuring dynamic sprite creation, collision detection, and an intuitive control system for the PACMAN character. Key components include:

# Sprite Creation
Dynamically generated sprites for PACMAN, ghosts, and the game map.
Game Mechanics: Detailed collision structures and food consumption logic to enhance gameplay.
User Interaction: Customizable background colors and responsive controls for PACMAN's movement.
Hardware Layer
The hardware aspect focuses on memory optimization and sprite management within the constraints of the BASYS3 platform. Highlights include:

# Peripheral Integration
Introduction of a new peripheral `ahblite_vga.vhd` for VGA output, facilitating immersive visual experiences.

# Memory Management 
Innovative strategies to maximize the limited memory available on the BASYS3 board, including map segmentation and sprite replication.
Sprite Animation: Seamless animation for PACMAN and ghosts, achieved through careful memory and register management.
Conclusion
The ICOBS Game project exemplifies the intricate balance between software and hardware in embedded systems. Through this project, significant insights were gained into memory management, system optimization, and the challenges of debugging in a hardware-dependent environment.

# References
Artix-7 FPGAs Data Sheet: DC and AC Switching Characteristics
The RISC-V Instruction Set Manual, Volume I: User-Level ISA, Version 2.2

# Getting Started
To run this project, ensure you have the necessary hardware setup including a BASYS3 board and the appropriate development environment for RISC-V and VHDL. Follow the setup instructions detailed within the software and hardware layer sections.
