/**
 * VERSION: 0.73
 * DATE: 2011-12-27
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins {
	import com.greensock.*;
	import com.greensock.core.*;

/**
 * <code>ThrowPropsPlugin</code> allows you to simply define an initial velocity for a property 
 * (or multiple properties) as well as optional maximum and/or minimum end values and then it 
 * will calculate the appropriate landing position and plot a smooth course based on the easing 
 * equation you define (Quad.easeOut by default, as set in TweenLite). This is perfect
 * for flick-scrolling or animating things as though they are being thrown. <br /><br />
 * 
 * For example, let's say a user clicks and drags a ball and you track its velocity using an 
 * <code>ENTER_FRAME</code> handler and then when the user releases the mouse button, you'd determine 
 * the velocity but you can't do a normal tween because you don't know exactly where it should 
 * land or how long the tween should last (faster initial velocity would mean a longer duration). 
 * You need the tween to pick up exactly where the user left off so that it appears to smoothly continue 
 * moving in the same direction and at the same velocity they were dragging and then decelerate 
 * based on whatever ease you define in your tween. <br /><br />
 * 
 * Oh, and one more challenge: maybe you want the final resting value to always lie within a 
 * particular range so that things don't land way off the edge of the screen. But you don't want 
 * it to suddenly jerk to a stop when it hits the edge of the screen; instead, you want it to ease 
 * gently into place even if that means going past the landing spot briefly and easing back 
 * (if the initial velocity is fast enough to require that). The whole point is to make it look smooth. <br /><br />
 * 
 * <strong>No problem.</strong> <br /><br />
 * 
 * In its simplest form, you can pass just the initial velocity for each property like this:<br /><br /><code>
 * 
 * TweenLite.to(mc, 2, {throwProps:{x:500, y:-300}});</code><br /><br />
 * 
 * In the above example, <code>mc.x</code> will animate at 500 pixels per second initially and 
 * <code>mc.y</code> will animate at -300 pixels per second. Both will decelerate smoothly 
 * until they come to rest 2 seconds later (because the tween's duration is 2 seconds). <br /><br /> 
 * 
 * To use the <code>Strong.easeOut</code> easing equation and impose maximum and minimum boundaries on 
 * the end values, use the object syntax with the <code>max</code> and <code>min</code> special 
 * properties like this:<br /><br /><code>
 * 
 * TweenLite.to(mc, 2, {throwProps:{x:{velocity:500, max:1024, min:0}, y:{velocity:-300, max:720, min:0}}, ease:Strong.easeOut});
 * </code><br /><br />
 * 
 * Notice the nesting of the objects ({}). The <code>max</code> and <code>min</code> values refer
 * to the range for the final resting position (coordinates in this case), NOT the velocity. 
 * So <code>mc.x</code> would always land between 0 and 1024 in this case, and <code>mc.y</code> 
 * would always land between 0 and 720. If you want the target object to land on a specific value 
 * rather than within a range, simply set <code>max</code> and <code>min</code> to identical values. 
 * Also notice that you must define a <code>velocity</code> value for each property.<br /><br />
 * 
 * ThrowPropsPlugin isn't just for tweening x and y coordinates. It works with any numeric property,
 * so you could use it for spinning the <code>rotation</code> of an object as well. Or the 
 * <code>scaleX</code>/<code>scaleY</code> properties. Maybe the user drags to spin a wheel and
 * lets go and you want it to continue increasing the <code>rotation</code> at that velocity, 
 * decelerating smoothly until it stops.<br /><br />
 *  
 * One of the trickiest parts of creating a <code>throwProps</code> tween that looks fluid and natural, 
 * particularly if you're applying maximum and/or minimum values, is determining its duration. 
 * Typically it's best to have a relatively consistent level of resistance so that if the 
 * initial velocity is very fast, it takes longer for the object to come to rest compared to 
 * when the initial velocity is slower. You also may want to impose some restrictions on how long
 * a tween can last (if the user drags incredibly fast, you might not want the tween to last 200
 * seconds). The duration will also affect how far past a max/min boundary the property can potentially
 * go, so you might want to only allow a certain amount of overshoot tolerance. That's why <code>ThrowPropsPlugin</code>
 * has a few static helper methods that make managing all these variables much easier. The one you'll 
 * probably use most often is the <a href="#to()"><code>to()</code></a> method which is very similar 
 * to <code>TweenLite.to()</code> except that it doesn't have a <code>duration</code> parameter and 
 * it adds several other optional parameters. Read the <a href="#to()">docs below</a> for details.<br /><br />
 * 
 * Feel free to experiment with using different easing equations to control how the values ease into
 * place at the end. You don't need to put the "ease" special property inside the 
 * <code>throwProps</code> object. Just keep it in the same place it has always been, like:<br /><br /><code>
 * 
 * TweenLite.to(mc, 1, {throwProps:{x:500, y:-300}, ease:Strong.easeOut});</code><br /><br />
 * 
 * A unique convenience of ThrowPropsPlugin compared to most other solutions out there which use 
 * <code>ENTER_FRAME</code> loops is that everything is reverseable and you can jump to any spot 
 * in the tween immediately. So if you create several <code>throwProps</code> tweens, for example, and 
 * dump them into a TimelineLite, you could simply call <code>reverse()</code> on the timeline 
 * to watch the objects retrace their steps right back to the beginning. <br /><br />
 * 
 * <i>(note: it is best to use an <code>easeOut</code> with <code>throwProps</code> tweens, but 
 * you can vary the strength by using different flavors like <code>Strong.easeOut, Cubic.easeOut, 
 * Quad.easeOut, Back.easeOut</code>, etc.)</i><br /><br />
 * 
 * The following example creates a Sprite (<code>mc</code>), populates it with a long TextField
 * and makes it vertically draggable. Then it tracks its velocity in an <code>ENTER_FRAME</code> 
 * handler and then allows it to be thrown within the bounds defined by the <code>bounds</code> 
 * rectangle, smoothly easing into place regardless of where and how fast it is thrown:
@example Example AS3 code:<listing version="3.0">
import com.greensock.~~;
import flash.events.MouseEvent;
import com.greensock.plugins.~~;
import com.greensock.easing.~~;
import flash.geom.Rectangle;
import flash.utils.getTimer;
import flash.text.~~;
import flash.display.~~;

TweenPlugin.activate([ThrowPropsPlugin]);

var bounds:Rectangle = new Rectangle(30, 30, 250, 230);
var mc:Sprite = new Sprite();
addChild(mc);
setupTextField(mc, bounds, 20);

//some variables for tracking the velocity of mc
var t1:uint, t2:uint, y1:Number, y2:Number;

mc.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);

function mouseDownHandler(event:MouseEvent):void {
	TweenLite.killTweensOf(mc);
	y1 = y2 = mc.y;
	t1 = t2 = getTimer();
	mc.startDrag(false, new Rectangle(bounds.x, -99999, 0, 99999999));
	mc.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	mc.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
}

function enterFrameHandler(event:Event):void {
	//track velocity using the last 2 frames for more accuracy
	y2 = y1;
	t2 = t1;
	y1 = mc.y;
	t1 = getTimer();
}

function mouseUpHandler(event:MouseEvent):void {
	mc.stopDrag();
	mc.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
	mc.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	var time:Number = (getTimer() - t2) / 1000;
	var yVelocity:Number = (mc.y - y2) / time;
	var yOverlap:Number = Math.max(0, mc.height - bounds.height);
	ThrowPropsPlugin.to(mc, {ease:Strong.easeOut, throwProps:{y:{velocity:yVelocity, max:bounds.top, min:bounds.top - yOverlap, resistance:200}}}, 10, 0.25, 1);
}

function setupTextField(container:Sprite, bounds:Rectangle, padding:Number=20):void {
	var tf:TextField = new TextField();
	tf.width = bounds.width - padding;
	tf.x = tf.y = padding / 2;
	tf.defaultTextFormat = new TextFormat("_sans", 12);
	tf.text = "Click and drag this content and then let go as you're dragging to throw it. Notice how it smoothly glides into place, respecting the initial velocity and the maximum/minimum coordinates.\n\nThrowPropsPlugin allows you to simply define an initial velocity for a property (or multiple properties) as well as optional maximum and/or minimum end values and then it will calculate the appropriate landing position and plot a smooth course based on the easing equation you define (Quad.easeOut by default, as set in TweenLite). This is perfect for flick-scrolling or animating things as though they are being thrown.\n\nFor example, let's say a user clicks and drags a ball and you track its velocity using an ENTER_FRAME handler and then when the user releases the mouse button, you'd determine the velocity but you can't do a normal tween because you don't know exactly where it should land or how long the tween should last (faster initial velocity would mean a longer duration). You need the tween to pick up exactly where the user left off so that it appears to smoothly continue moving at the same velocity they were dragging and then decelerate based on whatever ease you define in your tween.\n\nAs demonstrated here, maybe the final resting value needs to lie within a particular range so that the content doesn't land outside a particular area. But you don't want it to suddenly jerk to a stop when it hits the edge; instead, you want it to ease gently into place even if that means going past the landing spot briefly and curving back (if the initial velocity is fast enough to require that). The whole point is to make it look smooth.";
	tf.multiline = tf.wordWrap = true;
	tf.selectable = false;
	tf.autoSize = TextFieldAutoSize.LEFT;
	container.addChild(tf);
	
	container.graphics.beginFill(0xFFFFFF, 1);
	container.graphics.drawRect(0, 0, tf.width + padding, tf.textHeight + padding);
	container.graphics.endFill();
	container.x = bounds.x;
	container.y = bounds.y;
	
	var crop:Shape = new Shape();
	crop.graphics.beginFill(0xFF0000, 1);
	crop.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
	crop.graphics.endFill();
	container.parent.addChild(crop);
	container.mask = crop;
}

 </listing>
 * 
 * ThrowPropsPlugin is a <a href="http://www.greensock.com/club/">Club GreenSock</a> membership benefit. 
 * You must have a valid membership to use this class without violating the terms of use. Visit 
 * <a href="http://www.greensock.com/club/">http://www.greensock.com/club/</a> to sign up or get more details.<br /><br />
 * 
 * <b>Copyright 2011, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
 * 
 * @author Jack Doyle, jack@greensock.com
 */
	public class ThrowPropsPlugin extends TweenPlugin {
		/** @private **/
		public static const API:Number = 1.0; //If the API/Framework for plugins changes in the future, this number helps determine compatibility
		/** 
		 * The default <code>resistance</code> that is used to calculate how long it will take 
		 * for the tweening property (or properties) to come to rest by the static <code>ThrowPropsPlugin.to()</code>
		 * and <code>ThrowPropsPlugin.calculateTweenDuration()</code> methods. Keep in mind that you can define
		 * a <code>resistance</code> value either for each individual property in the <code>throwProps</code> tween
		 * like this:<br /><br /><code>
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{x:{velocity:500, resistance:150}, y:{velocity:-300, resistance:50}}});
		 * </code><br /><br />
		 * 
		 * <strong>OR</strong> you can define a single <code>resistance</code> value that will be used for all of the 
		 * properties in that particular <code>throwProps</code> tween like this:<br /><br /><code>
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{x:500, y:-300, resistance:150}}); <br /><br />
		 * 
		 * //-OR- <br /><br />
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{x:{velocity:500, max:800, min:0}, y:{velocity:-300, max:800, min:100}, resistance:150}});
		 * </code><br /><br /> 
		 **/
		public static var defaultResistance:Number = 100;
		
		/** @private **/
		protected var _tween:TweenLite;
		/** @private **/
		protected var _target:Object;
		/** @private **/
		protected var _props:Array;
		
		/** @private **/
		public function ThrowPropsPlugin() {
			super();
			this.propName = "throwProps"; //name of the special property that the plugin should intercept/manage
			this.overwriteProps = [];
		}
		
		/**
		 * Automatically analyzes various throwProps variables (like <code>velocity</code>, <code>max</code>, <code>min</code>, 
		 * and <code>resistance</code>) and creates a TweenLite instance with the appropriate duration. You can use
		 * <code>ThrowPropsPlugin.to()</code> instead of <code>TweenLite.to()</code> to create
		 * a tween - they're identical except that <code>ThrowPropsPlugin.to()</code> doesn't have a 
		 * <code>duration</code> parameter (it figures it out for you) and it adds a few extra parameters
		 * to the end that can optionally be used to affect the duration. <br /><br />
		 * 
		 * Another key difference is that <code>ThrowPropsPlugin.to()</code> will recognize the 
		 * <code>resistance</code> special property which basically controls how quickly each 
		 * property's velocity decelerates (and consequently influences the duration of the tween). 
		 * For example, if the initial <code>velocity</code> is 500 and the <code>resistance</code> 
		 * is 300, it will decelerate much faster than if the resistance was 20. You can define
		 * a <code>resistance</code> value either for each individual property in the <code>throwProps</code> 
		 * tween like this:<br /><br /><code>
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{x:{velocity:500, resistance:150}, y:{velocity:-300, resistance:50}}});
		 * </code><br /><br />
		 * 
		 * <strong>OR</strong> you can define a single <code>resistance</code> value that will be used for all of the 
		 * properties in that particular <code>throwProps</code> tween like this:<br /><br /><code>
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{x:500, y:-300, resistance:150}}); <br /><br />
		 * 
		 * //-OR- <br /><br />
		 * 
		 * ThrowPropsPlugin.to(mc, {throwProps:{x:{velocity:500, max:800, min:0}, y:{velocity:-300, max:700, min:100}, resistance:150}});
		 * </code><br /><br /> 
		 * 
		 * <code>resistance</code> should always be a positive value, although <code>velocity</code> can be negative. 
		 * <code>resistance</code> always works against <code>velocity</code>. If no <code>resistance</code> value is 
		 * found, the <code>ThrowPropsPlugin.defaultResistance</code> value will be used. The <code>resistance</code>
		 * values merely affect the duration of the tween and can be overriden by the <code>maxDuration</code> and 
		 * <code>minDuration</code> parameters. Think of the <code>resistance</code> as more of a suggestion that 
		 * ThrowPropsPlugin uses in its calculations rather than an absolute set-in-stone value. When there are multiple
		 * properties in one throwProps tween (like <code>x</code> and <code>y</code>) and the calculated duration
		 * for each one is different, the longer duration is always preferred in order to make things animate more 
		 * smoothly.<br /><br />
		 * 
		 * You also may want to impose some restrictions on the tween's duration (if the user drags incredibly 
		 * fast, for example, you might not want the tween to last 200 seconds). Use <code>maxDuration</code> and 
		 * <code>minDuration</code> parameters for that. You can use the <code>overshootTolerance</code>
		 * parameter to set a maximum number of seconds that can be added to the tween's duration (if necessary) to 
		 * accommodate temporarily overshooting the end value before smoothly returning to it at the end of the tween. 
		 * This can happen in situations where the initial velocity would normally cause it to exceed the <code>max</code> 
		 * or <code>min</code> values. An example of this would be in the iOS (iPhone or iPad) when you flick-scroll 
		 * so quickly that the content would shoot past the end of the scroll area. Instead of jerking to a sudden stop
		 * when it reaches the edge, the content briefly glides past the max/min position and gently eases back into place. 
		 * The larger the <code>overshootTolerance</code> the more leeway the tween has to temporarily shoot past the 
		 * max/min if necessary. 
		 * 
		 * 
		 * @param target Target object whose properties the tween affects. This can be ANY object, not just a DisplayObject. 
		 * @param vars An object containing the end values of the properties you're tweening, and it must also contain a <code>throwProps</code> object. For example, to create a tween that tweens <code>mc.x</code> at an initial velocity of 500 and <code>mc.y</code> at an initial velocity of -300 and applies a <code>resistance<code> of 80 and uses the <code>Strong.easeOut</code> easing equation and calls the method <code>tweenCompleteHandler</code> when it is done, the <code>vars</code> object would look like: <code>{throwProps:{x:500, y:-300, resistance:80}, ease:Strong.easeOut, onComplete:tweenCompleteHandler}</code>.
		 * @param maxDuration Maximum duration of the tween
		 * @param minDuration Minimum duration of the tween
		 * @param overshootTolerance sets a maximum number of seconds that can be added to the tween's duration (if necessary) to 
		 * accommodate temporarily overshooting the end value before smoothly returning to it at the end of the tween. 
		 * This can happen in situations where the initial velocity would normally cause it to exceed the <code>max</code> 
		 * or <code>min</code> values. An example of this would be in the iOS (iPhone or iPad) when you flick-scroll 
		 * so quickly that the content would shoot past the end of the scroll area. Instead of jerking to a sudden stop
		 * when it reaches the edge, the content briefly glides past the max/min position and gently eases back into place. 
		 * The larger the <code>overshootTolerance</code> the more leeway the tween has to temporarily shoot past the 
		 * max/min if necessary.
		 * @return TweenLite instance
		 * 
		 * @see #defaultResistance
		 */
		static public function to(target:Object, vars:Object, maxDuration:Number=100, minDuration:Number=0.25, overshootTolerance:Number=1):TweenLite {
			if (!("throwProps" in vars)) {
				vars = {throwProps:vars};
			}
			return new TweenLite(target, calculateTweenDuration(target, vars, maxDuration, minDuration, overshootTolerance), vars);
		}
		
		/**
		 * Determines the amount of change given a particular velocity, an specific easing equation, 
		 * and the duration that the tween will last. This is useful for plotting the resting position
		 * of an object that starts out at a certain velocity and decelerates based on an ease (like 
		 * <code>Strong.easeOut</code>). 
		 * 
		 * @param velocity The initial velocity
		 * @param ease The easing equation (like <code>Strong.easeOut</code> or <code>Quad.easeOut</code>).
		 * @param duration The duration (in seconds) of the tween
		 * @param checkpoint A value between 0 and 1 (typically 0.05) that is used to measure an easing equation's initial strength. The goal is for the value to have moved at the initial velocity through that point in the ease. So 0.05 represents 5%. If the initial velocity is 500, for example, and the ease is <code>Strong.easeOut</code> and <code>checkpoint</code> is 0.05, it will measure 5% into that ease and plot the position that would represent where the value would be if it was moving 500 units per second for the first 5% of the tween. If you notice that your tween appears to start off too fast or too slow, try adjusting the <code>checkpoint</code> higher or lower slightly. Typically 0.05 works great. 
		 * @return The amount of change (can be positive or negative based on the velocity)
		 */
		public static function calculateChange(velocity:Number, ease:Function, duration:Number, checkpoint:Number=0.05):Number {
			return (duration * checkpoint * velocity) / ease(checkpoint, 0, 1, 1);
		}
		
		/**
		 * Calculates the duration (in seconds) that it would take to move from a particular start value
		 * to an end value at the given initial velocity, decelerating according to a certain easing 
		 * equation (like <code>Strong.easeOut</code>). 
		 * 
		 * @param start Starting value
		 * @param end Ending value
		 * @param velocity the initial velocity at which the starting value is changing
		 * @param ease The easing equation used for deceleration (like <code>Strong.easeOut</code> or <code>Quad.easeOut</code>).
		 * @param checkpoint A value between 0 and 1 (typically 0.05) that is used to measure an easing equation's initial strength. The goal is for the value to have moved at the initial velocity through that point in the ease. So 0.05 represents 5%. If the initial velocity is 500, for example, and the ease is <code>Strong.easeOut</code> and <code>checkpoint</code> is 0.05, it will measure 5% into that ease and plot the position that would represent where the value would be if it was moving 500 units per second for the first 5% of the tween. If you notice that your tween appears to start off too fast or too slow, try adjusting the <code>checkpoint</code> higher or lower slightly. Typically 0.05 works great. 
		 * @return The duration (in seconds) that it would take to move from the start value to the end value at the initial velocity provided, decelerating according to the ease. 
		 */
		public static function calculateDuration(start:Number, end:Number, velocity:Number, ease:Function, checkpoint:Number=0.05):Number {
			return Math.abs( (end - start) * ease(checkpoint, 0, 1, 1) / velocity / checkpoint );
		}
		
		/**
		 * Analyzes various throwProps variables (like initial velocities, max/min values, 
		 * and resistance) and determines the appropriate duration. Typically it is best to 
		 * use the <code>ThrowPropsPlugin.to()</code> method for this, but <code>calculateTweenDuration()</code>
		 * could be convenient if you want to create a TweenMax instance instead of a TweenLite instance
		 * (which is what <code>throwPropsPlugin.to()</code> returns).
		 * 
		 * @param target Target object whose properties the tween affects. This can be ANY object, not just a DisplayObject. 
		 * @param vars An object containing the end values of the properties you're tweening, and it must also contain a <code>throwProps</code> object. For example, to create a tween that tweens <code>mc.x</code> at an initial velocity of 500 and <code>mc.y</code> at an initial velocity of -300 and applies a <code>resistance<code> of 80 and uses the <code>Strong.easeOut</code> easing equation and calls the method <code>tweenCompleteHandler</code> when it is done, the <code>vars</code> object would look like: <code>{throwProps:{x:500, y:-300, resistance:80}, ease:Strong.easeOut, onComplete:tweenCompleteHandler}</code>.
		 * @param maxDuration Maximum duration (in seconds)
		 * @param minDuration Minimum duration (in seconds)
		 * @param overshootTolerance sets a maximum number of seconds that can be added to the tween's duration (if necessary) to 
		 * accommodate temporarily overshooting the end value before smoothly returning to it at the end of the tween. 
		 * This can happen in situations where the initial velocity would normally cause it to exceed the <code>max</code> 
		 * or <code>min</code> values. An example of this would be in the iOS (iPhone or iPad) when you flick-scroll 
		 * so quickly that the content would shoot past the end of the scroll area. Instead of jerking to a sudden stop
		 * when it reaches the edge, the content briefly glides past the max/min position and gently eases back into place. 
		 * The larger the <code>overshootTolerance</code> the more leeway the tween has to temporarily shoot past the 
		 * max/min if necessary.
		 * @return The duration (in seconds) that the tween should use. 
		 */
		public static function calculateTweenDuration(target:Object, vars:Object, maxDuration:Number=100, minDuration:Number=0.25, overshootTolerance:Number=1):Number {
			var duration:Number = 0;
			var clippedDuration:Number = 9999999999;
			var throwPropsVars:Object = ("throwProps" in vars) ? vars.throwProps : vars;
			var ease:Function = (vars.ease is Function) ? vars.ease : _easeOut;
			var checkpoint:Number = ("checkpoint" in throwPropsVars) ? Number(throwPropsVars.checkpoint) : 0.05;
			var resistance:Number = ("resistance" in throwPropsVars) ? Number(throwPropsVars.resistance) : defaultResistance;
			var curProp:Object, curDuration:Number, curVelocity:Number, curResistance:Number, end:Number, curClippedDuration:Number;
			for (var p:String in throwPropsVars) {
				
				if (p != "resistance" && p != "checkpoint") {
					curProp = throwPropsVars[p];
					if (typeof(curProp) == "number") {
						curVelocity = Number(curProp);
						curDuration = (curVelocity * resistance > 0) ? curVelocity / resistance : curVelocity / -resistance;
						
					} else {
						curVelocity = Number(curProp.velocity) || 0;
						curResistance = ("resistance" in curProp) ? Number(curProp.resistance) : resistance;
						curDuration = (curVelocity * curResistance > 0) ? curVelocity / curResistance : curVelocity / -curResistance;
						end = target[p] + calculateChange(curVelocity, ease, curDuration, checkpoint);
						if ("max" in curProp && end > Number(curProp.max)) {
							//if the value is already exceeding the max or the velocity is too low, the duration can end up being uncomfortably long but in most situations, users want the snapping to occur relatively quickly (0.75 seconds), so we implement a cap here to make things more intuitive.
							curClippedDuration = (target[p] > curProp.max || (curVelocity > -15 && curVelocity < 45)) ? 0.75 : calculateDuration(target[p], curProp.max, curVelocity, ease, checkpoint);
							if (curClippedDuration + overshootTolerance < clippedDuration) {
								clippedDuration = curClippedDuration + overshootTolerance;
							}
							
						} else if ("min" in curProp && end < Number(curProp.min)) {
							//if the value is already exceeding the min or if the velocity is too low, the duration can end up being uncomfortably long but in most situations, users want the snapping to occur relatively quickly (0.75 seconds), so we implement a cap here to make things more intuitive.
							curClippedDuration = (target[p] < curProp.min || (curVelocity > -45 && curVelocity < 15)) ? 0.75 : calculateDuration(target[p], curProp.min, curVelocity, ease, checkpoint);
							if (curClippedDuration + overshootTolerance < clippedDuration) {
								clippedDuration = curClippedDuration + overshootTolerance;
							}
						}
						
						if (curClippedDuration > duration) {
							duration = curClippedDuration;
						}
					}
					
					if (curDuration > duration) {
						duration = curDuration;
					}
					
				}
			}
			if (duration > clippedDuration) {
				duration = clippedDuration;
			}
			if (duration > maxDuration) {
				return maxDuration;
			} else if (duration < minDuration) {
				return minDuration;
			}
			return duration;
		}
	
		/** @private **/
		override public function onInitTween(target:Object, value:*, tween:TweenLite):Boolean {
			_target = target;
			_tween = tween;
			_props = [];
			var ease:Function = (_tween.vars.ease is Function) ? _tween.vars.ease : _easeOut;
			var checkpoint:Number = ("checkpoint" in value) ? Number(value.checkpoint) : 0.05;
			var p:String, curProp:Object, velocity:Number, change1:Number, end:Number, change2:Number, duration:Number = _tween.cachedDuration, cnt:uint = 0;
			for (p in value) {
				if (p != "resistance" && p != "checkpoint") {
					curProp = value[p];
					if (typeof(curProp) == "number") {
						velocity = Number(curProp);
					} else if ("velocity" in curProp) {
						velocity = Number(curProp.velocity);
					} else {
						trace("ERROR: No velocity was defined in the throwProps tween of " + target + " property: " + p);
						velocity = 0;
					}
					change1 = calculateChange(velocity, ease, duration, checkpoint);
					change2 = 0;
					if (typeof(curProp) != "number") {
						end = _target[p] + change1;
						if ("max" in curProp && Number(curProp.max) < end) {
							change2 = (curProp.max - _target[p]) - change1;
							
						} else if ("min" in curProp && Number(curProp.min) > end) {							
							change2 = (curProp.min - _target[p]) - change1;
						}
					}
					_props[cnt++] = new ThrowProp(p, Number(target[p]), change1, change2);
					this.overwriteProps[cnt] = p;
				}
			}
			return true;
		}
		
		/** @private **/
		protected static function _easeOut(t:Number, b:Number, c:Number, d:Number):Number {
			return 1 - (t = 1 - (t / d)) * t;
		}
		
		/** @private **/
		override public function killProps(lookup:Object):void {
			var i:int = _props.length;
			while (i--) {
				if (_props[i].property in lookup) {
					_props.splice(i, 1);
				}
			}
			super.killProps(lookup);
		}
		
		/** @private **/
		override public function set changeFactor(n:Number):void {
			var i:int = _props.length, curProp:ThrowProp;
			if (!this.round) {
				while (i--) {
					curProp = _props[i];
					_target[curProp.property] = curProp.start + curProp.change1 * n + curProp.change2 * n * n;
				}
			} else {
				var val:Number;
				while (i--) {
					curProp = _props[i];
					val = curProp.start + curProp.change1 * n + curProp.change2 * n * n;
					_target[curProp.property] = (val >= 0) ? (val + 0.5) >> 0 : (val - 0.5) >> 0; //4 times as fast as Math.round();
				}
			}
		}
		
	}
}

/** @private **/
internal class ThrowProp {
	public var property:String;
	public var start:Number;
	public var change1:Number;
	public var change2:Number;
	
	public function ThrowProp(property:String, start:Number, change1:Number, change2:Number) {
		this.property = property;
		this.start = start;
		this.change1 = change1;
		this.change2 = change2;
	}	

}