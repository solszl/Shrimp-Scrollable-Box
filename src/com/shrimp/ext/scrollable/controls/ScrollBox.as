package com.shrimp.ext.scrollable.controls
{
	import com.shrimp.ext.scrollable.constant.ScrollConstant;
	import com.shrimp.framework.managers.StageManager;
	import com.shrimp.framework.ui.controls.core.Component;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 *	可拖拽容器
	 * @author Sol
	 *
	 */
	internal class ScrollBox extends TouchBox
	{
		/**	滑块消失的时候,每帧内,透明值变化量*/
		protected var indicatorFadeoutDelta:Number;

		/**	是否正在欢动中*/
		protected var isTweening:Boolean;

		/**	变化值*/
		public var maxScroll:Number;

		/**	是否正在拖放*/
		public var isDragging:Boolean;

		/**	用来统计帧频的,与INTERVAL_FRAMES_TO_MOVE 进行协作*/
		protected var enterFrameIndex:Number = 0;

		/**	是否重置*/
		protected var reset:Boolean;

		protected var targetScrollValue:Number;
		
		/**	滑块高度与自身高度的却别*/
		protected var totalScrollAmount:Number;
		
		/**
		 *	拖拽的时候. 记录坐标系位置
		 */
		protected var mouseDragCoords:Array;
		
		protected var scrollIndicatorHeight:Number;

		public function ScrollBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
		}

		override protected function preInit():void
		{
			super.preInit();
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		override protected function createChildren():void
		{
			super.createChildren();
			
			mouseDragCoords = [];
		}

		/**	鼠标按下操作*/
		protected function mouseDownHandler(e:MouseEvent):void
		{
			//添加鼠标监听,查看移动方向
			StageManager.stage.addEventListener(MouseEvent.MOUSE_MOVE,detectDirection_mouseMoveHandler);
			//添加鼠标抬起的监听
			StageManager.stage.addEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler);
		}

		/**	从舞台移除操作*/
		protected function removedFromStageHandler(e:Event):void
		{
			StageManager.stage.removeEventListener(Event.ENTER_FRAME,tween_enterFrame);
			indicator.visible = false;
		}

		/**	添加到舞台的操作*/
		protected function addedToStageHandler(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			//获取每帧变化量
			indicatorFadeoutDelta = 1 / (ScrollConstant.ANIMATION_DURATION * StageManager.stage.frameRate);
		}

		/**	重载显示列表更新方法,停止更新滚动,更新滚动条,设置显示区*/
		override protected function updateDisplayList():void
		{
			super.updateDisplayList();

			//停止缓动
			stopTween();

			//更新滚动条
			updateMaxScroll();
		}

		protected function stopTween():void
		{

		}

		protected function updateMaxScroll():void
		{

		}

		/**	更新滑块*/
		protected function updateIndicator():void
		{

		}

		/**	*/
		protected function tween_enterFrame(e:Event):void
		{

		}
		
		/**	拖拽处理函数*/
		protected function drag_enterFrameHandler(e:Event):void
		{
			
		}
		
		/**	更新滑块*/
		protected function updateScrollIndicator():void
		{
			
		}
		
		protected function drag_mouseUpHandler(e:MouseEvent):void
		{
			if(!StageManager.stage)
			{
				return;
			}
			
			StageManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE,detectDirection_mouseMoveHandler);
			StageManager.stage.removeEventListener(Event.ENTER_FRAME,drag_enterFrameHandler);
			StageManager.stage.removeEventListener(MouseEvent.MOUSE_UP,drag_mouseUpHandler);
			
			isTweening = false;
		}
		
		protected function detectDirection_mouseMoveHandler(e:MouseEvent):void
		{
			throw new Error("implements in subclass");
		}

		/**
		 * 滑块渐隐的函数
		 */
		protected function scrollIndicatorFade_enterFrameHandler(e:Event):void
		{
			indicator.alpha -= indicatorFadeoutDelta;

			if (indicator.alpha <= 0)
				removeEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
		}

		/**	外部设置滑块的显隐*/
		protected function set indicatorVisible(value:Boolean):void
		{
			if (indicator)
			{
				removeEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
				indicator.alpha = value ? 1 : 0;
			}
		}
	}
}
