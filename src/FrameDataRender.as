package
{	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	public class FrameDataRender
	{
		/**
		 * @param compareToLast Compare this FrameData to it, if the same, just return it.
		 */
		private static function getFrameDataByDisplay(source:DisplayObject, 
													  scale:Number=1,
													  expandW:int=50, expandH:int=50,
													  compareToLast:FrameData=null):FrameData
		{
			if(! source){
				return null;
			}
			
			var fdemp:FrameData = new FrameData(0, 0, null, 1);
			
			var srcRect:Rectangle = source.getBounds(source);
			srcRect.x -= expandW;
			srcRect.y -= expandH;
			srcRect.width += 2 * expandW;
			srcRect.height += 2 * expandH;
			
			if(srcRect.isEmpty()){
				return fdemp;
			}
			
			//			var x:int = srcRect.x * scale;
			//			var y:int = srcRect.y * scale;
			//			
			//			var bmpdata:BitmapData = new BitmapData(srcRect.width * scale, srcRect.height * scale, true, 0);
			//			
			//			bmpdata.draw(source, new Matrix(scale, 0, 0, scale, -x, -y), null, null, null, true);
			
			
			
			var x:int = srcRect.x * scale;
			var y:int = srcRect.y * scale;
			
			var bmpdata:BitmapData;bmpdata = new BitmapData(srcRect.width, srcRect.height, true, 0);
			
			bmpdata.draw(source, new Matrix(1, 0, 0, 1, - srcRect.x, - srcRect.y), 
				null, null, null, false);
			
			if(scale != 1){
				var bmpdataS:BitmapData = new BitmapData(srcRect.width * scale, srcRect.height * scale, true, 0);
				bmpdataS.draw(bmpdata, new Matrix(scale, 0, 0, scale, 0, 0), null, null, null, true);
				bmpdata.dispose();
				
				bmpdata = bmpdataS;
			}
			
			
			
			var colorRect:Rectangle = bmpdata.getColorBoundsRect(0xFF000000, 0x00000000, false);
			
			if(colorRect.isEmpty()){
				return fdemp;
			}
			
			if (colorRect.width!=srcRect.width || colorRect.height != srcRect.height){		
				var bmpdata2:BitmapData = new BitmapData(colorRect.width, colorRect.height, true, 0);
				bmpdata2.copyPixels(bmpdata, colorRect, new Point());
				
				bmpdata.dispose();
				bmpdata = bmpdata2;
				
				x += colorRect.x;
				y += colorRect.y;
			}
			
			var tx:int = x / scale;
			var ty:int = y / scale;
			var s:Number = 1 / scale;
			
			var fd:FrameData = new FrameData(tx, ty, bmpdata, s);
			if(compareToLast){
				if(fd.isBitmapDataEqual(compareToLast)){
					bmpdata.dispose();
					
					if(fd.isValueEqual(compareToLast)){
						fd.release();
						return compareToLast;
					}else{
						fd.bmpdata = compareToLast.bmpdata;
						return fd;
					}
				}
			}
			
			return fd;
		}
		
		/**
		 * 将影片绘制为位图帧数组
		 * */
		public static function getFrameDatasByMC(mc:MovieClip, 
												 scale:Number=1, 
												 expandForFilters:Boolean=true, 
												 skipEvery2Frames:Boolean=false):Vector.<FrameData>
		{
			if(!mc){
				return null;
			}
			
			var datas:Vector.<FrameData> = new Vector.<FrameData>();
			
			var t:int = mc.totalFrames;
			
			var lastFd:FrameData = null;
			
			mc.gotoAndStop(1);
			
			var expdW:int = 0;
			var expdH:int = 0;
			if(expandForFilters){
				expdW = 100;
				expdH = 100;
			}
			
			for(var i:int=1; i<=t; i++){
				var hasSkipped:Boolean = false;
				if(skipEvery2Frames){
					if(i % 2 == 0){
						datas.push(lastFd);
						hasSkipped = true;
					}
				}
				
				if(! hasSkipped){
					var fd:FrameData = getFrameDataByDisplay(mc, scale, expdW, expdH, lastFd);
					if(! fd){
						fd = new FrameData(0, 0, null, 1);
					}
					datas.push(fd);
					lastFd = fd;
				}
				
				var oldChildren:Vector.<MovieClip> = movieClipChildrenOf(mc);
				
				mc.nextFrame();
				
				var nowChildren:Vector.<MovieClip> = movieClipChildrenOf(mc);
				
				var newGuys:Vector.<MovieClip> = new Vector.<MovieClip>();
				
				for each(var aNowChild:MovieClip in nowChildren){
					if(oldChildren.indexOf(aNowChild) == -1){
						newGuys.push(aNowChild);
					}
				}
				
				nextFrameForAllChildren(mc, newGuys);
			}
			
			return datas;
		}
		
		
		public static function movieClipChildrenOf(mc:MovieClip):Vector.<MovieClip>{
			var children:Vector.<MovieClip> = new Vector.<MovieClip>();
			for(var j:int=0; j<mc.numChildren; j++){
				var sub:MovieClip = mc.getChildAt(j) as MovieClip;
				if(sub){
					children.push(sub);
				}
			}
			return children;
		}
		
		
		public static function playForAllChildren(mc:MovieClip):void{
			for(var j:int=0; j<mc.numChildren; j++){
				var sub:MovieClip = mc.getChildAt(j) as MovieClip;
				if(sub){
					sub.play();
					playForAllChildren(sub);
				}
			}
		}
		
		public static function stopForAllChildren(mc:MovieClip):void{
			for(var j:int=0; j<mc.numChildren; j++){
				var sub:MovieClip = mc.getChildAt(j) as MovieClip;
				if(sub){
					sub.stop();
					stopForAllChildren(sub);
				}
			}
		}
		
		
		public static function gotoAndStopForAllChildren(mc:MovieClip, f:int):void{
			for(var j:int=0; j<mc.numChildren; j++){
				var sub:MovieClip = mc.getChildAt(j) as MovieClip;
				if(sub){
					sub.gotoAndStop(f);
					
					gotoAndStopForAllChildren(sub, f);
				}
			}
		}
		
		public static function gotoAndPlayForAllChildren(mc:MovieClip, f:int):void{
			for(var j:int=0; j<mc.numChildren; j++){
				var sub:MovieClip = mc.getChildAt(j) as MovieClip;
				if(sub){
					sub.gotoAndPlay(f);
					
					gotoAndPlayForAllChildren(sub, f);
				}
			}
		}
		
		public static function nextFrameForAllChildren(mc:MovieClip, exlude:Vector.<MovieClip>):void{
			for(var j:int=0; j<mc.numChildren; j++){
				var sub:MovieClip = mc.getChildAt(j) as MovieClip;
				if(sub){
					if(exlude.indexOf(sub) >= 0){
						continue;
					}
					
					var f:int = sub.currentFrame + 1;
					if(f > sub.totalFrames){
						f = 1;
					}
					sub.gotoAndStop(f);
					
					nextFrameForAllChildren(sub, exlude);
				}
			}
		}
		
	}
}

