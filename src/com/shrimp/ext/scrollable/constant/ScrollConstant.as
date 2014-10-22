package com.shrimp.ext.scrollable.constant
{
	public class ScrollConstant
	{
		/*			组件公共定义区			*/
		/**	滚动动画持续时间,以秒为单位*/
		public static const ANIMATION_DURATION:Number = 1.25;
		
		/**	当滚动结束后,滚动条消失时间,以秒为单位*/
		public static const SCROLL_FADE_TWEEN_DURATION:Number = .3;
		
		/**	当鼠标抬起后,内容最大移动范围,以像素为单位*/
		public static const MAX_MOVE_AFTER_MOUSEUP:Number = 150;
		
		/**	当鼠标抬起后,内容最小移动范围,如果滚动量小于该值,则不进行滚动,防止用户不小心滑动造成的问题,以像素为单位*/
		public static const MIN_MOVE_AFTER_MOUSEUP:Number = 50;
		
		/**	当拖动的时候,每隔几帧计算或移动一次内容,以整数为单位,默认2帧算一次*/
		public static const INTERVAL_FRAMES_TO_MOVE:Number = 2;
		
		/*			针对于横纵向特殊定义区	*/
		/**	纵向滚动条,距右侧距离,以像素为单位*/
		public static const VSCROLL_RIGHT_PADDING:Number = 10;
		/**	纵向滚动条,最小高度,以像素为单位*/
		public static const VSCROLL_MIN_HEIGHT:Number = 10;
		/**	纵向滚动条,开始拖动时,超过该阈值以后,就开始进行拖放*/
		public static const VSCROLL_START_TO_DRAG_THRESHOLD:Number = 10;
		/**	当鼠标按下后,如果横向移动大于该值,则不进行纵向滚动*/
		public static const VSCROLL_STOP_THRESHOLD:Number = 40;
		
		/**	横向滚动条,距下侧距离,以像素为单位*/
		public static const HSCROLL_BOTTOM_PADDING:Number = 10;
		/**	横向滚动条,最小宽度,以像素为单位*/
		public static const HSCROLL_MIN_WIDTH:Number = 10;
		/**	横向滚动条,开始拖动时,超过该阈值以后,就开始进行拖放*/
		public static const HSCROLL_START_TO_DRAG_THRESHOLD:Number = 10;
		/**	当鼠标按下后,如果纵向移动大于该值,则不进行纵向滚动*/
		public static const HSCROLL_STOP_THRESHOLD:Number = 40;
	}
}