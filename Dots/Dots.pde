

void setup() {
  size(600, 200);
  smooth(8);
  background(100);
  float w = 100;
  float h = 100;
  int c = 255/50;
  for (int x=0; x<width; x+=w*2) {
    for (int y=0; y<height; y+=h*2) {
      for(int i=0; i<w; i+=5){
        noStroke();
      fill(100+i);
      ellipse(w+x, h+y, w-i, h*1.5-i);
    }}
  }
}

void draw() {
}

void keyPressed(){
  if(key=='s'){saveFrame("dots_gradient.png");}
  
  
}
