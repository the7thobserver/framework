package {
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	import screens.SettingsScreen;

	public class CameraImage {
		
		private var left_shoulder_pixels:Point;
		private var right_shoulder_pixels:Point;
		private var left_hip_pixels:Point;
		private var right_hip_pixels:Point;
		
		private var left_shoulder_real:Point;
		private var right_shoulder_real:Point;
		private var left_hip_real:Point;
		private var right_hip_real:Point;
		
		private var left_shoulder:Ray;
		private var right_shoulder:Ray;
		private var left_hip:Ray;
		private var right_hip:Ray;
		
		public var pos_x_res:Number;
		public var neg_x_res:Number;
		public var pos_y_res:Number;
		public var neg_y_res:Number;
		
		private var position:Vector3D;
	
		
		public function CameraImage(cam_number) {
			
			// load the starting position of the camera
			position = new Vector3D();
			loadPositions(cam_number);
			
			// create the ray objects with the camera's staring position
			left_shoulder = new Ray(position);
			right_shoulder = new Ray(position);
			left_hip = new Ray(position);
			right_hip = new Ray(position);
		}
		
		public function loadResolutions():void {
			
		}
		
		private function loadPositions(cam_number:Number):void {
			
			// get all lines from settings file
			var lines:Array = SettingsScreen.readSettingsFile();
			
			// get just the position numbers
			var pos:Array = lines[cam_number - 1].split(",");
			
			// set the position
			position.x = pos[0];
			position.y = pos[1];
			position.z = pos[2];
			
		}
		
		private function loadResolutions(cam_number):void {
			
		}
	}
}