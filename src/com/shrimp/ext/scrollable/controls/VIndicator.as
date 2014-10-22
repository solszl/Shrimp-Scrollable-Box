package com.shrimp.ext.scrollable.controls
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 *	滑块 
	 * @author Sol
	 * 
	 */	
	public class VIndicator extends BaseIndicator
	{
		
		public static const WIDTH:Number = 10;
		
		private static const TOP_SKIN_HEIGHT:Number = 3;
		private static const BOTTOM_SKIN_HEIGHT:Number = 3;
		
		[Embed(source="../assets/vtop.png")]
		private var topSkinClass:Class;
		
		[Embed(source="../assets/vmiddle.png")]
		private var middleSkinClass:Class;
		
		[Embed(source="../assets/vbottom.png")]
		private var bottomSkinClass:Class;
		
		private var topSkin:DisplayObject;
		private var middleSkin:DisplayObject;
		private var bottomSkin:DisplayObject;
		
		private var _height:Number;
		
		public function VIndicator()
		{
			initialize();
		}
		
		override public function initialize():void
		{
			//上
			topSkin = new topSkinClass();
			addChild(topSkin);
			//中
			middleSkin = new middleSkinClass();
			middleSkin.y = TOP_SKIN_HEIGHT;
			addChild(middleSkin);
			//下
			bottomSkin = new bottomSkinClass();
			addChild(bottomSkin);
		}
		
		/**
		 *	重写设置高度 
		 * @param value
		 * 
		 */		
		override public function set height(value:Number):void
		{
			//如果设定跟旧值不同,则计算中,下的位置.
			if (!isNaN(value) && value != _height)
			{
				middleSkin.height = Math.round(value - TOP_SKIN_HEIGHT - BOTTOM_SKIN_HEIGHT);
				bottomSkin.y = Math.round(middleSkin.height + TOP_SKIN_HEIGHT);
			}
			
			_height = value;
		}
	}
}