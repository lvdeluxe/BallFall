package {
import away3d.cameras.lenses.OrthographicLens;
import away3d.containers.ObjectContainer3D;
import away3d.containers.Scene3D;
import away3d.containers.View3D;
import away3d.debug.AwayStats;
import away3d.entities.Mesh;
import away3d.events.LoaderEvent;
import away3d.loaders.Loader3D;
import away3d.loaders.parsers.AWD2Parser;
import away3d.tools.utils.Bounds;

import awayphysics.collision.shapes.AWPBoxShape;
import awayphysics.collision.shapes.AWPSphereShape;
import awayphysics.debug.AWPDebugDraw;
import awayphysics.dynamics.AWPDynamicsWorld;
import awayphysics.dynamics.AWPRigidBody;

import com.deluxe.GAtlasManager;
import com.deluxe.ballfall.VirtualJoystick;
import com.deluxe.ballfall.particles.ExplosionParticles;
import com.genome2d.Genome2D;
import com.genome2d.components.GNapeDynamicBody;
import com.genome2d.components.GNapePhysics;
import com.genome2d.components.GNapeStaticBody;
import com.genome2d.components.renderables.GSprite;
import com.genome2d.components.renderables.particles.GSimpleParticleSystem;
import com.genome2d.context.GContextConfig;
import com.genome2d.context.IContext;
import com.genome2d.context.filters.GFilter;
import com.genome2d.context.stats.GStats;
import com.genome2d.node.GNode;
import com.genome2d.node.factory.GNodeFactory;
import com.genome2d.textures.GTexture;
import com.genome2d.textures.GTextureFilteringType;
import com.genome2d.textures.factories.GTextureFactory;
import com.greensock.TweenMax;
import com.greensock.easing.Ease;
import com.greensock.easing.Expo;
import com.greensock.easing.Linear;
import com.greensock.easing.Quad;
import com.greensock.easing.Quint;

import flash.events.AccelerometerEvent;
import flash.events.Event;
import flash.events.StageOrientationEvent;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.sensors.Accelerometer;

import nape.geom.Geom;
import nape.geom.Vec2;

import flash.desktop.NativeApplication;
import flash.desktop.SystemIdleMode;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.space.Space;

[SWF(width='1136', height='640', backgroundColor='#003f8c', frameRate='60')]
public class BallFall extends Sprite {

	[Embed(source="/assets/3d/scene.awd", mimeType="application/octet-stream")]
	private var SceneClass:Class;

	private var _accelerometer:Accelerometer;
	private var _joystick:VirtualJoystick;

	private var isAccelSupported:Boolean = false;
	private var _view:View3D;
	private var _scene:ObjectContainer3D;

	private var _physics:AWPDynamicsWorld;
	private var _physicsDebug:AWPDebugDraw;

	private var _ballBody:AWPRigidBody;
	private var _force:Vector3D = new Vector3D();

    public function BallFall() {
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.addEventListener(Event.RESIZE, onResize);
		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

		stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging );

		set3DScene();
    }

	private function onResize(event:Event):void {
		//if(_view)
	}

	private function set3DScene():void {

		_view = new View3D();
		addChild(_view);
		var stats:AwayStats = new AwayStats(_view);
		addChild(stats);

		_physics = AWPDynamicsWorld.getInstance();
		_physics.initWithDbvtBroadphase();
		_physicsDebug = new AWPDebugDraw(_view,_physics);

		var loader:Loader3D = new Loader3D();
		Loader3D.enableParser(AWD2Parser);
		loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onComplete);
		loader.loadData(SceneClass);
	}

	private function onComplete(event:LoaderEvent):void {
		_scene = event.currentTarget as ObjectContainer3D;
		var lens:OrthographicLens = new OrthographicLens(stage.fullScreenHeight);
//		lens.far = 10000;
//		lens.near = 0.01;
		_view.camera.lens = lens;
		_view.scene.addChild(_scene);
		_view.camera.position = new Vector3D(0,500,0);
		_view.camera.rotationX = 90;
		_view.camera.lookAt(_scene.scenePosition);

		for(var i:uint = 0 ; i < _scene.numChildren ; i ++){
			if(_scene.getChildAt(i).name == "ball"){
				Bounds.getMeshBounds(_scene.getChildAt(i) as Mesh);
				var ballShape:AWPSphereShape = new AWPSphereShape(Bounds.width / 4);
				_ballBody = new AWPRigidBody(ballShape, _scene.getChildAt(i),1);
				_ballBody.friction = 0.1;
				_ballBody.restitution = 0.9;
				_ballBody.position =  _scene.getChildAt(i).scenePosition;
				_physics.addRigidBody(_ballBody);
			}else if(_scene.getChildAt(i).name == "wall_right"){
				Bounds.getMeshBounds(_scene.getChildAt(i) as Mesh);
				var wallRightShape:AWPBoxShape = new AWPBoxShape(Bounds.width,Bounds.height,Bounds.depth);
				var wallRightBody:AWPRigidBody = new AWPRigidBody(wallRightShape,_scene.getChildAt(i));
				wallRightBody.friction = 0.1;
				wallRightBody.restitution = 0.9;
				wallRightBody.position =  _scene.getChildAt(i).scenePosition;
				_physics.addRigidBody(wallRightBody);
			}else if(_scene.getChildAt(i).name == "wall_left"){
				Bounds.getMeshBounds(_scene.getChildAt(i) as Mesh);
				var wallLeftShape:AWPBoxShape = new AWPBoxShape(Bounds.width,Bounds.height,Bounds.depth);
				var wallLeftBody:AWPRigidBody = new AWPRigidBody(wallLeftShape,_scene.getChildAt(i));
				wallLeftBody.friction = 0.1;
				wallLeftBody.restitution = 0.9;
				wallLeftBody.position =  _scene.getChildAt(i).scenePosition;
				_physics.addRigidBody(wallLeftBody);
			}else if(_scene.getChildAt(i).name == "floor"){
				Bounds.getMeshBounds(_scene.getChildAt(i) as Mesh);
				var floorShape:AWPBoxShape = new AWPBoxShape(Bounds.width,Bounds.height,Bounds.depth);
				var floorBody:AWPRigidBody = new AWPRigidBody(floorShape,_scene.getChildAt(i));
				floorBody.position =  _scene.getChildAt(i).scenePosition;
				_physics.addRigidBody(floorBody);
			}else if(_scene.getChildAt(i).name.indexOf("boundary") != -1){
				Bounds.getMeshBounds(_scene.getChildAt(i) as Mesh);
				var boundaryShape:AWPBoxShape = new AWPBoxShape(Bounds.width,Bounds.height,Bounds.depth);
				var boundaryBody:AWPRigidBody = new AWPRigidBody(boundaryShape,_scene.getChildAt(i));
				boundaryBody.friction = 0.1;
				boundaryBody.restitution = 0.9;
				boundaryBody.position =  _scene.getChildAt(i).scenePosition;
				_physics.addRigidBody(boundaryBody);
			}
		}
		_view.width = 1136;
		_view.height = 640;
		setAccelerometer();
		stage.addEventListener(Event.ENTER_FRAME, render);
	}

	public function onOrientationChanging(event:StageOrientationEvent ):void
	{
		event.preventDefault();
	}

	private function setAccelerometer():void {
		isAccelSupported = Accelerometer.isSupported;
		if(isAccelSupported){
			_accelerometer = new Accelerometer();
			_accelerometer.setRequestedUpdateInterval(100);
			_accelerometer.addEventListener(AccelerometerEvent.UPDATE, onChange);
		}else{
			//_joystick = new VirtualJoystick(setOrientation);
		}

	}

	private function setOrientation(accelX:Number, accelY:Number):void
	{
//		_orientation.x = -accelX * 5000;
//		_orientation.y = accelY * 5000;
		_force = new Vector3D();
		_force.x = -accelX * 10;
		_force.z = -accelY * 10;
	}

	private function onChange(e:AccelerometerEvent):void
	{
		setOrientation(e.accelerationX, e.accelerationY);
	}

	private function onContext():void {

	}

	private function render(event:Event):void {
		_ballBody.applyCentralForce(_force)
		_physicsDebug.debugDrawWorld();
		_physics.step(1/60);
		_view.render();
	}
}
}
