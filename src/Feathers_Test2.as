package
{
	// import Away3D packages
	import flash.display.Bitmap;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	
	import star.Main;
	
	import starling.core.Starling;
	
	// set size and background of window
	[SWF(frameRate = "60", backgroundColor = "0x000000", height="800", width="1200")]
	
	////// BEGIN CLASS Feathers_Test2 //////
	public class Feathers_Test2 extends Sprite
	{
		  ////////////////////////
		 // private variables  //
		////////////////////////
		
		// starling variable, used to instantiate the starling windows
		private var starling:Starling;
		
		// variable for shape/size of viewing window
		private var viewPort:Rectangle;
		
		// variables for creating a new, separate window
		public static var window:NativeWindow;
		private var initializer:NativeWindowInitOptions;
		
		// stage3D variables used for new native window
		public static var stage3DManager:Stage3DManager;
		public static var stage3DProxy:Stage3DProxy;
		public static var away3dView:View3D;
		
		
		// Splash screen
		[Embed(source="../assets/screen images/splash.png")]
		private var Splash:Class;
		private var splash:Bitmap;
		
		
		/**
		 * Constructor
		 */
		public function Feathers_Test2() {
			
			// create starling instance
			starling = new Starling(Main, stage);
			
			// set window initializer settings
			initializer = new NativeWindowInitOptions();
			initializer.resizable = true;
			initializer.maximizable = true;
			initializer.minimizable = true;
			initializer.renderMode = "direct";
			
			// create new window, activate it, but keep it minimized
			window = new NativeWindow(initializer);
			window.activate();
			window.minimize();
			
			// Define a new Stage3DManager for the Stage3D objects
			stage3DManager = Stage3DManager.getInstance(window.stage);
			
			// Create a new Stage3D proxy to contain the separate views
			stage3DProxy = stage3DManager.getFreeStage3DProxy();
			
			// create static View3D object
			away3dView = new View3D();
			
			// ensure that the main window starts with a maximized window
			stage.nativeWindow.maximize();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Splash screen
			splash = new Splash();
			splash.addEventListener(Event.ENTER_FRAME, onAddedToStage);
			addChild(splash);
			// 75 is the missing width for the splash screen for whatever reason
			splash.width = stage.stageWidth + 75;
			splash.height = stage.stageHeight;
			
			// add event listeners
			loaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			stage.nativeWindow.addEventListener(Event.CLOSING, onClose);
			stage.addEventListener(Event.RESIZE, onStageResize);
			window.stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, onKeyStrike);
			window.addEventListener(Event.CLOSING, onDirectClose);
		}
		
		
		/**
		 * onDirectClose(): used as an event handler to keep the Away3D window open
		 * even if a user tries to close it
		 */
		public function onDirectClose(event:Event):void {
			event.preventDefault();
			window.minimize();
		}
		
		
		/**
		 * onKeyStrike(): event handler called when any key is struck, causing the
		 * Away3D window to minimize
		 */
		public function onKeyStrike(event:KeyboardEvent):void {
			if (event.charCode == 27)
				window.minimize();
		}
		
		
		/**
		 * onClose(): event handler called when user closes the main program.  Also
		 * causes the Away3D window to close as well
		 */
		private function onClose(event:Event):void {
			window.removeEventListener(Event.CLOSING, onDirectClose);
			window.close();
		}
		
		
		/**
		 * onLoadComplete(): event handler called once everything is finished loading.
		 */
		protected function onLoadComplete(event:Event):void
		{
			// Set up Starlring
			starling.start();
			
			// initialize the viewport
			viewPort = new Rectangle();
			
			// set stage width and height
			starling.stage.stageWidth = stage.stageWidth;
			starling.stage.stageHeight = stage.stageHeight;
			
			// set the size and position of the Away3D window
			window.width = stage.nativeWindow.width;
			window.height = stage.nativeWindow.height;
			window.x = 0;
			window.y = 0;

			// set reference for viewPort, and it's height/width
			viewPort = starling.viewPort; 
			viewPort.width = stage.stageWidth;
			viewPort.height = stage.stageHeight;
		}
		
		protected function onStageResize(event:Event):void
		{
			// set new width/height of starling stage
			starling.stage.stageWidth = stage.stageWidth;
			starling.stage.stageHeight = stage.stageHeight;

			// set new width/height of view port
			viewPort = starling.viewPort; 
			viewPort.width = stage.stageWidth;
			viewPort.height = stage.stageHeight;
			
			// apply to starling viewport
			starling.viewPort = viewPort;
		}
		
		
		//Call this once your first Starling view has rendered
		public function removeSplash(event:TimerEvent):void
		{
			if (splash && splash.parent)
			{
				removeChild(splash);
			}
		}
		
		private function onAddedToStage(event:Event):void
		{
			splash.removeEventListener(Event.ENTER_FRAME, onAddedToStage);
			
			
			var timer:Timer = new Timer(1500);
			timer.addEventListener(TimerEvent.TIMER, removeSplash); // will call callback()
			timer.start();
		}
	}
}