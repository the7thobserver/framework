package screens
{
	// flash imports
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.text.TextFormat;
	
	// feathers imports
	import feathers.controls.Button;
	import feathers.controls.Screen;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	
	// starling import
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
		private const CENTER:String = "Center:";
		private const CENTER_LEFT:String = "Left Center:";
		private const CENTER_RIGHT:String = "Right Center:";
		private const CENTER_TOP:String = "Top Center:";
		private const CENTER_BOTTOM:String = "Bottom Center:";
		private const TOP_LEFT_DIAG:String = "Upper Left Diagonal:";
		private const BOTTOM_LEFT_DIAG:String = "Lower Left Diagonal:";
		private const TOP_RIGHT_DIAG:String = "Upper Right Diagonal:";
		private const BOTTOM_RIGHT_DIAG:String = "Lower Right Diagonal:";
		private const COORD_TITLE:String = "Camera Coordinates";
		private const CAM_1_COORDS:String = "Camera 1:";
		private const CAM_2_COORDS:String = "Camera 2:";
		private const CAM_3_COORDS:String = "Camera 3:";
		private const REFLECTOR_COORDS_HEADER:String = "Reflector Coordinates";
		
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
		private var center_header:TextArea;
		private var center_left_header:TextArea;
		private var center_right_header:TextArea;
		private var center_top_header:TextArea;
		private var center_bottom_header:TextArea;
		private var top_left_diag_header:TextArea;
		private var bottom_left_diag_header:TextArea;
		private var top_right_diag_header:TextArea;
		private var bottom_right_diag_header:TextArea;
		private var title:TextArea;
		private var cam_coords:TextArea;
		private var cam_1_header:TextArea;
		private var cam_2_header:TextArea;
		private var cam_3_header:TextArea;
		private var reflector_coords_header:TextArea;
		private var instructions:TextArea;
		
		// input box variables
		private var cam_1_coords:TextInput;
		private var cam_2_coords:TextInput;
		private var cam_3_coords:TextInput;
		private var center:TextInput;
		private var center_left:TextInput;
		private var center_right:TextInput;
		private var center_top:TextInput;
		private var center_bottom:TextInput;
		private var top_left_diag:TextInput;
		private var bottom_left_diag:TextInput;
		private var top_right_diag:TextInput;
		private var bottom_right_diag:TextInput;
		
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
			reflector_coords_header = new TextArea();
			center_header = new TextArea();
			center_left_header = new TextArea();
			center_right_header = new TextArea();
			center_top_header = new TextArea();
			center_bottom_header = new TextArea();
			top_left_diag_header = new TextArea();
			bottom_left_diag_header = new TextArea();
			top_right_diag_header = new TextArea();
			bottom_right_diag_header = new TextArea();
			instructions = new TextArea();
			
			// instantiate input boxes
			cam_1_coords = new TextInput();
			cam_2_coords = new TextInput();
			cam_3_coords = new TextInput();
			center = new TextInput();
			center_left = new TextInput();
			center_right = new TextInput();
			center_top = new TextInput();
			center_bottom = new TextInput();
			top_left_diag = new TextInput();
			bottom_left_diag = new TextInput();
			top_right_diag = new TextInput();
			bottom_right_diag = new TextInput();
			
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
			
			// create reflector coordinates title
			reflector_coords_header.text = REFLECTOR_COORDS_HEADER;
			reflector_coords_header.width = HEADER_WIDTH + 100;
			reflector_coords_header.height = HEADER_HEIGHT;
			reflector_coords_header.isEditable = false;
			reflector_coords_header.x = 5;
			reflector_coords_header.y = 250;
			
			// create center reflector text
			center_header.text = CENTER;
			center_header.width = HEADER_WIDTH;
			center_header.height = HEADER_HEIGHT;
			center_header.isEditable = false;
			center_header.x = 35;
			center_header.y = 292;
			
			// create left center reflector text
			center_left_header.text = CENTER_LEFT;
			center_left_header.width = HEADER_WIDTH;
			center_left_header.height = HEADER_HEIGHT;
			center_left_header.isEditable = false;
			center_left_header.x = 35;
			center_left_header.y = 322;
			
			// create right center reflector text
			center_right_header.text = CENTER_RIGHT;
			center_right_header.width = HEADER_WIDTH;
			center_right_header.height = HEADER_HEIGHT;
			center_right_header.isEditable = false;
			center_right_header.x = 35;
			center_right_header.y = 352;
			
			// create top center reflector text
			center_top_header.text = CENTER_TOP;
			center_top_header.width = HEADER_WIDTH;
			center_top_header.height = HEADER_HEIGHT;
			center_top_header.isEditable = false;
			center_top_header.x = 280;
			center_top_header.y = 292;
			
			// create bottom center relfector text
			center_bottom_header.text = CENTER_BOTTOM;
			center_bottom_header.width = HEADER_WIDTH;
			center_bottom_header.height = HEADER_HEIGHT;
			center_bottom_header.isEditable = false;
			center_bottom_header.x = 280;
			center_bottom_header.y = 322;
			
			// create top left diagonal reflector text
			top_left_diag_header.text = TOP_LEFT_DIAG;
			top_left_diag_header.width = HEADER_WIDTH;
			top_left_diag_header.height = HEADER_HEIGHT;
			top_left_diag_header.isEditable = false;
			top_left_diag_header.x = 280;
			top_left_diag_header.y = 352;
			
			// create bottom left diagonal reflector text
			bottom_left_diag_header.text = BOTTOM_LEFT_DIAG;
			bottom_left_diag_header.width = HEADER_WIDTH;
			bottom_left_diag_header.height = HEADER_HEIGHT;
			bottom_left_diag_header.isEditable = false;
			bottom_left_diag_header.x = 575;
			bottom_left_diag_header.y = 292;
			
			// create top right diagonal reflector text
			top_right_diag_header.text = TOP_RIGHT_DIAG;
			top_right_diag_header.width = HEADER_WIDTH;
			top_right_diag_header.height = HEADER_HEIGHT;
			top_right_diag_header.isEditable = false;
			top_right_diag_header.x = 575;
			top_right_diag_header.y = 322;
			
			// create bottom right diagonal reflector text
			bottom_right_diag_header.text = BOTTOM_RIGHT_DIAG;
			bottom_right_diag_header.width = HEADER_WIDTH;
			bottom_right_diag_header.height = HEADER_HEIGHT;
			bottom_right_diag_header.isEditable = false;
			bottom_right_diag_header.x = 575;
			bottom_right_diag_header.y = 352;
			
			// create instructions for the user
			instructions.text = "*** Input coordinates with the following format: x,y,z (no spaces) where x,y and z are numbers\n*** All units are in Meters";
			instructions.width = 900;
			instructions.height = 200;
			instructions.x = 25;
			instructions.y = 500;
			
			// create center reflector input box
			center.width = BOX_WIDTH;
			center.height = BOX_HEIGHT;
			center.x = 130;
			center.y = 290;
			
			// create left center reflector input box
			center_left.width = BOX_WIDTH;
			center_left.height = BOX_HEIGHT;
			center_left.x = 130;
			center_left.y = 320;
			
			// create right center reflector input box
			center_right.width = BOX_WIDTH;
			center_right.height = BOX_HEIGHT;
			center_right.x = 130;
			center_right.y = 350;
			
			// create top center reflector input box
			center_top.width = BOX_WIDTH;
			center_top.height = BOX_HEIGHT;
			center_top.x = 425;
			center_top.y = 290;
			
			// create bottom center reflector input box
			center_bottom.width = BOX_WIDTH;
			center_bottom.height = BOX_HEIGHT;
			center_bottom.x = 425;
			center_bottom.y = 320;
			
			// create top left diagonal reflector input box
			top_left_diag.width = BOX_WIDTH;
			top_left_diag.height = BOX_HEIGHT;
			top_left_diag.x = 425;
			top_left_diag.y = 350;
			
			// create bottom left diagonal reflector input box
			bottom_left_diag.width = BOX_WIDTH;
			bottom_left_diag.height = BOX_HEIGHT;
			bottom_left_diag.x = 750;
			bottom_left_diag.y = 290;
			
			// create top right diagonal reflector input box
			top_right_diag.width = BOX_WIDTH;
			top_right_diag.height = BOX_HEIGHT;
			top_right_diag.x = 750;
			top_right_diag.y = 320;
			
			// create bottom right diagonal reflector input box
			bottom_right_diag.width = BOX_WIDTH;
			bottom_right_diag.height = BOX_HEIGHT;
			bottom_right_diag.x = 750;
			bottom_right_diag.y = 350;
			
			// create save button
			save_button.label = SAVE;
			save_button.width = BUTTON_WIDTH;
			save_button.height = BUTTON_HEIGHT;
			save_button.x = 750;
			save_button.y = 400;
			
			// add components
			addChild(title);
			addChild(cam_coords);
			addChild(cam_1_header);
			addChild(cam_1_coords);
			addChild(cam_2_header);
			addChild(cam_2_coords);
			addChild(cam_3_coords);
			addChild(cam_3_header);
			addChild(reflector_coords_header);
			addChild(center_header);
			addChild(center);
			addChild(center_left_header);
			addChild(center_left);
			addChild(center_right_header);
			addChild(center_right);
			addChild(center_top_header);
			addChild(center_top);
			addChild(center_bottom_header);
			addChild(center_bottom);
			addChild(top_left_diag_header);
			addChild(top_left_diag);
			addChild(bottom_left_diag_header);
			addChild(bottom_left_diag);
			addChild(top_right_diag_header);
			addChild(top_right_diag);
			addChild(bottom_right_diag_header);
			addChild(bottom_right_diag);
			addChild(save_button);
			addChild(instructions);
			
			// change text formats
			title.textEditorProperties.textFormat = new TextFormat("Arial", 30, 0xffffff);
			cam_coords.textEditorProperties.textFormat = new TextFormat("Arial", 25, 0xffffff);
			cam_1_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			cam_2_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			cam_3_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			reflector_coords_header.textEditorProperties.textFormat = new TextFormat("Arial", 25, 0xffffff);
			center_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			center_left_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			center_right_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			center_top_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			center_bottom_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			top_left_diag_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			bottom_left_diag_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			top_right_diag_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			bottom_right_diag_header.textEditorProperties.textFormat = new TextFormat("Arial", 15, 0xffffff);
			instructions.textEditorProperties.textFormat = new TextFormat("Arial", 20, 0xffffff);
			
			// change font sizes of input boxes to be readable
			cam_1_coords.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			cam_2_coords.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			cam_3_coords.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			center.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			center_left.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			center_right.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			center_top.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			center_bottom.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			top_left_diag.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			bottom_left_diag.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			top_right_diag.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			bottom_right_diag.textEditorProperties.fontSize = INPUT_FONT_SIZE;
			
			// read settings file to get current values
			values = readSettingsFile();
			
			// set current values
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
			filestream.writeUTFBytes("center:" + center.text + "\r\n");
			filestream.writeUTFBytes("center_left:" + center_left.text + "\r\n");
			filestream.writeUTFBytes("center_right:" + center_right.text + "\r\n");
			filestream.writeUTFBytes("center_top:" + center_top.text + "\r\n");
			filestream.writeUTFBytes("center_bottom:" + center_bottom.text + "\r\n");
			filestream.writeUTFBytes("top_left_diag:" + top_left_diag.text + "\r\n");
			filestream.writeUTFBytes("bottom_left_diag:" + bottom_left_diag.text + "\r\n");
			filestream.writeUTFBytes("top_right_diag:" + top_right_diag.text + "\r\n");
			filestream.writeUTFBytes("bottom_right_diag:" + bottom_right_diag.text + "\r\n");
			
			// close the file
			filestream.close();
		}
		
		
		/**
		 * Function for reading the settings file and storing the values in an array
		 */
		public static function readSettingsFile():Array {
			
			// set the file and open the filestream
			var settings_file:File = File.desktopDirectory.resolvePath(SETTINGS_PATH);
			var filestream:FileStream = new FileStream();
			filestream.open(settings_file, FileMode.READ);
			
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
			center.text = values[3];
			center_left.text = values[4];
			center_right.text = values[5];
			center_top.text = values[6];
			center_bottom.text = values[7];
			top_left_diag.text = values[8];
			bottom_left_diag.text = values[9];
			top_right_diag.text = values[10];
			bottom_right_diag.text = values[11];
		}
	}
}