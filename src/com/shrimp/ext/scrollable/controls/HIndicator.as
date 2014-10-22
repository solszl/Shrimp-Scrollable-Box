package com.shrimp.ext.scrollable.controls
{
	import flash.display.DisplayObject;

	/**
	 *	横向滑块 
	 * @author Sol
	 * 
	 */	
	public class HIndicator extends BaseIndicator
	{
		public static const HEIGHT:Number = 10;
		
		private static const LEFT_SKIN_WIDTH:Number = 3;
		private static const RIGHT_SKIN_WIDTH:Number = 3;
		
		[Embed(source="../assets/vtop.png")]
		private var leftSkinClass:Class;
		
		[Embed(source="../assets/vmiddle.png")]
		private var middleSkinClass:Class;
		
		[Embed(source="../assets/vbottom.png")]
		private var rightSkinClass:Class;
		
		private var leftSkin:DisplayObject;
		private var middleSkin:DisplayObject;
		private var rightSkin:DisplayObject;
		
		
		private var _widht:Number;
		
		public function HIndicator()
		{
			super();
		}
		
		override public function initialize():void
		{
			super.initialize();
			//上
			leftSkin = new leftSkinClass();
			addChild(leftSkin);
			//中
			middleSkin = new middleSkinClass();
			middleSkin.x = LEFT_SKIN_WIDTH;
			addChild(middleSkin);
			//下
			rightSkin = new rightSkinClass();
			addChild(rightSkin);
		}
		
		override public function set width(value:Number):void
		{
			//如果设定跟旧值不同,则计算中,下的位置.
			if (!isNaN(value) && value != _widht)
			{
				middleSkin.width = Math.round(value - LEFT_SKIN_WIDTH - RIGHT_SKIN_WIDTH);
				rightSkin.x = Math.round(middleSkin.width + LEFT_SKIN_WIDTH);
			}
			
			_widht = value;
		}
	}
}