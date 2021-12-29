//Amy Traylor
//December 29, 2021
//Code maps a bitmap image to a 3D surface

//cameras to view different angles
import damkjer.ocd.*;
Camera camera0, camera1, camera2;

PVector[] v;//to contain points
color [] c;//to contain color/brightness data of each point
//variables to draw 3d form
float theta, radius, angleStep, numPointsPerLayer;

PImage img;

int currentCam = 0;
int camX, camY, camZ, aimX, aimY, aimZ;
float layerHeight = 0.15;
int count=0;
float protrude = 50;

void setup() {
  size(900, 900, P3D);
  smooth(8);
  img = loadImage("frames-038.png");
  img.resize(800, 800);
  c = new color[img.width*img.height];
  v = new PVector[img.height*img.width];

  radius = (img.width/PI)/2;
  theta= 0;
  numPointsPerLayer =img.width;
  angleStep=TWO_PI/numPointsPerLayer;


  for (int x=0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      int inc = x+y*img.width;
      float current = smoothStep(inc, protrude);      
      c[inc] = int(current);
      v[inc] = new PVector((radius+c[inc])*sin(theta), y*layerHeight, (radius+c[inc])*cos(theta));
    }
    theta+=angleStep;
  }

  //camera setup
  camera0 = new Camera(this, 0, 0, 0, width/2, height/2, 0, 0, 1, 0);
  camera1 = new Camera(this, 0, height*0.25, 500);
  camera2 = new Camera(this, width, height/2, -100);
  camera0.aim(width/2, height/2, 0);
  camera1.aim(width/2, height*0.25, 0);
  camera2.aim(width/2, height*0.25, 0);
}


void draw() {
  background(255, 255, 0);
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


  pushMatrix();
  translate(width/2, height/4, 0);
  //if(count<v.length){
  //  count+=1; //println(count);
  for (int count=0; count<v.length; count++ ) {
    stroke(c[count]*5, 255 - c[count]*50, 255/(c[count]+1));
    strokeWeight(1);
    if (count==0) {
      line(v[count].x, v[count].y, v[count].z, v[count+1].x, v[count+1].y, v[count+1].z);
    } else {
      line(v[count].x, v[count].y, v[count].z, v[count-1].x, v[count-1].y, v[count-1].z);
    }
    if (count%numPointsPerLayer==0) {
      pushMatrix();
      translate(v[count].x, v[count].y, v[count].z);
      fill(0, 255, 0);
      ellipse(0, 0, 10, 10);
      popMatrix();
    }
  }

  popMatrix();
}

void mouseMoved() {
  camera0.circle(radians(mouseX - pmouseX));
  camera1.circle(radians(mouseX - pmouseX));
  camera2.circle(radians(mouseX - pmouseX));
}

void keyPressed() {
  if (key=='0')currentCam=0;
  if (key=='1')currentCam=1;
  if (key=='2')currentCam=2;  

  if (key=='s') {
    saveFrame("saved/houseimage625_smooth_cam" + currentCam + "_" + hour() + second()+".png");
  }
}
