package star
{

	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.controls.TabBar;
	import feathers.data.ListCollection;
	import feathers.motion.transitions.ScreenFadeTransitionManager;
	import feathers.themes.MetalWorksMobileTheme;
	
	import screens.CameraScreen;
	import screens.DisplayScreen;
	import screens.HomeScreen;
	import screens.PointFinder;
	import screens.SettingsScreen;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Main extends Sprite
	{
		private var screenNavigator:ScreenNavigator;
		private var screenTransitionManager:ScreenFadeTransitionManager; // allow nice fades between screens. 
		private var navigationBar:TabBar; 
		// nav height - keep take of navigation bar height. 
		// adjust other components to take this height into consideration.
		private var navHeight:int;
		
		private static const HOME_SCREEN:String = "homeScreen"; 
		private static const BROWSE_SCREEN:String = "browseScreen"; 
		private static const POINTFINDER_SCREEN:String = "pointFinder";
		private static const DISPLAY_SCREEN:String = "displayScreen";
		private static const SETTINGS_SCREEN:String = "settingsScreen";
		
		
		
		/*
		Description - screen navigator instance - displays current screen and handling transitions between screens. 
		*/ 
		
		public function Main()
		{
			// when this class is added to the stage and is ready to do visual manipulation on it. 
			this.addEventListener(Event.ADDED_TO_STAGE, onStageReady);
		}
		
		private function onStageReady():void
		{
			new MetalWorksMobileTheme(); // all we need to do to implement the metalworks theme
			buildLayout();
			// take care of setting up all the screens and putting them in the screen navigator 
			setupScreens(); 
			completeLayout(); // wrap everything up.
			
		}
		
		private function completeLayout():void
		{
			// set nav height 
			// need to validate
			navigationBar.validate(); // force the component to report its position
			navHeight = Math.round(navigationBar.height); // could not be a whole number 
			//adjust position and size of our screen navigator component to take into account the nav bar height
			screenNavigator.y = navHeight;
			screenNavigator.width = stage.stageWidth;
			screenNavigator.height = stage.stageHeight-navHeight;
			
			addChild(screenNavigator);
		}
		
		private function buildLayout():void
		{
			// Create our tab bar and bind our data to it in a form of a list collection. 
			
			// instatitates our navigation bar 
			navigationBar = new TabBar();
			navigationBar.dataProvider = new ListCollection([
				{label:"Home", data:HOME_SCREEN},
				{label:"Camera Feeds" , data:BROWSE_SCREEN},
				{label:"Reflector Association Process" , data:POINTFINDER_SCREEN},
				{label:"3-D Display", data:DISPLAY_SCREEN},
				{label:"Settings", data:SETTINGS_SCREEN},
			]);
			
			navigationBar.selectedIndex  = 2; // loads homescreens
			navigationBar.addEventListener(Event.CHANGE, navigationBarChanged);
			
			// make the bar expand across the entire stage. 
			navigationBar.width = stage.stageWidth;
			
			// add it to the stage
			addChild(navigationBar);
			
		}
		
		private function navigationBarChanged(event:Event):void
		{
			// instruct our screen navigator to show a particular screen
			
			// we are passing in the selectedItem.data ATTRIBUTE from the navigation bar
			screenNavigator.showScreen(navigationBar.selectedItem.data);
			
		}
		
		private function setupScreens():void
		{
			screenNavigator = new ScreenNavigator();
			screenNavigator.addScreen(HOME_SCREEN, new ScreenNavigatorItem(HomeScreen));
			screenNavigator.addScreen(BROWSE_SCREEN, new ScreenNavigatorItem(CameraScreen));
			screenNavigator.addScreen(POINTFINDER_SCREEN, new ScreenNavigatorItem(PointFinder));
			screenNavigator.addScreen(DISPLAY_SCREEN, new ScreenNavigatorItem(DisplayScreen));
			screenNavigator.addScreen(SETTINGS_SCREEN, new ScreenNavigatorItem(SettingsScreen));
			
			// Full control over which screen is being displayed. 
			screenTransitionManager = new ScreenFadeTransitionManager(screenNavigator);
		}
	}
}

/*
// Button schematic 
//---------------------------------------
var btn:Button = new Button();
btn.label = "Feathers button";
addChild(btn);

*/