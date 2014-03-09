package screens
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
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
		private const BRIGHTNESS_THRESHOLD:uint = 3000000;
		
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
		private const IMAGE_PATH:String = "C:/SAS Data/camera images/"; 
		
		private const CAM_1_CALIBRATION_SETTINGS:String = "C:/SAS Data/cam1calibration.txt";
		private const CAM_2_CALIBRATION_SETTINGS:String = "C:/SAS Data/cam2calibration.txt";
		private const CAM_3_CALIBRATION_SETTINGS:String = "C:/SAS Data/cam3calibration.txt";
		
		
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
		
		// Reflector center-point variables
		private var left_shoulder:Point;
		private var right_shoulder:Point;
		private var left_hip:Point;
		private var right_hip:Point;
		private var complete:Boolean;
		
		// variable for keeping track of which reflector state we are in
		private var state:Number;
		
		// file variables
		private var file:File;
		private var filestream:FileStream;
		
		// camera objects
		private var cam1:CameraImage;
		private var cam2:CameraImage;
		private var cam3:CameraImage;
		
		
		private var x1:Number, x2:Number;
		private var clicks:Number = 0;
		
		private var numThumbNails:int = 0;
		
		private var bCalib:Button;
		private var isCalibrating:Boolean = false;
		private var calibStage:int = 0;
		private var calibStep:Array;
		

		
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
			
			// initialize filestream
			filestream = new FileStream();
			
			// create camera objects
			cam1 = new CameraImage(1);
			cam2 = new CameraImage(2);
			cam3 = new CameraImage(3);
			
			
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
			
			isCalibrating = false;
			
		//	loadSettings();
			
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
			
			// REMOVE
			numThumbNails = 2;
			
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
						else // not calibrating
						{
							// If the mouse moved < 10 then do not change the picture AKA user was scrolling the container
							if(Math.abs(t.globalX - touchBeginX) < 10) {
								if(Math.abs(t.globalY - touchBeginY) < 10) {
									// trace("Target Name " + t.target.name);
									
									// update the instructions to the user - moved to the top b/c calibration textfield in centerpoint
									updateInstructions();
									
									// user clicked main image
									if(t.target.name == "mainImage") {
										humanAssist(t);
									}
									else
									{
										// Make sure the user isn't touching the container of thumbnails or somewhere else invalid
										if(t.target.name != null)
										{
											// Dynamically get the thumbnail clicked
											index = int(t.target.name.substring(t.target.name.length - 1, t.target.name.length));
											mainImage = imageArray[index];
											state = 0;
										}
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
					// Keep track of the number of images
					numThumbNails++;
					
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
		
		private function calibrate(t:Touch, index:Number):void {
			
		}
	}
}