// Checks if an element is in an array
boolean in(String[] array, String element) {
  for (String el : array) {
    if (el.equals(element))
      return true;
  }
  
  return false;
}


// Returns the coordinates of a point given its index
PVector pointCoords(int pointIndex) {
  if (pointIndex == 0)
    return entrance;
  else if (pointIndex == 1)
    return exit;
  else
    return cornerCoords(obstacles.get((pointIndex-1)/4))[(pointIndex-1) % 4];  // (index-1)/4 is the obstacle index (divide by 4 because 4 corners per obstacle, -1 is to account for start point that is not part of any obstacle)
                                                                               // (index-1)%4 is to find the index of the specific corner of the specific obstacle (0/1/2/3)
}


// Converts a path of point indices in an ArrayList<int[]> into a string (can't use join() for ArrayList)
String pathToString(ArrayList<int[]> path) {
  String stringPath = str(path.get(0)[0]);
  
  for (int i = 1; i < path.size(); i++)
    stringPath += "-" + str(path.get(i)[0]);
    
  return stringPath;
}


// Sets up values to make path recalculation happen, also draws a "Calculating..." message to the screen for the duration of the recalculation
void recalculatePath() {
  recalcRequired = false;  // recalcRequired is only used to determine whether or not this function is called (has no effect on the actual recalculation of the path) so after this function is called, it should be set to false
  pathCalculated = pathAccuracy.equals("Approx");  // Approx mode does not need a recalculation of every path between every pair of points so pathCalculated would stay true
  pathFound = false;  // pathFound set to false no matter what
  
  textAlign(CENTER, CENTER);
  textSize(50);
  fill(0);
  text("Calculating...", width/2-3, height/2+3);
  text("Calculating...", width/2+1, height/2+1);
  text("Calculating...", width/2-1, height/2-1);
  text("Calculating...", width/2-1, height/2+1);
  text("Calculating...", width/2+1, height/2-1);
  fill(255);
  text("Calculating...", width/2, height/2);
}


// Finds coordinates of the default point of the fixture that an item is found in
PVector findPosition(String item) {
  for (Fixture f : fixtures) {
    for (String product : f.products) {
      if (product.toLowerCase().equals(item.toLowerCase())) {
        PVector position = f.defaultPoint;
        position.z = f.index;  // Index of fixture needs to be stored as well
        
        return f.defaultPoint;
      }
    }
  }
  
  return new PVector(-1, -1);  // (-1, -1) indicates that the item was not found
}


// No value given as parameter means it is not an initial search
void checkShoppingList() {
  checkShoppingList("");
}

// Checks through shopping list to figure out which fixtures need to be visited
void checkShoppingList(String checkMode) {
  int prevNumPoints = 0;
  
  if (checkMode.equals(""))
    prevNumPoints = requiredPoints.length;
  
  // Initialize lists
  pointsList = new ArrayList<PVector>();
  listPointFixtureIndices = new int[shoppingList.length];
  
  pointsList.add(entrance);
  pointsList.add(exit);
  
  // Find positions of all items on list
  for (int i = 0; i < shoppingList.length; i++) {
    PVector pos = findPosition(shoppingList[i]);
    
    if (pos.x != -1) {
      pointsList.add(pos);
      listPointFixtureIndices[i] = int(pos.z);
    }
    
    else {
      println("Sorry,", "'" + shoppingList[i] + "'", "is not a product in this store. Perhaps you made a typo in your shopping list?");
    }
      
  }
  
  
  fixtureCounter = new boolean[fixtures.size()];  // Use counter array to get rid of repeats
  requiredPoints = new int[0];
  
  // Loop through point indices found and store all non-repeated values
  for (int i = 0; i < listPointFixtureIndices.length; i++) {
    int fixtureIndex = listPointFixtureIndices[i];
    
    if (!fixtureCounter[fixtureIndex] && fixtureIndex > 1) {
      fixtureCounter[fixtureIndex] = true;
      requiredPoints = append(requiredPoints, fixtureIndex);
    }
  }
  
  
  if (requiredPoints.length != prevNumPoints) {  // If new requiredPoints found has different length than previous, the recalculation is required
    recalcRequired = true;
  }
}

// PATHFINDING RELATED FUNCTIONS //

// Returns list containing coords of corners of a given obstacle
PVector[] cornerCoords(int[] obsCoords) {
  PVector TL = new PVector(obsCoords[0], obsCoords[1]);  // Top left
  PVector TR = new PVector(obsCoords[2], obsCoords[1]);  // Top right
  PVector BL = new PVector(obsCoords[0], obsCoords[3]);  // Bottom left
  PVector BR = new PVector(obsCoords[2], obsCoords[3]);  // Bottom right
  
  return new PVector[]{TL, TR, BL, BR};
}


// Checks if an obstacle is intersected by a path (checks for intersection between line segments involved)
boolean intersectionFound(int[] obsCoords, PVector startCoords, PVector endCoords) {
    int x1 = (int) startCoords.x;
    int y1 = (int) startCoords.y;
    int x2 = (int) endCoords.x;
    int y2 = (int) endCoords.y;
    
    float m = (float) (y2-y1) / (x2-x1);  // Find m and b in order to find coords of the intersection between the lines if they were continuous
    float b = y2 - m*x2;
    
    obsCoords = concat(obsCoords, new int[]{(obsCoords[0]+obsCoords[2])/2, (obsCoords[1]+obsCoords[3])/2});  // Add middle x and y values to check as well
    
    for (int i = 0; i < obsCoords.length; i++) {
      int coord = obsCoords[i];  // Known coord
      int otherCoord;  // Unknown coord
      
      if (i % 2 == 0) {  // Known coord is x-coordinate
        
        otherCoord = round(m*coord + b);  // y = mx + b
        
        // If y of intersection is in between y's of obstacle and x of intersection is between x's of line segment, intersection has been found
        if (min(obsCoords[1], obsCoords[3]) < otherCoord && otherCoord < max(obsCoords[1], obsCoords[3]) && min(x1, x2) < coord && coord < max(x1, x2))
          return true;
        
      }
      
      else {  // Known coordinate is y
        if (x1 == x2) {  // Vertical line
          // Intersection is going to have x-coord = x1 = x2 and y-coord = calculated coord
          if (min(y1, y2) < coord && coord < max(y1, y2) && obsCoords[0] < x1 && x1 < obsCoords[2])
            return true;
        }
          
        else {
          otherCoord = round((coord-b)/m);  // x = (y-b)/m
          
          if (min(obsCoords[0], obsCoords[2]) < otherCoord && otherCoord < max(obsCoords[0], obsCoords[2]) && min(y1, y2) < coord && coord < max(y1, y2))
            return true;
        }
        
      }

    }
    
    return false;  // If not returned yet, intersection has not been found
}


// Checks whether or not there are any obstacles in the way of a path segment
boolean obsPresent(PVector destination, PVector currPoint) {
  for (int i = 0; i < obstacles.size(); i++) {
    if (intersectionFound(obstacles.get(i), currPoint, destination)) {
      return true;
    }
  }
  
  return false;
}


// Gets index of an element in an array
int getIndex(int[] arr, int el) {
  for (int i = 0; i < arr.length; i++) {
    if (arr[i] == el)
      return i;
  }
  return -1;
}

// Discards an element from an array
int[] discard(int[] arr, int el) {
  int splitIndex = getIndex(arr, el);
  
  return concat(subset(arr, 0, splitIndex), subset(arr, splitIndex + 1));
}
