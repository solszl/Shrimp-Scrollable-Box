package com.shrimp.ext.scrollable.ease
{

	/**
	 *  The Quartic class defines three easing functions to implement
	 *  motion with Flex effect classes. The acceleration of motion for a Quartic easing
	 *  equation is greater than for a Quadratic or Cubic easing equation.
	 *
	 *  For more information, see http://www.robertpenner.com/profmx.
	 */

	public class Quartic
	{
		/**
		 *  The <code>easeOut()</code> method starts motion fast,
		 *  and then decelerates motion to a zero velocity.
		 *
		 *  @param t Specifies time.
		 *
		 *  @param b Specifies the initial position of a component.
		 *
		 *  @param c Specifies the total change in position of the component.
		 *
		 *  @param d Specifies the duration of the effect, in milliseconds.
		 *
		 *  @return Number corresponding to the position of the component.
		 */
		public static function easeOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return -c * ((t = t / d - 1) * t * t * t - 1) + b;
		}
	}
}
