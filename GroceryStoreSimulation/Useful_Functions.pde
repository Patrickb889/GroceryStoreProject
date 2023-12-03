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
  else if (pointIndex == -1)
    return exit;
  else
    return cornerCoords(obstacles[(pointIndex-1)/4])[(pointIndex-1) % 4];  // (index-1)/4 is the obstacle index (divide by 4 because 4 corners per obstacle, -1 is to account for start point that is not part of any obstacle)
                                                                           // (index-1)%4 is to find the index of the specific corner of the specific obstacle
}


String pathToString(ArrayList<int[]> path) {
  String stringPath = str(path.get(0)[0]);
  
  for (int i = 1; i < path.size(); i++)
    stringPath += "-" + str(path.get(i)[0]);
    
  return stringPath;
}
