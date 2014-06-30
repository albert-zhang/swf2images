package
{
	import flash.display.BitmapData;
	
	public class FrameData
	{	
		public var x:Number;
		public var y:Number;
		public var bmpdata:BitmapData;
		public var reciprocalScale:Number;
		
		public function FrameData(x_:Number, y_:Number, bitmapData_:BitmapData, rscale_:Number):void
		{   
			x = x_;
			y = y_;
			bmpdata = bitmapData_;
			reciprocalScale = rscale_;
		}
		
		public function isValueEqual(other:FrameData):Boolean{
			if(Math.abs(this.x - other.x) >= 1){
				return false;
			}
			if(Math.abs(this.y - other.y) >= 1){
				return false;
			}
			if(Math.abs(this.reciprocalScale - other.reciprocalScale) >= 0.1){
				return false;
			}
			return true;
		}
		
		public function isBitmapDataEqual(other:FrameData):Boolean{
			if(other.bmpdata == this.bmpdata){
				return true;
			}
			if((! other.bmpdata && this.bmpdata) || (other.bmpdata && ! this.bmpdata)){
				return false;
			}
			if(this.bmpdata.compare(other.bmpdata) === 0){
				return true;
			}else{
				return false;
			}
		}
		
		public function release():void{
			// AZ: the Bitmapdata is shared and will dealloc by GC, so don't dispose:
			// this.mBmpdata.dispose();
			this.bmpdata = null;
		}
		
		
	}
}
