package com.scroll
{
	import com.shrimp.ext.scrollable.controls.TouchBox;
	import com.shrimp.ext.scrollable.controls.VIndicator;
	import com.shrimp.ext.scrollable.events.ScrollEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	/**
	 * Dispatched when a user has swiped horizontally before vertically.
	 */
	[Event(name="horizontalSwipe", type="com.adobe.lighthouse.events.HorizontalSwipeEvent")]
	
	/**
	 * Dispatched when the throw tweening has completed.
	 */
	[Event(name="tweenComplete", type="com.adobe.lighthouse.events.TweenEvent")]
	
	/**
	 * Dispatched when the list has started to scroll because of a user dragging.
	 */
	[Event(name="startScroll", type="com.adobe.lighthouse.events.ScrollEvent")]

	public class DragBox extends TouchBox
	{
		public var maxScroll:Number;
		
		/**
		 * In seconds.
		 */
		private static const ANIMATION_DURATION:Number = 1.25;
		
		private static const MIN_SCROLL_INDICATOR_HEIGHT:Number = 10;
		private static const SCROLL_FADE_TWEEN_DURATION:Number = .3;
		
		/**
		 * Right edge padding.
		 */
		private static const SCROLL_INDICATOR_RIGHT_PADDING:Number = 10;
		
		/**
		 *  The max number of pixels to move the list after a mouseUp event.
		 */
		private static const MAX_PIXEL_MOVE:Number = 150;
		
		/**
		 * The min number of pixels to move the list after a mouseUp event.
		 * If the amount to scroll is less than this value the list will
		 * not scroll. This is to prevent inadvertant flicks when a user
		 * slowly drags the list.
		 */
		private static const MIN_PIXEL_MOVE:Number = 50;
		
		/**
		 * The number of frames to wait to calculate speed when flicking.
		 */
		private static const NUM_FRAMES_TO_MEASURE_SPEED:Number = 2;
		
		/**
		 * The amount the mouse can move before dragging.
		 */
		public static const START_TO_DRAG_THRESHOLD:Number = 10;
		
		/**
		 * The amount the mouse must move horizontally to trigger a HorizontalSwipeEvent.
		 */
		private static const HORIZONTAL_DRAG_THRESHOLD:Number = 40;
		
		/**
		 *  The y offset in which to layout the first item.
		 */
		private var itemYOffsetTop:Number;
		
		/**
		 *  The y offset in which to layout the last item.
		 */
		private var itemYOffsetBottom:Number;
		
		/**
		 * The amount of top padding between scrollIndicator and the top edge.
		 */
		private var scrollIndicatorTopPadding:Number;
		
		/**
		 * The amount of top padding between scrollIndicator and the top edge.
		 */
		private var scrollIndicatorBottomPadding:Number;
		
		private var verticalGap:Number;
		
		/**
		 * The target scroll value when a user flicks.
		 */
		private var targetScrollY:Number;
		
		/**
		 * The start scroll value when a user flicks.
		 */
		private var startScrollY:Number;
		
		/**
		 * The total amount to scroll when a user flicks.
		 */
		private var totalScrollY:Number;
		
		/**
		 * The amount a user has dragged the mouse between frames.
		 */
		private var deltaMouseY:Number;
		
		/**
		 * Used to calculate the number of pixel per millisecond when a user flicks.
		 */
		private var previousDragTime:Number;
		
		/**
		 * The value of the last drag mouseY.
		 * Used to calculate the number of pixel per millisecond when a user flicks.
		 */
		private var previousDragMouseY:Number;
		
		/**
		 * The scrollY when a user first starts to drag.
		 */
		private var beginDragScrollY:Number;
		
		/**
		 * The mouseY when a user first starts to drag.
		 */
		private var mouseYDown:Number;
		
		/**
		 * Used to track the y coords when a user is dragging.
		 */
		private var mouseDragCoords:Array;
		
		/**
		 * Used to track a mouse coord every other frame for more
		 * accurate measurement of speed.
		 * 
		 */
		private var enterFrameIndex:Number = 0;
		
		/**
		 * The height of the scrollIndicator when a user has not dragged
		 * the content below the top edge or above the bottom edge,
		 * ie: scrollDelta > 0 && scrollDelta < 1
		 */
		private var scrollIndicatorHeight:Number;
		
		private var backgroundColor:Number;
		
		/**
		 * The difference between the scrollIndicator.height and _height.
		 */
		private var totalScrollAmount:Number;
		
		private var dispatchHorizontalSwipeEvents:Boolean;
		
		/**
		 * Used for detecting horizontal swipes.
		 */
		private var mouseXDownCoord:Number;
		
		/**
		 * Properties for tweening a user flick.
		 */
		private var tweenCurrentCount:Number;
		private var tweenTotalCount:Number;
		
		/**
		 * Used to store children which allow horizontal dragging
		 * such as a horizontal slideshow.
		 */
		private var horizontalDragChildren:Array;
		
		private var isDragging:Boolean;
		
		/**
		 * The amount to decrement scrollIndicator.alpha per frame
		 * when it fades out.
		 */
		private var scrollIndicatorAlphaDelta:Number;
		
		/**
		 * Flag for whether or not the flick tween is still playing.
		 */
		private var isTweening:Boolean;
		
		private var resetScrollY:Boolean;
		
		public function DragBox(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0,
								verticalGap:Number=0,
								backgroundColor:Number=0xffffff,
								dispatchHorizontalSwipeEvents:Boolean=false,
								itemYOffsetTop:Number=0,
								itemYOffsetBottom:Number=0,
								scrollIndicatorTopPadding:Number=0,
								scrollIndicatorBottomPadding:Number=0)
		{
			super(parent, xpos, ypos);
			
			this.backgroundColor = backgroundColor;
			this.verticalGap = verticalGap;
			this.dispatchHorizontalSwipeEvents = dispatchHorizontalSwipeEvents;
			this.itemYOffsetTop = itemYOffsetTop;
			this.itemYOffsetBottom = itemYOffsetBottom;
			this.scrollIndicatorTopPadding = scrollIndicatorTopPadding;
			this.scrollIndicatorBottomPadding = scrollIndicatorBottomPadding;
		}
		
		override protected function init():void
		{
			super.init();
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			horizontalDragChildren = new Array();
			
			mouseDragCoords = new Array();
		}
		
		private function addedToStageHandler(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			// Calculate how much to decrement the alpha per frame when scrollIndicator fades out.
			scrollIndicatorAlphaDelta = 1 / (SCROLL_FADE_TWEEN_DURATION * stage.frameRate);
		}
		
		private function removedFromStageHandler(e:Event):void
		{
			stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
			
			scrollIndicatorVisible = false;
		}
		
		/**
		 * Lays out the children.
		 * This should always be called after children have been added or resized.
		 * 
		 * @param resetScrollY Indicates whether or not to reset scrollY when laying out the items.
		 */
		public function refreshView(resetScrollY:Boolean):void
		{
			for (var i:Number = 0; i < itemContainer.numChildren; i++)
			{
				var child:DisplayObject = itemContainer.getChildAt(i);
				if (i == 0)
				{
					child.y = itemYOffsetTop;
				}
				else
				{
					var previousChild:DisplayObject = itemContainer.getChildAt(i - 1);
					child.y = previousChild.y + previousChild.height + verticalGap;
				}
			}
			
			if (stage)
				stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
			
			scrollIndicatorVisible = false;
			
			this.resetScrollY = resetScrollY;
			updateDisplayList();
			
			this.resetScrollY = false;
		}
		
		override protected function updateDisplayList():void
		{
			super.updateDisplayList();
			
			stopTween();
			
			updateMaxScroll();
			
			if (resetScrollY || !itemContainer.scrollRect)
			{
				itemContainer.scrollRect = new Rectangle(0, 0, width, height);
			}
			else
			{
				scrollY = Math.min(maxScroll, scrollY);
				itemContainer.scrollRect = new Rectangle(0, scrollY, width, height);
			}
			
			graphics.clear();
			graphics.beginFill(backgroundColor);
			graphics.drawRect(0, 0, width, height);
		}
		
		private function updateMaxScroll():void
		{
			if (itemContainer.numChildren > 0)
			{
				var lastChild:DisplayObject = itemContainer.getChildAt(itemContainer.numChildren - 1);
				var totalHeight:Number = lastChild.y + lastChild.height;
				maxScroll = Math.round(totalHeight - height) + itemYOffsetBottom;
				
				if (maxScroll > 0)
				{
					if (!indicator)
					{
						indicator = new VIndicator();
						indicator.mouseChildren = indicator.mouseEnabled = false;
						indicator.alpha = 0;
					}
					
					indicator.x = _width - VIndicator.WIDTH - SCROLL_INDICATOR_RIGHT_PADDING;
					indicator.y = scrollIndicatorTopPadding;
					
					if (!contains(indicator))
						addChild(indicator);
					
					// Calculate the values used for sizing indicator.
					var availableHeight:Number = _height - scrollIndicatorTopPadding - scrollIndicatorBottomPadding
					scrollIndicatorHeight = Math.max(Math.round((availableHeight / totalHeight) * availableHeight), MIN_SCROLL_INDICATOR_HEIGHT);;
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
		}
		
		private function mouseDownHandler(e:MouseEvent):void
		{
			mouseXDownCoord = root.mouseX;
			mouseYDown = previousDragMouseY = root.mouseY;
			
			if (maxScroll > 0)
			{
				isDragging = false;
				stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
				
				deltaMouseY = 0;
				previousDragTime = getTimer();
				
				beginDragScrollY = scrollY;
				
				enterFrameIndex = 0;
			}
			
			// Listen for a mouseMove first to detect the initial direction
			// and when to start dragging.
			stage.addEventListener(MouseEvent.MOUSE_MOVE, detectDirection_mouseMoveHandler);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler);
		}
		
		private function detectDirection_mouseMoveHandler(e:Event):void
		{
			if (maxScroll > 0 && Math.abs(mouseYDown - root.mouseY) > START_TO_DRAG_THRESHOLD)
			{
				scrollIndicatorVisible = true;
				
				isDragging = true;
				
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, detectDirection_mouseMoveHandler);
				stage.addEventListener(Event.ENTER_FRAME, drag_enterFrameHandler);
				
				dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLL, false, false, mouseYDown > root.mouseY ? ScrollEvent.DIRECTION_UP : ScrollEvent.DIRECTION_DOWN));
			}
			
			if (dispatchHorizontalSwipeEvents)
			{
				var deltaX:Number = mouseXDownCoord - root.mouseX;
				
				// To avoid inadvertant swipes make sure the user moved HORIZONTAL_DRAG_THRESHOLD.
				// Accidental swipes are more common when using fingers.
				if (Math.abs(deltaX) > HORIZONTAL_DRAG_THRESHOLD)
				{
					for each (var child:DisplayObject in horizontalDragChildren)
					{
						if (child.hitTestPoint(root.mouseX, root.mouseY))
						{
							// Mouse is over a horizontal drag child.
							stopVerticalScrolling();
						}
					}
					
					// Make sure the user moved more along the x-axis more than the y-axis.
					var deltaY:Number = mouseYDown - root.mouseY;
					if (Math.abs(deltaX) > Math.abs(deltaY))
						dispatchEvent(new HorizontalSwipeEvent(HorizontalSwipeEvent.HORIZONTAL_SWIPE, false, false, deltaX < 0 ? HorizontalSwipeDirections.RIGHT : HorizontalSwipeDirections.LEFT));
				}
			}
		}
		
		/**
		 * The handler for fading out the scrollIndicator.
		 */
		private function scrollIndicatorFade_enterFrameHandler(e:Event):void
		{
			indicator.alpha -= scrollIndicatorAlphaDelta;
			
			if (indicator.alpha <= 0)
				removeEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
		}
		
		/**
		 * Can be used after dispatching a HorizontalSwipeEvent if
		 * a listener would like to stop the vertical scrolling.
		 */
		public function stopVerticalScrolling():void
		{
			scrollIndicatorVisible = false;
			
			stage.removeEventListener(Event.ENTER_FRAME, drag_enterFrameHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, detectDirection_mouseMoveHandler);
		}
		
		private function drag_enterFrameHandler(e:Event):void
		{
			e.stopImmediatePropagation();
			
			if (stage)
			{
				var newY:Number = beginDragScrollY + (mouseYDown - root.mouseY);
				
				scrollY = newY;
				
				enterFrameIndex += 1;
				
				if (enterFrameIndex % NUM_FRAMES_TO_MEASURE_SPEED)
				{
					deltaMouseY = root.mouseY - previousDragMouseY;
					previousDragTime = getTimer();
					previousDragMouseY = root.mouseY;
				}
				
				mouseDragCoords.push(root.mouseY);
				
				updateScrollIndicator();
			}
		}
		
		private function updateScrollIndicator():void
		{
			var delta:Number = scrollY / maxScroll;
			var newHeight:Number;
			
			if (delta < 0) // user dragged below the top edge.
			{
				indicator.y = Math.round(scrollIndicatorTopPadding);
				
				// virtualScrollY will be < 0.
				// Shrink scrollIndicator.height by the amount a user has scrolled below the top edge.
				newHeight = scrollY + scrollIndicatorHeight;
				newHeight = Math.max(MIN_SCROLL_INDICATOR_HEIGHT, newHeight);
				indicator.height = Math.round(newHeight);
			}
			else if (delta < 1)
			{
				if (indicator.height != scrollIndicatorHeight)
					indicator.height = Math.round(scrollIndicatorHeight);
				
				var newY:Number = Math.round(delta * totalScrollAmount);
				newY = Math.min(_height - scrollIndicatorHeight - scrollIndicatorBottomPadding, newY);
				indicator.y = Math.round(newY + scrollIndicatorTopPadding);
			}
			else	// User dragged above the bottom edge.
			{
				// Shrink indicator.height by the amount a user has scrolled above the bottom edge.
				newHeight = scrollIndicatorHeight - (scrollY - maxScroll);
				newHeight = Math.max(MIN_SCROLL_INDICATOR_HEIGHT, newHeight);
				indicator.height = Math.round(newHeight);
				indicator.y = Math.round(_height - newHeight - scrollIndicatorBottomPadding);
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
		
		private function drag_mouseUpHandler(e:MouseEvent):void
		{
			if (stage)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, detectDirection_mouseMoveHandler);
				stage.removeEventListener(Event.ENTER_FRAME, drag_enterFrameHandler);
				stage.removeEventListener(MouseEvent.MOUSE_UP, drag_mouseUpHandler);
			}
			
			isTweening = false;
			
			if (maxScroll > 0)
			{
				// Calculate the speed between the last mouse moves which
				// will determine the speed in which to scroll the items.
				var elapsedMiliseconds:Number = getTimer() - previousDragTime;
				var pixelsPerMillisecond:Number = deltaMouseY / elapsedMiliseconds;
				targetScrollY = Math.round(-pixelsPerMillisecond * MAX_PIXEL_MOVE + scrollY);
				
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
					
					if (Math.abs(scrollY - targetScrollY) < MIN_PIXEL_MOVE)
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
					// No flick so fade out indicator immediately.
					addEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
					
					if (isDragging)
						dispatchEvent(new TweenEvent(TweenEvent.TWEEN_COMPLETE));
				}
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
			tweenTotalCount = Math.round(ANIMATION_DURATION * stage.frameRate);
			stage.addEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
			
			isTweening = true;
		}
		
		/**
		 * Tweens the content to a scrollY value.
		 */
		public function tweenScrollYTo(value:Number):void
		{
			if (maxScroll > 0)
			{
				// If a tween is still in process then take the amount of the 
				// remaining tween and add it to the value passed in.
				if (isTweening)
				{
					value += targetScrollY - scrollY;
					stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
				}
				
				// Make sure the list does not scroll below the top edge and above the bottom edge.
				if (value > maxScroll)
					value = maxScroll;
				else if (value < 0)
					value = 0;
				
				scrollIndicatorVisible = true;
				if (scrollY != value)
				{
					dispatchEvent(new ScrollEvent(ScrollEvent.START_SCROLL, false, false, scrollY < value ? ScrollEvent.DIRECTION_UP : ScrollEvent.DIRECTION_DOWN));
					doTween(value);
				}
				else // At the top or bottom scroll limits so fade out scrollIndicator.
				{
					addEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
				}
			}
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
				
				dispatchEvent(new TweenEvent(TweenEvent.TWEEN_COMPLETE));
			}
		}
		
		/**
		 * Set a child which has horizontal dragging enabled/disabled.
		 * Excludes this control from dispatching a HorizontalSwipeEvent if a user swiped over the child.
		 */
		public function setHorizontalDragChild(child:DisplayObject, value:Boolean):void
		{
			var index:Number = horizontalDragChildren.indexOf(child);
			if (value)
			{
				if (index == -1)
					horizontalDragChildren.push(child);
			}
			else
			{
				if (index != -1)
					horizontalDragChildren.splice(index, 1);
			}
		}
		
		private function set scrollIndicatorVisible(value:Boolean):void
		{
			if (indicator)
			{
				removeEventListener(Event.ENTER_FRAME, scrollIndicatorFade_enterFrameHandler);
				indicator.alpha = value ? 1 : 0;
			}
		}
		
		/**
		 * Stops the flick tween.
		 */
		private function stopTween():void
		{
			if (isTweening)
			{
				scrollY = targetScrollY;
				
				if (stage)
					stage.removeEventListener(Event.ENTER_FRAME, tween_enterFrameHandler);
				
				scrollIndicatorVisible = false;
				
				dispatchEvent(new TweenEvent(TweenEvent.TWEEN_COMPLETE));
			}
		}
	}
}