/*from Visualizing Data by Ben Fry*/

FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int rowCount;
int columnCount;
int currentColumn = 0;

int yearMin, yearMax;
int[] years;

int yearInterval = 10;
int volumeInterval = 10;
int volumeIntervalMinor = 5;

float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

Integrator[] interpolators;

PFont plotFont;

void setup() {
  size(720, 405);
  //canvas size
  data = new FloatTable("milk-tea-coffee.tsv");
  //get data from the file
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();
  //count the series of data from axises

  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length-1];

  dataMin = 0;
  dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;

  interpolators = new Integrator[rowCount];
  for (int row = 0; row<rowCount; row++) {
    float initialValue = data.getFloat(row, 0);
    interpolators[row] = new Integrator(initialValue);
    interpolators[row].attraction = .1;
  }

//define the size of the white rect to draw chart
//define of position x and y for drawing chart from data
  plotX1 = 120;
  plotX2 = width-80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height-25;

  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);

  smooth();
}

void draw() {
  background(224);
  //show the plot area as white box
  fill(255);
  rectMode(CORNERS);
  noStroke();
  //draw the white box for drawing chart
  rect(plotX1, plotY1, plotX2, plotY2);

  drawTitleTabs();
  drawAxisLabels();

  for (int row = 0; row<rowCount; row++) {
    interpolators[row].update();
  }

  drawYearLabels();
  drawVolumeLabels();

  noStroke();
  fill(#FF4C33);
  //have the color
  drawDataArea(currentColumn);
  //use the function to draw data
  //function defined at the bottom
}

void drawTitleTabs() {
  rectMode(CORNERS);
  noStroke();
  textSize(20);
  textAlign(LEFT);
  //onthe first use of this method allocate space for an array
  //to store the values for the left and right edges of the tabs
  if (tabLeft == null) {
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15;
  tabBottom = plotY1;

  for (int col = 0; col<columnCount; col++) {
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad +titleWidth + tabPad;

    // if the current tab sets its bg white, otherwise use grey
    fill(col ==currentColumn ? 255:224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    //if the current tab, use black for the text, otherwise grey
    fill(col == currentColumn?0:64);
    text(title, runningX+tabPad, plotY1-10);
    runningX = tabRight[col];
  }
}

void mousePressed() {
  if (mouseY>tabTop && mouseY<tabBottom) {
    for (int col = 0; col<columnCount; col++) {
      if (mouseX>tabLeft[col] && mouseX<tabRight[col]) {
        setColumn(col);
      }
    }
  }
}

void setColumn(int col) {
  currentColumn = col;
  for (int row = 0; row<rowCount; row++) {
    interpolators[row].target(data.getFloat(row, col));
  }
}

void drawAxisLabels() {
  fill(0);
  textSize(13);
  textLeading(15);

  textAlign(CENTER, CENTER);
  text("Mood\nRange 0-100", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Time", (plotX1+plotX2)/2, labelY);
}

void drawYearLabels() {
  fill(0);
  textSize(10);
  textAlign(CENTER);

  //grid
  stroke(224);
  strokeWeight(1);

  for (int row = 0; row<rowCount; row++) {
    if (years[row]% yearInterval ==0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row],x, plotY2+textAscent()+10);
      line(x, plotY1, x, plotY2);
    }
  }
}

void drawVolumeLabels() {
  fill(0);
  textSize(10);
  textAlign(RIGHT);

  stroke(128);
  strokeWeight(1);

  for (float v = dataMin; v<dataMax; v+= volumeIntervalMinor) {
    if (v%volumeIntervalMinor ==0) {
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if (v%volumeInterval == 0) {
        float textOffset = textAscent()/2;
        if (v == dataMin) {
          textOffset = 0;
        } else if (v == dataMax) {
          textOffset = textAscent();
        }
        text(floor(v), plotX1-10, y+textOffset);

      } else {
        //line...
      }
    }
  }
}
void drawDataArea(int col) {
  //use vertex to connect all points to draw the shape

  for (int row=0; row<rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = interpolators[row].value;
      //use map function to take the range of the data and map them to the chart box
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);
      
      int inc = row +1;
      if(inc>rowCount-1){
        inc = 0;
      }
      float x2 = map(years[inc], yearMin, yearMax, plotX1, plotX2);
      float y2 = map(value, dataMin, dataMax, plotY2, plotY1);
      
      vertex(x, y);
      line(x,y,x2,y2);
      point(x,y);
      ellipse(x,y,10,10);
    }
  }

}