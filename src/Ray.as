package {
	import flash.geom.Vector3D;

	public class Ray {
		private var origin:Vector3D;
		private var direction:Vector3D;
		private var final_point:Vector3D;
		
		public function Ray(orig:Vector3D) {
			origin = orig;
			final_point = new Vector3D();
		}
		
		public function getOrigin():Vector3D {
			return origin;
		}
		
		public function getDirection():Vector3D {
			return direction;
		}
		
		public function setDirection(dir:Vector3D):void {
			direction = dir;
		}
		
		public function solve(t:Number):Vector3D {
	
			// calculate the point at "time" t
			final_point.x = origin.x + direction.x * t;
			final_point.y = origin.y + direction.y * t;
			final_point.z = origin.z + direction.z * t;
			
			return final_point;
		}
	}
}