#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct
{
    int x;
    int y;
} Position;

int points = 0;
int totalPoints = 0;
int running = 1;

void countPoints(char maze[10][20])
{
    for (int i = 0; i < 10; i++)
    {
        for (int j = 0; j < 20; j++)
        {
            if (maze[i][j] == '.')
            {
                totalPoints++;
            }
        }
    }
}

void movementPacman(char maze[10][20], int *posX, int *posY, char movement)
{
    int newPosX = *posX, newPosY = *posY;

    switch (movement)
    {
    case 'w':
        newPosY--;
        break;
    case 's':
        newPosY++;
        break;
    case 'a':
        newPosX--;
        break;
    case 'd':
        newPosX++;
        break;
    default:
        printf("Invalid key.\n");
        return;
    }

    // To Verify if the next pos is a wall or ghost
    if (maze[newPosY][newPosX] == 'X')
    {
        printf("Invalid Movement ! Wall .\n");
        return;
    }

    // To verify if the next position have a point
    if (maze[newPosY][newPosX] == '.')
    {
        points++;                            // collect the point

        maze[newPosY][newPosX] = ' '; // Remove de point of maze
    }

    // Update the pos of PACMAN
    *posX = newPosX;
    *posY = newPosY;
}

void moveGhosts(char maze[10][20], Position ghost[], int numGhosts)
{
    for (int i = 0; i < numGhosts; i++)
    {
        int movement = rand() % 4; // to generate random movement 
        int newPosX = ghost[i].x;
        int newPosY = ghost[i].y;

        switch (movement)
        {
        case 0:
            newPosY--;
            break;
        case 1:
            newPosY++;
            break;
        case 2:
            newPosX--;
            break;
        case 3:
            newPosX++;
            break;
        }

        // To verify if the next pos is valid (not is wall or PACMAN )
        if (maze[newPosY][newPosX] != 'X')
        {
            ghost[i].x = newPosX;
            ghost[i].y = newPosY;
        }
    }
}

int verifyCollision(Position ghost[], int numGhosts, int posX, int posY)
{
    for (int i = 0; i < numGhosts; i++)
    {
        if (ghost[i].x == posX && ghost[i].y == posY)
        {
            return 1; // Collision detected
        }
    }
    return 0; // without collisions
}

int main() {
    char maze[10][20] = {
        "XXXXXXXXXXXXXXXXXXXX",
        "X..........XX......X",
        "X.XXXXX.XX.XXXXXX..X",
        "X.XXXXX.XX.XXXXXX..X",
        "X..........XX......X",
        "X.XXXXX.XXXXXX.XX.XX",
        "X....XX........XX..X",
        "X.XX.XXXXXX.XX.XX..X",
        "X..................X",
        "XXXXXXXXXXXXXXXXXXXX"
    };

    int posX = 1, posY = 3; // Initial Position of PACMAN

    countPoints(maze);
    srand(time(NULL));

    Position truePositions[200]; // Assumption with a max of 200 valid positions
    int totalPositionsTrues = 0;

    // Fill true Positions with positions other than walls, points, or the PACMAN 
    // starting position
    for (int y = 0; y < 10; y++) {
        for (int x = 0; x < 20; x++) {
            if (maze[y][x] == '.' && !(x == posX && y == posY)) {
                truePositions[totalPositionsTrues].x = x;
                truePositions[totalPositionsTrues].y = y;
                totalPositionsTrues++;
            }
        }
    }

    int numGhosts;
    do {
        printf("How much ghosts you want in the game?");
        scanf("%d", &numGhosts);
        if (numGhosts > totalPositionsTrues) {
            printf("Not is possible to position %d ghosts, because have only %d positions diponibles\n", numGhosts, totalPositionsTrues);
        }
    } while (numGhosts > totalPositionsTrues);

    Position ghost[numGhosts];

    //  Place ghosts in valid random locations
    for (int i = 0; i < numGhosts; i++) {
        int randomPosition = rand() % totalPositionsTrues;
        ghost[i] = truePositions[randomPosition];
        truePositions[randomPosition] = truePositions[--totalPositionsTrues]; 
        // Replaces the used position with the last one in the list and 
        //              decrements the total
    }

    while (running)
    {
        //system("clear"); // clear the terminal 

        // draw the maze with ghost
        for (int i = 0; i < 10; i++)
        {
            for (int j = 0; j < 20; j++)
            {
                int hereGhosts = 0;
                for (int k = 0; k < numGhosts; k++)
                {
                    if (ghost[k].x == j && ghost[k].y == i)
                    {
                        printf("F");
                        hereGhosts = 1;
                        break;
                    }
                }
                if (!hereGhosts)
                {
                    if (i == posY && j == posX)
                        printf("P");
                    else
                        printf("%c", maze[i][j]);
                }
            }
            printf("\n");
        }
        printf("Points: %d\n", points);

        // Capture user input and move PACMAN
        char movement;
        printf("Movement of PACMAN (w/a/s/d): ");
        scanf(" %c", &movement);

        movementPacman(maze, &posX, &posY, movement);
        // Verify the collisions with ghost
        if (verifyCollision(ghost, numGhosts, posX, posY))
        {
            printf("You was taked by one ghost! End Game ~ N O B ~.\n");
            running = 0;
        }
        moveGhosts(maze, ghost, numGhosts);

        // Verify the collisions with ghost
        if (verifyCollision(ghost, numGhosts, posX, posY))
        {
            printf("You was taked by one ghost! End Game ~ N O B ~.\n");
            running = 0;
        }
    }

    return 0;
}
