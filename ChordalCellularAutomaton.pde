// Written by Benjamin Reichler

// Main file contains high level control logic 
// Last edited April 25, 2026

// used to define Canvas size
final int CELLS_PER_GENERATION = 30;
final int NUM_GENERATIONS = 20;

// defines Cells size
final int CELL_SIDE_LENGTH = 40; // measured in Pixels

// volume controls
final float MAXIMUM_CELL_VOLUME = 0.50; // should be in [0,1]
final float FURTHEST_AUDIBLE_CELL = 3.0; // number of cells away from mouse that can be heard
// SOFTEN_HIGH_PITCHES is a measure in [0,1] of how much quieter a high pitch should be than a low pitch
// scaling down higher frequencies helps adjust for the ear's natural tendency to hear higher pitches as louder
final float SOFTEN_HIGH_PITCHES = 0.75;
//final float AMPLITUDE_UPDATE_SECONDS = 0.01; Pitch and amplitude interpolation and gliding control?? extra DEBUGGING TODO ?

// how many cells above a given Cell influence its chosen pitch
final int PARENTS_PER_CELL = 7;

Cell[][] cells;
SinOsc[] sineWaves;


// sets the Canvas size
void settings() {
  int w = CELLS_PER_GENERATION * CELL_SIDE_LENGTH;
  int h = NUM_GENERATIONS * CELL_SIDE_LENGTH;
  size(w,h);
}

// initializes every Cell in cells and draws the Canvas
void setup() {
  background(255);
  initializeCells();
  initializeSineWaves();
}

// plays frequencies according to mouse
void draw() {
  updateSineWaves();
}


// sketch-level helper functions

// sets the global cells equal to a fresh full set of Cell objects
void initializeCells() {
  cells = new Cell[NUM_GENERATIONS][CELLS_PER_GENERATION];
  
  for(int row = 0; row < NUM_GENERATIONS; row++) {
    // all cells in this row have the same yCenter value
    float y = (row + 0.5) * CELL_SIDE_LENGTH;
    
    for(int col = 0; col < CELLS_PER_GENERATION; col++) {
      float x = (col + 0.5) * CELL_SIDE_LENGTH;
      
      cells[row][col] = new Cell(x, y, getCellParents(row, col), row);
    }
  }
}

// sets sineWaves to appropriate starting pitches and amplitudes
void initializeSineWaves() {
  sineWaves = new SinOsc[CELLS_PER_GENERATION];
  for(int i = 0; i < sineWaves.length; i++) {
    sineWaves[i] = new SinOsc(this);
    Cell playingCell = cells[getRowOfMouse()][i];
    sineWaves[i].freq(playingCell.getPitch());
    sineWaves[i].amp(playingCell.getVolume());
    sineWaves[i].play();
  }
}

// updates sineWaves to new pitches and amplitudes
void updateSineWaves() {
  for(int i = 0; i < sineWaves.length; i++) {
    Cell playingCell = cells[getRowOfMouse()][i];
    sineWaves[i].freq(playingCell.getPitch());
    sineWaves[i].amp(playingCell.getVolume());
  }
}

// returns an array of each Cell above the cell at (childRow, childColumn), this child's "parents"
// each Cell in parents is ordered from most closely related to the child, to least
// for example, parents[0] is immediately above the child; parents[1] and parents[2] are on the child's diagnols
// a child in row 0 has no parents --> return []
// 0 <= childRow < NUM_GENERATIONS
// 0 <= childColumn < CELLS_PER_GENERATION
Cell[] getCellParents(int childRow, int childColumn) {
  if(childRow == 0) {
    return new Cell[0];
  }
  Cell[] parents = new Cell[PARENTS_PER_CELL];
  for(int i = 0; i < PARENTS_PER_CELL; i++) {
    // when i == 0 --> horizontal distance == 0
    // when i == 1 or 2 --> horizontal distance == 1
    // when i == 3 or 4 --> horizontal distance == 2
    int horizontalDistanceFromChild = (i+1) / 2;
    // when i is odd, we subtract from childColumn and then mod CELLS_PER_GENERATION
    // note that we do wrap around edges while considering parents
    if(i % 2 == 1) { horizontalDistanceFromChild *= -1; } // make negative
    int parentColumn = (childColumn + horizontalDistanceFromChild + CELLS_PER_GENERATION) % CELLS_PER_GENERATION;
    parents[i] = cells[childRow - 1][parentColumn];
    // println("cells[" + childRow + "][" + childColumn + "] has parents[" + i + "] = cells[" + (childRow - 1) + "][" + parentColumn + "]"); // info about parents
  }
  return parents;
}

// returns the row within cells which the mouse is currently positioned over, an int \in [0, NUM_GENERATIONS - 1]
int getRowOfMouse() {
  return mouseY / CELL_SIDE_LENGTH;
}
