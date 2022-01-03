//cameras to view different angles
import damkjer.ocd.*;
Camera camera0, camera1, camera2;
int currentCam = 1;
int camX, camY, camZ, aimX, aimY, aimZ;
float current_z = 0.1;
float layerHeight = 0.15;
float radInc = 0.15;

float waveX1, waveX2, waveY1, waveY2;
float pX1, pX2, pY1, pY2;
float wX2 = 10, wY2 = 10;
float radius = 100;
float theta = 1;
float angleStep = 1;

void setup() {
  size(500, 500, P3D);
  background(0);
frameRate(5);
  //camera setup
  camera0 = new Camera(this, 0, 0, 0, width/2, height/2, 0, 0, 1, 0);
  camera1 = new Camera(this, 0, height*0.25, 0);
  camera2 = new Camera(this, width, height/2, -100);
  camera0.aim(width/2, height/2, 0);
  camera1.aim(width/2, height*0.25, 0);
  camera2.aim(width/2, height*0.25, 0);
}

void draw() {

  switch(currentCam) {
  case 0:
    camera0.feed();
    break;
  case 1:
    camera1.feed();
    break;
  case 2:
    camera2.feed();
    break;
  }
  drawForm();
}

void drawForm() {
  int layers = int(radius/radInc);

  for (int l = 0; l<layers; l++) {    
    pushMatrix();
    translate(width/2, height/2);
    float speed = 0.25;
    waveX1 = sin(radians(theta * speed)) *radius;
    waveY1 = cos(radians(theta * speed)) *radius;
    //println(radians(frameCount * 0.50));

    waveX2 = sin(radians(theta * wX2)) * radius/10;//first number is busyness of line, last number is distance from line center
    waveY2 = cos(radians(theta * wY2)) * radius/10;

    strokeWeight(1);
    stroke(255);
    //stroke(frameCount%255, 255-frameCount%255, (frameCount%255)/10);
    if (frameCount>1) {
      line(pX1+pX2, current_z, pY1+pY2, waveX1 + waveX2, current_z, waveY1 + waveY2);
    }
    popMatrix();
    pX1 = waveX1;
    pX2 = waveX2;
    pY1 = waveY1;
    pY2 = waveY2;

    theta+=angleStep;
    //if (theta%360==0) {
    //  //fill(255, 0, 0);
    //  //ellipse(width/2, height/2, 500, 500);
    float layerInc = layerHeight/(360/angleStep);
    println(layerInc);
    if(l>0){
      current_z-=layerHeight/10;
    //current_z-=layerInc;
    }
  }
  if (radius>0) {
      radius-=radInc;
    }
}
void keyPressed() {
  if (key=='0')currentCam=0;
  if (key=='1')currentCam=1;
  if (key=='2')currentCam=2; 
  //try one direction beibng zero and the other not zero
  if (keyCode==UP) { 
    wX2+=1; 
    //println("wX2: " + wX2);
  }
  if (keyCode==DOWN) {
    if (wX2>0)wX2-=1; 
    // println("wX2: " + wX2);
  }
  if (keyCode==RIGHT) { 
    wY2+=1; 
    // println("wY2: " + wY2);
  }
  if (keyCode==LEFT) {
    if (wY2>0)wY2-=1; 
    //  println("wY2: " + wY2);
  }

  if (key=='s') {
    saveFrame("saved/wavyLine" + currentCam + "_" + hour() + second()+".png");
  }
}
//curls
//float wX2 = 10, wY2 = 10;
//float radius = 100;
//  float speed = 0.25;
//  waveX1 = sin(radians(frameCount * speed)) *radius;
//  waveY1 = cos(radians(frameCount * speed)) *radius;
//  //println(radians(frameCount * 0.50));

//  waveX2 = sin(radians(frameCount * wX2)) * radius/10;//first number is busyness of line, last number is distance from line center
//  waveY2 = cos(radians(frameCount * wY2)) * radius/10;
