package demo.item
{
	import com.shrimp.framework.ui.controls.Label;
	import com.shrimp.framework.ui.controls.core.Component;
	
	import flash.display.DisplayObjectContainer;
	
	public class AnchorItem extends Component
	{
		public function AnchorItem(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
		}
		
		private var lblAchor:Label;
		override protected function createChildren():void
		{
			super.createChildren();
			
			lblAchor = new Label(this);
		}
		
		public function set data(value:String):void
		{
			lblAchor.text = value;
		}
	}
}