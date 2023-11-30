//if intersection, check all corners to see which do not intersect itself when connected to point
//if 2, use those, if 3, use two with longest distance from point
//wrap around if dispY1 * dispY2 * dispX1 * dispX2 < 0 || dispX1 * dispX2 == 0 && dispY1 * dispY2 < 0 || dispY1 * dispY2 == 0 && dispX1 * dispX2 < 0
// second wrap corner:
//top left if initial path goes to top left
//top right if initial path goes to top right
//bottom left if initial path to first corner goes to bottom left
//bottom right if initial goes to bottom right
//add right into nextSteps and return
//todo: for subsequent, if point has data in copy array, get dist, and if dist smaller than minDist, store dist as minDist and index as minIndex
// afterwards, if minIndex has data in both arrays, backtrack in both directions, otherwise just backtrack normally
// whenever a complete path is found, if total distance less than current min for index of either first common point between new and copy, or last non end point in path,
// replace this at the index
// after all searching and drawing is done, use all info stored in this array to update copy array with new distances (start at last point before common point or second last point if no common point)
// backtrack through path according to new array, at any given index, update copy array to have distance = total - partial distance according to new array and index = previous index

ArrayList<PVector> nextSteps = new ArrayList<PVector>();
int[][] obstacles = new int[][]{new int[]{150, 170, 280, 180}, new int[]{395, 365, 430, 475}, new int[]{300, 100, 310, 350}, new int[]{320, 100, 330, 350}, new int[]{340, 100, 350, 350}, new int[]{360, 100, 370, 350}, new int[]{380, 100, 390, 350}, new int[]{400, 100, 410, 350}, new int[]{450, 250, 550, 450}, new int[]{290, 390, 390, 500}, new int[]{250, 200, 260, 400}};//new int[]{round(random(0, 800)), round(random(0, 600)), round(random(0, 800)), round(random(0, 600))}, new int[]{round(random(0, 800)), round(random(0, 600)), round(random(0, 800)), round(random(0, 600))}, new int[]{round(random(0, 800)), round(random(0, 600)), round(random(0, 800)), round(random(0, 600))}, new int[]{round(random(0, 800)), round(random(0, 600)), round(random(0, 800)), round(random(0, 600))}};
int[][] viableNextSteps = new int[obstacles.length * 4 + 1][];  // viable next steps for each corner, +1 so that no corner has index 0 (when finding corner index, object index * 4 + corner# + 1), index 0 is start point
float[][] shortestDistances = new float[obstacles.length * 4 + 1][2];  //index 0 is dist, index 1 is point index of point it came from to get that dist
float[][] shortestDistancesCopy = new float[obstacles.length * 4 + 1][2];
float[][][] pathInfo = new float[obstacles.length * 4][obstacles.length * 4 + 1][2];  //index 1 is last point index, index 0 is dist so far
//int[][] obstX, obstY; 
//int minWidth = -1;
//int minHeight = -1;

int[][][] widthRangeObsCheck;
int[][][] heightRangeObsCheck;

int obsLen = obstacles.length;

ArrayList<int[]> currPoints = new ArrayList<int[]>();  //dynamic arraylist because length will change constantly
ArrayList<int[]> nextPoints = new ArrayList<int[]>();

int[] nextPointsCounter = new int[obstacles.length * 4 + 1];

float minDist = -1;
int minIndex = -1;

//void setup() {
//  size(800, 600);
  
//}

void pathFind(PVector start, PVector end) {
  // initialize all variables and lists
  nextSteps = new ArrayList<PVector>();
  viableNextSteps = new int[obstacles.length * 4 + 1][];  // viable next steps for each corner, +1 so that no corner has index 0 (when finding corner index, object index * 4 + corner# + 1), index 0 is start point
  shortestDistances = new float[obstacles.length * 4 + 1][2];  //index 0 is dist, index 1 is point index of point it came from to get that dist
  pathInfo = new float[obstacles.length * 4][obstacles.length * 4 + 1][2];  //index 1 is last point index, index 0 is dist so far
  //todo: may not need pathInfo
  obsLen = obstacles.length;
  
  currPoints = new ArrayList<int[]>();
  nextPoints = new ArrayList<int[]>();
  
  nextPointsCounter = new int[obstacles.length * 4 + 1];
  
  minDist = -1;
  minIndex = -1;
  
  
  fill(0, 0, 255);
  circle(start.x, start.y, 10);
  circle(end.x, end.y, 10);
  fill(0);
  strokeWeight(4);
  line(start.x, start.y, end.x, end.y);
  strokeWeight(1);
  
  widthRangeObsCheck = new int[width][width][0];
  heightRangeObsCheck = new int[height][height][0];
  
  for (int i = 0; i < obstacles.length; i++) {
    int[] ob = obstacles[i];
    for (int lower = 0; lower < ob[2]; lower++) {
      for (int higher = max(lower + 1, ob[0] + 1); higher < width; higher++)
        widthRangeObsCheck[lower][higher] = append(widthRangeObsCheck[lower][higher], i);
    }
    
    for (int lower = 0; lower <= ob[3]; lower++) {
      for (int higher = max(lower + 1, ob[1]); higher < height; higher++)
        heightRangeObsCheck[lower][higher] = append(heightRangeObsCheck[lower][higher], i);
    }
  }
  
  currPoints.add(new int[]{0});
  
  
  //todo: make it so that middle points will not be chosen (like it was before)
  // for each obstacle, only check two corners that are relevant (if three can be reached, second and third farthest, if two can be reached, two closest
  // when two can be reached, starting point within either width or height of obstacle (cross area)
  // when three can be reached, starting point anywhere but the cross area
  // use that knowledge to select the two points that should be checked
  // proceed as normal (same, just less corners, therefore less branches)
  //if no time, just take order as provided in shopping list
  //todo: clean up stinky code
  for (int step = -1; step < pathInfo.length - 1; step++) {
    for (int[] index : currPoints) {
      int i = index[0];
      
      PVector currentPoint;
        float dist;
        if (i == 0) {
          currentPoint = start;
          dist = 0;
        }
        else {
          currentPoint = cornerCoords(obstacles[(i - 1)/4])[(i - 1) % 4];
          dist = pathInfo[step][i][0];
        }
        
      //if (shortestDistancesCopy[i][0] != 0) {
      //  println(i);
      //  float totalDist = dist + shortestDistancesCopy[i][0];
      //  if (minDist == -1 || totalDist < minDist) {
      //    minDist = dist;
      //    minIndex = i;
      //  }
        
      //  //float partialDist = dist(
      //}
          
      if (viableNextSteps[i] == null) {
        viableNextSteps[i] = new int[0];
        
        getNextValidPoints(currentPoint, end, start, dist, i);
      }
      
      else {
        for (int point : viableNextSteps[i]) {
          if (shortestDistances[point][0] == 0)
            continue;
            
          else {
            PVector nextPoint = cornerCoords(obstacles[(point-1)/4])[(point-1) % 4];
            float totalDist = dist + dist(nextPoint.x, nextPoint.y, currentPoint.x, currentPoint.y);
            
            if (totalDist < shortestDistances[point][0]) {
              shortestDistances[point][0] = totalDist;
              shortestDistances[point][1] = i;
            }
          }
        }
      }
    }
    
    if (nextPoints.size() == 0)
      break;
      
    for (int[] index : nextPoints) {
      int i = index[0];
      pathInfo[step+1][i] = shortestDistances[i];
    }
    
    for (int i = 0; i < nextPoints.size(); i++) {
      currPoints.add(nextPoints.get(i));
    }
  }
  
  stroke(0, 255, 0);
  strokeWeight(3);
  //println(minIndex);
  int pathIndex = paths.size();
  paths.add(new ArrayList<PVector>());
  
  if (minIndex <= 0) {
    //line(start.x, start.y, end.x, end.y);
    paths.get(pathIndex).add(new PVector(end.x, end.y));
    paths.get(pathIndex).add(new PVector(start.x, start.y));
  }
  else {
    PVector p = cornerCoords(obstacles[(minIndex-1)/4])[(minIndex-1) % 4];
    //line(end.x, end.y, p.x, p.y);
    paths.get(pathIndex).add(new PVector(end.x, end.y));
    paths.get(pathIndex).add(new PVector(p.x, p.y));
  }
  //PVector p1 = p;
  while (minIndex > 0) {
    PVector p1 = cornerCoords(obstacles[(minIndex-1)/4])[(minIndex-1) % 4];
    minIndex = (int) shortestDistances[minIndex][1];
    if (minIndex == 0) {
      //line(p1.x, p1.y, start.x, start.y);
      paths.get(pathIndex).add(new PVector(start.x, start.y));
      break;
    }
      
    PVector p2 = cornerCoords(obstacles[(minIndex-1)/4])[(minIndex-1) % 4];
    
    //line(p1.x, p1.y, p2.x, p2.y);
    paths.get(pathIndex).add(new PVector(p2.x, p2.y));
  }
  stroke(0);
  strokeWeight(1);
  //println(shortestDistances[3]);
  
}

//void draw() {
//  noLoop();
//  fill(255, 0, 0);
//  strokeWeight(1);
//  for (int[] ob : obstacles)
//    rect(ob[0], ob[1], ob[2] - ob[0], ob[3] - ob[1]);

//  //pathFind(new PVector(700, 500), new PVector(round(random(0, 100)), round(random(0, 599))));
//  //shortestDistancesCopy = new float[obstacles.length * 4 + 1][2];
//  //for (int i = 0; i < shortestDistances.length; i++) {
//  //  for (int j = 0; j < 2; j++)
//  //    shortestDistancesCopy[i][j] = shortestDistances[i][j];
//  //}
  
//  for (int i = 0; i < 1; i++) {
//    //pathFind(new PVector(420, 300), new PVector(round(random(0, 100)), round(random(0, 599))));
//    //pathFind(new PVector(420, 300), new PVector(round(random(0, 799)), round(random(0, 70))));
//    //pathFind(new PVector(420, 300), new PVector(round(random(700, width)), round(random(0, 599))));
//    //pathFind(new PVector(420, 300), new PVector(round(random(500, height)), round(random(0, 600))));
//    pathFind(new PVector(700, 500), new PVector(420, 300));
//    pathFind(new PVector(420, 300), new PVector(100, 150));
//  }
  
//  ////todo: make it so that middle points will not be chosen (like it was before)
//  //// for each obstacle, only check two corners that are relevant (if three can be reached, second and third farthest, if two can be reached, two closest
//  //// when two can be reached, starting point within either width or height of obstacle (cross area)
//  //// when three can be reached, starting point anywhere but the cross area
//  //// use that knowledge to select the two points that should be checked
//  //// proceed as normal (same, just less corners, therefore less branches)
//  ////if no time, just take order as provided in shopping list
//  ////todo: clean up stinky code
  
//}

int unblockedCorners(PVector startPoint, int[] obCoords) {
  if (obCoords[0] < startPoint.x && startPoint.x < obCoords[2] || obCoords[1] < startPoint.y && startPoint.y < obCoords[3])  // if a point can only directly go two points on a rectangle, it must be positioned in the cross extending off the rectangle
    return 2;
  else  // any other case, the point will be able to directly access 3 of 4 points
    return 3;
}

PVector[] cornerCoords(int[] obsCoords) {
  //int numCorners = unblockedCorners(startPoint, obsCoords);
  PVector TL = new PVector(obsCoords[0], obsCoords[1]);  // Top left
  PVector TR = new PVector(obsCoords[2], obsCoords[1]);  // Top right
  PVector BL = new PVector(obsCoords[0], obsCoords[3]);  // Bottom left
  PVector BR = new PVector(obsCoords[2], obsCoords[3]);  // Bottom right
  
  return new PVector[]{TL, TR, BL, BR};
}


 //<>//
//todo: figure out intersection not being caught (mostly positive slope lines)
//figure out no intersections not being counted
boolean intersectionFound(int[] obsCoords, PVector startCoords, PVector endCoords) {
    int x1 = (int) startCoords.x;
    int y1 = (int) startCoords.y;
    int x2 = (int) endCoords.x;
    int y2 = (int) endCoords.y;
    
    float m = (float) (y2-y1) / (x2-x1);
    float b = y2 - m*x2;
    
    obsCoords = append(obsCoords, (x1+x2)/2);
    
    for (int i = 0; i < obsCoords.length; i++) {
      int coord = obsCoords[i];
      int otherCoord;
      
      if (i % 2 == 0) {  //known coord is x-coordinate
        
        otherCoord = round(m*coord + b);
        
        if (min(obsCoords[1], obsCoords[3]) < otherCoord && otherCoord < max(obsCoords[1], obsCoords[3]) && min(x1, x2) < coord && coord < max(x1, x2))
          return true;
        
      }
      
      else {  //known coordinate is y
        
        otherCoord = round((coord-b)/m);
        
        if (min(obsCoords[0], obsCoords[2]) < otherCoord && otherCoord < max(obsCoords[0], obsCoords[2]) && min(y1, y2) < coord && coord < max(y1, y2))
          return true;
        
      }
        

    }
    
    return false;  // If not returned yet, intersection has not been found
}




boolean pathToCorner(PVector cornerCoords, PVector initialCoords, int obIndex) {
  int xStep = 0;
  int yStep = 0;
  
  if (cornerCoords == initialCoords)
    return true;
  
  if (initialCoords.x < cornerCoords.x)
    xStep = -1;
  else if (initialCoords.x > cornerCoords.x)
    xStep = 1;
    
  if (initialCoords.y < cornerCoords.y)
    yStep = -1;
  else if (initialCoords.y > cornerCoords.y)
    yStep = 1;
    
  int newX = (int) cornerCoords.x + xStep;
  int newY = (int) cornerCoords.y + yStep;
  int[] ob = obstacles[obIndex];
  //println(ob);
  //println(newX, newY, "DDDDDDDDDDDDDDDDDDDDDDD");
  return ob[0] < newX && newX < ob[2] && ob[1] < newY && newY < ob[3];
}


boolean in(int[] array, int element) {
  for (int el : array) {
    if (el == element)
      return true;
  }
  
  return false;
}
