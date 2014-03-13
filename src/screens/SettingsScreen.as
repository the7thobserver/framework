package screens
{
	// flash imports
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextFormat;
	
	import feathers.controls.Button;
	import feathers.controls.Screen;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	
	import starling.events.Event;
	
	// begin class SettingsScreen
	public class SettingsScreen extends Screen {
		
		  ///////////////////
		 //   CONSTANTS  //
		//////////////////
		
		// page title
		private const TITLE:String = "Settings";
		
		// button label
		private const SAVE:String = "Save settings";
		
		// constant field names
		private const VERTICAL:String = "Vertical Axis:";
		private const HORIZONTAL:String = "Horizontal Axis:";
		private const COORD_TITLE:String = "Camera Coordinates";
		private const CAM_1_COORDS:String = "Camera 1:";
		private const CAM_2_COORDS:String = "Camera 2:";
		private const CAM_3_COORDS:String = "Camera 3:";
		private const REFLECTOR_DIST_HEADER:String = "Calibration Reflector Distances";
		
		// settings file path
		public static const SETTINGS_PATH:String = "C:/SAS Data/settings.txt";
		
		// field sizes
		private const HEADER_WIDTH:Number = 150;
		private const HEADER_HEIGHT:Number = 50;
		private const BOX_WIDTH:Number = 100;
		private const BOX_HEIGHT:Number = 25;
		
		// button sizes
		private const BUTTON_WIDTH:Number = 100;
		private const BUTTON_HEIGHT:Number = 50;
		
		// font size
		private const INPUT_FONT_SIZE:Number = 15;
		
		  //////////////////
		 //   VARIABLES  //
		//////////////////
		
		// text field variables
		private var vertical_axis_header:TextArea;
		private var horizontal_axis_header:TextArea;
		private var title:TextArea;
		private var cam_coords:TextArea;
		private var cam_1_header:TextArea;
		private var cam_2_header:TextArea;
		private var cam_3_header:TextArea;
		private var reflector_dist_header:TextArea;
		private var instructions:TextArea;
		
		// input box variables
		private var cam_1_coords:TextInput;
		private var cam_2_coords:TextInput;
		private var cam_3_coords:TextInput;
		private var vertical_axis:TextInput;
		private var horizontal_axis:TextInput;
		
		// settings file variables
		private var settings_file:File;
		private var filestream:FileStream;

		// save button
		private var save_button:Button;
		
		// settings values
		private var values:Array;
		
		
//-----------------------------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------------------------//
		
		
		/**
		 * Constructor
		 */
		public function SettingsScreen() {
			
			// instantiate text area objects
			title = new TextArea();
			cam_coords = new TextArea();
			cam_1_header = new TextArea();
			cam_2_header = new TextArea();
			cam_3_header = new TextArea();
			reflector_dist_header = new TextArea();
			vertical_axis_header = new TextArea();
			horizontal_axis_header = new TextArea();
			instructions = new TextArea();
			
			// instantiate input boxes
			cam_1_coords = new TextInput();
			cam_2_coords = new TextInput();
			cam_3_coords = new TextInput();
			vertical_axis = new TextInput();
			horizontal_axis = new TextInput();
			
			// instantiate filestream
			filestream = new FileStream();
			
			// create array of values
			values = new Array();
			
			// instantiate save button
			save_button = new Button();
			
			// add event listener to button
			save_button.addEventListener(starling.events.Event.TRIGGERED, writeSettingsToFile);
		}
		
		
		/**
		 * initialize(): override of the standard initialize function
		 */
		override protected function initialize():void {
			
			// create title of the page
			title.text = TITLE;
			title.width = HEADER_WIDTH;
			title.height = HEADER_HEIGHT;
			title.isEditable = false;
			title.x = 5;
			title.y = 5;

			// create camera coordinates title
			cam_coords.text = COORD_TITLE;
			cam_coords.width = HEADER_WIDTH + 100;
			cam_coords.height = HEADER_HEIGHT;
			cam_coords.isEditable = false;
			cam_coords.x = 5;
			cam_coords.y = 70;
			
			// create camera 1 coordinates text
			cam_1_header.text = CAM_1_COORDS;
			cam_1_header.width = HEADER_WIDTH;
			cam_1_header.height = HEADER_HEIGHT;
			cam_1_header.isEditable = false;
			cam_1_header.x = 35;
			cam_1_header.y = 112;
			
			// create camera 2 coordinates text
			cam_2_header.text = CAM_2_COORDS;
			cam_2_header.width = HEADER_WIDTH;
			cam_2_header.height = HEADER_HEIGHT;
			cam_2_header.isEditable = false;
			cam_2_header.x = 35;
			cam_2_header.y = 142;
			
			// create camera 3 coordinates text
			cam_3_header.text = CAM_3_COORDS;
			cam_3_header.width = HEADER_WIDTH-50;
			cam_3_header.height = HEADER_HEIGHT;
			cam_3_header.isEditable = false;
			cam_3_header.x = 35;
			cam_3_header.y = 172;
			
			// create camera 1 input box
			cam_1_coords.width = BOX_WIDTH;
			cam_1_coords.height = BOX_HEIGHT;
			cam_1_coords.x = 130;
			cam_1_coords.y = 110;
			
			// create camera 2 input box
			cam_2_coords.width = BOX_WIDTH;
			cam_2_coords.height = BOX_HEIGHT;
			cam_2_coords.x = 130;
			cam_2_coords.y = 140;
			
			// create camera 3 input box
			cam_3_coords.width = BOX_WIDTH;
			cam_3_coords.height = BOX_HEIGHT;
			cam_3_coords.isEditable = true;
			cam_3_coords.x = 130;
			cam_3_coords.y = 170;
			
			// create reflector distances title
			reflector_dist_header.text = REFLECTOR_DIST_HEADER;
			reflector_dist_header.width = HEADER_WIDTH + 200;
			reflector_dist_header.height = HEADER_HEIGHT + 100;
			reflector_dist_header.isEditable = false;
			reflector_dist_header.x = 400;
			reflector_dist_header.y = 70;
			
			// create instructions for the user
			instructions.text = "*** Input coordinates with the following format: x,y,z (no spaces) where x,y and z are numbers\n*** All units are in Meters";
			instructions.width = 900;
			instructions.height = 200;
			instructions.x = 25;
			instructions.y = 300;
			
			// create the vertical axis text field
			vertical_axis_header.text = VERTICAL;
			vertical_axis_header.width = HEADER_WIDTH;
			vertical_axis_header.height = HEADER_HEIGHT;
			vertical_axis_header.isEditable = false;
			vertical_axis_header.x = 440;
			vertical_axis_header.y = 142;
			
			// create vertical axis input box
			vertical_axis.width = BOX_WIDTH;
			vertical_axis.height = BOX_HEIGHT;
			vertical_axis.x = 565;
			vertical_axis.y = 140;
			
			// create the horizontal axis text field
			horizontal_axis_header.text = HORIZONTAL;
			horizontal_axis_header.width = HEADER_WIDTH;
			horizontal_axis_header.height = HEADER_HEIGHT;
			horizontal_axis_header.isEditable = false;
			horizontal_axis_header.x = 440;
			horizontal_axis_header.y = 172;
			
			// create horizontal axis input box
			horizontal_axis.width = BOX_WIDTH;
			horizontal_axis.height = BOX_HEIGHT;
			horizontal_axis.x = 565;
			horizontal_axis.y = 170;
			
			save_button.label = "Save";
			save_button.width = BUTTON_WIDTH;
			save_button.height = BUTTON_HEIGHT;
			save_button.x = 565;
			save_button.y = 220;
			
			// add components
			addChild(title);
			addChild(cam_coords);
			addChild(cam_1_header);
			addChild(cam_1_coords);
			addChild(cam_2_header);
			addChild(cam_2_coords);
			addChild(cam_3_coords);
			addChild(cam_3_header);
			addChild(reflector_dist_header);
			addChild(vertical_axis_header);
			addChild(vertical_axis);
			addChild(horizontal_axis_header);
			addChild(horizontal_axis);
			addChild(instructions);
			addChild(save_button);
			
			// change text formats
			title.textEditorProperties.textFormat = new TextFormat("Arial", 30, 0xffffff);
			cam_coords.textEditorProperties.textFormat = new TextFormat("Arial", 25, 0xffffff);
			cam_1_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			cam_2_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			cam_3_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			vertical_axis_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			horizontal_axis_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			reflector_dist_header.textEditorProperties.textFormat = new TextFormat("Arial", 25, 0xffffff);
			instructions.textEditorProperties.textFormat = new TextFormat("Arial", 20, 0xffffff);
			
			// change font sizes of input boxes to be readable
			cam_1_coords.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			cam_2_coords.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			cam_3_coords.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			vertical_axis.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			horizontal_axis.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			
			// read settings file to get current values
			values = readSettingsFile();
			
			// set current values
			if(values != null)
				loadSettings(values);
		}
		
		/**
		 * Function for saving settings to text file
		 */
		private function writeSettingsToFile(event:Event):void {
			
			// set the settings file
			settings_file = File.desktopDirectory.resolvePath(SETTINGS_PATH);
			
			// open the file
			filestream.open(settings_file, FileMode.WRITE);
			
			// write field values to text file
			filestream.writeUTFBytes("camera1:" + cam_1_coords.text + "\r\n");
			filestream.writeUTFBytes("camera2:" + cam_2_coords.text + "\r\n");
			filestream.writeUTFBytes("camera3:" + cam_3_coords.text + "\r\n");
			filestream.writeUTFBytes("horizontal:" + vertical_axis.text + "\r\n");
			filestream.writeUTFBytes("vertical:" + horizontal_axis.text + "\r\n");
			
			// close the file
			filestream.close();
		}
		
		
		/**
		 * Function for reading the settings file and storing the values in an array
		 */
		public static function readSettingsFile():Array {
			
			try{
				// set the file and open the filestream
				var settings_file:File = File.desktopDirectory.resolvePath(SETTINGS_PATH);
				var filestream:FileStream = new FileStream();
				filestream.open(settings_file, FileMode.READ);
			}
			catch(e:Error)
			{
				return null;
			}
			
			// get all lines within the file
			var lines:Array = filestream.readUTFBytes(filestream.bytesAvailable).split("\r\n");
			
			// temporary array to hold keys and values
			var tempvals:Array;
			
			var values:Array = new Array();
			
			// write each value from file into array of values
			for(var i:int = 0; i < lines.length-1; i++) {
				tempvals = lines[i].split(":");
				values[i] = tempvals[1];
			}
			
			// close the filestream
			filestream.close();
			
			return values;
		}
		
		
		/**
		 * Function for loading the current settings to show in input boxes
		 */
		private function loadSettings(values:Array):void {
			
			// place each value in appropriate input box
			cam_1_coords.text = values[0];
			cam_2_coords.text = values[1];
			cam_3_coords.text = values[2];
			horizontal_axis.text = values[3];
			vertical_axis.text = values[4];
		}
	}
}