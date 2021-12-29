float smoothStep(int inc, float maxDist) {
  int pixLength = img.pixels.length;
  float val1, val2, val3, val4, val5, avg = 0;
  //covers all rows but first and last
  if (inc>img.width&&inc<pixLength-img.width) {
    val1 = brightness(img.pixels[inc]);
    val2 = brightness(img.pixels[inc-1]);
    val3 = brightness(img.pixels[inc+1]);
    val4 = brightness(img.pixels[inc-img.width]);
    val5 = brightness(img.pixels[inc+img.width]);
    avg = (val1 + val2 + val3 + val4 + val5)/5;
    //covers first row
  } else if (inc<pixLength-img.width&&inc!=0) {
    val1 = brightness(img.pixels[inc]);
    val2 = brightness(img.pixels[inc-1]);
    val3 = brightness(img.pixels[inc+1]);
    //val4 = brightness(img.pixels[inc-img.width]);
    val5 = brightness(img.pixels[inc+img.width]);
    avg = (val1 + val2 + val3 + val5)/4;
    //covers first pixel
  } else if (inc == 0) {
    val1 = brightness(img.pixels[inc]);
    //val2 = brightness(img.pixels[inc-1]);
    val3 = brightness(img.pixels[inc+1]);
    //val4 = brightness(img.pixels[inc-img.width]);
    val5 = brightness(img.pixels[inc+img.width]);
    avg = (val1 + val3 + val5)/3;
    //covers last pixel
  } else if (inc==pixLength) {
    val1 = brightness(img.pixels[inc]);
    val2 = brightness(img.pixels[inc-1]);
    //val3 = brightness(img.pixels[inc+1]);
    val4 = brightness(img.pixels[inc-img.width]);
    //val5 = brightness(img.pixels[inc+img.width]);
    avg = (val1 + val2 + val4)/3;
  } else {
    //assume all that are left is the last row, excluding the last pixel
    //which is inc>pixLength-img.width && inc!=pix.length
    val1 = brightness(img.pixels[inc]);
    val2 = brightness(img.pixels[inc-1]);
    //val3 = brightness(img.pixels[inc+1]);
    val4 = brightness(img.pixels[inc-img.width]);
    //val5 = brightness(img.pixels[inc+img.width]);
    avg = (val1 + val2 + val4)/3;
  }
  avg = map(avg, 0, 255, 0, maxDist);
  return avg;
}
