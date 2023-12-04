class FixturePreset {
  String type;  // shelf, fridge, display, counter
  String name;  // (ex: meat, dairy, fruit, pharmacy, etc)
  int maxStock;
  float restockChance;
  color colour;
  
  FixturePreset(String t, String n, int ms, float rc, color c) {
    this.type = t;
    this.name = n;
    this.maxStock = ms;
    this.restockChance = rc;
    this.colour = c;
  }
  
  FixturePreset(String t, int ms, float rc, color c) {
    this.type = t;
    this.maxStock = ms;
    this.restockChance = rc;
    this.colour = c;
  }
  
  void newFixture(int[] pos, int[] mainSideCoords, String[] products) {
    fixtures.add(new Fixture(pos, mainSideCoords, this.type, this.name, products, this.maxStock, this.restockChance, this.colour));
  }
  
  void newFixture(int[] pos, int[] mainSideCoords, String name, String[] products) {
    fixtures.add(new Fixture(pos, mainSideCoords, this.type, name, products, this.maxStock, this.restockChance, this.colour));
  }
}
