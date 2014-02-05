package screens
{
	import flash.display.BitmapData;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class PointFinder extends Screen
	{
		// Max resolution size of a texture(?) = 2048x2048
		[Embed(source="/../assets/humanAssistPhotos/table_side.jpg")]
		private static const SideTable:Class;
		
		[Embed(source="/../assets/humanAssistPhotos/table_front.jpg")]
		private static const FrontTable:Class;
		
		[Embed(source="/../assets/humanAssistPhotos/table_front1.jpg")]
		private static const FrontTable1:Class;
		
		// Thumbnail design specs
		private const BORDERSIZE:int = 0;
		private const thumNailSize:int = 200;
		private const padding:int = 5;
		
		// Arrays to hold pictures
		private var imageArray:Array;
		private var thumnailArray:Array;
		
		// Keep track of side scroll
		private var touchBeginX:int;
		private var touchBeginY:int;
		
		// Temp main image holder
		private var mainImage:Image; 
		
		// Keep track of current image in array
		private var index:int = 0;
		
		// Containers which I assume are like divs in http
		private var mainImageContainer:LayoutGroup;
		private var thumnailContainer:ScrollContainer;
		private var layout:VerticalLayout;
		
		override protected function initialize():void{
			// Initilize arrays
			imageArray = new Array();
			thumnailArray = new Array();
			
			// Initilze thumnail contain with thumbnails
			buildContainers(); 
			
			// Initilize images
		 	loadImages();
			
			this.addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		private function onTouch(event:TouchEvent):void
		{
			var t:Touch = event.getTouch(this);
			
			if(t)
			{
				switch(t.phase)
				{	
				case TouchPhase.BEGAN:
					touchBeginX = t.globalX;
					touchBeginY = t.globalY;
					break;
				case TouchPhase.ENDED:
					if(Math.abs(t.globalX - touchBeginX) < 10)
					{
						if(Math.abs(t.globalY - touchBeginY) < 10)
						{
							trace(t.target.name);
							
							if(t.target.name == "mainImage")
							{
								trace("Human Assist Go");
								// humanAssist(t);
								index = (index + 1)  % imageArray.length;
								mainImage = imageArray[index];
							}	
							
							else if(t.target.name == "thumnail0")
							{
								var img:Image = new Image(Texture.fromEmbeddedAsset(FrontTable));
								
								mainImage = imageArray[0];
								index = 0;
							}
							else if(t.target.name == "thumnail1")
							{
								mainImage = imageArray[1];
								index = 1;
							}
							else if(t.target.name == "thumnail2")
							{
								mainImage = imageArray[2];
								index = 2;
							}
							
							mainImageContainer.addChild(mainImage);
						}
					}
					break;
				
				}
			}
		}
		
		private function loadImages():void
		{
			var thumNail1:Image = new Image(Texture.fromEmbeddedAsset(SideTable));
			var thumNail2:Image = new Image(Texture.fromEmbeddedAsset(FrontTable));
			var thumNail3:Image = new Image(Texture.fromEmbeddedAsset(FrontTable1));
			mainImage = new Image(Texture.fromEmbeddedAsset(SideTable));
			
			mainImage.name = "mainImage";
			thumNail1.name = "mainImage";
			thumNail2.name = "mainImage";
			thumNail3.name = "mainImage";
			
			var x:Image = new Image(Texture.fromEmbeddedAsset(SideTable));
			
			imageArray[0] = thumNail1;
			imageArray[1] = thumNail2;
			imageArray[2] = thumNail3;
			
			initThumnails();
		
			mainImageContainer.addChild(mainImage);
		}
		
		private function initThumnails():void
		{
			var thumNailHeight:int = 0;
			
			for(var i:int = 0; i < imageArray.length; i++)	
			{
				var temp:Image = new Image(imageArray[i].texture);
				
				temp.x = temp.x;
				temp.width = thumNailSize;
				temp.y = thumNailHeight;
				temp.height = thumNailSize;
				thumNailHeight += temp.height + BORDERSIZE;
	
				temp.name = "thumnail" + i;
				thumnailArray[i] = temp;
					
				thumnailContainer.addChild(temp);
			}
		}
		
		private function buildContainers():void
		{	
			layout = new VerticalLayout();
			layout.paddingTop = 0;
			layout.paddingRight = padding;
			layout.paddingBottom = padding;
			layout.paddingLeft = padding;
			layout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER
			layout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			layout.gap = 20;

			mainImageContainer = new LayoutGroup();
			mainImageContainer.x = thumNailSize + 2 * padding;
			mainImageContainer.y = 0;
			
			thumnailContainer = new ScrollContainer();
			thumnailContainer.layout = layout;
			thumnailContainer.backgroundSkin = new Image(Texture.fromBitmapData(new BitmapData(150, 150, true, 0x80FF3300)));
			thumnailContainer.x = 0;
			thumnailContainer.y = 0;
			thumnailContainer.width = thumNailSize + padding * 2;
			thumnailContainer.height = this.stage.stageHeight;
			thumnailContainer.verticalScrollPolicy = ScrollContainer.SCROLL_POLICY_ON;
			thumnailContainer.horizontalScrollPolicy = ScrollContainer.SCROLL_POLICY_OFF;

			addChild(thumnailContainer);
			addChild(mainImageContainer);
		}
	}
}