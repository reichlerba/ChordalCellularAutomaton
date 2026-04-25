// Written by Benjamin Reichler

import processing.sound.*;

class Cell {
  private float xCenter, yCenter, pitch;
  private int row;
  
  private static final float MINIMUM_HZ = 440 * 2 / 5.0; // == F3
  private static final float MAXIMUM_HZ = 440 * 3 / 2; // 660 == Just Intonation E5
  
  private static final int CELL_BORDER_COLOR = 0xFFF95E10; // value found using print(hex(color(249, 94, 16)));
  private static final int CELL_FILL_COLOR = 0xFFFA8E02; // value found using print(hex(color(250,142,2)));
  
  // MAXIMUM_CANDIDATE_PITCH_CHANGE_FACTOR specifies the maximum ratio a candidate pitch can be generated from it's base pitch
  // ex. MAXIMUM_CANDIDATE_PITCH_CHANGE_FACTOR = 0.1 means the Cell under a Cell with pitch p could inherit a pitch *around* the range [p*(1-0.1),p*(1+0.1)] (but symmetric in log space)
  private static final float MAXIMUM_CANDIDATE_PITCH_CHANGE_FACTOR = 0.1;
  
  private final float[] SIMPLE_RATIOS = { 1.0, 2.0, 3.0/2.0, 4.0/3.0, 5.0/4.0, 6.0/5.0, 5.0/3.0, 8.0/5.0 };
  
  // public
  
  // initialize and draw this Cell with a new pitch
  Cell(float xCenter, float yCenter, Cell[] parents, int row) {
    this.xCenter = xCenter;
    this.yCenter = yCenter;
    this.row = row;
    pitch = calculateNewPitch(parents);
    drawCell();
  }
  
  // initialize and draw this Cell with a given pitch
  Cell(float xCenter, float yCenter, float pitch, int row) {
    this.xCenter = xCenter;
    this.yCenter = yCenter;
    this.row = row;
    this.pitch = pitch;
    drawCell();
  }
  
  // chooses the volume of this Cell's associated oscillator according to the position of the mouse
  // note that a Cell on the other side of the screen can be heard when the mouse is close to the edge
  // returns a float in the range [0,MAXIMUM_CELL_VOLUME]
  public float getVolume() {
    float distance = abs(xCenter - mouseX);
    float wrapAroundDistance = abs(distance - width);
    if(wrapAroundDistance < distance) {
      distance = wrapAroundDistance;
    }
    float maxDist = CELL_SIDE_LENGTH * FURTHEST_AUDIBLE_CELL;
    
    // close cells have normalized close to 0, far ones have normalized up to 1
    float normalized = constrain(distance / maxDist, 0, 1); 
    float volume = pow(1 - normalized, 2);
    
    // scale down based on MAXIMUM_CELL_VOLUME
    float scale = min(abs(MAXIMUM_CELL_VOLUME), 1);
    
    // scale down higher frequencies to adjust for human high-pitch sensitivity
    float freqNorm = constrain((pitch - MINIMUM_HZ) / (MAXIMUM_HZ - MINIMUM_HZ), 0, 1);
    float freqFactor = 1.0 - pow(freqNorm, 1.5) * (1.0 - SOFTEN_HIGH_PITCHES);
    
    return volume * scale * freqFactor;
  }
  
  // getters
  public float getPitch() {
    return pitch;
  }
  
  
  // private
  
  // display this Cell
  private void drawCell() {
    float r = CELL_SIDE_LENGTH / 2.0;
    float x = xCenter - r;
    float y = yCenter - r;
    float cornerRadius = r * 0.55;
    float borderWidth = CELL_SIDE_LENGTH * 0.2;
    strokeWeight(borderWidth);
    stroke(CELL_BORDER_COLOR);
    fill(CELL_FILL_COLOR);
    rect(x, y, CELL_SIDE_LENGTH, CELL_SIDE_LENGTH, cornerRadius);
  }
  
  // find the pitch a cell needs based on is parents' pitches
  private float calculateNewPitch(Cell[] parents) {
    if(parents.length == 0) {
      // this cell is in the top row
      return random(MINIMUM_HZ, MAXIMUM_HZ);
    }
    float basePitch = parents[0].getPitch();
    float bestPitch = basePitch;
    float bestScore = -1;
    
    for(int numCandidatesToGenerate = 20; numCandidatesToGenerate > 0; numCandidatesToGenerate--) {
      // choose pitch option
      float r = log(1.0 + MAXIMUM_CANDIDATE_PITCH_CHANGE_FACTOR);
      float candidatePitch = basePitch * exp(random(-r, r)); // choose candidate pitch symetrically around basePitch in log space
      
      // one could instead symmetrically choose a pitch in pitch space with the following command, but this biases and favors selection of lower pitches
      // candidatePitch = random(basePitch * (1.0 - MAXIMUM_CANDIDATE_PITCH_CHANGE_FACTOR), basePitch * (1.0 + MAXIMUM_CANDIDATE_PITCH_CHANGE_FACTOR));
      
      // randomly jump a frequency occassionally for added variation
      if(random(1) < 0.05) {
        candidatePitch = randomlyJumpPitch(candidatePitch);
      }
      
      // move into valid range
      candidatePitch = wrapOctave(MINIMUM_HZ, candidatePitch, MAXIMUM_HZ);
      
      // score candidate
      float score = totalScore(candidatePitch, parents);
      if(score > bestScore) {
        bestScore = score;
        bestPitch = candidatePitch;
      }
    }
    
    return bestPitch;
  }
  
  // returns pitch jumped either up or down by a simple ratio
  private float randomlyJumpPitch(float pitch) {
    float randomInterval = SIMPLE_RATIOS[int(random(SIMPLE_RATIOS.length))];
    pitch *= randomInterval;
    // randomInterval >= 1, so allow optional octave jump down manually
    if(random(1) < 0.5) {
      pitch /= 2.0;
    }
    return pitch;
  }
  
  // wrap pitch using factors of 2 into the range [minVal,maxVal)
  private float wrapOctave(float minVal, float pitch, float maxVal) {
    while(pitch >= maxVal) {
      pitch /= 2.0;
    }
    while(pitch < minVal) {
      pitch *= 2.0;
    }
    return pitch;
  }
  
  // returns a candidate pitch's cumulative score weighed against parents
  private float totalScore(float candidatePitch, Cell[] parents) {
    float sum = 0;
    // since candidates are chosen from parents[0], we don't want to award candidates that don't change from their parent
    boolean skipParent0 = true;
    for(int i = 0; i < parents.length; i++) {
      if(i == 0 && skipParent0) {
        continue;
      }
      sum += scoreConsonance(candidatePitch, parents[i].getPitch());
    }
    return sum;
  }
  
  // gives higher scores to frequencies close to simple ratios
  private float scoreConsonance(float f1, float f2) {
    // normalize ratio to [1,2)
    float ratio = f1 / f2;
    ratio = wrapOctave(1.0, ratio, 2.0);
    // frequencies in simple ratios with each other are generally more pleasing to the human ear
    float highestScore = 0;
    for(float sr : SIMPLE_RATIOS) {
      float difference = abs(log(ratio / sr));
      int sharpness = 10; // higher sharpness values, up to 20, tune very strictly, while lower values, down to 5, are more forgiving
      float score = exp(-sharpness * difference); // smaller difference deserves higher score
      highestScore = max(highestScore, score);
    }
    // penalize unison to discourage stagnant motion
    if(abs(log(ratio)) < 0.01) {
      highestScore *= 0.7;
    }
    return highestScore;
  }
  
}
