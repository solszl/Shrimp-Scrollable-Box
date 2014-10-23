package demo.item
{
	import com.shrimp.framework.ui.controls.Label;
	import com.shrimp.framework.ui.controls.core.Component;
	
	import demo.vo.PersonVO;
	
	import flash.display.DisplayObjectContainer;
	
	public class PersonItem extends Component
	{
		public function PersonItem(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
		}
		
		private var lblFirstName:Label;
		
		private var lblSecondName:Label;
		
		private var lblAge:Label;
		override protected function createChildren():void
		{
			super.createChildren();
			
			lblFirstName = new Label(this);
			
			lblSecondName = new Label(this,100);
			
			lblAge = new Label(this,200);
		}
		
		public function set data(value:PersonVO):void
		{
			lblFirstName.text = value.fn;
			lblSecondName.text=value.sn;
			lblAge.text = value.age+'';//(Math.floor(Math.random()*20)+20).toString();
		}
								 
	}
}