#include <stdio.h>
#include <stdlib.h>
#include <time.h>

typedef struct
{
    int x;
    int y;
} Posicao;

int pontos = 0;
int pontosTotais = 0;
int rodando = 1;

void contarPontosTotais(char labirinto[10][20])
{
    for (int i = 0; i < 10; i++)
    {
        for (int j = 0; j < 20; j++)
        {
            if (labirinto[i][j] == '.')
            {
                pontosTotais++;
            }
        }
    }
}

void movimentarPacman(char labirinto[10][20], int *posX, int *posY, char movimento)
{
    int novaPosX = *posX, novaPosY = *posY;

    switch (movimento)
    {
    case 'w':
        novaPosY--;
        break;
    case 's':
        novaPosY++;
        break;
    case 'a':
        novaPosX--;
        break;
    case 'd':
        novaPosX++;
        break;
    default:
        printf("Tecla inválida.\n");
        return;
    }

    // Verificar se a próxima posição é uma parede ou fantasma
    if (labirinto[novaPosY][novaPosX] == 'X')
    {
        printf("Movimento inválido! Parede.\n");
        return;
    }

    // Verificar se a próxima posição tem um ponto
    if (labirinto[novaPosY][novaPosX] == '.')
    {
        pontos++;                            // Coletar ponto
        labirinto[novaPosY][novaPosX] = ' '; // Remover ponto do labirinto
    }

    // Atualizar a posição do PACMAN
    *posX = novaPosX;
    *posY = novaPosY;
}

void movimentarFantasmas(char labirinto[10][20], Posicao fantasmas[], int numFantasmas)
{
    for (int i = 0; i < numFantasmas; i++)
    {
        int movimento = rand() % 4; // Gerar movimento aleatório
        int novaPosX = fantasmas[i].x;
        int novaPosY = fantasmas[i].y;

        switch (movimento)
        {
        case 0:
            novaPosY--;
            break;
        case 1:
            novaPosY++;
            break;
        case 2:
            novaPosX--;
            break;
        case 3:
            novaPosX++;
            break;
        }

        // Verificar se a próxima posição é válida (não é parede nem PACMAN)
        if (labirinto[novaPosY][novaPosX] != 'X')
        {
            fantasmas[i].x = novaPosX;
            fantasmas[i].y = novaPosY;
        }
    }
}

int verificarColisao(Posicao fantasmas[], int numFantasmas, int posX, int posY)
{
    for (int i = 0; i < numFantasmas; i++)
    {
        if (fantasmas[i].x == posX && fantasmas[i].y == posY)
        {
            return 1; // Colisão detectada
        }
    }
    return 0; // Sem colisões
}

int main() {
    char labirinto[10][20] = {
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

    int posX = 1, posY = 3; // Posição inicial do PACMAN

    contarPontosTotais(labirinto);
    srand(time(NULL));

    Posicao posicoesValidas[200]; // Assumindo um máximo de 200 posições válidas
    int totalPosicoesValidas = 0;

    // Preencher posicoesValidas com posições que não sejam paredes, pontos, ou a posição inicial do PACMAN
    for (int y = 0; y < 10; y++) {
        for (int x = 0; x < 20; x++) {
            if (labirinto[y][x] == '.' && !(x == posX && y == posY)) {
                posicoesValidas[totalPosicoesValidas].x = x;
                posicoesValidas[totalPosicoesValidas].y = y;
                totalPosicoesValidas++;
            }
        }
    }

    int numFantasmas;
    do {
        printf("Quantos fantasmas você deseja no jogo? ");
        scanf("%d", &numFantasmas);
        if (numFantasmas > totalPosicoesValidas) {
            printf("Não é possível posicionar %d fantasmas, pois só há %d posições disponíveis.\n", numFantasmas, totalPosicoesValidas);
        }
    } while (numFantasmas > totalPosicoesValidas);

    Posicao fantasmas[numFantasmas];

    // Posicionar os fantasmas em locais aleatórios válidos
    for (int i = 0; i < numFantasmas; i++) {
        int posicaoAleatoria = rand() % totalPosicoesValidas;
        fantasmas[i] = posicoesValidas[posicaoAleatoria];
        posicoesValidas[posicaoAleatoria] = posicoesValidas[--totalPosicoesValidas]; // Substitui a posição usada pela última na lista e decrementa o total
    }

    while (rodando)
    {
        system("clear"); // Limpar a tela (use "cls" no Windows)

        // Desenhar o labirinto com fantasmas
        for (int i = 0; i < 10; i++)
        {
            for (int j = 0; j < 20; j++)
            {
                int fantasmaAqui = 0;
                for (int k = 0; k < numFantasmas; k++)
                {
                    if (fantasmas[k].x == j && fantasmas[k].y == i)
                    {
                        printf("F");
                        fantasmaAqui = 1;
                        break;
                    }
                }
                if (!fantasmaAqui)
                {
                    if (i == posY && j == posX)
                        printf("P");
                    else
                        printf("%c", labirinto[i][j]);
                }
            }
            printf("\n");
        }
        printf("Pontos: %d\n", pontos);

        // Capturar entrada do usuário e mover o PACMAN
        char movimento;
        printf("Mova o PACMAN (w/a/s/d): ");
        scanf(" %c", &movimento);

        movimentarPacman(labirinto, &posX, &posY, movimento);
        // Verificar colisões com fantasmas
        if (verificarColisao(fantasmas, numFantasmas, posX, posY))
        {
            printf("Você foi pego por um fantasma! Fim de jogo.\n");
            rodando = 0;
        }
        movimentarFantasmas(labirinto, fantasmas, numFantasmas);

        // Verificar colisões com fantasmas
        if (verificarColisao(fantasmas, numFantasmas, posX, posY))
        {
            printf("Você foi pego por um fantasma! Fim de jogo.\n");
            rodando = 0;
        }
    }

    return 0;
}
