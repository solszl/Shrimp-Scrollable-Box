package com.shrimp.ext.scrollable.controls
{
	import com.shrimp.framework.ui.controls.core.Component;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	
	/**
	 *	可拖拽的容器 
	 * @author Sol
	 * 
	 */	
	public class TouchBox extends Component
	{
		/**	子容器*/
		protected var itemContainer:Sprite;
		
		/**	滚动条基类*/
		protected var indicator:BaseIndicator;
		
		public function TouchBox(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0)
		{
			super(parent, xpos, ypos);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			//添加一级子容器
			itemContainer = new Sprite();
			addChild(itemContainer);
		}
		
		/**	重载get numChildren函数*/
		override public function get numChildren():int
		{
			return itemContainer.numChildren;
		}
		
		/**	重载包含方法,此处检测itemContainer是否包含child*/
		override public function contains(child:DisplayObject):Boolean
		{
			return itemContainer.contains(child);
		}
		
		/**	重载setChildIndex,将child的深度设定在itemContainer内部*/
		override public function setChildIndex(child:DisplayObject, index:int):void
		{
			return itemContainer.setChildIndex(child, index);
		}
		
		/**	重载addChildAt方法,如果child不是滑块,并且不是一级子容器,则将其添加到一级子容器内,否则添加到父容器*/
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject
		{
			if (child != indicator as DisplayObject && child != itemContainer)
				itemContainer.addChildAt(child, index);
			else
				super.addChildAt(child, index);
			
			return child;
		}
		
		/**	@see addChildAt*/
		override public function addChild(child:DisplayObject):DisplayObject
		{
			if (child != indicator as DisplayObject && child != itemContainer)
				itemContainer.addChild(child);
			else
				super.addChild(child);
			
			return child;
		}
		
		/**	重载removeChildAt方法,如果child不是滑块,并且不是一级子容器,从itemContainer中将其移除,否则从父容器中移除*/
		override public function removeChildAt(index:int):DisplayObject
		{
			if (index < numChildren - 1)
			{
				if (getChildAt(index) == indicator as DisplayObject || getChildAt(index) == itemContainer)
					return null;
			}
			
			return itemContainer.removeChildAt(index);
		}
		
		/**	@see removeChildAt*/
		override public function removeChild(child:DisplayObject):DisplayObject
		{
			if (child != indicator as DisplayObject && child != itemContainer)
				itemContainer.removeChild(child);
			else
				super.removeChild(child);
			
			return child;
		}
	}
}