package {
import as3GeomAlgo.EarClipper;

import away3d.cameras.lenses.OrthographicLens;
import away3d.containers.ObjectContainer3D;
import away3d.containers.Scene3D;
import away3d.containers.View3D;
import away3d.controllers.HoverController;
import away3d.core.base.Geometry;
import away3d.core.base.SubGeometry;
import away3d.core.managers.Stage3DManager;
import away3d.core.managers.Stage3DProxy;
import away3d.debug.AwayStats;
import away3d.entities.Mesh;
import away3d.events.LoaderEvent;
import away3d.events.Stage3DEvent;
import away3d.loaders.Loader3D;
import away3d.loaders.parsers.AWD2Parser;
import away3d.materials.ColorMaterial;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.primitives.CubeGeometry;
import away3d.tools.utils.Bounds;

import awayphysics.collision.shapes.AWPBoxShape;
import awayphysics.collision.shapes.AWPSphereShape;
import awayphysics.debug.AWPDebugDraw;
import awayphysics.dynamics.AWPDynamicsWorld;
import awayphysics.dynamics.AWPRigidBody;

import com.deluxe.GAtlasManager;
import com.deluxe.View2D;
import com.deluxe.ballfall.JoystickEvent;
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

import starling.core.Starling;

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
	private var _stage3DManager:Stage3DManager;
	private var _stage3DProxy:Stage3DProxy;
	private var _starling:Starling;
	private var _container:ObjectContainer3D;
	private var _camController:HoverController;
	private var _lightPicker:StaticLightPicker;


	private var move:Boolean = false;
	private var lastPanAngle:Number;
	private var lastTiltAngle:Number;
	private var lastMouseX:Number;
	private var lastMouseY:Number;

    public function BallFall() {
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.addEventListener(Event.RESIZE, onResize);
		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

		stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging );

		setContext();


    }

	private function setContext():void {
		_stage3DManager = Stage3DManager.getInstance(stage);

		// Create a new Stage3D proxy to contain the separate views
		_stage3DProxy = _stage3DManager.getFreeStage3DProxy();

		_stage3DProxy.addEventListener(Stage3DEvent.CONTEXT3D_CREATED, onContextCreated);
		_stage3DProxy.antiAlias = 8;
		_stage3DProxy.color = 0x000000;
	}

	private function onContextCreated(event:Stage3DEvent):void {
		_stage3DProxy.width = stage.stageWidth;
		_stage3DProxy.height = stage.stageHeight;
		set3DScene();
		_starling = new Starling(View2D, stage, _stage3DProxy.viewPort, _stage3DProxy.stage3D);
		_starling.shareContext = true;
		_starling.showStats = true;
		_starling.start();
	}

	private function onResize(event:Event):void {
		//if(_view)
	}

	private function set3DScene():void {

		_view = new View3D();
		_view.stage3DProxy = _stage3DProxy;
		_view.shareContext = true;
		addChild(_view);
//		var stats:AwayStats = new AwayStats(_view);
//		addChild(stats);

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
		//var lens:OrthographicLens = new OrthographicLens(stage.fullScreenHeight* 1.0);
		//_view.camera.lens = lens;
		_view.scene.addChild(_scene);
		//_view.camera.position = new Vector3D(0,500,0);
		//_view.camera.rotationX = 90;
		//_view.camera.lookAt(_scene.scenePosition);

		for(var i:uint = 0 ; i < _scene.numChildren ; i ++){
			_scene.getChildAt(i).visible = false;
			if(_scene.getChildAt(i).name == "ball"){
				_scene.getChildAt(i).visible = false;
				var ball:Mesh = _scene.getChildAt(i) as Mesh;
				_lightPicker = ball.material.lightPicker as StaticLightPicker;
				trace(_lightPicker);
				Bounds.getMeshBounds(_scene.getChildAt(i) as Mesh);
				var ballShape:AWPSphereShape = new AWPSphereShape(Bounds.width / 2);
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
				_scene.getChildAt(i).visible = false;
			}else if(_scene.getChildAt(i).name == "wall_left"){
				Bounds.getMeshBounds(_scene.getChildAt(i) as Mesh);
				var wallLeftShape:AWPBoxShape = new AWPBoxShape(Bounds.width,Bounds.height,Bounds.depth);
				var wallLeftBody:AWPRigidBody = new AWPRigidBody(wallLeftShape,_scene.getChildAt(i));
				wallLeftBody.friction = 0.1;
				wallLeftBody.restitution = 0.9;
				wallLeftBody.position =  _scene.getChildAt(i).scenePosition;
				_physics.addRigidBody(wallLeftBody);
				_scene.getChildAt(i).visible = false;
			}else if(_scene.getChildAt(i).name == "floor"){
				Bounds.getMeshBounds(_scene.getChildAt(i) as Mesh);
				var floorShape:AWPBoxShape = new AWPBoxShape(Bounds.width,Bounds.height,Bounds.depth);
				var floorBody:AWPRigidBody = new AWPRigidBody(floorShape,_scene.getChildAt(i));
				floorBody.position =  _scene.getChildAt(i).scenePosition;
				_physics.addRigidBody(floorBody);
			}else if(_scene.getChildAt(i).name.indexOf("boundary") != -1){
				_scene.getChildAt(i).visible = false;
				Bounds.getMeshBounds(_scene.getChildAt(i) as Mesh);
				var boundaryShape:AWPBoxShape = new AWPBoxShape(Bounds.width,Bounds.height,Bounds.depth);
				var boundaryBody:AWPRigidBody = new AWPRigidBody(boundaryShape);
				boundaryBody.friction = 0.1;
				boundaryBody.restitution = 0.9;
				boundaryBody.position =  _scene.getChildAt(i).scenePosition;
				_physics.addRigidBody(boundaryBody);
				_scene.getChildAt(i).visible = false;
			}
		}
		_view.width = 1136;
		_view.height = 640;
		setAccelerometer();
		testGeometry();
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		_stage3DProxy.addEventListener(Event.ENTER_FRAME, render);

	}

	private function mouseDownHandler(e:MouseEvent):void
	{
		lastPanAngle = _camController.panAngle;
		lastTiltAngle = _camController.tiltAngle;
		lastMouseX = stage.mouseX;
		lastMouseY = stage.mouseY;
		move = true;
		stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}
	private function onStageMouseLeave(e:Event):void
	{
		move = false;
		stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}
	private function mouseUpHandler(e:MouseEvent):void
	{
		move = false;
		stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
	}

	private function testGeometry():void {

		var v:Vector.<Point> = new Vector.<Point>();
		v.push(new Point(0,0), new Point(0,100),new Point(100,100),new Point(100,200));
		v.push(new Point(0,200), new Point(0,300),new Point(300,300),new Point(300,200));
		v.push(new Point(200,200), new Point(200,100),new Point(300,100),new Point(300,0));

		var triangles:Vector.<Vector.<Point>> = EarClipper.triangulate(v);

		trace("yo")
		trace(triangles)

		var container:Sprite = new Sprite();
		container.x = 10;
		container.y = 10;
		stage.addChild(container);

		var coords:Vector.<Number> = new Vector.<Number>();

		for(var i:uint = 0 ; i < triangles.length ; i++){
			for(var j:uint = 0 ; j < triangles[i].length ; j++){
				coords.push(triangles[i][j].x, triangles[i][j].y);
			}
			//coords.push(triangles[i].x, triangles[i].y);
		}

		container.graphics.lineStyle(1, 0x00cc00);
		//container.graphics.beginFill(0x00cc00);
		container.graphics.drawTriangles(coords);
		container.graphics.endFill();



		trace(triangles);

		_container = new ObjectContainer3D();
		_camController = new HoverController(_view.camera, _container, 150, 10, 1000);

		var geom:Geometry = new Geometry();

		var subgeometry:SubGeometry = new SubGeometry();
		// A list of vertex positions - Numbers
		var verts:Vector.<Number> = new Vector.<Number>();

		verts.push(-512, 0, 512);
		verts.push(512, 0, 512);
		verts.push(-512, 0, 162);

		verts.push(512, 0, 162);

		verts.push(-162, 0, 162);
		verts.push(162, 0, 162);
		verts.push(-162, 0, -162);

		verts.push(162, 0, -162);

		verts.push(-512, 0, -162);
		verts.push(-54, 0, -162);
		verts.push(-512, 0, -512);

		verts.push(-54, 0, -512);

		verts.push(54, 0, -162);
		verts.push(512, 0, -162);
		verts.push(54, 0, -512);

		verts.push(512, 0, -512);

		verts.push(-54, 0, -162);
		verts.push(54, 0, -162);
		verts.push(-54, 0, -270);

		verts.push(54, 0, -270);

		verts.push(-54, 0, -404);
		verts.push(54, 0, -404);
		verts.push(-54, 0, -512);

		verts.push(54, 0, -512);


//		verts.push(-100,50,0); // 0 vert position
//		verts.push(-100,-50,0); // 1 vert position
//		verts.push(100,50,0); // 2 vert position
//		verts.push(100,-50,0); // 3 vert position
		// A list of UV coordinates - between 0 and 1
//		var uvs:Vector.<Number> = new Vector.<Number>();
//		uvs.push(0,0);
//		uvs.push(0,1);
//		uvs.push(1,0);
//		uvs.push(1,1);
		// A list of indices - whole, positive numbers
		var indices:Vector.<uint> = new Vector.<uint>();
		indices.push(0,1,2);
		indices.push(2,1,3);

		indices.push(4,5,6);
		indices.push(6,5,7);

		indices.push(8,9,10);
		indices.push(10,9,11);

		indices.push(12,13,14);
		indices.push(14,13,15);

		indices.push(16,17,18);
		indices.push(18,17,19);

		indices.push(20,21,22);
		indices.push(22,21,23);

//		indices.push(0,2,1); // linked in order
//		indices.push(1,2,3);
		// Update the subgeometry with the verts, uvs and indices
		subgeometry.updateVertexData(verts);
//		subgeometry.updateUVData(uvs);
		subgeometry.updateIndexData(indices);
		geom.addSubGeometry(subgeometry);



		var mat:ColorMaterial = new ColorMaterial(0xcc0000);
		mat.lightPicker = _lightPicker;
		var mesh:Mesh = new Mesh(geom, mat);
		_container.addChild(mesh);
		_view.scene.addChild(_container);
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
			_accelerometer.addEventListener(AccelerometerEvent.UPDATE, onAccelerometer);
		}else{
			_joystick = new VirtualJoystick();
			_starling.stage.addChild(_joystick);
			_joystick.addEventListener(JoystickEvent.JOYSTICK_UPDATE, onJoystickUpdate)
		}

	}

	private function onJoystickUpdate(e:JoystickEvent):void
	{
		setOrientation(-e.velX * 0.5, e.velY * 0.5);
	}

	private function setOrientation(accelX:Number, accelY:Number):void
	{
		_force = new Vector3D();
		_force.x = -accelX * 10;
		_force.z = -accelY * 10;
	}


	private function onAccelerometer(e:AccelerometerEvent):void
	{
		setOrientation(e.accelerationX, e.accelerationY);
	}

	private function render(event:Event):void {
		_ballBody.applyCentralForce(_force);

		if (move) {
			_camController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
			_camController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
		}
		///_physicsDebug.debugDrawWorld();
		_physics.step(1/60);
		_view.render();
		_starling.nextFrame();
	}
}
}
