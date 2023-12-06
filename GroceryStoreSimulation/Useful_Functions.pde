boolean in(String[] array, String element) {
  for (String el : array) {
    if (el.equals(element))
      return true;
  }
  
  return false;
}


PVector pointCoords(int pointIndex) {
  if (pointIndex == 0)
    return entrance;
  else if (pointIndex == 1)
    return exit;
  else
    return cornerCoords(obstacles.get((pointIndex-1)/4))[(pointIndex-1) % 4];  // (index-1)/4 is the obstacle index (divide by 4 because 4 corners per obstacle, -1 is to account for start point that is not part of any obstacle)
                                                                           // (index-1)%4 is to find the index of the specific corner of the specific obstacle
}


String pathToString(ArrayList<int[]> path) {
  String stringPath = str(path.get(0)[0]);
  
  for (int i = 1; i < path.size(); i++)
    stringPath += "-" + str(path.get(i)[0]);
    
  return stringPath;
}


void recalculatePath() {
  recalcRequired = false;
  pathCalculated = pathAccuracy.equals("Approx");
  pathFound = false;
  
  int numFixtures = fixtures.size();
  println("A");
  //allDistances = new float[numFixtures][numFixtures];
  //optimalPaths = new String[numFixtures][numFixtures];
  
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
  
  //todo: also determine which paths were affected by the new/modified obstacle
}


void checkShoppingList() {
  checkShoppingList("");
}

void checkShoppingList(String checkMode) {
  int prevNumPoints = 0;
  
  if (checkMode.equals(""))
    prevNumPoints = requiredPoints.length;
  
  pointsList = new ArrayList<PVector>();
  listPointFixtureIndices = new int[shoppingList.length];
  
  pointsList.add(entrance);
  pointsList.add(exit);
  //listPointFixtureIndices[0] = 0;
  //listPointFixtureIndices[listPointFixtureIndices.length-1] = 1;
  for (int i = 0; i < shoppingList.length; i++) {
    PVector pos = findPosition(shoppingList[i]);
    
    if (pos.x != -1) {
      pointsList.add(pos);
      listPointFixtureIndices[i] = int(pos.z);
    }
    
    else {  // if pos.x is -1, then the function was unable to find the item in any of the fixtures
      println("Sorry,", "'" + shoppingList[i] + "'", "is not a product in this store. Perhaps you made a typo in your shopping list?");
      //pointsList[i+1] = pointsList[i];
      listPointFixtureIndices[i] = 0;
    }
      
  }
  
  fixtureCounter = new boolean[fixtures.size()];
  requiredPoints = new int[0];
  for (int i = 0; i < listPointFixtureIndices.length; i++) {
    int fixtureIndex = listPointFixtureIndices[i];
    
    if (!fixtureCounter[fixtureIndex] && fixtureIndex > 1) {
      fixtureCounter[fixtureIndex] = true;
      requiredPoints = append(requiredPoints, fixtureIndex);
    }
  }
  
  if (requiredPoints.length != prevNumPoints) {
    recalcRequired = true;
  }
}
