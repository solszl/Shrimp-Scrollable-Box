package com.shrimp.ext.scrollable.events
{
	import flash.events.Event;
	
	/**
	 *	滚动事件 
	 * @author Sol
	 * 
	 */	
	public class ScrollEvent extends Event
	{
		public static const START_SCROLL:String = "startScroll";
		
		public static const DIRECTION_DOWN:String = "directionDown";
		public static const DIRECTION_UP:String = "directionUp";
		public static const DIRECTION_LEFT:String = "directionLeft";
		public static const DIRECTION_RIGHT:String = "directionRight";
		
		public var direction:String;
		
		public function ScrollEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false,direction:String=DIRECTION_UP)
		{
			super(type, bubbles, cancelable);
			
			this.direction = direction;
		}
		
		override public function clone():Event
		{
			return new ScrollEvent(type,bubbles,cancelable,this.direction);
		}
	}
}