#include "pacman.h"

__uint8_t points = 0;
__uint8_t totalPoints = 0;
__uint8_t running = 1;

static  void countPoints(char maze[10][20])
{
    for (__uint8_t i = 0; i < 10; i++)
    {
        for (__uint8_t j = 0; j < 20; j++)
        {
            if (maze[i][j] == '.')
            {
                totalPoints++;
            }
        }
    }
}

static  void movementPacman(char maze[10][20], __uint8_t *posX,
                                             __uint8_t *posY, char movement)
{
    __uint8_t newPosX = *posX, newPosY = *posY;

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
        points++; // collect the point

        maze[newPosY][newPosX] = ' '; // Remove de point of maze
    }

    // Update the pos of PACMAN
    *posX = newPosX;
    *posY = newPosY;
}

static   __uint8_t isPositionOccupiedByGhost(Position ghosts[], 
                                __uint8_t numGhosts, __uint8_t x, __uint8_t y)
{
    for (__uint8_t i = 0; i < numGhosts; i++)
    {
        if (ghosts[i].x == x && ghosts[i].y == y)
        {
            return 1; // Busy Position
        }
    }
    return 0; // Free Position
}

static  void moveGhosts(char maze[10][20], Position ghosts[],
     __uint8_t numGhosts, __uint8_t posX, __uint8_t posY, __uint8_t difficulty)
{
    for (__uint8_t i = 0; i < numGhosts; i++)
    {
        __uint8_t movement;
        __uint8_t newPosX = ghosts[i].x;
        __uint8_t newPosY = ghosts[i].y;

        if (difficulty == 1)
        { // Easy : random movement
            movement = rand() % 4;
        }
        else if (difficulty == 2)
        { // Medium : occasionally movement in direction to PACMAN
            if (rand() % 4){ // 75% of chance of random movement, 25% of chance
                                                            // to follow PACMAN
                movement = rand() % 4;
            }
            else
            {
                if (abs(ghosts[i].x - posX) > abs(ghosts[i].y - posY))
                {
                    movement = ghosts[i].x > posX ? 2 : 3; // left or right
                }
                else
                {
                    movement = ghosts[i].y > posY ? 0 : 1; // above or below
                }
            }
        }
        else
        { // Hard : movement smartest in direction to PACMAN
            if (rand() % 2)
            {                            // Alternance between axes X or Y
                movement = newPosX > posX ? 2 : 3; // Left or Right 
            }
            else
            {
                movement = newPosY > posY ? 0 : 1; //  above or below
            }
        }

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

        // Verify if is valid the position of the ghost
        if (maze[newPosY][newPosX] != 'X' && !isPositionOccupiedByGhost(ghosts, 
                                                   numGhosts, newPosX, newPosY))
        {
            ghosts[i].x = newPosX;
            ghosts[i].y = newPosY;
        }
    }
}

static  __uint8_t verifyCollision(Position ghost[], __uint8_t numGhosts, 
                                                __uint8_t posX, __uint8_t posY)
{
    for (__uint8_t i = 0; i < numGhosts; i++)
    {
        if (ghost[i].x == posX && ghost[i].y == posY)
        {
            return 1; // Collision detected
        }
    }
    return 0; // without collisions
}

int main()
{
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
        "XXXXXXXXXXXXXXXXXXXX"};

    __uint8_t posX = 1, posY = 3; // Initial Position of PACMAN

    countPoints(maze);
    srand(time(NULL));

    Position truePositions[200]; // Assumption with a max of 200 valid positions
    __uint8_t totalPositionsTrues = 0;

    //Fill true Positions with positions other than walls, points, or the PACMAN
    // starting position
    for (__uint8_t y = 0; y < 10; y++)
    {
        for (__uint8_t x = 0; x < 20; x++)
        {
            if (maze[y][x] == '.' && !(x == posX && y == posY))
            {
                truePositions[totalPositionsTrues].x = x;
                truePositions[totalPositionsTrues].y = y;
                totalPositionsTrues++;
            }
        }
    }

    __uint8_t numGhosts;
    do
    {
        printf("How much ghosts you want in the game?");
        scanf("%hhu", &numGhosts);
        if (numGhosts > totalPositionsTrues)
        {
            printf("Not is possible to position %d ghosts, because have only %d positions diponibles\n", numGhosts, totalPositionsTrues);
        }
    } while (numGhosts > totalPositionsTrues);

    printf("What difficulty you want?(Number)\n");

    __uint8_t difficulty;
    scanf("%hhu",&difficulty);

    Position ghost[numGhosts];

    //  Place ghosts in valid random locations
    for (__uint8_t i = 0; i < numGhosts; i++)
    {
        __uint8_t randomPosition = rand() % totalPositionsTrues;
        ghost[i] = truePositions[randomPosition];
        truePositions[randomPosition] = truePositions[--totalPositionsTrues];
        // Replaces the used position with the last one in the list and
        //              decrements the total
    }

    while (running)
    {
        // system("clear"); // clear the terminal

        // draw the maze with ghost
        for (__uint8_t i = 0; i < 10; i++)
        {
            for (__uint8_t j = 0; j < 20; j++)
            {
                __uint8_t hereGhosts = 0;
                for (__uint8_t k = 0; k < numGhosts; k++)
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
        moveGhosts(maze, ghost, numGhosts, posX, posY, difficulty);

        // Verify the collisions with ghost
        if (verifyCollision(ghost, numGhosts, posX, posY))
        {
            printf("You was taked by one ghost! End Game ~ N O B ~.\n");
            running = 0;
        }
    }

    return 0;
}
