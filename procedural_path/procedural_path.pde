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

float LAST_DIRECTION_WEIGHT = 0.5f;


boolean[][] obstacleMap = new boolean[WIDTH][HEIGHT];
boolean[][] pathMap = new boolean[WIDTH][HEIGHT];


class Point {

    public int x;
    public int y;

    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

}


boolean isOutOfBounds(Point p) {
    return p.x < 1 || p.x > WIDTH - 2 || p.y < 1 || p.y > HEIGHT - 2;
}


void drawCell(Point p, color col) {
    fill(col);
    rect(p.x * CELL_SIZE, p.y * CELL_SIZE, CELL_SIZE, CELL_SIZE);
}


void drawObstacleMap() {
    background(255);
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            Point point = new Point(x, y);
            if (isObstacle(point)) {
                drawCell(point, color(100, 100, 100));
            }
        }
    }
}


void drawPathMap() {
    background(255);
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            if (pathMap[x][y]) {
                drawCell(new Point(x, y), color(255, 0, 0));
            }
        }
    }
}


void drawAllMaps() {
    background(255);
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            Point point = new Point(x, y);
            if (isObstacle(point)) {
                drawCell(point, color(100, 100, 100));
            }
            else if (pathMap[x][y]) {
                drawCell(point, color(255, 0, 0));
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
    UP(-1),
    DOWN(1),
    LEFT(-1),
    RIGHT(1),
    NONE(0)
}


final Directions[] DIRECTIONS = {
    Directions.UP,
    Directions.DOWN,
    Directions.LEFT,
    Directions.RIGHT
};


final Directions[][] PERPENDICULAR = new Directions[][] {
    {Directions.LEFT, Directions.RIGHT}, // UP
    {Directions.LEFT, Directions.RIGHT}, // DOWN
    {Directions.UP, Directions.DOWN},    // LEFT
    {Directions.UP, Directions.DOWN}     // RIGHT
};


final Direction[] OPPOSITE = new Directions[] {
    Directions.DOWN, // UP
    Directions.UP,   // DOWN
    Directions.RIGHT,// LEFT
    Directions.LEFT  // RIGHT
};


Point addDirection(Point p, Directions direction) {
    // UP-DOWN
    if (direction < Directions.LEFT) {
        return new Point(p.x, p.y + direction.value);
    }
    // LEFT-RIGHT
    return new Point(p.x + direction.value, p.y);
}


boolean isObstacle(Point p) {
    return obstacleMap[p.x][p.y];
}


boolean isValidPoint(Point p) {
    return !isOutOfBounds(p) && !isObstacle(p);
}


Point nextPoint(Point location, Directions last) {
    
    float rand = random(1);
    
    // Check if the last direction is valid
    // The last direction is always preferred to form straight paths
    Point lastDirPoint = addDirection(location, last);
    if (isValidPoint(lastDirPoint)) {
        if (rand < LAST_DIRECTION_WEIGHT) {
            return lastDirPoint;
        }
    }

    // Check if one perpendicular direction is valid
    if (rand < (1f - LAST_DIRECTION_WEIGHT) / 2f) {
        Direction perpendicular = PERPENDICULAR[last][0];
        Point newP = addDirection(location, perpendicular);
        if (isValidPoint(newP)) {
            return newP;
        }
    }

    // If the previous perpendicular direction is not valid,
    // check for the other perpendicular direction
    Direction perpendicular = PERPENDICULAR[last][1];
    Point newP = addDirection(location, perpendicular);
    if (isValidPoint(newP)) {
        return newP;
    }

    // If no other direction is valid, return the direction opposite to the last direction
    // The opposite direction is always valid, as it corresponds to going back one step
    return OPPOSITE[last];
}


Directions randomDirection(Point location) {
    while (true) {
        int rand = floor(random(4));
        Directions direction = DIRECTIONS[rand];
        // Check if the direction is valid
        Point newP = addDirection(location, direction);
        if (isValidPoint(newP)) {
            return direction;
        }
    }
}


void generatePath(Point start) {

    Directions lastDirection = randomDirection(start);

    for (int length = 0; length < PATH_LENGTH; length ++) {

        Point p = nextPoint(start, lastDirection);
        pathMap[p.x][p.y] = true;

    }

}


Directions[] getAvailableDirections(Point p) {
    Directions[] directions = new Directions[4];
    int index = 0;
    
    if (isValidPoint(new Point(p.x - 1, p.y)) {
        directions[index] = Directions.LEFT;
        index++;
    }
    if (isValidPoint(new Point(p.x + 1, p.y)) {
        directions[index] = Directions.RIGHT;
        index++;
    }
    if (isValidPoint(new Point(p.x, p.y - 1)) {
        directions[index] = Directions.UP;
        index++;
    }
    if (isValidPoint(new Point(p.x, p.y + 1)) {
        directions[index] = Directions.DOWN;
        index++;
    }

    return directions;
}


void mousePressed() {
    int x = floor(mouseX / CELL_SIZE);
    int y = floor(mouseY / CELL_SIZE);

    if (isOutOfBounds(x, y)) {
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

