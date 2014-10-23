package demo
{
	import com.shrimp.ext.scroll.ui.scroll.mobile.ABScrollList;
	import com.shrimp.framework.ui.controls.core.Component;
	
	import demo.item.AnchorItem;
	import demo.item.PersonItem;
	import demo.pools.AnchorPool;
	import demo.pools.PersonItemPool;
	import demo.vo.PersonVO;
	
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public class ABSelectorDemo extends Component
	{
		public function ABSelectorDemo()
		{
			super();
			
			trace("ABSelector Demo init");
		}
		
		private var abselector:ABScrollList;
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			//姓
			var fArr:Array=["Smith","Johnson","Williams","Brown","Jones","Miller","Davis","Garcia","Rodriguez","Wilson"];
			//名
			var sArr:Array=["Agnes","Bernice","Caroline","Daisy","Eden","Flora","Gill","Hilary","Irene","Jamie","Keal"];
			var arr:Vector.<Object> = new Vector.<Object>();
			var data:PersonVO;
			for (var i:int = 0; i < 100; i++) 
			{
				data = new PersonVO();
				data.fn = fArr[i%10];
				data.sn = sArr[i%11];
				data.age = i;
				data.index = i;
				arr.push(data);
			}
			var viewport:Rectangle = new Rectangle(0,0,300,500);
			
			var elementPool:PersonItemPool = new PersonItemPool()
			var anchorPool:AnchorPool = new AnchorPool();
			abselector = new ABScrollList(arr,viewport,alphaIndex,elementPool,initElementFct,anchorPool,initAnchorFct);
			abselector.x = 100;
			abselector.y = 100;
			addChild(abselector);
		}
		
		private function alphaIndex(data:PersonVO):String
		{
			return data.fn+"-"+data.sn;
		}
		
		private function initElementFct(item:DisplayObject,data:PersonVO):void
		{
			var p:PersonItem = item as PersonItem;
			p.data = data;
		}
		
		private function initAnchorFct(item:DisplayObject,data:String):void
		{
			var anchor:AnchorItem = item as AnchorItem;
			
			anchor.data = data;
		}
		
		
	}
}