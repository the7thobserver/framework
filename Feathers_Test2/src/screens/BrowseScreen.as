package screens
{
	import flash.filesystem.File;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	
	
	
	public class BrowseScreen extends Screen 
	{
		
		private var scrollContainer:ScrollContainer;	// feathers object
		private var verticalLayout:VerticalLayout;		// applied to scroll container
		private var imageLoader:ImageLoader;		// load in image loader 
		private var noImagesText:Label;					// label
		private var imagesList:List;
		

		override protected function initialize():void{
			buildContainer();
			buildControls();
			loadImages();
		}
		
		private function loadImages():void
		{
			//var listCollection:ListCollection = new ListCollection();
			// Step 1- declare file, represents a directy. but can represent both files and folders. 
			// The path "photos" corresponds to the directory path where we are saving any photos.
			var imagesDirectory:File = File.documentsDirectory.resolvePath("C:\Users\Nick\Pictures\PhotoData");
			var imagesArray:Array = new Array();//imagesDirectory.getDirectoryListing();
			var listCollection:ListCollection = new ListCollection();
			
//			// Step 2 - If a directory does exist do this stuff. 
			if(imagesDirectory.exists){ // this if statement checks to see if the directory actually exist. 
				imagesArray = imagesDirectory.getDirectoryListing();
				//var listCollection:ListCollection = new ListCollection();
				
				for (var i:int = 0; i < imagesArray.length; i++){
					if (imagesArray[i].extension == "jpg"){
						// define each object with 2 properties, Tile-name of file and Image-url property(points to location to file)
						listCollection.push({title:imagesArray[i].name, image:imagesArray[i].url})	
					}
				}
			}
//			
			if(listCollection.length == 0){
				showMessage();
			}else{
				imagesList.dataProvider = listCollection;
				imagesList.itemRendererProperties.labelField = "title";
				scrollContainer.addChild(imagesList);
			}
		}
		
		private function showMessage():void
		{
			scrollContainer.removeChildren(); // removes everything
			scrollContainer.addChild(noImagesText);
		}
		
		private function buildControls():void
		{
			imageLoader = new ImageLoader();
			scrollContainer.addChild(imageLoader); // pass in image loader
			
			noImagesText = new Label();
			noImagesText.text = "No images yet!";
			
			imagesList = new List();
			scrollContainer.addChild(imagesList); 

		}
		
		private function buildContainer():void
		{
			verticalLayout = new VerticalLayout(); 
			verticalLayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			verticalLayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			verticalLayout.gap = 25; // defines space between child items. 
			verticalLayout.padding = 25; // top bottom left right of scrool container has 25 pixel margin.
			
			
			scrollContainer = new ScrollContainer();
			scrollContainer.layout = verticalLayout; 	
			scrollContainer.width = this.stage.stageWidth;	
			scrollContainer.height = this.stage.stageHeight;
			addChild(scrollContainer); // add to the screen class
		}
		
		// Used for reposition, resize components. invoked anytime its necessary to invoke. 
		override protected function draw():void{
			var canvasDimension:int = this.actualWidth - (verticalLayout.padding*2);
			imageLoader.width = canvasDimension;
			imageLoader.height = canvasDimension; 
			
			// gives us the proper height for images list
			imagesList.height = actualHeight - actualWidth - verticalLayout.padding; 
			imagesList.width = canvasDimension;
		}
		
		
		
	}
}