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

// INITIALIZATION
ArrayList<PVector> nextSteps = new ArrayList<PVector>();
//int[][] obstacles = new int[][]{new int[]{675, 100, 700, 500}, new int[]{75, 250, 200, 375}, new int[]{75, 395, 200, 520}, new int[]{0, 100, 25, 300}, new int[]{0, 320, 35, 599}, new int[]{200, 565, 790, 599}, new int[]{150, 170, 280, 180}, new int[]{395, 365, 430, 475}, new int[]{300, 100, 310, 350}, new int[]{320, 100, 330, 350}, new int[]{340, 100, 350, 350}, new int[]{360, 100, 370, 350}, new int[]{380, 100, 390, 350}, new int[]{400, 100, 410, 350}, new int[]{450, 250, 550, 450}, new int[]{290, 390, 390, 500}, new int[]{250, 200, 260, 400}};//new int[]{round(random(0, 800)), round(random(0, 600)), round(random(0, 800)), round(random(0, 600))}, new int[]{round(random(0, 800)), round(random(0, 600)), round(random(0, 800)), round(random(0, 600))}, new int[]{round(random(0, 800)), round(random(0, 600)), round(random(0, 800)), round(random(0, 600))}, new int[]{round(random(0, 800)), round(random(0, 600)), round(random(0, 800)), round(random(0, 600))}};
int[][] viableNextSteps = new int[obstacles.size() * 4 + 1][];  // viable next steps for each corner, +1 so that no corner has index 0 (when finding corner index, object index * 4 + corner# + 1), index 0 is start point
float[][] shortestDistances = new float[obstacles.size() * 4 + 1][2];  //index 0 is dist, index 1 is point index of point it came from to get that dist
float[][] shortestDistancesCopy = new float[obstacles.size() * 4 + 1][2];
float[][][] pathInfo = new float[obstacles.size() * 4][obstacles.size() * 4 + 1][2];  //index 1 is last point index, index 0 is dist so far
//int[][] obstX, obstY; 
//int minWidth = -1;
//int minHeight = -1;

int[][][] widthRangeObsCheck;
int[][][] heightRangeObsCheck;

int obsLen = obstacles.size();

ArrayList<int[]> currPoints = new ArrayList<int[]>();  //dynamic arraylist because length will change constantly
ArrayList<int[]> nextPoints = new ArrayList<int[]>();

int[] nextPointsCounter = new int[obstacles.size() * 4 + 1];

float minDist = -1;
int minIndex = -1;


String[] pathFind(PVector start, PVector end, int startIndex, int endIndex) {
  // reinitialize all variables and lists
  nextSteps = new ArrayList<PVector>();
  viableNextSteps = new int[obstacles.size() * 4 + 1][];  // viable next steps for each corner, +1 so that no corner has index 0 (when finding corner index, object index * 4 + corner# + 1), index 0 is start point
  shortestDistances = new float[obstacles.size() * 4 + 1][2];  //index 0 is dist, index 1 is point index of point it came from to get that dist
  pathInfo = new float[obstacles.size() * 4][obstacles.size() * 4 + 1][2];  //index 1 is last point index, index 0 is dist so far
  //todo: may not need pathInfo
  obsLen = obstacles.size();
  
  currPoints = new ArrayList<int[]>();
  nextPoints = new ArrayList<int[]>();
  
  nextPointsCounter = new int[obstacles.size() * 4 + 1];
  
  minDist = -1;
  minIndex = -1;
  
  
  //fill(0, 0, 255);
  //circle(start.x, start.y, 10);
  //circle(end.x, end.y, 10);
  //fill(0);
  //strokeWeight(4);
  //line(start.x, start.y, end.x, end.y);
  //strokeWeight(1);
  
  // 2d array containing information about which obstacles can be found in each pixel range for both x and y
  widthRangeObsCheck = new int[width][width][0];  // index i is the lowest number of the range, index j is the highest, array at [i][j] would contain all indices of obstacles with x values in that range
  heightRangeObsCheck = new int[height][height][0];  // same but for y
  
  // Iterate through all obstacles
  for (int i = 0; i < obstacles.size(); i++) {
    int[] ob = obstacles.get(i);
    // Ranges that should be updated include ranges with lowest value less than obstacle's rightmost x and highest value more than obstacle's leftmost x
    for (int lower = 0; lower < ob[2]; lower++) {
      for (int higher = max(lower + 1, ob[0] + 1); higher < width; higher++)
        widthRangeObsCheck[lower][higher] = append(widthRangeObsCheck[lower][higher], i);
    }
    
    // Update ranges with lowest val less than bottommost y (largest y for the obstacle) and highest more than topmost y (smallest y)
    for (int lower = 0; lower <= ob[3]; lower++) {
      for (int higher = max(lower + 1, ob[1]); higher < height; higher++)
        heightRangeObsCheck[lower][higher] = append(heightRangeObsCheck[lower][higher], i);
    }
  }
  
  currPoints.add(new int[]{0});  // Add the start point as the first point
  
  // initialization finished
  
  //todo: make it so that middle points will not be chosen (like it was before)
  // for each obstacle, only check two corners that are relevant (if three can be reached, second and third farthest, if two can be reached, two closest
  // when two can be reached, starting point within either width or height of obstacle (cross area)
  // when three can be reached, starting point anywhere but the cross area
  // use that knowledge to select the two points that should be checked
  // proceed as normal (same, just less corners, therefore less branches)
  //if no time, just take order as provided in shopping list
  //todo: clean up stinky code
  
  // each step would involve each path moving forward by one line segment (max path length would go through each obstacle corner once)
  for (int step = -1; step < pathInfo.length - 1; step++) {
    // Loop through indices of current last points of each path
    for (int[] index : currPoints) {
      int i = index[0];
      
      PVector currentPoint;
      float dist;
      
      // Index 0 is always the start point
      if (i == 0) {
        currentPoint = start;
        dist = 0;
      }
      
      // otherwise, find coords of point and distance of path so far
      else {
        // Specific coords of a point
        currentPoint = pointCoords(i);
        dist = pathInfo[step][i][0];
      }
        
      //todo (fix):
      //if (shortestDistancesCopy[i][0] != 0) {
      //  println(i);
      //  float totalDist = dist + shortestDistancesCopy[i][0];
      //  if (minDist == -1 || totalDist < minDist) {
      //    minDist = dist;
      //    minIndex = i;
      //  }
        
      //  //float partialDist = dist(
      //}
          
      // If no data in terms of optimal next steps from the current corner, create empty array and call function to get the required data
      if (viableNextSteps[i] == null) {
        viableNextSteps[i] = new int[0];
        
        // Finds the corners that a point can directly go to which are part of obstacles that are in the way of the path going from the point directly to the destination
        getNextValidPoints(currentPoint, end, start, dist, i);
      }
      
      // If data available already, no need to call function
      else {
        // Loop through all optimal next corners
        for (int point : viableNextSteps[i]) {
          //if (shortestDistances[point][0] == 0)
          //  continue;
            
          //else {
            
          PVector nextPoint = pointCoords(point);  // Coords of the point
          float totalDist = dist + dist(nextPoint.x, nextPoint.y, currentPoint.x, currentPoint.y);  // Distance of path including that point
          
          // If dist found is less than the current minimum distance to the point from the starting point, discard point from list of next points for the point that was originally though to be the best previous point
          // then update shortestDistances according to the new previous point in the new path
          if (totalDist < shortestDistances[point][0]) {
            discard(viableNextSteps[(int) shortestDistances[point][1]], point);
            shortestDistances[point][0] = totalDist;
            shortestDistances[point][1] = i;  // i is index of the point with this point in its viableNextSteps array (the point right before this point)
          }
          //}
        }
      }
    }
    
    // If there are no next points to check, pathfinding is finished (break out of outer loop)
    if (nextPoints.size() == 0)
      break;
      
    // Each iteration, update path info according to info found and stored in shortestDistances
    for (int[] index : nextPoints) {
      int i = index[0];
      pathInfo[step+1][i] = shortestDistances[i];
    }
    
    // Next points become current points
    for (int i = 0; i < nextPoints.size(); i++) {
      currPoints.add(nextPoints.get(i));
    } //<>// //<>//
  }
  
  // At this point, the optimal path has already been determined
  stroke(0, 255, 0);
  strokeWeight(3);
  //println(minIndex);
  int pathIndex = paths.size();
  paths.add(new ArrayList<int[]>());  // Add ArrayList into paths which would contain all points in the path determined
  
  float totalDistance = 0;
  
  // If minIndex <= 0, there were no obstacles at all from start to end
  if (minIndex <= 0) {
    //line(start.x, start.y, end.x, end.y);
    paths.get(pathIndex).add(new int[]{endIndex});
    paths.get(pathIndex).add(new int[]{startIndex});
    totalDistance = dist(start.x, start.y, end.x, end.y);
  }
  
  else {  // Otherwise, first add the last and second last points
    PVector p = pointCoords(minIndex);
    totalDistance = dist(p.x, p.y, end.x, end.y);
    //line(end.x, end.y, p.x, p.y);
    paths.get(pathIndex).add(new int[]{endIndex});
    paths.get(pathIndex).add(new int[]{minIndex});
    
  }
  
  //PVector p1 = p;
  // Loop through all points in path based on point indices stored in shortestDistances (in shortestDistances, each point would store the index of the previous point in the best path from start to itself)
  while (minIndex > 0) {
    PVector p1 = pointCoords(minIndex);
    minIndex = (int) shortestDistances[minIndex][1];
    if (minIndex == 0) {
      //line(p1.x, p1.y, start.x, start.y);
      totalDistance += dist(p1.x, p1.y, start.x, start.y);
      paths.get(pathIndex).add(new int[]{startIndex});
      break;
    }
      
    PVector p2 = pointCoords(minIndex);
    
    //line(p1.x, p1.y, p2.x, p2.y);
    totalDistance += dist(p1.x, p1.y, p2.x, p2.y);
    paths.get(pathIndex).add(new int[]{minIndex});
  }
  stroke(0);
  strokeWeight(1);
  
  return new String[]{str(totalDistance), pathToString(paths.get(pathIndex))};
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

// Finds number of corners on an obstacle a point to get to directly (not accounting for other obstacles)
//todo: implement this
int unblockedCorners(PVector startPoint, int[] obCoords) {
  if (obCoords[0] < startPoint.x && startPoint.x < obCoords[2] || obCoords[1] < startPoint.y && startPoint.y < obCoords[3])  // if a point can only directly go two points on a rectangle, it must be positioned in the cross extending off the rectangle
    return 2;
  else  // any other case, the point will be able to directly access 3 of 4 points
    return 3;
}

// Returns list containing coords of corners given an obstacle
PVector[] cornerCoords(int[] obsCoords) {
  //int numCorners = unblockedCorners(startPoint, obsCoords);
  PVector TL = new PVector(obsCoords[0], obsCoords[1]);  // Top left
  PVector TR = new PVector(obsCoords[2], obsCoords[1]);  // Top right
  PVector BL = new PVector(obsCoords[0], obsCoords[3]);  // Bottom left
  PVector BR = new PVector(obsCoords[2], obsCoords[3]);  // Bottom right
  
  return new PVector[]{TL, TR, BL, BR};
}


PVector[] relevantCornerCoords(PVector startPoint, int[] obsCoords) {
  PVector[] corners = cornerCoords(obsCoords);
  PVector[] relevantCorners = new PVector[4];
  int numReachable = unblockedCorners(startPoint, obsCoords);
  
  int[] selectedIndices = new int[]{-1, -1};
  //PVector[] selectedCorners = new PVector[2];
  
  if (numReachable == 2) {
    if (obsCoords[0] < startPoint.x && startPoint.x < obsCoords[2]) {
      if (startPoint.y <= obsCoords[1])
        selectedIndices = new int[]{0, 1};
      else
        selectedIndices = new int[]{2, 3};
    }
    
    else if (obsCoords[1] < startPoint.y && startPoint.y < obsCoords[3]) {
      if (startPoint.x <= obsCoords[0])
        selectedIndices = new int[]{0, 2};
      else
        selectedIndices = new int[]{1, 3};
    }
    
    for (int index : selectedIndices)
      relevantCorners[index] = corners[index];

      
  }
  
  else {
    //get middle two in terms of dist
    float minDist = -1, maxDist = -1;
    int minIndex = -1, maxIndex = -1;
    PVector minCorner = new PVector();
    PVector maxCorner = new PVector();
    
    for (int c = 0; c < 4; c++) {
      PVector corner = corners[c];
      float dist = dist(corner.x, corner.y, startPoint.x, startPoint.y);
      
      if (minDist == -1) {
        minDist = dist;
        minIndex = c;
        minCorner = corner;
        continue;
      }
      else if (maxDist == -1) {
        if (dist >= minDist) {
          maxDist = dist;
          maxIndex = c;
          maxCorner = corner;
        } else {
          maxDist = minDist;
          maxIndex = minIndex;
          maxCorner = minCorner;
          minDist = dist;
          minIndex = c;
          minCorner = corner;
        }
        continue;
      }
      
      
      if (dist < minDist) {
        relevantCorners[minIndex] = minCorner;
        minDist = dist;
        minIndex = c;
        minCorner = corner;
      } else if (dist > maxDist) {
        relevantCorners[maxIndex] = maxCorner;
        maxDist = dist;
        maxIndex = c;
        maxCorner = corner;
      } else {
        relevantCorners[c] = corner;
      }
        
    }
  }
  //for (PVector c : relevantCorners)
  //  println(c);
  return relevantCorners;
}

//todo: own pathfinding for all shoppers
//todo: add second middle line for intersection finding(done)
//todo: user decides order if not time
//todo: user can drag points


//todo: figure out intersection not being caught (mostly positive slope lines)
//figure out no intersections not being counted
// Checks if an obstacle is intersected by a path (checks for intersection between line segments involved)
boolean intersectionFound(int[] obsCoords, PVector startCoords, PVector endCoords) {
    int x1 = (int) startCoords.x; //<>//
    int y1 = (int) startCoords.y;
    int x2 = (int) endCoords.x;
    int y2 = (int) endCoords.y;
    
    float m = (float) (y2-y1) / (x2-x1);
    float b = y2 - m*x2;
    
    obsCoords = concat(obsCoords, new int[]{(obsCoords[0]+obsCoords[2])/2, (obsCoords[1]+obsCoords[3])/2});
    
    for (int i = 0; i < obsCoords.length; i++) {
      int coord = obsCoords[i];
      int otherCoord;
      
      if (i % 2 == 0) {  //known coord is x-coordinate
        
        otherCoord = round(m*coord + b);
        
        
        if (min(obsCoords[1], obsCoords[3]) < otherCoord && otherCoord < max(obsCoords[1], obsCoords[3]) && min(x1, x2) < coord && coord < max(x1, x2))
          return true;
        
      }
      
      else {  //known coordinate is y
        if (x1 == x2) {
          if (min(y1, y2) < coord && coord < max(y1, y2) && obsCoords[0] < x1 && x1 < obsCoords[1])
            return true;
        }
          
        else {
          otherCoord = round((coord-b)/m);
          
          if (min(obsCoords[0], obsCoords[2]) < otherCoord && otherCoord < max(obsCoords[0], obsCoords[2]) && min(y1, y2) < coord && coord < max(y1, y2))
            return true;
        }
        
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
  int[] ob = obstacles.get(obIndex);
  //println(ob);
  //println(newX, newY, "DDDDDDDDDDDDDDDDDDDDDDD");
  return ob[0] < newX && newX < ob[2] && ob[1] < newY && newY < ob[3];
}
