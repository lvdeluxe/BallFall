/**
 * Created by lvdeluxe on 14-08-03.
 */
package com.deluxe.ballfall {
import com.genome2d.Genome2D;
import com.genome2d.components.renderables.GSprite;
import com.genome2d.node.GNode;
import com.genome2d.node.factory.GNodeFactory;
import com.genome2d.signals.GNodeMouseSignal;
import com.genome2d.textures.factories.GTextureFactory;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

public class VirtualJoystick {

	[Embed(source = "/assets/joystick.png")]
	private var JoystickTexture:Class;
	[Embed(source = "/assets/joystickTarget.png")]
	private var JoystickTargetTexture:Class;

	private var _joystickCenter:Point;
	private var _joystickRadius:Number = 64;
	private var _joystickTargetSprite:GSprite;

	private var _factor:Number = .15;

	public var accelX:Number = 0;
	public var accelY:Number = 0;

	private var _callback:Function;


	public function VirtualJoystick(pCallback:Function) {

		_callback = pCallback;
		GTextureFactory.createFromEmbedded("joystickTexture",JoystickTexture);
		GTextureFactory.createFromEmbedded("joystickTargetTexture",JoystickTargetTexture);

		var node:GNode = GNodeFactory.createNode("joystickContainer");

		var joystickSprite:GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
		joystickSprite.textureId = "joystickTexture";
		joystickSprite.node.mouseEnabled = true;
		node.addChild(joystickSprite.node);

		_joystickTargetSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
		_joystickTargetSprite.textureId = "joystickTargetTexture";
		_joystickTargetSprite.node.mouseEnabled = true;
		node.addChild(_joystickTargetSprite.node);
		_joystickTargetSprite.node.setActive(false);

		node.transform.x = Genome2D.getInstance().getContext().getNativeStage().fullScreenWidth - (_joystickRadius + 20);
		node.transform.y = Genome2D.getInstance().getContext().getNativeStage().fullScreenHeight - (_joystickRadius + 20);

		_joystickCenter = new Point(node.transform.x, node.transform.y);
		joystickSprite.mousePixelEnabled = true;

		Genome2D.getInstance().root.addChild(node);
		node.mouseEnabled = true;
		node.mouseChildren = true;
		node.onMouseDown.add(onMouseDown);
	}

	private function onMouseMove(event:MouseEvent):void {
		if(_joystickTargetSprite.node.isActive()){
			var isInCircle:Boolean = isPointInCircle(event.stageX, event.stageY);
			if(isInCircle){
				_joystickTargetSprite.node.transform.setPosition(event.stageX - _joystickCenter.x, event.stageY - _joystickCenter.y);
			}else{
				var angle:Number = Math.atan2(_joystickCenter.y - event.stageY, _joystickCenter.x - event.stageX);//getAngle(event.stageX, event.stageY, _joystickCenter.x, _joystickCenter.y);
				var pt:Point = new Point();
				pt.x = _joystickCenter.x + _joystickRadius * Math.cos(angle);
				pt.y = _joystickCenter.y + _joystickRadius * Math.sin(angle);
				_joystickTargetSprite.node.transform.setPosition(_joystickCenter.x - pt.x,_joystickCenter.y -  pt.y);
			}
		}
	}

	private function onMouseUp(event:MouseEvent):void {
		_joystickTargetSprite.node.setActive(false);
		Genome2D.getInstance().getContext().getNativeStage().stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Genome2D.getInstance().getContext().getNativeStage().stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		Genome2D.getInstance().getContext().getNativeStage().stage.removeEventListener(Event.ENTER_FRAME, onFrame);
		_callback(0,0);
	}

	private function onMouseDown(sig:GNodeMouseSignal):void {

		_joystickTargetSprite.node.setActive(true);
		_joystickTargetSprite.node.transform.setPosition(sig.localX, sig.localY);
		Genome2D.getInstance().getContext().getNativeStage().stage.addEventListener(Event.ENTER_FRAME, onFrame);
		Genome2D.getInstance().getContext().getNativeStage().stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Genome2D.getInstance().getContext().getNativeStage().stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
	}

	private function onFrame(event:Event):void {
		accelX = (_joystickTargetSprite.node.transform.x / _joystickRadius) * _factor;
		accelY = (_joystickTargetSprite.node.transform.y / _joystickRadius) * _factor;
		_callback(-accelX, accelY);
//		trace(accelX, accelY);
	}

	private function isPointInCircle(pX:Number, pY:Number):Boolean{

		var distance:Number = Math.sqrt(Math.pow(_joystickCenter.x - pX, 2) + Math.pow(_joystickCenter.y - pY, 2));
		return distance <= _joystickRadius;
	}
}
}
