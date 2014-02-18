package
{
	/* adobe flash platform, AS3, any IDE, */
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	import star.Main;
	
	import starling.core.Starling;
	
	[SWF(frameRate = "60", backgroundColor = "0x000000", height="800", width="1200")]
	
	public class Feathers_Test2 extends Sprite
	{
		private var starling:Starling;
		//private var mycomponent:MyComponent;
		
		
		[Embed(source="../bin-debug/splash.png")]
		private var Splash:Class;
		private var splash:Bitmap;
		
		
		public function Feathers_Test2()
		{
			splash = new Splash();
			splash.addEventListener(Event.ENTER_FRAME, onAddedToStage);
			addChild(splash);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			loaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		protected function onLoadComplete(event:Event):void
		{
			// Set up Starlring
			//Starling.handleLostContext = true;
			starling = new Starling(Main, stage);
			starling.start();
			// add event listeners to stage
			stage.addEventListener(Event.RESIZE, onStageResize); 
		}
		
		protected function onStageResize(event:Event):void
		{
			starling.stage.stageWidth = stage.stageWidth;
			starling.stage.stageHeight = stage.stageHeight;
			
			const viewPort:Rectangle = starling.viewPort; 
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
			timer.addEventListener(TimerEvent.TIMER, removeSplash); 
			timer.start();
		}
	}
}