package screens
{
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.layout.VerticalLayout;
	
	import starling.textures.Texture; 			// using png images as textures for feathers controls image loader
	
	public class HomeScreen extends Screen
	{
		[Embed(source="/../assets/screen images/blue_skeleton.jpg")]
		private static const TitleImage:Class; // use this to refer to the image data
		
		private var scrollContainer:ScrollContainer;	// feathers object
		private var verticalLayout:VerticalLayout;		// applied to scroll container
		private var titleLoader:ImageLoader;		// load in image loader 
		private var subText:Label;					// Good for displaying Text on the screen.
		
		
		// runs whenever the class is first initialized. must be inherited from the Screen Class.
		override protected function initialize():void{
			
			buildContainer();
			loadTitles();
			
		}
		
		private function loadTitles():void
		{
			titleLoader = new ImageLoader();
			//titleLoader.maintainAspectRatio = true; // this changes the images to maintain aspect ration
			
			titleLoader.source = Texture.fromEmbeddedAsset(TitleImage); // the name of the image data. Texture is a starling class
			scrollContainer.addChild(titleLoader); // add to scroll container.
			
			
			subText = new Label();
			subText.text = "Getting those measurements faster.";
			scrollContainer.addChild(subText);
		}
		
		private function buildContainer():void
		{
			verticalLayout = new VerticalLayout(); 
			verticalLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			verticalLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			verticalLayout.gap = 25; // defines space between child items. 
			
			scrollContainer = new ScrollContainer();
			scrollContainer.layout = verticalLayout; 	
			scrollContainer.width = this.stage.stageWidth;	
			scrollContainer.height = this.stage.stageHeight;
			addChild(scrollContainer); // add to the screen class
		}
		
		// method of screen class, made to be overwritten. 
		// position and size things accurately.
		override protected function draw():void{
			titleLoader.validate(); // enforce current numbers to use them
			//titleLoader.width = actualWidth; // actualWidth is a property of the feathers screen class 
			titleLoader.width =  actualWidth;
		}
	}
}