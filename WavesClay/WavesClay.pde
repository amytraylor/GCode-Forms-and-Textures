void setup() {
  size(1080, 1080, P3D);
  background(0);
}

void draw() {

  noStroke();
  for (int i=0; i<105; i++) {
    pushMatrix();
    translate(width/2, height/2, i);
    float waveFreq = 0.5;
    float waveX1 = sin(radians(frameCount * waveFreq)) * height * (0.4-(i*0.003));
    float waveY1 = cos(radians(frameCount * waveFreq)) * height * (0.4-(i*0.003));

    float waveX2 = sin(radians(frameCount * waveFreq*10)) * 100;//was 30 and 5
    float waveY2 = cos(radians(frameCount * waveFreq*10)) * 10;//was 30 and 5
    fill(i*2, 255-(i*2.2), i*5);
    ellipse(waveX1 + waveX2, waveY1 + waveY2, 5, 5);
    popMatrix();
  }
}
