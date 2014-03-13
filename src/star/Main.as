package star
{
	
	// import feathers packages
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.controls.TabBar;
	import feathers.data.ListCollection;
	import feathers.motion.transitions.ScreenFadeTransitionManager;
	import feathers.themes.MetalWorksMobileTheme;
	
	// import screens
	import screens.CameraScreen;
	import screens.DisplayScreen;
	import screens.HomeScreen;
	import screens.PointFinder;
	import screens.SettingsScreen;
	
	// import starling packages
	import starling.display.Sprite;
	import starling.events.Event;
	
	///// BEGIN Main CLASS /////
	public class Main extends Sprite {
		
		  ////////////////////////////
		 ///// private constants ////
		////////////////////////////
		
		private static const HOME_SCREEN:String = "homeScreen"; 
		private static const BROWSE_SCREEN:String = "browseScreen"; 
		private static const POINTFINDER_SCREEN:String = "pointFinder";
		private static const DISPLAY_SCREEN:String = "displayScreen";
		private static const SETTINGS_SCREEN:String = "settingsScreen";
		
		  ////////////////////////////
		 ///// private variables ////
		////////////////////////////
		
		private var screenNavigator:ScreenNavigator;
		private var screenTransitionManager:ScreenFadeTransitionManager; // allow nice fades between screens. 
		private var navigationBar:TabBar; 
		private var navHeight:int;
		
//------------------------------------------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function Main() {
			// instantiate navigation bar and screen navigator 
			navigationBar = new TabBar();
			screenNavigator = new ScreenNavigator();
			
			// add event listener
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onStageReady);
		}
		
		//-----------------------------------------------------//
		//					 class functions                   //
		//-----------------------------------------------------//
		
		/**
		 * buildLayout(): builds the navigation bar
		 */
		private function buildLayout():void {
			
			// add screen names to the navigation bar
			navigationBar.dataProvider = new ListCollection([
				{label:"Home", data:HOME_SCREEN},
				{label:"Camera Feeds" , data:BROWSE_SCREEN},
				{label:"Reflector Association Process" , data:POINTFINDER_SCREEN},
				{label:"3-D Display", data:DISPLAY_SCREEN},
				{label:"Settings", data:SETTINGS_SCREEN},
			]);
			
			// set the initial screen
			navigationBar.selectedIndex  = 0;
			
			// make the bar expand across the entire stage. 
			navigationBar.width = stage.stageWidth;
			
			// add event listener
			navigationBar.addEventListener(starling.events.Event.CHANGE, navigationBarChanged);
			
			// add it to the stage
			addChild(navigationBar);
		}
		
		
		/**
		 * completeLayout(): finalizes the screen elements
		 */
		private function completeLayout():void {
			// force the component to report its position
			navigationBar.validate(); 
			navHeight = Math.round(navigationBar.height);
			
			//adjust position and size of our screen navigator component to take into account the nav bar height
			screenNavigator.y = navHeight;
			screenNavigator.width = stage.stageWidth;
			screenNavigator.height = stage.stageHeight-navHeight;
			
			// add screen navigator to the stage
			addChild(screenNavigator);
		}
		
		
		/**
		 * setupScreens(): adds the screen types that are used by the navigation bar
		 */
		private function setupScreens():void {
			
			// add screens to the navigation bar
			screenNavigator.addScreen(HOME_SCREEN, new ScreenNavigatorItem(HomeScreen));
			screenNavigator.addScreen(BROWSE_SCREEN, new ScreenNavigatorItem(CameraScreen));
			screenNavigator.addScreen(POINTFINDER_SCREEN, new ScreenNavigatorItem(PointFinder));
			screenNavigator.addScreen(DISPLAY_SCREEN, new ScreenNavigatorItem(DisplayScreen));
			screenNavigator.addScreen(SETTINGS_SCREEN, new ScreenNavigatorItem(SettingsScreen));
			
			// Full control over which screen is being displayed. 
			screenTransitionManager = new ScreenFadeTransitionManager(screenNavigator);
		}
		
		//------------------------------------------------------//
		//					  Event handlers                   //
		//-----------------------------------------------------//
		
		/**
		 * onStageReady(): event handler that build the screen elements when the stage is ready
		 */
		private function onStageReady(event:starling.events.Event):void {
			// implement the theme
			new MetalWorksMobileTheme();
			 
			// create the layout of the screen
			buildLayout();
			
			// setup all the screens and add to the screen navigator
			setupScreens();
			
			// finalize everything
			completeLayout();
			
			// add event listener
			stage.addEventListener(Event.RESIZE, resize);
		}

		
		/**
		 * navigationBarChanged(): event handler that changes the displayed screen when a new tab
		 * in the navigation bar is clicked
		 */
		private function navigationBarChanged(event:starling.events.Event):void {
			// instruct our screen navigator to show a particular screen
			
			// we are passing in the selectedItem.data ATTRIBUTE from the navigation bar
			screenNavigator.showScreen(navigationBar.selectedItem.data);
			
		}
		
		private function resize(event:Event):void {
			navigationBar.width = stage.stageWidth;
		}
	}
}
