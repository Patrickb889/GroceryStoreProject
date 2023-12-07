class FixturePreset {
  String type;  // shelf, fridge, display, counter
  String name;  // (ex: meat, dairy, fruit, pharmacy, etc)
  int maxStock;
  float restockChance;
  PVector colour;
  
  
  // If name (product category) is given
  FixturePreset(String t, String n, int ms, float rc, PVector c) {
    this.type = t;
    this.name = n;
    this.maxStock = ms;
    this.restockChance = rc;
    this.colour = c;
  }
  
  // No name given (ex: a general counter that could be pharmacy, post office, etc)
  FixturePreset(String t, int ms, float rc, PVector c) {
    this.type = t;
    this.name = "Default";
    this.maxStock = ms;
    this.restockChance = rc;
    this.colour = c;
  }
  
  
  // Functions for creating a new fixture with similar attributes
  void newFixture(int[] pos, int[] mainSideCoords, String[] products) {
    fixtures.add(new Fixture(pos, mainSideCoords, this.type, this.name, products, this.maxStock, this.restockChance, this.colour));
  }
  
  void newFixture(int[] pos, int[] mainSideCoords, String name, String[] products) {
    fixtures.add(new Fixture(pos, mainSideCoords, this.type, name, products, this.maxStock, this.restockChance, this.colour));
  }
}
