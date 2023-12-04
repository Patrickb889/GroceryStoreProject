int[] potentialObs(PVector currPoint, PVector destination) {
  
  if (max(currPoint.x, destination.x) == 0 || min(currPoint.x, destination.x) == 799 || max(currPoint.y, destination.y) == 0 || min(currPoint.y, destination.y) == 599)
    return new int[]{};
    
  int[] potentialObsX = widthRangeObsCheck[(int) min(currPoint.x, destination.x)][(int) max(min(currPoint.x, destination.x) + 1, max(currPoint.x, destination.x))];
  int[] potentialObsY = heightRangeObsCheck[(int) min(currPoint.y, destination.y)][(int) max(min(currPoint.y, destination.y) + 1, max(currPoint.y, destination.y))];
  
  
    
  //println(potentialObsX);
  //println(potentialObsY);
  if (potentialObsX.length > potentialObsY.length)
    return potentialObsY;
  else
    return potentialObsX; 
}

boolean obsPresent(PVector destination, PVector currPoint) {  // checks whether or not there are obstacles in the way of a path
  
  //if (!pathToCorner(destination, destination, obIndex))
  //  return true;
    
    
  int[] potObs = potentialObs(currPoint, destination);
  
  for (int i : potObs) {
    //println(destination);
    //println(obstacles[i]);
    //println(currPoint);
    //if (destination.x == 450 && destination.y == 450 && currPoint.x == 390 && currPoint.y == 400) //<>// //<>//
    //println(intersectionFound(obstacles[i], currPoint, destination));
    //println(pathToCorner(currPoint, destination));
    if (intersectionFound(obstacles[i], currPoint, destination)) {
      //println(intersectionFound(obstacles[i], currPoint, destination));
      //println(pathToCorner(currPoint, destination));
      return true;
    }
    //println(obsFound);
  }
  
  //return obsFound;
  return false;
}

void getNextValidPoints(PVector currPoint, PVector destination, PVector startingPoint, float distSoFar, int pointIndex) {
  int[] potObs = potentialObs(currPoint, destination);
  if (pointIndex == 6) {
    //println("PPPPPPPPP");
    //println(potObs);
    //println("PPPPPPPP");
  }
  int obsToDest = 0;
  //println("A");
  if (distSoFar + dist(currPoint.x, currPoint.y, destination.x, destination.y) >= minDist && minDist != -1)
    return;
  
  for (int i : potObs) {
    //println("B");
    int[] obsCoords = obstacles[i];
    //println(i, "EEEE");
    //println(obsCoords);
    //if (i == 1) {
    //  println("");
    //}
    if (intersectionFound(obsCoords, currPoint, destination)) {
      //if (pointIndex == 6) {
        //println("PPPPPPPPP");
        //println(obsCoords);
        //println("PPPPPPPP");
      //}
      obsToDest += 1;
      //println("C");
      PVector[] corners = relevantCornerCoords(currPoint, obsCoords);
      for (int c = 0; c < 4; c++) {
        PVector corner = corners[c];
        
        if (corner == null)
          continue;
        //if (pointIndex == 6) {
          //println("PPPPPPPPP");
          //println(pointIndex);
          //println(currPoint);
          //println(corner);
          //println("AAA", obsPresent(currPoint, corner, (pointIndex-1)/4));
          //println("PPPPPPPP");
        //}
        
        if (!obsPresent(currPoint, corner)) {
          //println("D");
          float dist = distSoFar + dist(currPoint.x, currPoint.y, corner.x, corner.y);
          int cornerIndex = i*4 + c + 1;
          if (shortestDistances[cornerIndex][0] == 0 || dist < shortestDistances[cornerIndex][0]) {
            if (nextPointsCounter[cornerIndex] == 0) {
              nextPointsCounter[cornerIndex] = 1;
              nextPoints.add(new int[]{cornerIndex});
            }
            if (pointIndex == 0) {
              PVector p1 = startingPoint;
              PVector p2 = pointCoords(cornerIndex);
              line(p1.x, p1.y, p2.x, p2.y);
            }
            else {
              PVector p1 = pointCoords(pointIndex);
              PVector p2 = pointCoords(cornerIndex);
              line(p1.x, p1.y, p2.x, p2.y);
            }
            viableNextSteps[pointIndex] = append(viableNextSteps[pointIndex], cornerIndex);
            if (shortestDistances[cornerIndex][0] != 0)
              viableNextSteps[(int) shortestDistances[cornerIndex][1]] = discard(viableNextSteps[(int) shortestDistances[cornerIndex][1]], cornerIndex);
            shortestDistances[cornerIndex][0] = dist;
            shortestDistances[cornerIndex][1] = pointIndex;
          }
        }
      }
    }
  }
  if (obsToDest == 0) {
    float dist = distSoFar + dist(currPoint.x, currPoint.y, destination.x, destination.y);
    if (minDist == -1 || dist < minDist) {
      minDist = dist;
      minIndex = pointIndex;
    }
  }
}


int getIndex(int[] arr, int el) {
  for (int i = 0; i < arr.length; i++) {
    if (arr[i] == el)
      return i;
  }
  return -1;
}

int[] discard(int[] arr, int el) {
  int splitIndex = getIndex(arr, el);
  
  return concat(subset(arr, 0, splitIndex), subset(arr, splitIndex + 1));
}
