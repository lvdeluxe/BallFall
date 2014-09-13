/**
 * Created by lvdeluxe on 14-08-03.
 */
package com.deluxe.ballfall {

import flash.geom.Point;

import starling.core.Starling;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.textures.Texture;

public class VirtualJoystick extends Sprite{

	[Embed(source = "/assets/joystick.png")]
	private var JoystickTexture:Class;
	[Embed(source = "/assets/joystickTarget.png")]
	private var JoystickTargetTexture:Class;

	private var _joystickRadius:Number = 64;
	private var _joystickTargetSprite:Image;

	private var _pivotPoint:Point = new Point();

	private var evt:JoystickEvent = new JoystickEvent(JoystickEvent.JOYSTICK_UPDATE);


	public function VirtualJoystick() {
		var joystickSprite:Image = new Image(Texture.fromBitmap(new JoystickTexture()));
		addChild(joystickSprite);

		_joystickTargetSprite = new Image(Texture.fromBitmap(new JoystickTargetTexture()));
		_joystickTargetSprite.pivotX = _joystickTargetSprite.width>>1;
		_joystickTargetSprite.pivotY = _joystickTargetSprite.height>>1;
		_joystickTargetSprite.x = _joystickRadius;
		_joystickTargetSprite.y = _joystickRadius;
		addChild(_joystickTargetSprite);

		pivotX = _joystickRadius;
		pivotY = _joystickRadius;

		x = Starling.current.nativeStage.fullScreenWidth - (_joystickRadius + 20);
		y = Starling.current.nativeStage.fullScreenHeight - (_joystickRadius + 20);

		_joystickTargetSprite.addEventListener(TouchEvent.TOUCH, onMouseDown);
	}

	private function onMouseDown(event:TouchEvent):void {
		var touch:Touch = event.getTouch(_joystickTargetSprite);
		if(touch){
			if(touch.phase == TouchPhase.BEGAN){
				_joystickTargetSprite.x = touch.globalX - x + _joystickRadius;
				_joystickTargetSprite.y	= touch.globalY - y + _joystickRadius;
				_pivotPoint.x = touch.globalX - pivotX + _joystickTargetSprite.x;
				_pivotPoint.y = touch.globalY - pivotY + _joystickTargetSprite.y;
				addEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
			}else if(touch.phase == TouchPhase.ENDED){
				removeEventListener(EnterFrameEvent.ENTER_FRAME, onFrame);
				evt.velX = 0;
				evt.velY = 0;
				dispatchEvent(evt);
				_joystickTargetSprite.x = _joystickRadius;
				_joystickTargetSprite.y = _joystickRadius;
			}else if(touch.phase == TouchPhase.MOVED){
				var distX:Number = (touch.globalX - _pivotPoint.x);
				var distY:Number = (touch.globalY - _pivotPoint.y);
				_joystickTargetSprite.x = distX + pivotX; _joystickTargetSprite.y = distY + pivotY;

				var dis:Number = Math.sqrt((distX * distX) + (distY * distY));

				if(((dis < 0) ? -dis : dis) > pivotX )
				{
					var force:Number = dis-pivotX;
					_joystickTargetSprite.x -= distX/dis*force;
					_joystickTargetSprite.y -= distY/dis*force;
				}
			}
		}
	}

	private function onFrame(event:EnterFrameEvent):void {
		evt.velX = (_joystickTargetSprite.x / _joystickRadius) - 1;
		evt.velY = (_joystickTargetSprite.y / _joystickRadius) - 1;
		dispatchEvent(evt);
	}
}
}
