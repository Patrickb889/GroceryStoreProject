boolean in(String[] array, String element) {
  for (String el : array) {
    if (el.equals(element))
      return true;
  }
  
  return false;
}
