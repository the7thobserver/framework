package
{
	/* adobe flash platform, AS3, any IDE, */
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import star.Main;
	
	import starling.core.Starling;
	
	[SWF(frameRate = "60", backgroundColor = "0x000000", height="800", width="1200")]
	
	public class Feathers_Test2 extends Sprite
	{
		private var starling:Starling;
		
		private var viewPort:Rectangle;
		
		public function Feathers_Test2()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			loaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		protected function onLoadComplete(event:Event):void
		{
			// Set up Starlring
			starling = new Starling(Main, stage);
			starling.start();
			
			// initialize the viewport
			viewPort = new Rectangle();
			
			// add event listeners to stage
			stage.addEventListener(Event.RESIZE, onStageResize);
			
		}
		
		protected function onStageResize(event:Event):void
		{
			starling.stage.stageWidth = stage.stageWidth;
			starling.stage.stageHeight = stage.stageHeight;
			
			viewPort = starling.viewPort; 
			viewPort.width = stage.stageWidth;
			viewPort.height = stage.stageHeight;
			
			// apply to starling viewport
			starling.viewPort = viewPort;
		}
	}
}