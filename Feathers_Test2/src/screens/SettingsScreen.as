package screens
{
	
	import flash.text.TextFormat;
	
	import feathers.controls.Screen;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import feathers.events.FeathersEventType;
	
	public class SettingsScreen extends Screen {
		
		private var center_input:TextInput;
		private var header1:TextArea;
		private var header2:TextArea;
		private var header3:TextArea;
		
		private const HEADER_1_TEXT:String = "Camera 1 Settings";
		private const HEADER_2_TEXT:String = "Camera 2 Settings";
		private const HEADER_3_TEXT:String = "Camera 3 Settings";
		private const INPUT_DEFAULT_TEXT:String = "Enter distance";
		
		private const HEADER_WIDTH:Number = 250;
		private const HEADER_HEIGHT:Number = 50;
		
		
		public function SettingsScreen() {
			
			header1 = new TextArea();
			header2 = new TextArea();
			header3 = new TextArea();
			
			center_input = new TextInput();
			
			center_input.addEventListener(FeathersEventType.ENTER , onEnter);
		}
		
		override protected function initialize():void {
			
			center_input.text = INPUT_DEFAULT_TEXT;
			center_input.width = HEADER_WIDTH;
			center_input.height = HEADER_HEIGHT;
			
			header1.text = HEADER_1_TEXT;
			header1.width = HEADER_WIDTH;
			header1.height = HEADER_HEIGHT;
			header1.y = 200;
			
			header2.text = HEADER_2_TEXT;
			header2.width = HEADER_WIDTH;
			header2.height = HEADER_HEIGHT;
			header2.y = 300;
			
			header3.text = HEADER_3_TEXT;
			header3.width = HEADER_WIDTH;
			header3.height = HEADER_HEIGHT;
			header3.y = 400;
			
			addChild(center_input);
			addChild(header1);
			addChild(header2);
			addChild(header3);
			
			center_input.textEditorProperties.fontSize = 40;
			
			header1.textEditorProperties.textFormat = new TextFormat("Verdania", 30, 0xffffff);
			header2.textEditorProperties.textFormat = new TextFormat("Verdania", 30, 0xffffff);
			header3.textEditorProperties.textFormat = new TextFormat("Verdania", 30, 0xffffff);
		}
		
		private function onEnter():void {
			
		}
		
		
	}
}