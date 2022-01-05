float circSize;
PImage img;

void setup() {
  size(600, 800);
  background(0);
  smooth(8);
  circSize = width*0.9;
  img = loadImage("radial_gradient2.png");
}

void draw() {
  //for (int r = 0; r <circSize; r+=1) {
  //  noStroke();
  //  //float c = map(r, 0, circSize, 0, 255);
  //  fill(r);
  //  ellipse(width/2, height/2, circSize-r, circSize*1.05-r);
  //  //h = (h + 1) % 360;
  //}
  image(img, 0, 0, width, 200);
  image(img, -img.width/2, 200, width, 200);
  image(img, img.width/2, 200, width, 200);
  image(img, 0, 400, width, 200);
}

void keyPressed(){
 saveFrame("radial_gradient_multi.png"); 
  
}
