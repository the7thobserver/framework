package screens
{
	import flash.text.TextFormat;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	public class PointFinder extends Screen
	{
		// 2048x2048
		[Embed(source="/../assets/humanAssistPhotos/table_sideR.jpg")]
		private static const SideTableR:Class; // use this to refer to the image data
		
		[Embed(source="/../assets/humanAssistPhotos/table_frontR.jpg")]
		private static const FrontTableR:Class; // use this to refer to the image data
		
		[Embed(source="/../assets/humanAssistPhotos/table_front1R.jpg")]
		private static const FrontTable1R:Class; // use this to refer to the image data
		
		// feathers display container stuff
		private var scrollContainer:ScrollContainer;
		private var verticleLayout:VerticalLayout;
		
		// picutres loader objects - This is where the picutre goes
		private var sideTable:ImageLoader;
		private var frontTable:ImageLoader;
		private var frontTable1:ImageLoader;
		
		private var instructionsText:Label;
		
		
		
		// Runs when class is first initialized. -made to be overridden
		private var verticalLayout:VerticalLayout;
		private var horizontalLayout:HorizontalLayout;
		private var container:ScrollContainer;
		private var layout:HorizontalLayout;
		
		
		override protected function initialize():void{
			buildContainer(); 
		 	loadTitles();
		}
		
		// This is where we load the images and text 
		private function loadTitles():void
		{
			var x:Image = new Image(Texture.fromEmbeddedAsset(SideTableR));
			var y:Image = new Image(Texture.fromEmbeddedAsset(SideTableR));
			var z:Image = new Image(Texture.fromEmbeddedAsset(SideTableR));
			
			container.addChild(x);
			container.addChild(y);
			container.addChild(z);
//			x.x = 25;
//			x.y = 25;
//			x.height = (1/3)*stage.height;
//			x.width = (1/3)*stage.width;
//			
//			this.addChild(x);
//			
//			var y:Image = new Image(Texture.fromEmbeddedAsset(SideTableR));
//			y.x = 
//			y.y = 25;
//			y.height = (1/3)*stage.height;
//			y.width = (1/3)*stage.width;
//			
//			this.addChild(y);
//			
//			var z:Image = new Image(Texture.fromEmbeddedAsset(SideTableR));
//			z.x = 25;
//			z.y = 25;
//			z.height = (1/3)*stage.height;
//			z.width = (1/3)*stage.width;
//			
//			this.addChild(z);
//			
			//sideTable = new ImageLoader();
			//frontTable = new ImageLoader();
			//frontTable1 = new ImageLoader();
			
			
			//The aspect ratio of an image describes the proportional relationship between its width and its height.
			//sideTable.maintainAspectRatio = true; // this changes the images to maintain aspect ration
			//sideTable
			//frontTable.maintainAspectRatio = true;
			//frontTable1.maintainAspectRatio = true;
			
			// Does the loading
			//sideTable.source = Texture.fromEmbeddedAsset(SideTableR); // the name of the image data. Texture is a starling class
			//frontTable.source = Texture.fromEmbeddedAsset(FrontTable); // the name of the image data. Texture is a starling class
			//frontTable1.source = Texture.fromEmbeddedAsset(FrontTable1); // the name of the image data. Texture is a starling class
		//sideTable.textureScale = 0.5;
		//	sideTable.height = 0.6*stage.height;
		//	sideTable.width = 0.6*stage.width;
			//addChild(sideTable);
			//scrollContainer.addChild(sideTable); // add to scroll container.
			//scrollContainer.addChild(frontTable); // add to scroll container.
			//scrollContainer.addChild(frontTable1); // add to scroll container.
			
//			
			instructionsText = new Label();
			instructionsText.textRendererProperties.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
			instructionsText.textRendererProperties.embedFonts = true;
			instructionsText.text = "Welcome to the marker selection screen. Please match the reflectors.";
			addChild(instructionsText);
			//scrollContainer.addChild(instructionsText);
			
		}
		
		// Here we deal with the scroll container and the layout thats being applied
		private function buildContainer():void
		{
//			verticalLayout = new VerticalLayout(); 
//			verticalLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
//			verticalLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
//			verticalLayout.gap = 25; // defines space between child items. 
			
//			horizontalLayout = new HorizontalLayout();
//			horizontalLayout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER; 
//			horizontalLayout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
//			horizontalLayout.gap = 25; 
//			addChild(horizontalLayout); 
			
			layout = new HorizontalLayout();
			layout.paddingTop = 10;
			layout.paddingRight = 15;
			layout.paddingBottom = 10;
			layout.paddingLeft = 15;
			layout.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			layout.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_MIDDLE;
			layout.gap = 20;

			
			
			container = new ScrollContainer();
			container.layout = layout;
			container.width = this.stage.stageWidth;	
			container.height = this.stage.stageHeight - 300;
			
			addChild(container);
			
//			scrollContainer = new ScrollContainer();
//			scrollContainer.layout = verticalLayout; 	
//			scrollContainer.width = this.stage.stageWidth;	
//			scrollContainer.height = this.stage.stageHeight;
//			addChild(scrollContainer); // add to the screen class
		}		
		
		
		// method of screen class, made to be overwritten. 
		// position and size things accurately.
		override protected function draw():void{
//			sideTable.validate(); // enforce current numbers to use them
//			sideTable.width = actualWidth; // actualWidth is a property of the feathers screen class 
//			sideTable.width =  actualWidth;
			
			//frontTable.validate(); // enforce current numbers to use them
			//frontTable.width = actualWidth; // actualWidth is a property of the feathers screen class 
			//frontTable.width =  actualWidth;
			
			//frontTable1.validate(); // enforce current numbers to use them
			//frontTable1.width = actualWidth; // actualWidth is a property of the feathers screen class 
			//frontTable1.width =  actualWidth;
		}
	}
}