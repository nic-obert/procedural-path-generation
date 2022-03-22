
final int WIDTH = 500;
final int HEIGHT = 500;

float[][] pathMap;


float pointPathValue(int x, int y) {
   
  // Sum the path values of the nearest cells
  float sum = 0;
  
  for (int ix = -1; ix < 2; ix++) {
    for (int iy = -1; iy < 2; iy++) {
        sum += pathMap[x + ix][y+iy];
    }
  }  
  
  return sum;
}


void setup() {
  size(500, 500);

  
}


void draw() {
  
}
