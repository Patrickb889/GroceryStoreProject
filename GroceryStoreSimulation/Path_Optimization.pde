boolean ignoreStock = true;
float busyness = 0.5;

// Uses greedy algorithm (doesn't always find the absolute best path, but is still able to find some pretty good approximations)
void search(int pathLength) {
  float maxPriority = -1;
  int maxIndex = -1;
  int currPointIndex;
  
  if (pathLength == 0)
    currPointIndex = 0;
  else
    currPointIndex = requiredPoints[pathLength-1];
  
  for (int pointIndex = pathLength; pointIndex < requiredPoints.length; pointIndex++) {
    float priority = pointPriority(currPointIndex, requiredPoints[pointIndex]);
    
    if (priority > maxPriority) {
      maxPriority = priority;
      maxIndex = pointIndex;
    }
  }
  
  swap(requiredPoints, pathLength, maxIndex);  // Move point with max priority to first section (saved section) of array
}

// Calculates priority of a point (point with highest priority will be the next point in the path)
float pointPriority(int currPointIndex, int nextPointIndex) {
  float distToPoint = allDistances[min(currPointIndex, nextPointIndex)][max(currPointIndex, nextPointIndex)];// = dist(currPoint.x, currPoint.y, nextPoint.x, nextPoint.y);  // Distance from current point to next point
  float distToDest = allDistances[1][nextPointIndex];// = dist(nextPoint.x, nextPoint.y, exit.x, exit.y);  // Distance from the next point being checked to the ultimate destination (checkout/store exit)
  
  //todo: after stock and urgency implemented (implement shopper pathfinding first), this will be fixture.get(nextPointIndex).urgency*distToDest/distToPoint
  float priority = distToDest/distToPoint;
  
  if (!ignoreStock) {
    Fixture f = fixtures.get(nextPointIndex);
    if (f.stock == 0)
      return 0;  // if stock is 1, priority very high, but if stock is 0, no more priority
    
    priority += f.urgency * busyness;
  }
    
  return priority;  // Longer distance from destination means higher priority (points farther away from destination should be passed earlier in the path)
                                  // Shorter distance to current point also means higher priority (inverse relationship so it's on the denominator)
}


void swap(int[] arr, int i1, int i2) {
  int tempStorage = arr[i1];
  
  arr[i1] = arr[i2];
  arr[i2] = tempStorage;
}
