package screens
{
	// import image encoder
	import com.adobe.images.PNGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.sendToURL;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.text.BitmapFontTextFormat;
	
	import starling.display.Image;
	import starling.events.Event;
	
	
	///////////////////////////////////////////
	//		  	   Class Variables           //
	//////////////////////////////////////////
	
	public class CameraScreen extends Screen 
	{
		
		// URLs for Camera 1
		private const CAM_1_IMAGE_URL:String = "http://192.168.10.102/image/jpeg.cgi";
		private const CAM_1_IR_ON:String = "http://192.168.10.102/dev/ir_ctrl.cgi?ir=1";
		private const CAM_1_IR_OFF:String = "http://192.168.10.102/dev/ir_ctrl.cgi?ir=0";
		private const CAM_1_SAVE_PATH:String = "C:/SAS Data/camera images/cam1.png";
		
		// URLS for Camera 2
		private const CAM_2_IMAGE_URL:String = "http://192.168.10.103/image/jpeg.cgi";
		private const CAM_2_IR_ON:String = "http://192.168.10.103/dev/ir_ctrl.cgi?ir=1";
		private const CAM_2_IR_OFF:String = "http://192.168.10.103/dev/ir_ctrl.cgi?ir=0";
		private const CAM_2_SAVE_PATH:String = "C:/SAS Data/camera images/cam2.png";
		
		// URLs for Camera 3
		private const CAM_3_IMAGE_URL:String = "http://192.168.10.104/image/jpeg.cgi";
		private const CAM_3_IR_ON:String = "http://192.168.10.104/dev/ir_ctrl.cgi?ir=1";
		private const CAM_3_IR_OFF:String = "http://192.168.10.104/dev/ir_ctrl.cgi?ir=0";
		private const CAM_3_SAVE_PATH:String = "C:/SAS Data/camera images/cam3.png";
		
		// Constants for snapshots button
		private const SNAPSHOT_BUTTON_LABEL:String = "Take snapshots";
		private const SNAPSHOT_BUTTON_X:Number = 800;
		private const SNAPSHOT_BUTTON_Y:Number = 400;
		
		// Constants for ir button
		private const IR_BUTTON_LABEL:String = "Switch IR On/Off";
		private const IR_BUTTON_X:Number = 800;
		private const IR_BUTTON_Y:Number = 450;
		
		// Constants for pause button
		private const PAUSE_BUTTON_LABEL:String = "Pause/Resume";
		private const PAUSE_BUTTON_X:Number = 800;
		private const PAUSE_BUTTON_Y:Number = 500;
		
		// Scaling factor for images
		private const SCALER:Number = 2.4;
		
		// General constants for buttons
		private const BUTTON_WIDTH:Number = 100;
		private const BUTTON_HEIGHT:Number = 50;
		
		// Boolean values to determine state of the IR lights
		private var ir_lights:Boolean;
		
		// Temporary Bitmap used to store incoming images
		private var bitmap_cam_1:Bitmap;
		private var bitmap_cam_2:Bitmap;
		private var bitmap_cam_3:Bitmap;
		
		// Image variables for camera images
		private var image_cam_1:Image;
		private var image_cam_2:Image;
		private var image_cam_3:Image;
		
		// Byte array used to store image bytes
		private var image_bytes:ByteArray;
		
		// Loader and URL variables for Camera 1
		private var loader_cam_1:Loader;
		private var request_cam_1:URLRequest;
		
		// Loader and URL variables for Camera 2
		private var loader_cam_2:Loader;
		private var request_cam_2:URLRequest;
		
		// Loader and URL variables for Camera 3
		private var loader_cam_3:Loader;
		private var request_cam_3:URLRequest;
		
		// Timing variable
		private var timer:Timer;
		
		// Variables for saving images
		private var bytes:ByteArray;
		private var file_stream:FileStream;
		private var save_file:File;
		
		// Feathers object
		private var image_layout:LayoutGroup;
		
		// Button variables
		private var snapshot_button:Button;
		private var ir_button:Button;
		private var pause_button:Button;


		/////////////////////////////////////////
		//			    Constructor            //
		////////////////////////////////////////
		
		/**
		 * Constructor:
		 * Initializes all variables and adds event listeners
		 */
		public function CameraScreen():void{
			
			// initialize Bitmap objects
			bitmap_cam_1 = new Bitmap();
			bitmap_cam_2 = new Bitmap();
			bitmap_cam_3 = new Bitmap();
			
			// set initial state of the IR light
			ir_lights = false;
			
			// initialize timer to go off every 500ms
			timer = new Timer(1500);
			
			// initialize camera 1 variables
			request_cam_1 = new URLRequest();
			loader_cam_1 = new Loader();
			
			// initialize camera 2 variables
			request_cam_2 = new URLRequest();
			loader_cam_2 = new Loader();
			
			// initialize camera 3 variables
			request_cam_3 = new URLRequest();
			loader_cam_3 = new Loader();
			
			// initialize filestream used to save files
			file_stream = new FileStream();
			
			// create the layout used for the images
			image_layout = new LayoutGroup();
			
			// create the buttons
			snapshot_button = new Button();
			ir_button = new Button();
			pause_button = new Button();
			
			// create loader event listeners
			loader_cam_1.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, cam1LoadComplete);
			loader_cam_2.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, cam2LoadComplete);
			loader_cam_3.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, cam3LoadComplete);
			
			// create button event listeners
			snapshot_button.addEventListener(starling.events.Event.TRIGGERED, snapshotButtonClicked);
			ir_button.addEventListener(starling.events.Event.TRIGGERED, switchIRLights);
			pause_button.addEventListener(starling.events.Event.TRIGGERED, pauseButtonClicked);
			
			// create timer listener
			timer.addEventListener(TimerEvent.TIMER, refreshImages);
		}
		
		
		////////////////////////////////////////////////////
		//				Overridden Functions             //
		///////////////////////////////////////////////////
		
		/**
		 * Override of dispose function to stop the timer when screen is no longer active,
		 * otherwise weird things start happening
		 */
		override public function dispose():void {
			
			// stop the timer
			timer.stop();
			
			// call the superclass dispose function
			super.dispose();
		}
		
		
		/**
		 * Override of the initialize function to build the image container and start the timer
		 * when the screen is active
		 */
		override protected function initialize():void{
			
			// set the size of the image layout
			image_layout.width = this.stage.stageWidth;
			image_layout.height = this.stage.stageHeight;
			
			// add the image layout to the screen
			addChild(image_layout);
			
			// initialize the snapshot button
			snapshot_button.label = SNAPSHOT_BUTTON_LABEL;
			snapshot_button.width = BUTTON_WIDTH;
			snapshot_button.height = BUTTON_HEIGHT;
			snapshot_button.x = SNAPSHOT_BUTTON_X;
			snapshot_button.y = SNAPSHOT_BUTTON_Y;
			
			// add the button to the screen
			addChild(snapshot_button);
			
			// initialize the IR button
			ir_button.label = IR_BUTTON_LABEL;
			ir_button.width = BUTTON_WIDTH;
			ir_button.height = BUTTON_HEIGHT;
			ir_button.x = IR_BUTTON_X;
			ir_button.y = IR_BUTTON_Y;
			
			// add the button to the screen
			addChild(ir_button);
			
			// initialize the Pause button
			pause_button.label = PAUSE_BUTTON_LABEL;
			pause_button.width = BUTTON_WIDTH;
			pause_button.height = BUTTON_HEIGHT;
			pause_button.x = PAUSE_BUTTON_X;
			pause_button.y = PAUSE_BUTTON_Y;
			
			// add the button to the screen
			addChild(pause_button);
			
			// start the timer
			timer.start();
		}
		
		
		//////////////////////////////////////////////////////////////
		//				       EVENT HANDLERS                      //
		/////////////////////////////////////////////////////////////
		
		/**
		 * Displays the image from Camera 1 once the image is loaded
		 */
		private function cam1LoadComplete(event:flash.events.Event):void {
			
			// if the image is in the layout, remove it first
			if (image_layout.contains(image_cam_1))
				image_layout.removeChild(image_cam_1);
			
			// get the bitmapData of the loaded image
			bitmap_cam_1.bitmapData = event.target.content.bitmapData;
			
			// load the bitmapData into an Image object
			image_cam_1 = Image.fromBitmap(bitmap_cam_1);
			
			// set the height and width of the image
			image_cam_1.height = (image_layout.height / SCALER) + 20;
			image_cam_1.width = image_layout.width / SCALER;
			
			// set the coordinates of the image
			image_cam_1.x = 72;
			image_cam_1.y = 0;
			
			// add the image to the layout
			image_layout.addChild(image_cam_1);
		}
		
		
		/**
		 * Displays the image from Camera 2 once the image is loaded
		 */
		private function cam2LoadComplete(event:flash.events.Event):void {
			
			// if the image is in the layout, remove it first
			if (image_layout.contains(image_cam_2))
				image_layout.removeChild(image_cam_2);
			
			// get the bitmapData of the loaded image
			bitmap_cam_2.bitmapData = event.target.content.bitmapData;
			
			// load the bitmapData into an Image object
			image_cam_2 = Image.fromBitmap(bitmap_cam_2);
			
			// set the height and width of the image
			image_cam_2.height = (image_layout.height / SCALER) + 20;
			image_cam_2.width = image_layout.width / SCALER;
			
			// set the coordinates of the image
			image_cam_2.x = image_layout.width/SCALER + 78;
			image_cam_2.y = 0;
			
			// add the image to the layout
			image_layout.addChild(image_cam_2);
		}
		
		
		/**
		 * Displays the image from Camera 3 once the image is loaded
		 */
		private function cam3LoadComplete(event:flash.events.Event):void {
			
			// if the image is in the layout, remove it first
			if (image_layout.contains(image_cam_3))
				image_layout.removeChild(image_cam_3);
			
			// get the bitmapData of the loaded image
			bitmap_cam_3.bitmapData = event.target.content.bitmapData;
			
			// load the bitmapData into an Image object
			image_cam_3 = Image.fromBitmap(bitmap_cam_3);
			
			// set the height and width of the image
			image_cam_3.height = (image_layout.height / SCALER) + 20;
			image_cam_3.width = image_layout.width / SCALER;
			
			// set the coordinates of the image
			image_cam_3.x = 72;
			image_cam_3.y = image_layout.height / SCALER + 25;
			
			// add the image to the layout
			image_layout.addChild(image_cam_3);
		}
		
		
		/**
		 * Event handler for pause button.  Allows the user to start/stop the camera feeds
		 */
		private function pauseButtonClicked(event:starling.events.Event):void {
			if (timer.running)
				timer.stop();
			else
				timer.start();
		}
		
		
		/**
		 * Refresh each of the camera images once the timer completes 1 tick
		 */
		private function refreshImages(event:flash.events.Event):void {
			
			// set the URL for the first camera and load the image
			request_cam_1.url = CAM_1_IMAGE_URL;
			try {
				// placed in try/catch block in case camera is not connected or something else goes wrong
				loader_cam_1.load(request_cam_1);
			} catch (e:Error){}
			
			// set the URL for the second camera and load the image
			request_cam_2.url = CAM_2_IMAGE_URL;
			try {
				// placed in try/catch block in case camera is not connected or something else goes wrong
				loader_cam_2.load(request_cam_2);
			} catch (e:Error){}
			
			// set the URL for the third camera and load the image
			request_cam_3.url = CAM_3_IMAGE_URL; 
			try {
				// placed in try/catch block in case camera is not connected or something else goes wrong
				loader_cam_3.load(request_cam_3);
			} catch(e:Error) {}
		}
		
		
		/**
		 * Event handler for snapshot button.
		 * 
		 * Saves files in the directory C:/camera images/
		 */
		private function snapshotButtonClicked(event:starling.events.Event):void {
			
			////// FOR CAMERA 1 //////
			
			// check if bitmapdata exists
			if (bitmap_cam_1.bitmapData != null) {
				
				// encode the image
				image_bytes = PNGEncoder.encode(bitmap_cam_1.bitmapData);
				
				// open the file
				save_file = File.desktopDirectory.resolvePath(CAM_1_SAVE_PATH);
				file_stream.open(save_file, FileMode.WRITE);
				
				// write to the file
				file_stream.writeBytes(image_bytes);
				
				// close the file
				file_stream.close();
			}
			
			////// FOR CAMERA 2 //////
			
			// check if bitmapdata exists
			if (bitmap_cam_2.bitmapData != null) {
				
				// encode the image
				image_bytes = PNGEncoder.encode(bitmap_cam_2.bitmapData);
				
				// open the file
				save_file = File.desktopDirectory.resolvePath(CAM_2_SAVE_PATH);
				file_stream.open(save_file, FileMode.WRITE);
				
				// write to the file
				file_stream.writeBytes(image_bytes);
				
				// close the file
				file_stream.close();
			}
			
			////// FOR CAMERA 3 //////
			
			// check if bitmapdata exists
			if (bitmap_cam_3.bitmapData != null) {
				
				// encode the image
				image_bytes = PNGEncoder.encode(bitmap_cam_3.bitmapData);
				
				// open the file
				save_file = File.desktopDirectory.resolvePath(CAM_3_SAVE_PATH);
				file_stream.open(save_file, FileMode.WRITE);
				
				// write to the file
				file_stream.writeBytes(image_bytes);
				
				// close the file
				file_stream.close();
			}
		}
		
		
		/**
		 * Event handler to switch on/off the IR lights
		 */
		private function switchIRLights(event:starling.events.Event, cam_number):void {
			
			// check status of lights
			if (ir_lights) {
				
				// set the appropriate URLs
				request_cam_1.url = CAM_1_IR_OFF;
				request_cam_2.url = CAM_2_IR_OFF;
				request_cam_3.url = CAM_3_IR_OFF;
				
				// set status to false
				ir_lights = false;
			}
			else {
				
				// set the appropriate URLs
				request_cam_1.url = CAM_1_IR_ON;
				request_cam_2.url = CAM_2_IR_ON;
				request_cam_3.url = CAM_3_IR_ON;
				
				// set status to true
				ir_lights = true;
			}
			
			// send requests to URLs; don't care about response
			sendToURL(request_cam_1);
			sendToURL(request_cam_2);
			sendToURL(request_cam_3);
		}
	}
}