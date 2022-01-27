void combineImages() {
  PImage newImage = createImage(img.width, img.height, RGB);
  float currentCT, currentCR, currentCD;
  newImage.loadPixels();
  img.loadPixels();
  imgTexture.loadPixels();
  imgDetail.loadPixels();
  
  for (int x=0; x<img.width; x++) {
    for (int y=0; y<img.height; y++) {
      int inc = x+y*img.width;
      currentCT = brightness(img.pixels[inc]);//green
      currentCR = brightness(imgTexture.pixels[inc]);//red
      currentCD = brightness(imgDetail.pixels[inc]);//blue
      newImage.pixels[inc] = color(currentCR,currentCT, currentCD); 
      //println(brightness(int(cR[inc])));
      //newImage.pixels();
      //    cR[inc] = currentRad;
      //cT[inc] = currentTexture;
      //cD[inc]=  currentDetail;
    }
  }
  newImage.updatePixels();
  newImage.save("combined-" + day()+"_"+minute()+"_"+second()+".png");
}
