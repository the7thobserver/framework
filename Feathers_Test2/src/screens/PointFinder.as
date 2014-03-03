package screens
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.net.sendToURL;
	
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class PointFinder extends Screen {
		
		  ////////////////////////////
		 ////      Constants    /////
		////////////////////////////
		
		// color constants
		private const RED:uint = 0xff0000;
		private const GREEN:uint = 0x00ff00;
		private const BLUE:uint = 0x0000ff;
		
		// brightness threshold
		private const BRIGHTNESS_THRESHOLD:uint = 3400000;
		
		// box bound around mouse click area
		private const BOUNDS:uint = 30;
		
		// scaling factors for mouse click positions
		private const X_SCALE:Number = -215;
		private const Y_SCALE:Number = -20;
		
		// thumbbnail design specs
		private const thumbNailSize:int = 200;
		
		// width-to-height ratio of images
		private const ASPECT_RATIO:Number = 8/5;
		
		// Path to where the images are
		private const IMAGE_PATH:String = "C:/camera images/"; 
		
		  ///////////////////////////
		 //// Regular Variables ////
		///////////////////////////
		
		// Arrays to hold pictures
		private var imageArray:Array;
		private var thumbnailArray:Array;
		
		// Keep track of side scroll
		private var touchBeginX:int;
		private var touchBeginY:int;
		
		// Main image holder
		private var mainImage:ImageLoader; 
		
		// Keep track of current image in array
		// Note both arrays (thumbnail and image) use the same index
		private var index:int = 0;
		
		// Containers which I assume are like divs in http
		private var mainImageContainer:LayoutGroup;
		private var thumbnailContainer:ScrollContainer;
		private var layout:VerticalLayout;
		
		// text field to display instructions to user
		private var textField:TextField;
		
		// hard-coded variables for pixel resolution
		private var distance_away:Number = 1.5494; // in meters
		private var distance:Number = 0.5; // in meters
		
		// Reflector center-point variables
		private var left_shoulder:Point;
		private var right_shoulder:Point;
		private var left_hip:Point;
		private var right_hip:Point;
		private var complete:Boolean;
		
		// variable for keeping track of which reflector state we are in
		private var state:Number;
		
		private var x1:Number, x2:Number;
		private var clicks:Number = 0;
		
		private var numThumbNails:int;
		
		// Holds the distances between the dots in the coresponding direction in cm : W is the distance to the edge of the board
		// Unsure about the 30.5
		private var calibrator:Vector3D = new Vector3D(-.250,0.2, 0 , 30.5);
		private var camera1:Vector3D = new Vector3D(0.08, -0.25, -1.7);
		private var camera2:Vector3D = new Vector3D(-0.29, -0.25, 1.53);
		private var point1:Vector3D;
		private var point2:Vector3D;
		private var r1:Vector3D;
		private var r2:Vector3D;
		
		private var centerPoint:Array;
		private var calibXPoints:Array;
		private var calibYPoints:Array;
		private var calibMPoints:Array;
		private var calibIndex:int = 0;
		
		private var bCalib:Button;
		private var isCalibrating:Boolean = false;
		private var calibStage:int = 0;
		
		private var vStep:Number;
		private var hStep:Number;
		private var mStep:Number;
		
		  ///////////////////////
		 //     Functions     //
		///////////////////////
		
		
		/**
		 * Constructor
		 */
		public function PointFinder() {
			
			// create layout objects
			layout = new VerticalLayout();
			thumbnailContainer = new ScrollContainer();
			mainImageContainer = new LayoutGroup();
			
			// initialize reflector point variables
			left_shoulder = new Point();
			right_shoulder = new Point();
			left_hip = new Point();
			right_hip = new Point();
			
			// Initilize center points array
			numThumbNails = 3;
			
			centerPoint = new Array();
			calibXPoints = new Array();
			calibYPoints = new Array();
			calibMPoints = new Array();
			
			for(var i:int = 0; i < numThumbNails; i++)
			{
				centerPoint[i] = 0;
			}
		
			// set initial state
			state = 0;
			
			// 
			complete = false;
			
			// Initilize arrays
			imageArray = new Array();
			thumbnailArray = new Array();
			
			// create textField
			textField = new TextField(220, 100, "Click on the left shoulder reflector");
			textField.x = 0;
			textField.y = 500;
			textField.color = 0xffffff;
			
			// Init button
			bCalib = new Button();
			bCalib.label = "Calibrate";
			bCalib.width = 100;
			bCalib.height = 50;
			bCalib.x = 10;
			bCalib.y = 600;
			
			// Add the mouse click event
			this.addEventListener(TouchEvent.TOUCH, onTouch);
			bCalib.addEventListener(starling.events.Event.TRIGGERED, startCalibrate);
		}
		
		
		/**
		 * Override of initialize() function used to set up containers on the screen
		 */
		override protected function initialize():void {
			
			// Initilze the containers which hold the pictures
			buildContainers(); 
			
			// Load Pictures from the file path
			loadPictures();
			
			// Initilize the thumbbnails
			initThumbbnails();
			
			// add the text field to the screen
			addChild(textField);
			addChild(bCalib);
		}
		
		
		/**
		 * Event handler to determine which actions to take when the screen is clicked on
		 */
		private function onTouch(event:TouchEvent):void {
			var t:Touch = event.getTouch(this);
			
			// make sure the event actually happened
			if(t) {
				switch(t.phase) {	
					// Equal to mouse down
					case TouchPhase.BEGAN:
						touchBeginX = t.globalX;
						touchBeginY = t.globalY;
						break;
					
					// Equal to mouse up
					case TouchPhase.ENDED:
						
						// If in calibration mode
						if(isCalibrating)
						{
							// If inside the main image x-wise
							if(t.globalX > -X_SCALE)
							{
								// If inside the main image y-wise
								if(t.globalY > -Y_SCALE)
								{
									// Let's calibrate (find the middle image)
									calibrate(t, index);	
								}
							}	
						}
						else
						{
							// If the mouse moved < 10 then do not change the picture AKA user was scrolling the container
							if(Math.abs(t.globalX - touchBeginX) < 10) {
								if(Math.abs(t.globalY - touchBeginY) < 10) {
									// trace("Target Name " + t.target.name);
									
									// update the instructions to the user - moved to the top b/c calibration textfield in centerpoint
									updateInstructions();
									
									// user clicked main image
									if(t.target.name == "mainImage") {
										// If the user hasn't calibrated, then we're going to force them to			
										if(centerPoint[index] == 0)
										{
											isCalibrating = true;
											textField.text = "Beginning calibration, please select the center";
											setCenter(t, index);
										}
										else
										{
											// trace("human assist called");
											humanAssist(t);
										}
										
										// Display saved center poitns
										/*
										for(var i:int = 0; i < numThumbNails; i++)
											trace(centerPoint[i]);
										*/
										
									}	
									
									// user clicked 1st thumbnail
									else if(t.target.name == "thumbnail0") {
										mainImage = imageArray[0];
										
										// reset the state
										state = 0;
										
										// set the array index
										index = 0;
									}
									
									// user clicked 2nd thumbnail
									else if(t.target.name == "thumbnail1") {
										mainImage = imageArray[1];
										
										// reset the state
										state = 0;
										
										// set the array index
										index = 1;
									}
									
									// user clicked 3rd thumbnail
									else if(t.target.name == "thumbnail2") {
										mainImage = imageArray[2];
										
										// reset the state
										state = 0;
										
										// set the array index
										index = 2;
									}
									
									// set correct sizes of the image
									mainImage.maintainAspectRatio = false;
									mainImage.width = mainImageContainer.width;
									mainImage.height = mainImageContainer.height;
									
									// add the image to the container
									mainImageContainer.addChild(mainImage);
								}
							}
						}
						break;
				}
			}
		}
		
		private function setCenter(target:Touch, index:int):int
		{
			var point:Point = findCenter(target);
			
			// If x or y comes out to be Not A Number cal return -1 (error)
			if(isNaN(point.x) || isNaN(point.y))
			{
				textField.text = "Error calibrating current picture. Please select the center again.";
				return -1;	
			}
			
			trace("Center - index " + index + " to " + point);
			
			centerPoint[index] = point; 
			
			return 0;
		}		

		/**
		 * Finds the center of a dot in the picture
		 */
		private function findCenter(target:Touch):Point
		{
			// Get location of mouse click
			var location:Point = new Point(target.globalX + X_SCALE, target.globalY + Y_SCALE);
			// trace("coordinates - x: " + location.x + ", y: " + location.y);
			
			var bmd:BitmapData = copyAsBitmapData(mainImage);
			
			// variables used to calculate average positions of pixels
			var sumXCoords:uint = 0;
			var sumYCoords:uint = 0;
			var totalPixels:uint = 0;
			
			// Check pixels in 100x100 pixel box around the mouse position at the time it was clicked
			for (var i:int = location.x - BOUNDS; i < location.x + BOUNDS; i++) {
				for (var j:uint = location.y - BOUNDS; j < location.y + BOUNDS; j++){
					
					// If "brightness" is greater than a certain amount, color that pixel red
					if (calcBrightness(bmd.getPixel(i, j)) > BRIGHTNESS_THRESHOLD) {
						totalPixels++; //increment the total number of pixels by 1
						sumXCoords += i; // add the i coordinate to running total
						sumYCoords += j; // add the j coordinate to running total
					}
				}
			}
			
			// calculate the center of the circle
			var x:Number = sumXCoords/totalPixels;
			var y:Number = sumYCoords/totalPixels;
			
			var point:Point = new Point(x,y);
		
			return point;
		}
		
		/**
		 * Loads each picture into a sized down thumbbnail version of it into the scrolling container
		 */ 
		private function initThumbbnails():void {
			var temp:ImageLoader;
			
			// add each image to the thumbnail container
			for(var i:int = 0; i < imageArray.length; i++) {
				// get the image
				temp = thumbnailArray[i];
				
				// set the coordinates and size
				temp.x = 0;
				temp.width = thumbNailSize;
				
				// set the name and add it back into the array
				temp.name = "thumbnail" + i;
				thumbnailArray[i] = temp;
				
				// add the image to the container
				thumbnailContainer.addChild(temp);
			}
		}
			
		/**
		 * Function to build the display containers for the screen
		 */
		private function buildContainers():void {	
			// create the layout
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER
			layout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = 10;
			
			// create scroll container
			thumbnailContainer.layout = layout;
			thumbnailContainer.backgroundSkin = new Image(Texture.fromBitmapData(new BitmapData(150, 150, true, 0x80FF3300)));
			thumbnailContainer.x = 0;
			thumbnailContainer.y = 0; 
			thumbnailContainer.width = 220;
			thumbnailContainer.height = 450;
			thumbnailContainer.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_ON;
			thumbnailContainer.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;
			
			// create center image
			mainImageContainer.x = thumbnailContainer.width; 
			mainImageContainer.y = 0;
			
			// scale container to fit the screen
			mainImageContainer.width = stage.stageWidth - 220;
			mainImageContainer.height = (1/ASPECT_RATIO) * mainImageContainer.width;
			
			// add components to page
			addChild(thumbnailContainer);
			addChild(mainImageContainer);
		}
				
		/**
		 *  Load pictures from image path into the arrays
		 *  Take note of the file extensions acceptable by the program
		 */
		private function loadPictures():void {
			// get all images in the image directory
			var folder:File = File.applicationDirectory.resolvePath(IMAGE_PATH);
			var fileArray:Array = folder.getDirectoryListing();
			
			// temporary index
			var index:int = 0;
			
			for each(var f:File in fileArray) {
				// check file extensions
				if(f.extension == 'jpg' || f.extension == 'JPG' || f.extension == 'png' || f.extension == 'PNG') {
					// load images into thumbnail array
					var thumbnail_loader:ImageLoader = new ImageLoader();
					thumbnail_loader.source = f.nativePath;
					thumbnailArray[index] = thumbnail_loader;
					
					// load normal images into the image array
					var normal_image_loader:ImageLoader = new ImageLoader();
					normal_image_loader.source = f.nativePath;
					normal_image_loader.name = "mainImage";
					
					// set correct size of each image
					normal_image_loader.width = mainImageContainer.width;
					normal_image_loader.height = mainImageContainer.height;
					
					// add to array and increment index
					imageArray[index++] = normal_image_loader;
				}
			}
			
			// set the main image to the first element of the image array
			mainImage = imageArray[0];
			
			// ensure that the sizes are correct
			mainImage.maintainAspectRatio = false;
			mainImage.width = mainImageContainer.width;
			mainImage.height = mainImageContainer.height;
			
			// add image to the main image container
			mainImageContainer.addChild(mainImage);
		}
		 
		/**
		 * Function for finding reflector in the area around the mouse click
		 */
		public function humanAssist(target:Touch):void {
			
			var center:Point = new Point();
			
			// variables for drawing the circle around reflectors
			var radius:uint = 0;
			var x:Number = 0;
			var y:Number = 0;
			
			// variables used to calculate average positions of pixels
			var sumXCoords:uint = 0;
			var sumYCoords:uint = 0;
			var totalPixels:uint = 0;
			
			// variables for calculating the average height
			var cols:uint = 0;
			var heights:uint = 0;
			var currentHeight:uint = 0;
			var avgHeight:uint = 0;
			
			// variable for calculating the average width
			var rows:uint = 0;
			var widths:uint = 0;
			var currentWidth:uint = 0;
			var avgWidth:uint = 0;
			
			// boolean flag used for height/width calculations
			var flag:Boolean = false;
			
			var bmd:BitmapData = copyAsBitmapData(mainImage);
			
			// Get location of mouse click
			var location:Point = new Point(target.globalX + X_SCALE, target.globalY + Y_SCALE);
			// trace("coordinates - x: " + location.x + ", y: " + location.y);
			
			// circle sprite to be drawn around desired area
			var circle:Sprite = new Sprite();
			
			// line sprite to be drawn between points
			var line:Sprite = new Sprite();
			// trace("finding bright pixels");
			
			// Check pixels in 100x100 pixel box around the mouse position at the time it was clicked
			for (var i:uint = location.x - BOUNDS; i < location.x + BOUNDS; i++) {
				for (var j:uint = location.y - BOUNDS; j < location.y + BOUNDS; j++){
					
					// If "brightness" is greater than a certain amount, color that pixel red
					if (calcBrightness(bmd.getPixel(i, j)) > BRIGHTNESS_THRESHOLD) {
						bmd.setPixel(i,j,RED); // set the pixel to red
						totalPixels++; //increment the total number of pixels by 1
						sumXCoords += i; // add the i coordinate to running total
						sumYCoords += j; // add the j coordinate to running total
					}
				}
			}
			
			// trace("done finding bright pixels");
			
			// calculate the center of the circle
			x = sumXCoords/totalPixels;
			y = sumYCoords/totalPixels;
			
			// trace("finding avg width");
			
			/* find the average width of the hilighted area  */
			
			// loop through each row first
			for (i = location.x - BOUNDS; i < location.x + BOUNDS; i++) {
				
				// reset internally used variables
				currentWidth = 0;
				flag = false;
				
				// loop through each column in the row
				for (j = location.y - BOUNDS; j < location.y + BOUNDS; j++) {
					
					// check for marked pixel
					if (bmd.getPixel(i, j) == RED) {
						currentWidth++; // increment the width of this row by 1
						flag = true; // set a flag so we know this row has at least one marked pixel in it
					}
				}
				
				// add this row's width to a running total
				widths += currentWidth;
				
				// check the flag; if it's set, increment the total number of rows by 1
				if (flag == true)
					rows++;
			}
			
			// calculate the average width of the reflector
			avgWidth = widths/rows;
			
			/* find the average height of the hilighted area */
			// trace("finding avg height");
			// loop through each column first
			for (j = location.y - BOUNDS; j < location.y + BOUNDS; j++) {
				
				// reset internally used variables
				currentHeight = 0;
				flag = false;
				
				// loop through each row in the column
				for(i = location.x - BOUNDS; i < location.x + BOUNDS; i++) {
					
					// check for marked pixel
					if (bmd.getPixel(i, j) == RED) {
						currentHeight++; // increment the height of this column by 1
						flag = true; // set flag to true so that we know there is at least one marked pixel in this column
					}
				}
				
				// add this columns height to a running total
				heights += currentHeight;
				
				// check the flag; if it's true, increment the total number of columns by 1
				if (flag == true)
					cols++;
			}
			
			// calculate the average height of the reflector
			avgHeight = heights/cols;
			
			// average the width and height together to get the radius
			radius = (avgWidth + avgHeight)/2;
			// trace("drawing circle");
			
			// draw the circle around the reflector
			circle.graphics.clear();
			circle.graphics.beginFill(RED, 0.0);
			circle.graphics.lineStyle(2.0);
			circle.graphics.drawCircle(x, y, radius);
			circle.graphics.endFill();
			bmd.draw(circle);
			
			// update text field
			//textField.text = "Radius = " + radius;
			
			updateStateAfterClick(x, y, bmd);
			
			// trace("updating image");
			
			// Point finding stuff
			var centerX:Number = centerPoint[index].x;
			var centerY:Number = centerPoint[index].y;
			var FOV:Number = 25.9;
			
			// trace("Current Center is " + centerX + ", " + centerY);
			
			// Pixels/cm
			// 21.043 / 21.58
			//var vStep:Number = 21.043;
			//var hStep:Number = 21.58;
			
			// recalc pix/cm
			//var vStep:Number = 1 / 8.84514436;
			//vStep =  1 / 8.84514436;
			//var hStep:Number = 9.04199478;
			
			if(clicks == 0)
			{
				// Between the horizontal dots (lEFT)
				// (679.1477832512315 - 510.58704453441294) / PIX
				point1 = new Vector3D();
				
				point1.x = (centerX - x) * vStep;
				point1.y = (centerY - y) * hStep;
				point1.z = 0;
				
				// trace("1 point " + x + " pixels -> " + point1.x + "cms from center");
				trace("Center " + centerX + " " + centerY);
				trace(x + " " + y);
				trace(point1);
				
				clicks++;
			}
			else
			{
				point2 = new Vector3D();
				
				point2.x = (centerX - x) * vStep;
				point2.y = (centerY - y) * hStep;
				point2.z = 0;
				//trace("Y Points " + point1.y + " " + point2.y);
				trace("Center " + centerX + " " + centerY);
				trace(x + " " + y);
				trace(point2);
				// trace("2 point " + x + " pixels -> "  + point2.x + " cms from center");
				
				// Find magnatude
				point1.x;
				var mx:Number = Math.pow(point1.x - camera1.x, 2);
				var my:Number = Math.pow(point1.y - camera1.y, 2);
				var mz:Number = Math.pow(point1.z - camera1.z, 2);
				
				var magnitude:Number = Math.sqrt(mx + my + mz);
				trace("Mag " + magnitude + " " + mx + " " + my + " " +mz);
				
				// Create rays
				r1 = new Vector3D();
				r1.x = (point1.x - camera1.x) * (1 / magnitude);
				r1.y = (point1.y - camera1.y) * (1 / magnitude);
				r1.z = (point1.z - camera1.z) * (1 / magnitude);
				
				// Find magnitude
				mx = Math.pow(point2.x - camera2.x, 2);
				my = Math.pow(point2.y - camera2.y, 2);
				mz = Math.pow(point2.z - camera2.z, 2);
				
				magnitude = Math.sqrt(mx + my + mz);
				
				r2 = new Vector3D();
				r2.x = (point2.x - camera2.x) * (1 / magnitude);
				r2.y = (point2.y - camera2.y) * (1 / magnitude);
				r2.z = (point2.z - camera2.z) * (1 / magnitude);
				
				// Do maths
				var lhs:Vector3D = camera1.subtract(camera2);
				var rhs:Vector3D = r2.subtract(r1);
				
				trace("p1 " + point1);
				trace("p2 " + point2);
				trace("r1 " + r1);
				trace("r2 " + r2);
				trace("lhs " + lhs);
				trace("rhs " + rhs);
				
				var fx:Number = lhs.x / rhs.x;
				var fy:Number = lhs.y / rhs.y;
				var fz:Number = lhs.z / rhs.z;
				
				trace("Result " + fx + " " + fy + " " + fz);
				
				clicks = 0;
			}
			
			// Update image
			imageArray[index].source = Texture.fromBitmapData(bmd);
			
			// Update main image
			mainImage = imageArray[index];
			
			// Update thumbbnail
			//thumbnailArray[index].source = Texture.fromBitmapData(bmd);
		}
			
		/**
		 * Function for handling what happens after a user clicks on the image
		 */
		private function updateStateAfterClick(x:Number, y:Number, bmd:BitmapData):void {
			
			// Check if the coordinates are valid
			if (x > 0 && y > 0) {
			
			
				// assign point locations based on state
				switch (state) {
			
					// case 0 means left shoulder reflector
					case 0:
						
						// set the coordinates
						left_shoulder.x = x;
						left_shoulder.y = y;
						
						
						break;
					
					// case 1 means right shoulder reflector
					case 1:
						
						// set the coordinates
						right_shoulder.x = x;
						right_shoulder.y = y;
						
						// draw a line now that we have two points in common
						drawLine(left_shoulder, right_shoulder);
						break;
					
					// case 2 means left hip reflector
					case 2:
						
						// set the coordinates
						left_hip.x = x;
						left_hip.y = y;
						break;
					
					// case 3 means right hip reflector
					case 3:
						
						// set the coordinates
						right_hip.x = x;
						right_hip.y = y;
						complete = true;
						// draw a line now that we have two points in common
						drawLine(left_hip, right_hip);
						break;
					default:
						break;
				}
				
				// update the state
				if (++state == 4)
					state = 0;
				
				
				
				// update the instructions based on the new state
				updateInstructions();
			}
			
			// location not valid
			else {
				textField.text = "There is no reflector at that location.  Please try again.";
			}
			
			// internal function for drawing line between two points
			function drawLine(p1:Point, p2:Point):void {
				var line:Sprite = new Sprite();
				line.graphics.clear();
				line.graphics.beginFill(BLUE, 1.0);
				line.graphics.lineStyle(3, BLUE);
				line.graphics.moveTo(p1.x, p1.y);
				line.graphics.lineTo(p2.x, p2.y);
				bmd.draw(line);
				
				if(complete) {
					var center:Sprite = new Sprite();
					center.graphics.clear();
					center.graphics.beginFill(BLUE, 1.0);
					center.graphics.lineStyle(3, BLUE);
					center.graphics.moveTo( (right_shoulder.x + left_shoulder.x)/2, (right_shoulder.y + left_shoulder.y)/2);
					center.graphics.lineTo( (right_hip.x + left_hip.x)/2, (right_hip.y + left_hip.y)/2);
					bmd.draw(center);
					complete = false;
				}
			}
		}
				
		/**
		 * Function for updating the instructions displayed to the user
		 */
		private function updateInstructions():void {

			// update based on state variable
			switch (state) {
				
				// case 0 means left shoulder reflector
				case 0:
					textField.text = "Click on the left shoulder reflector";
					break;
				
				// case 1 means right shoulder reflector
				case 1:
					textField.text = "Click on the right shoulder reflector";
					break;
				
				// case 2 means left hip reflector
				case 2:
					textField.text = "Click on the left hip reflector";
					break;
				
				// case 3 means right hip reflector
				case 3:
					textField.text = "Click on the right hip reflector";
				default:
					break;
			}
		}
			
		/**
		 * Function to calculate pixel resolution based on mouse clicks
		 */
		private function calcRes(point1:Point, point2:Point):void {
			var x:Number = Math.abs(point2.x - point1.x);
			var y:Number = Math.abs(point2.y - point1.y);
			
			var res:Number = distance / x; // meters per pixel
			textField.text = "resolution = " + (res * 1000) + " millimeters per pixel";
		}
		
		/**
		 * calcBrightness() is a function to calculate the brightness of a pixel
		 */
		private function calcBrightness(pixel:uint) :Number {
			
			var r:uint = RED & pixel; // get only the red value of the pixel
			var g:uint = GREEN & pixel; // get only the green value of the pixel
			var b:uint = BLUE & pixel; // get only the blue value of the pixel
			
			return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
		}
				
		/**
		 * Makes a deep copy of a starling display object and returns a bitmapdata
		 */
		public function copyAsBitmapData(sprite:starling.display.DisplayObject):BitmapData {
			
			// first make sure the sprite isn't null
			if (sprite == null) {
				trace("Copying failed - Sprite is null");
				return null;
			}
			
			var resultRect:Rectangle = new Rectangle();
			sprite.getBounds(sprite, resultRect);
			var context:Context3D = Starling.context;
			var support:RenderSupport = new RenderSupport();
			
			RenderSupport.clear();
			support.setOrthographicProjection(0,0, stage.stageWidth, stage.stageHeight);
			support.transformMatrix(sprite.root);
			support.translateMatrix( -resultRect.x, -resultRect.y);
			
			var result:BitmapData = new BitmapData(resultRect.width, resultRect.height, true, 0x00000000);
			
			support.pushMatrix();
			support.transformMatrix(sprite);
			sprite.render(support, 1.0);
			support.popMatrix();
			support.finishQuadBatch();
			
			context.drawToBitmapData(result);
			
			return result;
		}
	
		private function startCalibrate():void
		{
			isCalibrating = true;
			
			textField.text = "CALIBRATING: Please click the center dot";
			
			index = 0;
			
			mainImage = imageArray[0];
			
			// set correct sizes of the image
			mainImage.maintainAspectRatio = false;
			mainImage.width = mainImageContainer.width;
			mainImage.height = mainImageContainer.height;
			
			// add the image to the container
			mainImageContainer.addChild(mainImage);
		}
		
		private function calibrate(target:Touch, index:int):int
		{
			switch(calibStage)
			{
				case 0:
					// If set center == -1 (got NaN) then return - the number doesn't matter, index doesn't increment
					// Currently returns index, in case things change
					if(setCenter(target, index) == -1)
						return index;
					textField.text = "Please select the top middle dot";
					
					calibStage++;
					break;
				case 1:
					if(calibrateY(target) == -1)
						return index;
					
					textField.text = "Please select the bottom middle dot";
					
					// Needs to do this 2x because 2 dots on the x-axis calibrator
					if(calibIndex == 2)
					{
						calibStage++;
						calibIndex = 0;
						textField.text = "Please select the center left dot";
					}
					
					break;
				case 2:
					if(calibrateX(target) == -1)
						return index;
					
					textField.text = "Please select the center right dot";
					
					
					// Needs to do this 2x because 2 dots on the y-axis calibrator
					if(calibIndex == 2)
					{
						calibStage++;
						calibIndex = 0;
						textField.text = "Please select the top left dot";
					}
					
					break;
				case 3:
					if(calibrateM(target) == -1)
						return index;
					
					textField.text = "Please select the top left dot";
					
					// Need to do this 4x because 4 dots for the m
					// Will never be calibIndex 0
					if(calibIndex == 1)
						textField.text = "Please select the bottom left dot";
					else if(calibIndex == 2)
						textField.text = "Please select the bottom right dot";
					else if(calibIndex == 3)
						textField.text = "Please select the top right dot";
					else if(calibIndex == 4)
					{
						calibStage++;
						calibIndex = 0;
						isCalibrating = false;
					}
					
					break;
				default:
					trace("Something went wrong with calibration");
					return index;
			}
			
			// trace("Stage # " + calibStage);
			
			
			
			// Number of points = 8 on the calibrator
			if(calibStage == 4)
			{
				textField.text = "CALIBRATION COMPLETE";

				calibrationCalculations();
				
				calibStage = 0;
			}
			
			return 0;
		}
		
		private function calibrationCalculations():void
		{
			// TODO do we want the distance between the points instead of raw x/y distances 
			// Left + right x distances / 2
			vStep = (centerPoint[0].x - calibXPoints[0].x) / calibrator.x;
			vStep -= (centerPoint[0].x - calibXPoints[1].x) / calibrator.x;
			vStep = vStep / 2;
			vStep = 1 / vStep;
			
			
			trace("vStep " + vStep);
			
			// Top + bottom y distances / 2
			hStep = (centerPoint[0].y - calibYPoints[0].y) / calibrator.y;
			hStep -= (centerPoint[0].y - calibYPoints[1].y) / calibrator.y;
			hStep = -hStep / 2;
			hStep = 1 / hStep;
			
			trace("hStep " + hStep);
			
			// How much image distortion there is by comparing slopes
			// Top right with bottom left
			// Bottom right with top left
			var m:Number;
			var m1:Number;
			
			m = (centerPoint[0].x - calibMPoints[0].x) / (centerPoint[0].y - calibMPoints[0].y); 
			m1 = (centerPoint[0].x - calibMPoints[2].x) / (centerPoint[0].y - calibMPoints[2].y);
			
			//trace(m + " " + m1);
			//trace("Differ in +m " + (m1 - m));
			
			m = (centerPoint[0].x - calibMPoints[3].x) / (centerPoint[0].y - calibMPoints[3].y);
			m1 = (centerPoint[0].x - calibMPoints[1].x) / (centerPoint[0].y - calibMPoints[1].y);
			
			//trace(m + " " + m1);
			//trace("Differ in -m " + (m1 - m));
		}
		
		private function calibrateM(target:Touch):int
		{
			var point:Point = findCenter(target);
			
			if(isNaN(point.x) || isNaN(point.y))
			{
				if(calibIndex == 0)
					textField.text = "Error calibrating: Please select the top left";
				else if(calibIndex == 1)
					textField.text = "Error calibrating: Please select the top right";
				else if(calibIndex == 2)
					textField.text = "Error calibrating: Please select the bottom left";
				else if(calibIndex == 3)
					textField.text = "Error calibrating: Please select the bottom right";
				else
					trace("Something went wrong calibrating m");
					
				return index;
			}
			
			calibMPoints[calibIndex] = point;
			
			// trace("M " + calibIndex + " " + point);
			
			calibIndex++;
			
			return 0;
		}
		
		private function calibrateY(target:Touch):int
		{
			var point:Point = findCenter(target);
			
			if(isNaN(point.x) || isNaN(point.y))
			{
				if(calibIndex == 0)
					textField.text = "Error calibrating: Please select the center left";
				else if(calibIndex == 1)
					textField.text = "Error calibrating: Please select the center right";
				else
					trace("Something went wrong calibrating y");
				
				return index;
			}
			
			calibYPoints[calibIndex] = point;
			
			// trace("Y " + calibIndex + " " + point);
			
			calibIndex++;
			
			return 0;
		}
		
		private function calibrateX(target:Touch):int
		{
			var point:Point = findCenter(target);
			
			if(isNaN(point.x) || isNaN(point.y))
			{
				if(calibIndex == 0)
					textField.text = "Error calibrating: Please select the top middle";
				else if(calibIndex == 1)
					textField.text = "Error calibrating: Please select the bottom middle";
				else
					trace("Something went wrong calibrating x");
				
				return index;
			}
			
			calibXPoints[calibIndex] = point;
			
			trace("X " + calibIndex + " " + point);
			
			calibIndex++;
			
			return 0;
		}
		
		private function nextImage():void
		{
			if(index == (numThumbNails - 1))
			{
				isCalibrating = false;
				textField.text = "Calibration complete";
				return;
			}
			
			index++;
			
			mainImage = imageArray[index];
			
			// set correct sizes of the image
			mainImage.maintainAspectRatio = false;
			mainImage.width = mainImageContainer.width;
			mainImage.height = mainImageContainer.height;
			
			// add the image to the container
			mainImageContainer.addChild(mainImage);
		}
	}
}