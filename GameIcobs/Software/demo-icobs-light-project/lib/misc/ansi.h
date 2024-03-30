/**
 * author: Guillaume Patrigeon
 * update: 27-02-2017
 */

#ifndef __ANSI_H__
#define __ANSI_H__



// ANSI commands:
#define ANSI_ERASE_SCREEN       "\x1B[2J"                       // Clear entire screen
#define ANSI_ERASE_DOWN         "\x1B[J"                        // Erase display
#define ANSI_ERASE_UP           "\x1B[1J"                       // Erase display
#define ANSI_ERASE_LINE         "\x1B[2K"                       // Erase line
#define ANSI_ERASE_RIGHT        "\x1B[K"                        // Clear line from cursor right
#define ANSI_ERASE_LEFT         "\x1B[1K"                       // Clear line from cursor left

#define ANSI_GOHOME             "\x1B[H"                        // Move cursor to upper left corner
#define ANSI_GOTO(X, Y)         "\x1B[" #Y ";" #X "H"           // Move cursor to position X Y (start at 1)
#define ANSI_MOVE(N, D)         "\x1B[" #N D                    // Move cursor N times in direction D (see ANSI_UP/DOWN/RIGHT/LEFT)

#define ANSI_RESET              "\x1B[m"                        // Turn off character attributes
#define ANSI_SAVE               "\x1B[s"                        // Save cursor position and attributes
#define ANSI_LOAD               "\x1B[u"                        // Restore cursor position and attributes

// Directions for ANSI mode
#define ANSI_UP                 "A"
#define ANSI_DOWN               "B"
#define ANSI_RIGHT              "C"
#define ANSI_LEFT               "D"

// Text graphic attributes
#define ANSI_ATTR(A)            "\x1B[" A "m"                   // Set 1 text attribute
#define ANSI_ATTR2(A, B)        "\x1B[" A ";" B "m"             // Set 2 text attributes
#define ANSI_ATTR3(A, B, C)     "\x1B[" A ";" B ";" C "m"       // Set 3 text attributes

#define ANSI_BOLD               "1"
#define ANSI_UNDERSCORE         "4"
#define ANSI_BLINK              "5"
#define ANSI_REVERSE            "7"
#define ANSI_CONCEAL            "8"

#define ANSI_FG_BLACK           "30"
#define ANSI_FG_RED             "31"
#define ANSI_FG_GREEN           "32"
#define ANSI_FG_YELLOW          "33"
#define ANSI_FG_BLUE            "34"
#define ANSI_FG_MAGENTA         "35"
#define ANSI_FG_CYAN            "36"
#define ANSI_FG_WHITE           "37"

#define ANSI_BG_BLACK           "40"
#define ANSI_BG_RED             "41"
#define ANSI_BG_GREEN           "42"
#define ANSI_BG_YELLOW          "43"
#define ANSI_BG_BLUE            "44"
#define ANSI_BG_MAGENTA         "45"
#define ANSI_BG_CYAN            "46"
#define ANSI_BG_WHITE           "47"



#endif
