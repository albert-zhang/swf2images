package
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class ConfigData
	{	
		private static var _instance:ConfigData = null;
		public static function sharedInstance():ConfigData{
			if(! _instance){
				_instance = new ConfigData();
			}
			return _instance;
		}
		
		public static function getAppConfigStorageFile():File{
			var f:File = File.documentsDirectory.resolvePath("Swf2Images.xml");
			return f;
		}
		
		
		public var sourceLocaltion:String = null;
		public var destLocation:String = null;
		
		public function ConfigData()
		{
		}
		
		public function read():void{
			var f:File = getAppConfigStorageFile();
			if(f.exists){
				var fs:FileStream = new FileStream();
				fs.open(f, FileMode.READ);
				var cnt:String = fs.readUTFBytes(fs.bytesAvailable);
				fs.close();
				
				this.deserialize(cnt);
				
			}
		}
		
		public function save():void{
			var f:File = getAppConfigStorageFile();
			var fs:FileStream = new FileStream();
			fs.open(f, FileMode.WRITE);
			fs.writeUTFBytes(this.serialize());
			fs.close();
		}
		
		private function serialize():String{
			var xml:XML = <config></config>;
			if(sourceLocaltion){
				xml.sourceLocaltion = sourceLocaltion;
			}
			if(destLocation){
				xml.destLocation = destLocation;
			}
			return xml.toXMLString();
		}
		
		private function deserialize(str:String):void{
			var xml:XML = new XML(str);
			var xmlList:XMLList = xml.*;
			for(var i:uint = 0; i<xmlList.length(); i++){
				var key:String = xmlList[i].localName();
				var value:String = xmlList[i].children()[0].toXMLString();
				if(key == "sourceLocaltion"){
					this.sourceLocaltion = value;
				}else if(key == "destLocation"){
					this.destLocation = value;
				}
			}
		}
		
	}
}