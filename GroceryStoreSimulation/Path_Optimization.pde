//PVector start = new PVector(700, 590);
//PVector end = new PVector(100, 590);
//PVector[] points = new PVector[20];
//int[] pointIndices = new int[50];

//int pathLength = 0;

//void setup() {
//  size(800, 600);
  
//  fill(0, 0, 255);
//  for (int i = 0; i < points.length; i++) {
//    PVector newPoint = new PVector(round(random(10, width-10)), round(random(10, height-10)));
//    points[i] = newPoint;
//    circle(newPoint.x, newPoint.y, 10);
//  }
  
//}


//void draw() {
//  //noLoop();
//  ///////////////////
//  for (int pathLength = 0; pathLength < pointsList.size() - 1; pathLength++) {  // only pointsList.size() - 1 iterations because between the last two points not counting the exit, if one is chosen, the other has to be last (no need to check what is already known)
//    search(pathLength);
//  }
//  ///////////////////
//  //stroke(255, 0, 0);
//  //strokeWeight(3);
  
//  //line(start.x, start.y, points[0].x, points[0].y);
  
//  //for (int i = 1; i < points.length; i++)
//  //  line(points[i].x, points[i].y, points[i-1].x, points[i-1].y);
    
//  //line(points[points.length-1].x, points[points.length-1].y, end.x, end.y);
  
//}


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
  
  return distToDest/distToPoint;  // Longer distance from destination means higher priority (points farther away from destination should be passed earlier in the path)
                                  // Shorter distance to current point also means higher priority (inverse relationship so it's on the denominator)
}


void swap(int[] arr, int i1, int i2) {
  int tempStorage = arr[i1];
  
  arr[i1] = arr[i2];
  arr[i2] = tempStorage;
}
