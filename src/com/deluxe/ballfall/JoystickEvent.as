/**
 * Created by lvdeluxe on 14-09-07.
 */
package com.deluxe.ballfall {
import starling.events.Event;

public class JoystickEvent extends Event
{
	public static const JOYSTICK_UPDATE:String = "joystickUpdate";

	public var velX:Number;
	public var velY:Number;

	public function JoystickEvent(type:String, bubbles:Boolean=false, data:Object=null) {
		super(type, bubbles, data);
	}
}
}
