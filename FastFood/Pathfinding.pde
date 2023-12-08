// INITIALIZATION
ArrayList<PVector> nextSteps = new ArrayList<PVector>();  // The next points selected during each step of searching
int[][] viableNextSteps = new int[obstacles.size() * 4 + 1][];  // Viable next points from each corner, +1 so that no corner has index 0 (when finding corner index, object index * 4 + corner# + 1), index 0 is start point
float[][] shortestDistances = new float[obstacles.size() * 4 + 1][2];  // Index 0 is distance of shortest path to the point, index 1 is index of point it came from to get that distance (only for current search step)
float[][][] pathInfo = new float[obstacles.size() * 4][obstacles.size() * 4 + 1][2];  // Index 0 is dist so far, index 1 is last point index (difference is that it stores these values for every single search step)

int obsLen = obstacles.size();

ArrayList<int[]> currPoints = new ArrayList<int[]>();  // Dynamic ArrayList because length will change constantly
ArrayList<int[]> nextPoints = new ArrayList<int[]>();

int[] nextPointsCounter = new int[obstacles.size() * 4 + 1];  // Keeps track of which points have been considered as part of the path already to prevent unnecessary repetition

float minDist = -1;
int minIndex = -1;


String[] pathFind(PVector start, PVector end, int startIndex, int endIndex) {
  // Reinitialize all variables and lists
  nextSteps = new ArrayList<PVector>();
  viableNextSteps = new int[obstacles.size() * 4 + 1][];
  shortestDistances = new float[obstacles.size() * 4 + 1][2];
  pathInfo = new float[obstacles.size() * 4][obstacles.size() * 4 + 1][2];
  obsLen = obstacles.size();
  
  currPoints = new ArrayList<int[]>();
  nextPoints = new ArrayList<int[]>();
  
  nextPointsCounter = new int[obstacles.size() * 4 + 1];
  
  minDist = -1;
  minIndex = -1;
  
  currPoints.add(new int[]{0});  // Add the start point as the first point
  
  // INITIALIZATION FINISHED //
  
  
  // Each step would involve each path moving forward by one line segment (max path length would go through each obstacle corner once)
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
      
      // Otherwise, find coords of point and distance of path so far
      else {
        // Specific coords of a point
        currentPoint = pointCoords(i);
        dist = pathInfo[step][i][0];
      }
        
          
      // If no data in terms of optimal next steps from the current corner, create empty array and call function to get the required data
      if (viableNextSteps[i] == null) {
        viableNextSteps[i] = new int[0];
        
        // Finds the corners that a point can directly go to which are part of obstacles that are in the way of the path going from the point directly to the destination
        getNextValidPoints(currentPoint, end, start, dist, i);
      }
      
      // If data available already, no need to call function
      else {
        // Loop through all viable next corners
        for (int point : viableNextSteps[i]) {
          PVector nextPoint = pointCoords(point);  // Coords of the point
          float totalDist = dist + dist(nextPoint.x, nextPoint.y, currentPoint.x, currentPoint.y);  // Distance of path including that point
          
          // If dist found is less than the current minimum distance to the point from the starting point, discard point from list of next points for the point that was originally though to be the best previous point
          // then update shortestDistances according to the new previous point in the new path
          if (totalDist < shortestDistances[point][0]) {
            discard(viableNextSteps[(int) shortestDistances[point][1]], point);
            shortestDistances[point][0] = totalDist;
            shortestDistances[point][1] = i;  // i is index of the point with this point in its viableNextSteps array (the point right before this point)
          }
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
    }
  }
  
  // At this point, the optimal path has already been determined
  int pathIndex = paths.size();
  paths.add(new ArrayList<int[]>());  // Add ArrayList into paths which would contain all points in the path determined
  
  float totalDistance = 0;
  
  // If minIndex <= 0, there were no obstacles at all from start to end
  if (minIndex <= 0) {
    paths.get(pathIndex).add(new int[]{endIndex});  // Path will just be straight line from start to end
    paths.get(pathIndex).add(new int[]{startIndex});
    totalDistance = dist(start.x, start.y, end.x, end.y);
  }
  
  else {  // Otherwise, first add the last and second last points
    PVector p = pointCoords(minIndex);
    totalDistance = dist(p.x, p.y, end.x, end.y);
    
    paths.get(pathIndex).add(new int[]{endIndex});
    paths.get(pathIndex).add(new int[]{minIndex});
    
  }
  
  
  // Loop through all points in path based on point indices stored in shortestDistances (in shortestDistances, each point would store the index of the previous point in the best path from start to itself)
  while (minIndex > 0) {
    PVector p1 = pointCoords(minIndex);
    minIndex = (int) shortestDistances[minIndex][1];
    if (minIndex == 0) {
      totalDistance += dist(p1.x, p1.y, start.x, start.y);
      
      paths.get(pathIndex).add(new int[]{startIndex});
      break;
    }
      
    PVector p2 = pointCoords(minIndex);
    
    totalDistance += dist(p1.x, p1.y, p2.x, p2.y);
    paths.get(pathIndex).add(new int[]{minIndex});
  }
  
  return new String[]{str(totalDistance), pathToString(paths.get(pathIndex))};
  
}


// Finds all the meaningful points (corners of obstacles in the way) a path could go to next from its current point
void getNextValidPoints(PVector currPoint, PVector destination, PVector startingPoint, float distSoFar, int pointIndex) {
  int obsToDest = 0;
  float angleToDest = new PVector(destination.x - currPoint.x, destination.y - currPoint.y).heading();//
  
  // If distance of path so far + minimum possible distance to destination is already greater than minimum already found, no point in getting next points
  if (distSoFar + dist(currPoint.x, currPoint.y, destination.x, destination.y) >= minDist && minDist != -1)
    return;
  
  ArrayList<PVector> leftSideObsCorners = new ArrayList<PVector>();//
  ArrayList<PVector> rightSideObsCorners = new ArrayList<PVector>();//
  
  // Loop through all obstacles
  for (int i = 0; i < obstacles.size(); i++) {
    int[] obsCoords = obstacles.get(i);
    
    if (intersectionFound(obsCoords, currPoint, destination)) {
      obsToDest += 1;
      
      
      PVector[] corners = cornerCoords(obsCoords);
      
      for (PVector corn : corners) {//
        float angle = new PVector(corn.y - currPoint.y, corn.x - currPoint.x).heading();//
        
        if (angleToDest - PI/2 <= angle && angle <= angleToDest || angleToDest <= PI/2 && angle >= angleToDest + 3*PI/2)
          leftSideObsCorners.add(corn);
          
        else if (angleToDest <= angle && angle <= angleToDest + PI/2 || angleToDest >= 3*PI/2 && angle <= angleToDest - 3*PI/2)
          rightSideObsCorners.add(corn);
          
        
      }
      
      // Loop through all 4 corners
      for (int c = 0; c < 4; c++) {
        PVector corner = corners[c];
        
        // Check if there are any obstacles between the current point and the potential next point
        if (!obsPresent(currPoint, corner)) {
          float dist = distSoFar + dist(currPoint.x, currPoint.y, corner.x, corner.y);  // Distance of new path
          int cornerIndex = i*4 + c + 1;  // obstacle index * 4 + corner index + 1 (+1 to account for entrance coords at index 0)
          
          // Information for the next point in shortestDistances will be replaced if it is empty (array {0, 0}), or if the current distance is less than the distance previously found
          if (shortestDistances[cornerIndex][0] == 0 || dist < shortestDistances[cornerIndex][0]) {
            // If the point has already been added to nextPoints, no need to add again
            if (nextPointsCounter[cornerIndex] == 0) {
              nextPointsCounter[cornerIndex] = 1;
              nextPoints.add(new int[]{cornerIndex});  // Only add if not already added
            }

            viableNextSteps[pointIndex] = append(viableNextSteps[pointIndex], cornerIndex);
            
            // If new path is shorter than previous path, discard the corner checked from the list of the point that came right before the corner in the previous path
            if (shortestDistances[cornerIndex][0] != 0)
              viableNextSteps[(int) shortestDistances[cornerIndex][1]] = discard(viableNextSteps[(int) shortestDistances[cornerIndex][1]], cornerIndex);
              
            // Overwrite info in shortestDistances
            shortestDistances[cornerIndex][0] = dist;
            shortestDistances[cornerIndex][1] = pointIndex;
          }
        }
        
        
      }
    }
  }
  
  // If no obstacles between current point and destination, complete path has been found (update minimum distance and index)
  if (obsToDest == 0) {
    float dist = distSoFar + dist(currPoint.x, currPoint.y, destination.x, destination.y);
    if (minDist == -1 || dist < minDist) {
      minDist = dist;
      minIndex = pointIndex;
    }
  }
}
