package com.shrimp.ext.scrollable.controls
{
	import com.shrimp.ext.scrollable.constant.ScrollConstant;
	import com.shrimp.ext.scrollable.ease.Quartic;
	import com.shrimp.framework.managers.StageManager;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	/**
	 *	纵向滑动容器
	 * @author Sol
	 *
	 */
	public class VScrollBox extends ScrollBox
	{
		/**	存一下 当前鼠标的X坐标*/
		private var mouseXDownCoord:Number;
		/**	记录一下 开始拖拽时候的鼠标Y值*/
		private var mouseYDown:Number;
		/**	记录开始拖拽的时候,scrollY的值*/
		private var beginDragScrollY:Number;
		/**	用来计算每毫秒像素便宜的*/
		private var previousDragMouseY:Number;
		/**	拖拽总和*/
		private var deltaMouseY:Number;
		/**	记录上一次拖拽时间*/
		private var previousDragTime:Number;

		private static const TOP_PADDING:Number = 10;
		private static const BOTTOM_PADDING:Number = 10;
		
		//The start scroll value when a user flicks.
		private var startScrollY:Number;
		//The total amount to scroll when a user flicks.
		private var totalScrollY:Number;
		
		//Properties for tweening a user flick.
		private var tweenCurrentCount:Number;
		private var tweenTotalCount:Number;
		
		/**	当前scrollY*/
		private var targetScrollY:Number;

		public function VScrollBox(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0)
		{
			super(parent, xpos, ypos);
		}

		override protected function updateDisplayList():void
		{
			super.updateDisplayList();
			//如果重置
			if (reset || !itemContainer.scrollRect)
			{
				itemContainer.scrollRect = new Rectangle(0, 0, width, height);
			}
			else
			{
				scrollY = Math.min(maxScroll, scrollY);
				itemContainer.scrollRect = new Rectangle(0, scrollY, width, height);
			}
		}

		override protected function stopTween():void
		{
			super.stopTween();
			if (isTweening)
			{
				scrollY = targetScrollValue;

				StageManager.stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrame);

				indicatorVisible = false;

//				dispatchEvent(new TweenEvent(TweenEvent.TWEEN_COMPLETE));
			}
		}

		override protected function updateMaxScroll():void
		{
			super.updateMaxScroll();
			if (itemContainer.numChildren <= 0)
			{
				return;
			}

			var lastChild:DisplayObject = itemContainer.getChildAt(itemContainer.numChildren - 1);
			var totalHeight:Number = lastChild.y + lastChild.height;
			maxScroll = Math.round(totalHeight - height);

			if (maxScroll > 0)
			{
				if (!indicator)
				{
					indicator = new VIndicator();
					indicator.mouseChildren = indicator.mouseEnabled = false;
					indicator.alpha = 0;
				}

				indicator.x = _width - VIndicator.WIDTH - ScrollConstant.VSCROLL_RIGHT_PADDING;
				indicator.y = TOP_PADDING;

				if (!contains(indicator))
					addChild(indicator);

				// Calculate the values used for sizing indicator.
				var availableHeight:Number = _height - TOP_PADDING - BOTTOM_PADDING
				scrollIndicatorHeight = Math.max(Math.round((availableHeight / totalHeight) * availableHeight), ScrollConstant.VSCROLL_MIN_HEIGHT);
				indicator.height = scrollIndicatorHeight;
				totalScrollAmount = availableHeight - scrollIndicatorHeight;
			}
			else
			{
				maxScroll = 0;
				if (indicator && contains(indicator))
					removeChild(indicator);
			}
		}

		override protected function mouseDownHandler(e:MouseEvent):void
		{
			mouseXDownCoord = root.mouseX;
			mouseYDown = previousDragMouseY = root.mouseY;

			if (maxScroll > 0)
			{
				isDragging = false;
				StageManager.stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrame);
				deltaMouseY = 0;
				previousDragTime = getTimer();
				
				beginDragScrollY = scrollY;
				
				enterFrameIndex = 0;
			}
			//添加事件监听
			super.mouseDownHandler(e);
		}

		/**	察觉方向事件监听*/
		override protected function detectDirection_mouseMoveHandler(e:MouseEvent):void
		{
			if (maxScroll > 0 && Math.abs(mouseYDown - root.mouseY) > ScrollConstant.VSCROLL_START_TO_DRAG_THRESHOLD)
			{
				indicatorVisible = true;

				isDragging = true;

				StageManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE, detectDirection_mouseMoveHandler);
				StageManager.stage.addEventListener(Event.ENTER_FRAME, drag_enterFrameHandler);

//				dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLL, false, false, mouseYDown > root.mouseY ? ScrollEvent.DIRECTION_UP : ScrollEvent.DIRECTION_DOWN));
			}
		}

		override protected function drag_enterFrameHandler(e:Event):void
		{
			e.stopImmediatePropagation();

			if (!StageManager.stage)
			{
				return;
			}

			var newY:Number = beginDragScrollY + (mouseYDown - root.mouseY);

			scrollY = newY;

			enterFrameIndex += 1;

			if (enterFrameIndex % ScrollConstant.INTERVAL_FRAMES_TO_MOVE)
			{
				deltaMouseY = root.mouseY - previousDragMouseY;
				previousDragTime = getTimer();
				previousDragMouseY = root.mouseY;
			}

			mouseDragCoords.push(root.mouseY);

			updateScrollIndicator();
		}

		/**	鼠标抬起的监听事件*/
		override protected function drag_mouseUpHandler(e:MouseEvent):void
		{
			super.drag_mouseUpHandler(e);
			
			if (maxScroll > 0)
			{
				// Calculate the speed between the last mouse moves which
				// will determine the speed in which to scroll the items.
				var elapsedMiliseconds:Number = getTimer() - previousDragTime;
				var pixelsPerMillisecond:Number = deltaMouseY / elapsedMiliseconds;
				targetScrollY = Math.round(-pixelsPerMillisecond * ScrollConstant.MAX_MOVE_AFTER_MOUSEUP + scrollY);
				
				if (targetScrollY >= 0) // Scrolling up.
					targetScrollY = Math.min(maxScroll, targetScrollY);
				else			  // Scrolling down.
					targetScrollY = Math.max(targetScrollY, 0);
				
				targetScrollY = Math.round(targetScrollY);
				
				var isFlick:Boolean = true;
				if (targetScrollY != maxScroll && targetScrollY != 0)
				{
					var len:Number = mouseDragCoords.length;
					// Compare the last coord (len - 1) and the one two before it (len - 3).
					// This is to ensure a user flicked the list. If a user is dragging the
					// list slowly there could be an inadvertant flick, so to avoid it
					// compare the two y coords.
					if (len > 3)
					{
						if (mouseDragCoords[len - 1] == mouseDragCoords[len - 3])
							isFlick = false;
					}
					
					if (Math.abs(scrollY - targetScrollY) < ScrollConstant.MIN_MOVE_AFTER_MOUSEUP)
						isFlick = false;
				}
				
				// Remove all of the elements from the array.
				mouseDragCoords.splice(0, mouseDragCoords.length);
				
				if (targetScrollY != scrollY && isFlick)
				{
					doTween(targetScrollY);
				}
				else
				{
					// No flick so fade out scrollIndicator immediately.
					addEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
					
//					if (isDragging)
//						dispatchEvent(new TweenEvent(TweenEvent.TWEEN_COMPLETE));
				}
			}
		}

		public function get scrollY():Number
		{
			return itemContainer.scrollRect.y;
		}

		public function set scrollY(value:Number):void
		{
			var rect:Rectangle = itemContainer.scrollRect;
			rect.y = value;
			itemContainer.scrollRect = rect;
		}

		override protected function updateScrollIndicator():void
		{
			super.updateScrollIndicator();
			var delta:Number = scrollY / maxScroll;
			var newHeight:Number;

			if (delta < 0) // user dragged below the top edge.
			{
				indicator.y = Math.round(TOP_PADDING);

				// virtualScrollY will be < 0.
				// Shrink indicator.height by the amount a user has scrolled below the top edge.
				newHeight = scrollY + scrollIndicatorHeight;
				newHeight = Math.max(ScrollConstant.VSCROLL_MIN_HEIGHT, newHeight);
				indicator.height = Math.round(newHeight);
			}
			else if (delta < 1)
			{
				if (indicator.height != scrollIndicatorHeight)
					indicator.height = Math.round(scrollIndicatorHeight);

				var newY:Number = Math.round(delta * totalScrollAmount);
				newY = Math.min(_height - scrollIndicatorHeight - BOTTOM_PADDING, newY);
				indicator.y = Math.round(newY + TOP_PADDING);
			}
			else // User dragged above the bottom edge.
			{
				// Shrink indicator.height by the amount a user has scrolled above the bottom edge.
				newHeight = scrollIndicatorHeight - (scrollY - maxScroll);
				newHeight = Math.max(ScrollConstant.VSCROLL_MIN_HEIGHT, newHeight);
				indicator.height = Math.round(newHeight);
				indicator.y = Math.round(_height - newHeight - BOTTOM_PADDING);
			}
		}
		
		/**
		 * The amount to tween is the amount itemContainer.scrollRect.y will change.
		 */
		private function doTween(value:Number):void
		{
			targetScrollY = Math.round(value);
			
			startScrollY = scrollY;
			totalScrollY = targetScrollY - startScrollY;
			
			tweenCurrentCount = 0;
			tweenTotalCount = Math.round(ScrollConstant.ANIMATION_DURATION * StageManager.stage.frameRate);
			stage.addEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
			
			isTweening = true;
		}
		
		private function tween_enterFrameHandler(e:Event):void
		{
			scrollY = Math.round(Quartic.easeOut(tweenCurrentCount, startScrollY, totalScrollY, tweenTotalCount));
			tweenCurrentCount += 1;
			
			updateScrollIndicator();
			
			if (scrollY == targetScrollY)
			{
				stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
				
				isTweening = false;
				
				// Fade out scrollIndicator.
				addEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
				
//				dispatchEvent(new TweenEvent(TweenEvent.TWEEN_COMPLETE));
			}
		}
	}
}
