/*

    Generate a perlin noise map for invisible obstables which will
    put some constraints on the path generation algorithm.
    The path cannot go through the obstacles.

    The path generation algorithm generates the path procedurally,
    given a valid starting point and a path length.

    Path generation rules:
    - the path must go through the map and not out of borders
    - the path must not go through the obstacles
    - when choosing the next direction, the last direction is preferred (weighted more)
    - the next direction must be valid (not out of borders, not through the obstacles)
    - the next direction can be the opposite of the last direction, but it's the least preferred option
    - the next direction is chosen via a weighted random choice:
        1. the last direction is the most likely
        2. the directions perpendicular to the last are equally likely
        3. the direction opposite to the last is the least likely

*/


final int WIDTH = 70;
final int HEIGHT = 50;

final int CELL_SIZE = 10;

//final int SEED = round(random(10000000));
final int SEED = 5;

float OBSTACLE_SCALE = 0.18f;
float OBSTACLE_THRESHOLD = 0.6f;

final int PATH_LENGTH = 20;


boolean[][] obstacleMap = new boolean[WIDTH][HEIGHT];
boolean[][] pathMap = new boolean[WIDTH][HEIGHT];


boolean isOutOfBounds(int x, int y) {
    return x < 1 || x > WIDTH - 2 || y < 1 || y > HEIGHT - 2;
}


void drawCell(int x, int y, color col) {
    fill(col);
    rect(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE);
}


void drawObstacleMap() {
    background(255);
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            if (obstacleMap[x][y]) {
                drawCell(x, y, color(100, 100, 100));
            }
        }
    }
}


void drawPathMap() {
    background(255);
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            if (pathMap[x][y]) {
                drawCell(x, y, color(255, 0, 0));
            }
        }
    }
}


void drawAllMaps() {
    background(255);
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            if (obstacleMap[x][y]) {
                drawCell(x, y, color(100, 100, 100));
            }
            if (pathMap[x][y]) {
                drawCell(x, y, color(255, 0, 0));
            }
        }
    }
}


void generateObstacleMap() {
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            obstacleMap[x][y] = noise(x * OBSTACLE_SCALE, y * OBSTACLE_SCALE, SEED) > OBSTACLE_THRESHOLD;
        }
    }
}


void keyPressed() {
    switch (key) {
        case '+':
            OBSTACLE_SCALE += 0.01f;
            println("OBSTACLE_SCALE: " + OBSTACLE_SCALE);
            generateObstacleMap();
            drawObstacleMap();
            break;
        
        case '-':
            OBSTACLE_SCALE -= 0.01f;
            println("OBSTACLE_SCALE: " + OBSTACLE_SCALE);
            generateObstacleMap();
            drawObstacleMap();
            break;
        
        case ',':
            OBSTACLE_THRESHOLD -= 0.01f;
            println("OBSTACLE_THRESHOLD: " + OBSTACLE_THRESHOLD);
            generateObstacleMap();
            drawObstacleMap();
            break;

        case '.':
            OBSTACLE_THRESHOLD += 0.01f;
            println("OBSTACLE_THRESHOLD: " + OBSTACLE_THRESHOLD);
            generateObstacleMap();
            drawObstacleMap();
            break;
    }
}


enum Directions {
    UP, DOWN, LEFT, RIGHT, NONE
}


Directions randomDirection(Directions last, Directions[] available) {
    
    

}


void generatePath(int x, int y) {

    Directions lastDirection = Directions.NONE;

    for (int length = 0; length < PATH_LENGTH; length ++) {

        // 

    }

}


Directions[] getAvailableDirections(int x, int y) {
    Directions[] directions = new Directions[4];
    int index = 0;
    
    if (!isOutOfBounds(x - 1, y) && !obstacleMap[x - 1][y]) {
        directions[index] = Directions.LEFT;
        index++;
    }
    if (!isOutOfBounds(x + 1, y) && !obstacleMap[x + 1][y]) {
        directions[index] = Directions.RIGHT;
        index++;
    }
    if (!isOutOfBounds(x, y - 1) && !obstacleMap[x][y - 1]) {
        directions[index] = Directions.UP;
        index++;
    }
    if (!isOutOfBounds(x, y + 1) && !obstacleMap[x][y + 1]) {
        directions[index] = Directions.DOWN;
        index++;
    }

    return directions;
}


void mousePressed() {
    int x = floor(mouseX / CELL_SIZE);
    int y = floor(mouseY / CELL_SIZE);

    if isOutOfBounds(x, y) {
        println("Out of bounds cell at " + x + ", " + y);
        return;
    }

    if (obstacleMap[x][y]) {
        println("Invalid cell at " + x + ", " + y);
        return;
    }



}


void setup() {
    size(700, 500);
    randomSeed(SEED);
    background(#000000);
    generateObstacleMap();
    drawObstacleMap();
}


void draw() {

}

