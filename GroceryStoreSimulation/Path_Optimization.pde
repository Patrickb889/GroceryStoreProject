boolean ignoreStock = true;  // Whether or not urgency relating to supply will be considered in path calculations
float busyness = numShoppers/10.;  // Coefficient of urgency

// Uses greedy algorithm (may not always find the absolute best path, but is still able to find good approximations)
void search(int pathLength) {
  float maxPriority = -1;
  int maxIndex = -1;
  int currPointIndex;  // Index of the fixture the current point belongs to
  
  if (pathLength == 0)  // pathLength is length of path calculated so far, not length of final path
    currPointIndex = 0;  // 0 is not included in requiredPoints
  else
    currPointIndex = requiredPoints[pathLength-1];
  
  // When a point is deemed the best next point, it is swapped to the front of requiredPoints
  // This means when checking which point should come next, the front portion of the array (of length pathLength) does not need to be checked
  for (int pointIndex = pathLength; pointIndex < requiredPoints.length; pointIndex++) {
    // Calculate priority of the point and update according to current max
    float priority = pointPriority(currPointIndex, requiredPoints[pointIndex]);
    if (priority == -1) {
      pathFound = false;
      return;
    }
    
    if (priority > maxPriority) {
      maxPriority = priority;
      maxIndex = pointIndex;
    }
  }
  
  swap(requiredPoints, pathLength, maxIndex);  // Move point with max priority to front of array
  
  // If path calculation is approx mode, the specific path between the most recent point swapped and second most recent point swapped with all the intermediate corners passed needs to be calculated
  if (pathAccuracy.equals("Approx")) {
    // Update for entrance and first point on first iteration
    if (pathLength == 0)
      updatePathInfo(0, requiredPoints[0]);
      
    // Update for most recent and second most recent otherwise
    if (pathLength > 0 || requiredPoints.length <= 2) {
      int i = requiredPoints[pathLength - 1 + int(pathLength == 0)];
      int j = requiredPoints[pathLength + int(pathLength == 0)];
      updatePathInfo(min(i, j), max(i, j));  // Smaller value comes first (just the convention set in the program)
      fixtures.get(i).defPointModified = false;  // Once path has been calculated, all modifications have been accounted for
      
      // Update for most recent point and last remaining point as well as last remaining point and exit on last iteration
      if (pathLength == requiredPoints.length - 2) {
        int lastPointIndex = requiredPoints[requiredPoints.length - 1];
        updatePathInfo(min(j, lastPointIndex), max(j, lastPointIndex));
        updatePathInfo(1, lastPointIndex);
        
        fixtures.get(j).defPointModified = false;
        fixtures.get(lastPointIndex).defPointModified = false;
      }
        
    }
    
  }
}


// Calls pathFind() to update allDistance and optimalPaths
void updatePathInfo(int i, int j) {  //i < j
  // Only updates if the required path is currently uncalculated, or if any of the points involved has been modified
  if (optimalPaths[i][j] == null || optimalPaths[i][j].equals("null") || fixtures.get(i).defPointModified || fixtures.get(j).defPointModified) {
    PVector p1 = fixtures.get(i).defaultPoint;
    PVector p2 = fixtures.get(j).defaultPoint;
    
    String[] pathInfo = pathFind(p1, p2, i, j);
     //<>//
    allDistances[i][j] = float(pathInfo[0]);
    optimalPaths[i][j] = pathInfo[1];
    
  }
}

// Calculates priority of a point (point with highest priority will be the next point in the path)
float pointPriority(int currPointIndex, int nextPointIndex) {
  float distToPoint, distToDest;
  
  if (pathAccuracy.equals("Accurate")) {  // If in accurate mode, grab the calculated distances from the array
    distToPoint = allDistances[min(currPointIndex, nextPointIndex)][max(currPointIndex, nextPointIndex)];  // Distance from current point to next point
    distToDest = allDistances[1][nextPointIndex];  // Distance from the next point being checked to the exit
    
    if (distToPoint == 0)
      return -1;
  }
  
  else {  // If in approx mode, dists will just be shortest dist (straight path) between the points
    PVector currPoint = fixtures.get(currPointIndex).defaultPoint;
    PVector nextPoint = fixtures.get(nextPointIndex).defaultPoint;
    
    distToPoint = dist(currPoint.x, currPoint.y, nextPoint.x, nextPoint.y);
    distToDest = dist(nextPoint.x, nextPoint.y, exit.x, exit.y);
  }

  float priority = distToDest/distToPoint;  // Farther distance from exit means it should be visited earlier in the path (higher distance means higher priority so it's on the numerator)
                                            // Closer distance to current point also means it has higher priority (lower distance means higher priority so it's on the denominator)
  
  // Adjust priority based on urgency if needed
  if (!ignoreStock) {
    Fixture f = fixtures.get(nextPointIndex);
    
    if (f.stock == 0)
      return 0;  // if stock is 1, priority very high, but if stock is 0, no more priority
    
    priority += f.urgency * busyness;
  }
    
  return priority;
}


// Swaps values at two indices
void swap(int[] arr, int i1, int i2) {
  int tempStorage = arr[i1];
  
  arr[i1] = arr[i2];
  arr[i2] = tempStorage;
}
