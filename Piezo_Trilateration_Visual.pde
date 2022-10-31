
int w = 1000;                  /* Spacing between piezos */
int h = floor(sqrt(3)*w/2);;   /* Equilateral triangle */

/* This speed affects the accuracy likely due to the size of the time step.
 * The smaller this number the better the accuracy.  It's probably analogous
 * to sampling rate.
 */
float soundSpeed = 30;

float currentTime = 0;
float measurementStart = currentTime;
float impactTime = 0;
boolean measurementStarted = false;

ArrayList<SoundCircle> circleList = new ArrayList<SoundCircle>();
ArrayList<Piezo> piezoList = new ArrayList<Piezo>();

public void settings()
{
	size(w, h);
}

void setup()
{
	background(255);
	ellipseMode(RADIUS);

	piezoList.add(new Piezo(0, 0));
	piezoList.add(new Piezo(w, 0));
	piezoList.add(new Piezo(w/2, h));
}

void showGrid()
{
	strokeWeight(1);
	background(255);

	for (int i = 0; i < w; i+=10) {
		for (int j = 0; j < h; j+=10) {
			fill(255);
			stroke(225);
			rect(i, j, 10, 10);
		}
	}
}

void draw()
{
	currentTime++;

	showGrid();

	showMeasurement();

	for (int i = 0; i < piezoList.size(); i++) {
		piezoList.get(i).drawPiezo();
		for (int j = 0; j < circleList.size(); j++) {
			if (!piezoList.get(i).collided) {
				piezoList.get(i).collides(circleList.get(j));
			}
		}
	}

	text("d0 = " + piezoList.get(0).deltaZeroTime*soundSpeed, 10, 100);
	text("d1 = " + piezoList.get(1).deltaZeroTime*soundSpeed, w-200, 100);
	text("d2 = " + piezoList.get(2).deltaZeroTime*soundSpeed, w/2-200, h-100);

	text("Δt = " + piezoList.get(0).deltaTime, 10, 130);
	text("Δt = " + piezoList.get(1).deltaTime, w-200, 130);
	text("Δt = " + piezoList.get(2).deltaTime, w/2-200, h-70);

	text("Δd1 = " + floor(piezoList.get(0).deltaTime*soundSpeed), 10, 160);
	text("Δd2 = " + floor(piezoList.get(1).deltaTime*soundSpeed), w-200, 160);
	text("Δd3 = " + floor(piezoList.get(2).deltaTime*soundSpeed), w/2-200, h-40);
}


void mouseClicked()
{
	circleList.clear();
	circleList.add(new SoundCircle(mouseX, mouseY));

	for (int i = 0; i < piezoList.size(); i++) {
		piezoList.get(i).reset();
	}

	measurementStarted = false;
	impactTime = currentTime;
	loop();
}

void showMeasurement()
{
	boolean measurementComplete = true;
	noLoop();
	for (int i = 0; i < piezoList.size(); i++) {
		if (!piezoList.get(i).collided) {
			loop();
			measurementComplete = false;
		}
	}
  
	if(!measurementComplete) {
		// draw expanding SoundCircle
		for (int i = 0; i < circleList.size(); i++) {
			circleList.get(i).drawSoundCircle();
		}
		return;
	}

	showMouse();

//	showRadii();

	showPoint();
}

void showMouse()
{
	float mouseX = circleList.get(0).xPos;
	float mouseY = circleList.get(0).yPos;

	/* Show the mouse location */
	fill(255,255,0,125);
	circle(mouseX, mouseY, 10);
}

void showRadii()
{
	/* show the radii */
	fill(0,0,0,0);
	strokeWeight(2);
	stroke(0);
	for (int i = 0; i < piezoList.size(); i++) {
		float d = piezoList.get(i).deltaZeroTime*soundSpeed;
		circle(piezoList.get(i).xPos, piezoList.get(i).yPos, d);
	}
}

void showPoint()
{
	/* bunch o' math from here:
	 * https://math.stackexchange.com/questions/3373011/how-to-solve-this-system-of-hyperbola-equations
	 */

	float dt0 = piezoList.get(0).deltaTime*soundSpeed;
	float dt1 = piezoList.get(1).deltaTime*soundSpeed;
	float dt2 = piezoList.get(2).deltaTime*soundSpeed;

	float r1, r2;

	float x0;
	float y0;
	float x1;
	float y1;
	float x2;
	float y2;

	/* one of these dt is going to be r=0 and it will be the one closest to
	 * the point of impact.  We don't want to use that one.
	 */

	if(dt0 == 0) {
		r1 = dt1;
		r2 = dt2;

		x0 = piezoList.get(0).xPos;
		y0 = piezoList.get(0).yPos;
		x1 = piezoList.get(1).xPos;
		y1 = piezoList.get(1).yPos;
		x2 = piezoList.get(2).xPos;
		y2 = piezoList.get(2).yPos;
	} else if (dt1 == 0) {
		r1 = dt0;
		r2 = dt2;

		x0 = piezoList.get(1).xPos;
		y0 = piezoList.get(1).yPos;
		x1 = piezoList.get(0).xPos;
		y1 = piezoList.get(0).yPos;
		x2 = piezoList.get(2).xPos;
		y2 = piezoList.get(2).yPos;
	} else { /* dt2 == 0 */
		r1 = dt0;
		r2 = dt1;

		x0 = piezoList.get(2).xPos;
		y0 = piezoList.get(2).yPos;
		x1 = piezoList.get(0).xPos;
		y1 = piezoList.get(0).yPos;
		x2 = piezoList.get(1).xPos;
		y2 = piezoList.get(1).yPos;
	}

	float a1 = 2*(x0 - x1);
	float b1 = 2*(y0 - y1);
	float c1 = pow(r1, 2) + pow(x0, 2) + pow(y0, 2) - pow(x1, 2) - pow(y1, 2);

	float a2 = 2*(x0 - x2);
	float b2 = 2*(y0 - y2);
	float c2 = pow(r2, 2) + pow(x0, 2) + pow(y0, 2) - pow(x2, 2) - pow(y2, 2);

	float d1 = (2*r1*b2 - 2*r2*b1)/(a1*b2 - a2*b1);
	float e1 = (c1*b2 - c2*b1)/(a1*b2 - a2*b1);
	float d2 = (2*r1*a2 - 2*r2*a1)/(a2*b1 - a1*b2);
	float e2 = (c1*a2 - c2*a1)/(a2*b1 - a1*b2);

	float a = pow(d1, 2) + pow(d2, 2) - 1;
	float b = 2*(e1 - x0)*d1 + 2*(e2 - y0)*d2;
	float c = pow((e1 - x0), 2) + pow((e2 - y0), 2);

	/* two solutions to the quadratic equation */
	float r_1 = (-b + sqrt(pow(b, 2) - 4*a*c))/(2*a);
	float r_2 = (-b - sqrt(pow(b, 2) - 4*a*c))/(2*a);


	/* This solution is always wrong */
/*
	float x = d1*r_1 + e1;
	float y = d2*r_1 + e2;

	fill(0,0,255,125);
	circle(x, y, 10);
*/

	/* This solution seems to always be correct */
	float x = d1*r_2 + e1;
	float y = d2*r_2 + e2;

	fill(255,0,0,125);
	circle(x, y, 10);
}
