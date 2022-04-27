
final int WIDTH = 70;
final int HEIGHT = 50;

final int CELL_SIZE = 10;

//final int SEED = round(random(10000000));
final int SEED = 5;

final int DIRECTION_PRECISION = 100;

color[][] pathMap = new color[WIDTH][HEIGHT];

PathGenerator pathGenerator = null;


enum Direction {
  UP(-1),
  DOWN(1),
  LEFT(-1),
  RIGHT(1),
  NONE(0);
  
  public final int value;
  
  private Direction(int value) {
    this.value = value;
  }
  
}

Direction[] activeDirections = {
  Direction.UP,
  Direction.DOWN,
  Direction.LEFT,
  Direction.RIGHT
};


boolean isOutOfBounds(int x, int y) {
  return x < 1 || x > WIDTH - 2 || y < 1 || y > HEIGHT - 2;
}


class PathGenerator {

  private int[] startCell;
  private int[] endCell;
  private int[] currentCell;

  public PathGenerator() {

  }

  public void setStartCell(int[] startCell) {
    this.startCell = startCell;
  }

  public void setEndCell(int[] endCell) {
    this.endCell = endCell;
  }


  private Direction[] calculateDirection() {
    int xDiff = endCell[0] - currentCell[0];
    int yDiff = endCell[1] - currentCell[1];

    Direction[] directions = new Direction[2];

    if (xDiff == 0) {
      directions[0] = Direction.NONE;
    }
    else if (xDiff > 0) {
      directions[0] = Direction.RIGHT;
    }
    else {
      directions[0] = Direction.LEFT;
    }

    if (yDiff == 0) {
      directions[1] = Direction.NONE;
    }
    else if (yDiff > 0) {
      directions[1] = Direction.DOWN;
    }
    else {
      directions[1] = Direction.UP;
    }

    return directions;    
  }


  public void generatePath() {

    currentCell = startCell;

    while (true) {
      
      println("Current cell: " + currentCell[0] + ", " + currentCell[1]);
      
      //delay(100);

      // Calculate the direction to reach the target cell
      Direction[] directions = calculateDirection();

      // Check if the target cell has been reached
      if (directions[0] == Direction.NONE && directions[1] == Direction.NONE) {
        break;
      }

      int x_or_y = floor(random(2));
      int randomDirection = floor(random(4 + DIRECTION_PRECISION));
      
      int[] previousCell = new int[] {currentCell[0], currentCell[1]};

      if (randomDirection > 3) {
        // Move towards the target cell
        if (x_or_y == 0) {
          currentCell[0] += directions[x_or_y].value;
        }
        else {
          currentCell[1] += directions[x_or_y].value;
        }
      }
      else {
        // Move in a random direction
        currentCell[x_or_y] += activeDirections[randomDirection].value;
      }
      
      if (isOutOfBounds(currentCell[0], currentCell[1])) {
        currentCell = previousCell;
        println("Previous cell is: " + currentCell[0] + ", " + currentCell[1]);
        continue;
      }

      pathMap[currentCell[0]][currentCell[1]] = #ffffff;
      drawCell(currentCell[0], currentCell[1], #ffffff);

    }

  }

  
}


void fillMaps() {
 for (int x = 0; x < WIDTH; x++) {
   for (int y = 0; y < HEIGHT; y++) {
     pathMap[x][y] = #000000;
    }
  }
}  


void drawCell(int x, int y, color col) {
  fill(col);
  rect(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE);
}


void drawPathMap() {
  for (int x = 0; x < WIDTH; x++) {
    for (int y = 0; y < HEIGHT; y++) {
      drawCell(x, y, pathMap[x][y]);
    }
  }
}


void mouseClicked() {
  int x = mouseX / CELL_SIZE;
  int y = mouseY / CELL_SIZE;

  if (isOutOfBounds(x, y)) {
    println("Selected point out of bounds");
    return;
  }
 
  println("Selected point: " + x + ", " + y);

  if (pathGenerator != null) {
    pathGenerator.setEndCell(new int[] {x, y});
    drawCell(x, y, #0000FF);
    delay(100);
    pathGenerator.generatePath();
    pathGenerator = null;
  } 
  else {
    pathGenerator = new PathGenerator();
    pathGenerator.setStartCell(new int[] {x, y});
    drawCell(x, y, #FF0000);
  }

}


void keyPressed() {
 if (key == 'c') {
   fillMaps();
   drawPathMap();
   pathGenerator = null;
 }
}


void setup() {
  size(700, 500);
  randomSeed(SEED);
  background(#000000);
  fillMaps();
}


void draw() {
  //drawPathMap();
}
