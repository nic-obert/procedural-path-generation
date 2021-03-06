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
//final int SEED = 5;

float OBSTACLE_SCALE = 0.18f;
float OBSTACLE_THRESHOLD = 0.6f;

final int PATH_LENGTH = 200;

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

    public String toString() {
        return "(" + x + ", " + y + ")";
    }

}


class Vector {

    public Point point;
    public Directions direction;

    public Vector(Point point, Directions direction) {
        this.point = point;
        this.direction = direction;
    }

    public String toString() {
        return "(" + point.toString() + ", " + direction.toString() + ")";
    }
}


boolean isOutOfBounds(Point p) {
    return p.x < 0 || p.x > WIDTH - 1 || p.y < 0 || p.y > HEIGHT - 1;
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
            obstacleMap[x][y] = noise(x * OBSTACLE_SCALE, y * OBSTACLE_SCALE) > OBSTACLE_THRESHOLD;
        }
    }
}


void clearPathMap() {
    for (int x = 0; x < WIDTH; x++) {
        for (int y = 0; y < HEIGHT; y++) {
            pathMap[x][y] = false;
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
        
        case 'c':
            clearPathMap();
            drawPathMap();
            break;
        
        case 'r':
            randomSeed(round(random(10000000)));
            noiseSeed(round(random(10000000)));
            generateObstacleMap();
            clearPathMap();
            drawAllMaps();          
            break;

    }
}


enum Directions {
    UP(-1),
    DOWN(1),
    LEFT(-1),
    RIGHT(1),
    NONE(0);

    public final int value;

    private Directions(int value) {
        this.value = value;
    }

    public String toString() {
        switch (this) {
            case UP:
                return "UP";
            case DOWN:
                return "DOWN";
            case LEFT:
                return "LEFT";
            case RIGHT:
                return "RIGHT";
            case NONE:
                return "NONE";
        }
        return "";
    }

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

 //<>//
final Directions[] OPPOSITE = new Directions[] {
    Directions.DOWN, // UP
    Directions.UP,   // DOWN
    Directions.RIGHT,// LEFT
    Directions.LEFT  // RIGHT
};


Point addDirection(Point p, Directions direction) {
    // UP-DOWN
    if (direction.ordinal() < Directions.LEFT.ordinal()) {
        return new Point(p.x, p.y + direction.value);
    }
    // LEFT-RIGHT
    return new Point(p.x + direction.value, p.y); //<>// //<>//
}


boolean isObstacle(Point p) {
    return obstacleMap[p.x][p.y];
}


boolean isValidPoint(Point p) {
    return !isOutOfBounds(p) && !isObstacle(p);
}


Vector nextPoint(Vector vec) {

    Point location = vec.point;
    Directions last = vec.direction; //<>//
    
    float rand = random(1);
     //<>//
    // Check if the last direction is valid
    // The last direction is always preferred to form straight paths
    Point lastDirPoint = addDirection(location, last);
    if (isValidPoint(lastDirPoint)) {
        if (rand < LAST_DIRECTION_WEIGHT) {
            return new Vector(lastDirPoint, last);
        }
    }

    // Check if one perpendicular direction is valid
    if (rand < (1f - LAST_DIRECTION_WEIGHT) / 2f) {
        Directions perpendicular = PERPENDICULAR[last.ordinal()][0]; //<>//
        Point newP = addDirection(location, perpendicular);
        if (isValidPoint(newP)) { //<>//
            return new Vector(newP, perpendicular); //<>//
        }
    }
 
    // If the previous perpendicular direction is not valid,
    // check for the other perpendicular direction
    Directions perpendicular = PERPENDICULAR[last.ordinal()][1];
    Point newP = addDirection(location, perpendicular);
    if (isValidPoint(newP)) {
        return new Vector(newP, perpendicular);
    }

    // If no other direction is valid, return the direction opposite to the last direction
    // The opposite direction is always valid, as it corresponds to going back one step
    return new Vector(addDirection(location, OPPOSITE[last.ordinal()]), OPPOSITE[last.ordinal()]); //<>//
}


Directions randomDirection(Point location) {
    int rand = floor(random(4));
    Directions direction = DIRECTIONS[rand];
    // Check if the direction is valid
    Point newP = addDirection(location, direction);
    if (isValidPoint(newP)) {
        return direction;
    }

    // Try with the other directions
    Directions newDir = PERPENDICULAR[direction.ordinal()][0];
    newP = addDirection(location, newDir);
    if (isValidPoint(newP)) {
        return newDir;
    }

    newDir = PERPENDICULAR[direction.ordinal()][1];
    newP = addDirection(location, newDir);
    if (isValidPoint(newP)) {
        return newDir;
    }

    newDir = OPPOSITE[direction.ordinal()];
    newP = addDirection(location, newDir);
    if (isValidPoint(newP)) {
        return newDir;
    }

    // If no direction is possible, return NONE
    return Directions.NONE;
}


void generatePath(Point start) {

    Directions direction = randomDirection(start);

    if (direction == Directions.NONE) {
        return;
    }

    Vector vec = new Vector(
        start,
        direction
    );

    drawCell(start, color(255, 0, 0));
    pathMap[start.x][start.y] = true;

    for (int length = 0; length < PATH_LENGTH; length ++) {

        vec = nextPoint(vec);
        pathMap[vec.point.x][vec.point.y] = true;

        println("Current vector: " + vec);

        drawCell(vec.point, color(255, 0, 0));
        //delay(200);

    }

}


Directions[] getAvailableDirections(Point p) {
    Directions[] directions = new Directions[4];
    int index = 0;
    
    if (isValidPoint(new Point(p.x - 1, p.y))) {
        directions[index] = Directions.LEFT;
        index++;
    }
    if (isValidPoint(new Point(p.x + 1, p.y))) {
        directions[index] = Directions.RIGHT;
        index++;
    }
    if (isValidPoint(new Point(p.x, p.y - 1))) {
        directions[index] = Directions.UP;
        index++;
    }
    if (isValidPoint(new Point(p.x, p.y + 1))) {
        directions[index] = Directions.DOWN;
        index++;
    }

    return directions;
}


void mousePressed() {
    int x = floor(mouseX / CELL_SIZE);
    int y = floor(mouseY / CELL_SIZE);

    Point point = new Point(x, y);

    if (isOutOfBounds(point)) {
        println("Out of bounds cell at " + x + ", " + y);
        return;
    }

    if (obstacleMap[x][y]) {
        println("Invalid cell at " + x + ", " + y);
        return;
    }

    println("Selecting cell at " + x + ", " + y);
    generatePath(point);

}


void setup() {
    size(700, 500);
    //randomSeed(SEED);
    background(#000000);
    generateObstacleMap();
    drawObstacleMap();
}


void draw() {
    drawAllMaps();
}
