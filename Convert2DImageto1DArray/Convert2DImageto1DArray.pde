PImage img;
color [] c;

void setup(){
  size(500, 500);
  img = loadImage("dots-260.png");
  c= new color[img.width*img.height];
  //img.loadPixels();
  for (int y=0; y<img.height; y++){
  for(int x=0; x<img.width; x++){
    
      int count = x+y*img.width;
      c[count] = int(brightness(img.pixels[count]));
    }}
  
}

void draw(){
  //image(img, 0, 0);
     for (int y=0; y<img.height; y++){
    for(int x=0; x<img.width; x++){
 
      int count = x+y*img.width;
      color current = color(c[count]);
      fill(current);
      noStroke();
      ellipse(x,y,1, 1);
    }}
}
