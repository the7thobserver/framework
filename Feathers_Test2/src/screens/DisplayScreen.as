package screens
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowBoundsEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.controllers.LookAtController;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.entities.SegmentSet;
	import away3d.events.MouseEvent3D;
	import away3d.events.Stage3DEvent;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.LineSegment;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.utils.Cast;
	
	import feathers.controls.Screen;
	

	
	// set the window size
	[SWF(width="1000", height="800")]
	
	public class DisplayScreen extends Screen
	{
		// Constants
		private var awayToReal:Number = 10;
		
		//[Embed(source="../../assets/display images/skeletonR.jpg")]
		[Embed(source="../../assets/screen images/xRayMod.jpg")]
		private var xRay:Class;
		
		//[Embed(source="../../assets/screen images/green_button.png")]
		//private var greenButton:Class;
		
		// File variables
		private var coordinates_file:File;
		private var filestream:FileStream;
		
		
		// coordinates.txt file path
		public static const SETTINGS_PATH:String = "C:/SAS Data/coordinates.txt";
		
		// Array to simulate passed in points
		private var arrayData:Array;
		
		
		// Stage manager and proxy instances
		private var stage3DManager : Stage3DManager;
		private var stage3DProxy : Stage3DProxy;
		
		// Away3D view instances
		private var away3dView : View3D;
		
		// Runtime variables
		private var lastPanAngle : Number = 0;
		private var lastTiltAngle : Number = 0;
		private var lastMouseX : Number = 0;
		private var lastMouseY : Number = 0;
		private var mouseDown : Boolean;
		
		// Camera controllers
		private var hoverController : HoverController;
		
		
		// Lighting effects 
		private var light:DirectionalLight;
		
		// skeleton image
		private var material:TextureMaterial;
		private var blockMesh:Mesh; 
		
		
		
		// frameWork Images
		private var topFrame:WireframePlane;
		private var rightFrame:WireframePlane;
		private var leftFrame:WireframePlane;
		private var frontFrame:WireframePlane;
		private var middleFrame:WireframePlane;
		
		// Window Components
		private var initializer:NativeWindowInitOptions;
		private var window:NativeWindow;
		
		// Camera Controls 
		private var cam:Camera3D;
		private var camController:LookAtController;
		private var lastKey:uint;
		private var keyIsDown:Boolean = false;
		private var cameraSwitch:Boolean = false;
		
		// Add/Remove Picture
		private var pictureButton:Boolean = false;
		private var picturePlane:Mesh;
		
		
		// Button Constants
		private const SNAPSHOT_BUTTON_LABEL:String = "Add/Remove X-Ray";
		private const SNAPSHOT_BUTTON_X:Number = 800;
		private const SNAPSHOT_BUTTON_Y:Number = 400;
		
		
		/*
		* Constructor
		*
		*/
		
		public function DisplayScreen()
		{
			// create references to static objects
			window = Feathers_Test2.window;
			away3dView = Feathers_Test2.away3dView;
			stage3DProxy = Feathers_Test2.stage3DProxy;
			stage3DManager = Feathers_Test2.stage3DManager;

			// check window for existing objects and remove them
			checkWindow();
			
			iniArray();		
			init();
			//addEventListener(Event.ENTER_FRAME, update);
		}
		
		
		/**
		 * checkWindow(): Checks the native window for existing objects and listeners, then removes them
		 */
		private function checkWindow():void {
			
			// remove all scene items from the away3d view
			while(away3dView.scene.numChildren > 0)
				away3dView.scene.removeChildAt(0);
			
			// remove all objects from the stage
			while(window.stage.numChildren > 0)
				window.stage.removeChildAt(0);
			
			// remove all event listeners, if they exist
			if (window.stage.hasEventListener(KeyboardEvent.KEY_DOWN))
				window.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			
			if (window.stage.hasEventListener(KeyboardEvent.KEY_UP))
				window.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			
			if (window.stage.hasEventListener(MouseEvent.MOUSE_DOWN))
				window.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			if (window.stage.hasEventListener(MouseEvent.MOUSE_UP))
				window.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			if (window.hasEventListener(NativeWindowBoundsEvent.RESIZE))
				window.removeEventListener(NativeWindowBoundsEvent.RESIZE, onResize);
			
			if (stage3DProxy.hasEventListener(Stage3DEvent.CONTEXT3D_CREATED))
				stage3DProxy.removeEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			
			if (stage3DProxy.hasEventListener(Event.ENTER_FRAME))
				stage3DProxy.removeEventListener(Event.ENTER_FRAME, update);
		}
		
		
		/**
		 * Override of default dispose() function to ensure that the window minimizes
		 */
		public override function dispose():void {
			window.minimize();
		}
		
		
		/*
		* Initializes the window, then calls the iniStage 
		*
		*/
		private function init():void {
			window.stage.scaleMode = StageScaleMode.NO_SCALE;
			window.stage.align = StageAlign.TOP_LEFT;
			
			// set up stage and stage manager
			initStage();
			// activate the window
			window.activate();
			window.maximize();
		}
		
		
		/* 
		* Description : 
		*		-manually sets up the Stage through the Stage3DManager
		*		- Set some stage properties like background color...
		*/
		private function initStage():void
		{
			stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
			stage3DProxy.antiAlias = 8;
			stage3DProxy.color = 0x000000;
			onContextCreated(new Stage3DEvent(""));
		}	
		
		
		/*
		* Where everything gets built, all initializations and Event Listeners
		*
		*/
		private function onContextCreated(event:Stage3DEvent):void{
			initAway3D();
			iniCameras(); 
			iniLight();
			iniReferenceMarkers();	
			iniFloor();
			iniBlock();				// Inserts x-ray 
			iniMarkers();   		// plot points
			iniConnectDots();
			//iniButton();
			
			//You can listen for the stage ENTER_FRAME event which fires before rendering every frame
			stage3DProxy.addEventListener(Event.ENTER_FRAME, update);
			window.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			window.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			
			
			// Used for hover controller implementation
			//window.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			//window.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
		}
		
		//		private function iniButton():void
		//		{
		//			var texture:Texture = Texture.fromBitmap(new greenButton());
		//			var testButton:Button = new Button(texture, "", null);
		//			
		//			testButton.x = 10;
		//			testButton.y = 10;
		//			
		//			window.stage.addChild(testButton);
		//			testButton.addEventListener(Event.TRIGGERED, 
		//		}
		
		private function onGreenButton(event:MouseEvent):void
		{
			// On button click
		}
		
		
		private function changeCameras(e:MouseEvent3D):void{
			// Hover controller implementation----------uncomment to revert to a working demo
			if(cameraSwitch){
				hoverController = new HoverController(away3dView.camera);
				hoverController.distance = 700;
				hoverController.minTiltAngle = 0;
				hoverController.maxTiltAngle = 90;
				hoverController.panAngle = 70;
				hoverController.tiltAngle = 20;
				cameraSwitch=false; 
				
				window.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
				window.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
				
			else{
				cameraSwitch=true; 
				camController = new LookAtController(cam);
				window.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				window.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			}
		}
		
		
		private function iniCameras():void
		{
			// Look at Controller Implementation
			
			// create a basic camera
			cam = new Camera3D();
			cam.z = 500; // make sure it's positioned away from the default 0,0,0 coordinate
			cam.y = 100;
			away3dView.camera = cam;
			
			camController = new LookAtController(cam);
			// position and target the camera
			//hoverController = new HoverController(away3dView.camera, null, 45, 30, 1100, 5, 89.999);
			
			// Hover controller implementation----------uncomment to revert to a working demo
			//hoverController = new HoverController(away3dView.camera);
			//hoverController.distance = 700;
			//hoverController.minTiltAngle = 0;
			//hoverController.maxTiltAngle = 90;0
			//hoverController.panAngle = 70;
			//hoverController.tiltAngle = 20;
		}
		
		private function iniConnectDots():void
		{
			// Local variables 
			var start:Vector3D = new Vector3D();
			var end:Vector3D = new Vector3D();
			var count:Number = 0;								//Used to keep tabs on point numbers	
			var numPoints:Number = arrayData.length;  
			var midPointArray:Array = new Array();
			
			// Quick error check
			if(numPoints%2 != 0){
				trace("Odd num of points");
			}
			
			//for(var i:Number=0; i < numPoints-1; i++){						// iffy with the -1 thing
			//For every other two points draw a line between them
			
			for(var i:int = 0; i < arrayData.length; i++){
				
				// Extract point data for the next 2 points that will be connected
				var t:Array = arrayData[i].split(",");
				var startPoint:Vector3D = new Vector3D(t[0],t[1],t[2]);
				var g:Array = arrayData[i+1].split(",");
				var endPoint:Vector3D = new Vector3D(g[0],g[1],g[2]);
				
				// find midpoint through vector substraction. 
				midPointArray[count] = new Vector3D((endPoint.x+startPoint.x)*0.5, (endPoint.y+startPoint.y)*0.5, (endPoint.z+startPoint.z)*0.5);
				
				//increment i again to accomadate for the second point being extracted
				i++;
				
				// Create the line between the two points
				var s:LineSegment = new LineSegment(startPoint , endPoint, 0xFF0000, 0xFFFFFF, 1);
				var lineSet:SegmentSet = new SegmentSet();
				lineSet.addSegment(s);
				
				// add it to the scene
				away3dView.scene.addChild(lineSet);
				
				// Connect the midpoints on the two lines.
				if(count==1){
					// if count = 1, then we have read in 4 points and we want to connect the midpoints.
					var m:LineSegment = new LineSegment(midPointArray[0], midPointArray[1], 0xFF0000, 0xFFFFFF, 1);
					var lineSetMid:SegmentSet = new SegmentSet();
					lineSetMid.addSegment(m);
					away3dView.scene.addChild(lineSetMid);
					count = -1;
				}
				count++;
			}
		}
		
		
		/* 
		* Description : 
		*	Handles user movement in 3D world. 
		*/
		private function update(event:Event):void{
			var speed:Number = 35;
			if (mouseDown) {
				hoverController.panAngle = 0.3 * (window.stage.mouseX - lastMouseX) + lastPanAngle;
				hoverController.tiltAngle = 0.3 * (window.stage.mouseY - lastMouseY) + lastTiltAngle;
			}
			
			if(keyIsDown){
				// if the key is still pressed, just keep on moving
				switch(lastKey){
					case 87				: cam.moveUp(speed); break;
					case 83				: cam.moveDown(speed); break;
					case 65				: cam.moveLeft(speed); break;
					case 68				: cam.moveRight(speed); break;
					case Keyboard.UP	: cam.moveForward(speed); break;
					case Keyboard.DOWN	: cam.moveBackward(speed); break;
				}
			}
			// render the view
			camController.update();
			
			
			// re-render the view to see the changes. 
			away3dView.render();	
		}
		
		
		/*
		* Description : 
		*		Accessess the existing file coordinates.txt, and returns an Array of Strings,
		*		where each String corresponds to a line in the file.
		*		
		*
		*/
		private function getFileData():Array 
		{
			// set the file and open the filestream
			var coordinates_file:File = File.desktopDirectory.resolvePath(SETTINGS_PATH);
			var filestream:FileStream = new FileStream();
			filestream.open(coordinates_file, FileMode.READ);
			
			// get all lines within the file
			var lines:Array = filestream.readUTFBytes(filestream.bytesAvailable).split("\n");
			
			filestream.close();
			return lines;
		}
		
		
		/* 
		* Description : 
		*		Calls getFileData and puts the data into a private class variable 
		*/
		private function iniArray():void
		{
			var  j:int = 0; 
			arrayData = new Array();
			arrayData = getFileData();
		}
		
		
		/* 
		* Description : 
		*		Extracts coordinate data from array and plots the points.
		*/
		private function iniMarkers():void
		{
			// write each value from file into array of values
			for(var i:int = 0; i < arrayData.length; i++){
				var point = new Mesh(new SphereGeometry(10,50,50));
				var tempvals:Array = arrayData[i].split(",");
				point.x = tempvals[0];
				point.y = tempvals[1];
				point.z = tempvals[2];
				
				point.mouseEnabled = true; 
				
				point.material = new ColorMaterial(0x00FF00);
				point.material.lightPicker = new StaticLightPicker([light]);
				point.material.shadowMethod = new FilteredShadowMapMethod(light);
				
				point.addEventListener(MouseEvent3D.MOUSE_DOWN, objectClick);
				
				away3dView.scene.addChild(point);
			}
		}
		
		
		/* 
		* Description : 
		*	If the user clicks on a particular point they can zoom in and out on it.
		*/
		
		private function keyDown(e:KeyboardEvent):void
		{
			lastKey = e.keyCode;
			keyIsDown = true;
		}
		private function keyUp(e:KeyboardEvent):void
		{
			keyIsDown = false;
		}
		
		private function objectClick(e:MouseEvent3D):void
		{
			camController.lookAtObject = e.target as ObjectContainer3D;
		}
		
		
		/* 
		* Description : 
		*		Used to scale the away3d universe, using referenece points
		*		The sheres represent reflectors of diameter 0.9525cm in the real world
		*		10 units = 1cm 
		*/
		
		private function iniReferenceMarkers():void
		{
			//SphereGeometry(radius:Number = 50, segmentsW:uint = 16, segmentsH:uint = 12, yUp:Boolean = true)
			
			// change this to adjust marker diameters
			var reflectorDia = 10; 
			
			// GREEN MARKER 1
			var markerGreen = new Mesh(new SphereGeometry(reflectorDia,50,50));
			markerGreen.x = 0;
			markerGreen.y = 0;
			markerGreen.z = 0;
			markerGreen.material = new ColorMaterial(0x00FF00);
			markerGreen.material.lightPicker = new StaticLightPicker([light]);
			markerGreen.material.shadowMethod = new FilteredShadowMapMethod(light);
			
			// code for lookatcamera to use
			markerGreen.mouseEnabled = true;
			markerGreen.addEventListener(MouseEvent3D.MOUSE_DOWN, objectClick);
			
			// add to scene
			away3dView.scene.addChild(markerGreen);
			
			// RED MARKER 2
			var markerRed = new Mesh(new SphereGeometry(reflectorDia,50,50));
			markerRed .x = 500;
			markerRed .y = 0;
			markerRed .z = 0;
			markerRed .material = new ColorMaterial(0xFF0000);
			markerRed .material.lightPicker = new StaticLightPicker([light]);
			markerRed .material.shadowMethod = new FilteredShadowMapMethod(light);
			
			
			markerRed.mouseEnabled = true;
			markerRed.addEventListener(MouseEvent3D.MOUSE_DOWN, removeXRAY);
			away3dView.scene.addChild(markerRed);
			
			
			// Dark BLUE MARKER 3
			var markerBlue = new Mesh(new SphereGeometry(reflectorDia,50,50));
			markerBlue.x = -500;
			markerBlue.y = 0;
			markerBlue.z = 0;
			markerBlue.material = new ColorMaterial(0x0000FF);
			markerBlue.material.lightPicker = new StaticLightPicker([light]);
			markerBlue.material.shadowMethod = new FilteredShadowMapMethod(light);
			
			markerBlue.mouseEnabled = true;
			markerBlue.addEventListener(MouseEvent3D.MOUSE_DOWN, changeCameras);
			
			away3dView.scene.addChild(markerBlue);		
			
			// VIOLET MARKER 4
			var markerViolet = new Mesh(new SphereGeometry(reflectorDia,50,50));
			markerViolet.x = 0;
			markerViolet.y = 0;
			markerViolet.z = -500;
			markerViolet.material = new ColorMaterial(0xFF00FF);
			markerViolet.material.lightPicker = new StaticLightPicker([light]);
			markerViolet.material.shadowMethod = new FilteredShadowMapMethod(light);
			away3dView.scene.addChild(markerViolet);
			
			
			// LIGHTBLUE MARKER 5
			var markerLBlue = new Mesh(new SphereGeometry(reflectorDia,50,50));
			markerLBlue.x = 0;
			markerLBlue.y = 0;
			markerLBlue.z = 500;
			markerLBlue.material = new ColorMaterial(0x00FFFF);
			markerLBlue.material.lightPicker = new StaticLightPicker([light]);
			markerLBlue.material.shadowMethod = new FilteredShadowMapMethod(light);
			away3dView.scene.addChild(markerLBlue);		
			
			// WHITE MARKER 6
			var markerWhite = new Mesh(new SphereGeometry(10,50,50));
			markerWhite.x = 0;
			markerWhite.y = 500;
			markerWhite.z = 0;
			markerWhite.material = new ColorMaterial(0xFFFFFF);
			markerWhite.material.lightPicker = new StaticLightPicker([light]);
			markerWhite.material.shadowMethod = new FilteredShadowMapMethod(light);
			away3dView.scene.addChild(markerWhite);
			
		}
		
		private function removeXRAY(e:MouseEvent3D):void{
			if(!pictureButton){
				away3dView.scene.removeChild(picturePlane);
				pictureButton = true;
			}
			else{
				away3dView.scene.addChild(picturePlane);
				pictureButton = false; 
			}
			
		}
		
		private function iniBlock():void
		{
			// initialize texture 
			material = new TextureMaterial(Cast.bitmapTexture(xRay));
			
			// Width and height of a texture must be at least a height of 2.
			//var block = new Mesh(new CubeGeometry(300,800,10),material);
			
			//			var block = new CubeGeometry (256,1024,10);
			//			block.tile6 = false;
			//			blockMesh = new Mesh (block, material);
			//			
			//			blockMesh.x = 0;
			//			blockMesh.y = -480;
			//			blockMesh.z = 0;
			//block.material = new ColorMaterial(0xFFFFFF);
			//block.material = material;
			
			
			//block.material.lightPicker = new StaticLightPicker([light]);
			//block.material.shadowMethod = new FilteredShadowMapMethod(light);
			
			
			// try a planeGeometry Instead	
			picturePlane = new Mesh(new PlaneGeometry(256,1024,1,1,false,true),material);
			
			picturePlane.x = 0;
			picturePlane.y = 0;
			picturePlane.z = 0;
			
			//away3dView.scene.addChild(blockMesh);
			away3dView.scene.addChild(picturePlane);
		}
		
		private function iniLight():void{
			//light = new PointLight();
			light = new DirectionalLight();
			away3dView.scene.addChild(light);
			light.position = new Vector3D(400,300,-200);
			light.lookAt(new Vector3D());
			light.castsShadows = true;
			light.color = 0xCCCCFF;
			light.ambient = 0.25;	// fraction of light that effects all surfaces.
		}
		
		private function onMouseDown(event : MouseEvent) : void {
			mouseDown = true;
			lastPanAngle = hoverController.panAngle;
			lastTiltAngle = hoverController.tiltAngle;
			lastMouseX = window.stage.mouseX;
			lastMouseY = window.stage.mouseY;
		}
		
		private function onMouseUp(event : MouseEvent) : void {
			mouseDown = false;
		}
		
		
		private function iniFloor():void
		{
			// var floor = new Mesh(new PlaneGeometry(2000,2000));
			var cylinder = new Mesh(new CylinderGeometry(500,600,10,50));
			//cylinder.pivotX = cylinde; // centers
			cylinder.x = 0; // in the middle
			cylinder.y = -500; // trail and error
			cylinder.z = 0;
			// floor.y = -50;
			//
			// //add color
			// floor.material = new ColorMaterial(0xFFFF44);
			cylinder.material = new ColorMaterial(0xFFFFFF);
			cylinder.material.lightPicker = new StaticLightPicker([light]);
			cylinder.material.shadowMethod = new FilteredShadowMapMethod(light);
			// floor.material.lightPicker = new StaticLightPicker([light]); // array of lights
			// // tell material to recieve shadows
			// floor.material.shadowMethod = new FilteredShadowMapMethod(light);
			//
			// // add it to the world.
			// away3dView.scene.addChild(floor);
			away3dView.scene.addChild(cylinder);
		}
		
		
		
		private function initAway3D():void
		{
			// Create the first Away3D view which holds the cube objects.
			away3dView.backgroundColor = 0x00FF00;
			away3dView.stage3DProxy = stage3DProxy;
			away3dView.shareContext = true;
			
			
			// Window assignments 
			window.stage.addChild(away3dView);
			window.stage.addChild(new AwayStats(away3dView));
			window.addEventListener(NativeWindowBoundsEvent.RESIZE, onResize);
		}
		
		
		/* 
		* Description : 
		*		called when the user adjust the window size
		*/
		private function onResize(event:Event):void{
			away3dView.width = window.stage.stageWidth;
			away3dView.height = window.stage.stageHeight;
			stage3DProxy.width = window.stage.stageWidth;
			stage3DProxy.height = window.stage.stageHeight;
		}	
	}
}// end of "display screen"
// ===================================================================================================================





// Graveyard.....
/*

// Line plotting code
//to draw the line you use :LineSegment and SegmentSet.
//		
//			
//			var line:LineSegment = new LineSegment(start , end, 0xFF0000, 0xFFFFFF, 1);
//			var lineSet:SegmentSet = new SegmentSet();
//			lineSet.addSegment(line);
//			
//			var line1:LineSegment = new LineSegment(new Vector3D(50,50,17), new Vector3D(-50,50,17), 0xFFFF00, 0x333333, 1);
//			var lineSet1:SegmentSet = new SegmentSet();
//			lineSet1.addSegment(line1);
//			
//			var line2:LineSegment = new LineSegment(new Vector3D(0,-500,5), new Vector3D(0,500,5), 0x0000FF, 0x333333, 1);
//			var lineSet2:SegmentSet = new SegmentSet();
//			lineSet2.addSegment(line2);
//			
//			
//			away3dView.scene.addChild(lineSet);
//			away3dView.scene.addChild(lineSet1);
//			away3dView.scene.addChild(lineSet2);
//			



// Code to create texture from a jpeg. 
private function iniTexture():void
{
material = new TextureMaterial(Cast.bitmapTexture(skeleton));
}




private function plotPoint():void
{
// Create a sphere
var point1 = new Mesh(new SphereGeometry(10,50,50));
point1.x = 0;
point1.y = 0;
point1.z = 0;
// Use a random Color
// var materialBitmap:BitmapData = new BitmapData(512,512,false,Math.random()*0xFFFFFF);
// markerGreen.material = new ColorMaterial(0x00FF00);
// markerGreen.material.lightPicker = new StaticLightPicker([light]);
// markerGreen.material.shadowMethod = new FilteredShadowMapMethod(light);
// away3dView.scene.addChild(markerGreen);
}




private function initListeners():void
{
stage3DProxy.addEventListener(Event.ENTER_FRAME, update);
}





private function iniFrameWork():void
{
topFrame = new WireframePlane(500, 500, 2, 2, 0xFF6613, 1.5, WireframePlane.ORIENTATION_XZ);
topFrame.y = 515;
away3dView.scene.addChild(topFrame);

rightFrame = new WireframePlane(500, 500, 2, 2, 0xFF6613, 1.5, WireframePlane.ORIENTATION_YZ);
rightFrame.y = 265;
rightFrame.x = 250;
away3dView.scene.addChild(rightFrame);

frontFrame = new WireframePlane(500, 500, 2, 2, 0xFF6613, 1.5, WireframePlane.ORIENTATION_XY);
frontFrame.y = 265;
frontFrame.x = 0;
frontFrame.z = 250;
away3dView.scene.addChild(frontFrame);


leftFrame = new WireframePlane(500, 500, 2, 2, 0xFF6613, 1.5, WireframePlane.ORIENTATION_YZ);
leftFrame.y = 265;
leftFrame.x = -250;
leftFrame.z = 0;
away3dView.scene.addChild(leftFrame);

middleFrame = new WireframePlane(500, 500, 2, 2, 0xFF6613, 1.5, WireframePlane.ORIENTATION_XZ);
middleFrame.y = 265;
away3dView.scene.addChild(middleFrame);
}



// Basic camera setup.... using hover controller instead

//away3dView.camera.position = new Vector3D(0,500,-700);
//away3dView.camera.lookAt(new Vector3D());
//hoverController = new HoverController(away3dView.camera, null, 45, 30, 1200, 5, 89.999);

*/






