package {
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
import flash.events.StageOrientationEvent;
import flash.geom.Point;
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

	[Embed(source = "/assets/stars.jpg")]
	private var SpaceTexture:Class;
//	[Embed(source = "assets/endPoint.JPG")]
//	private var EndPointTexture:Class;
//	[Embed(source = "assets/tile.jpg")]
//	private var TileTexture:Class;
//	[Embed(source = "assets/background.jpg")]
//	private var BackgroundTexture:Class;

	private var _genome:Genome2D;
	private var _physics:GNapePhysics;

	private var _balls:Vector.<Body> = new Vector.<Body>();

	private var _orientation:Vec2 = new Vec2();
	private var _accelerometer:Accelerometer;
	private var _joystick:VirtualJoystick;

	private var isAccelSupported:Boolean = false;

	private var _endPointBody:Body;
	private var _ballBody:Body;
	private var _ballSprite:GNode;

	private var _attractionForce:Number = 50;

	private var _space:Space;

	private var _spaceSprite:GSprite;

	private static const BOUNDARIES_SIZE:Number = 8;

	private var _emptySpaces:Vector.<Rectangle> = new Vector.<Rectangle>();
	private var _gameOver:Boolean = false;
	private var _loopEnd:Boolean = false;

    public function BallFall() {
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

		stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging );

		var config:GContextConfig = new GContextConfig(new Rectangle(0,0,stage.fullScreenWidth,stage.fullScreenHeight), stage);

		GStats.visible = true;
		_genome = Genome2D.getInstance();
		_genome.backgroundAlpha = 1;
		_genome.backgroundBlue = 140/255;
		_genome.backgroundGreen = 63/255;
		_genome.backgroundRed = 0;
		_genome.onInitialized.addOnce(onContext);
		_genome.init(config);
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
			_joystick = new VirtualJoystick(setOrientation);
		}

	}

	private function setOrientation(accelX:Number, accelY:Number):void
	{
		_orientation.x = -accelX * 5000;
		_orientation.y = accelY * 5000;
	}

	private function onChange(e:AccelerometerEvent):void
	{
		setOrientation(e.accelerationX, e.accelerationY);
	}

	private function onContext():void {
		GAtlasManager.init();

		//GTextureFactory.createFromEmbedded("ballTexture",BallTexture);

		_physics = _genome.root.addComponent(GNapePhysics) as GNapePhysics;

		createStaticBoundary(new Rectangle(88,0,960, stage.fullScreenHeight), 100, Material.glass());

		//createLevelTexture();

		createBackground();

		createEndPoint();
//
		createBall(568, 320);



		_genome.onPreRender.add(onPreRender);
//
		setAccelerometer();
	}

	private function createBackground():void {
		GTextureFactory.createFromEmbedded("spaceTexture",SpaceTexture,"bgra",true);
		_spaceSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
		_spaceSprite.textureId = "spaceTexture";
		_spaceSprite.node.transform.alpha = 0.999999;
		_spaceSprite.node.maskRect = new Rectangle((1136 - 960) / 2, 0, 960, 640);
		//_spaceSprite.texture.repe = true;
		_spaceSprite.node.transform.setPosition(568,320);
		_genome.root.addChild(_spaceSprite.node);

		var bg:GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
//		bg.node.transform.alpha = 0.75;
		bg.texture = GAtlasManager.mainAtlas.getSubTexture("bgTexture");
		bg.node.transform.setPosition(568,320);
		_genome.root.addChild(bg.node);

		var rect1:Rectangle = new Rectangle(288,0,560, 224);
		var rect2:Rectangle = new Rectangle(288, 416, 560, 224);
		_emptySpaces.push(rect1,rect2);
	}

//	private function createLevelTexture():void {
//		var texture:GTexture = GTextureFactory.createFromEmbedded("tileTexture",TileTexture);
//		texture.g2d_filteringType = GTextureFilteringType.LINEAR;
//		var renderTexture:GTexture = GTextureFactory.createRenderTexture("rTexture",512,512);
//		var context:IContext = _genome.getContext();
//
//		renderTexture.g2d_filteringType = GTextureFilteringType.LINEAR;
//		context.begin(1,1,1,1);
//		context.setRenderTarget(renderTexture);
//
//		for(var i:Number = 0 ; i < 32 ; i++){
//			for(var j:Number = 0 ; j < 32 ; j++){
//				context.draw(texture,i*16+8,j*16+8);
//			}
//		}
//
//		context.end();
//
//		var bg:GSprite = GNodeFactory.createNodeWithComponent(GSprite) as GSprite;
//		trace(renderTexture.width);
//		trace(renderTexture.gpuWidth);
//		bg.textureId = "rTexture";
//		bg.node.transform.setPosition(256,256);
//		_genome.root.addChild(bg.node);
//	}

	private function createEndPoint():void {
		//var texture:GTexture = GTextureFactory.createFromEmbedded("endPointTexture",EndPointTexture);
		var endpointBody:GNapeStaticBody = GNodeFactory.createNodeWithComponent(GNapeStaticBody) as GNapeStaticBody;
		endpointBody.body.shapes.add(new Polygon(Polygon.box(64,64)));
		var sprite:GSprite = endpointBody.node.addComponent(GSprite) as GSprite;
		//endpointBody.body.setShapeMaterials(Material.rubber());
//		endpointBody.body.type = BodyType.STATIC;
//		sprite.textureId = "endPointTexture";
		sprite.texture = GAtlasManager.mainAtlas.getSubTexture("endpointTexture");
		sprite.texture.g2d_filteringType = GTextureFilteringType.LINEAR;
		endpointBody.x = 200;
		endpointBody.y = 200;
		_endPointBody = endpointBody.body;
		_genome.root.addChild(endpointBody.node);

	}

	private function onPreRender():void {
		//test
		if(!_gameOver){
			applyGyroForce();
			if(_gameOver = testEmptySpaces()){
				killBall();
			}
			testEndPoint();
		}

		_spaceSprite.texture.uvX += 0.0001;
		_spaceSprite.texture.uvY += 0.00005;
	}

	private function killBall():void {
		var direction:Vec2 = _ballBody.velocity;
		direction = direction.mul(0.25);
		trace(direction);
		trace(direction.length);
		var pos:Point = new Point(_ballBody.position.x + direction.x, _ballBody.position.y + direction.y);
		_ballBody.space = null;
		TweenMax.to(_ballSprite.transform,1, {x:pos.x, y:pos.y, scaleX:0, scaleY:0, ease:Linear.easeOut, onComplete:function():void{
			var particles:ExplosionParticles = GNodeFactory.createNodeWithComponent(ExplosionParticles) as ExplosionParticles;
			particles.node.transform.setPosition(pos.x, pos.y);
			_genome.root.addChild(particles.node);
		}});
	}

	private function testEmptySpaces():Boolean {
		for(var i:uint = 0 ; i < _emptySpaces.length ; i++){
			if(_emptySpaces[i].contains(_ballBody.position.x, _ballBody.position.y)){
				return true;
			}
		}
		return false;
	}

	private function testEndPoint():void{
		var dist:Number = Point.distance(new Point(_endPointBody.position.x, _endPointBody.position.y), new Point(_ballBody.position.x, _ballBody.position.y));//._endPointBody, _ballBody, Vec2.get(), Vec2.get());

		if(dist < 32&& dist > 2){
			var dx:Number = _endPointBody.position.x - _ballBody.position.x;
			var dy:Number = _endPointBody.position.y - _ballBody.position.y;

			var impulse:Vec2 = Vec2.weak(dx, dy);
			impulse.length = _attractionForce;
			_ballBody.applyImpulse(impulse);

		}else if(dist < 2){
			trace("gagné");
			_ballBody.position = _endPointBody.position;
		}
	}

	private function applyGyroForce():void{
		for each(var body:Body in _balls){
			body.force = _orientation;
		}
	}

	private function createStaticBoundary(p_rect:Rectangle, p_size:Number, p_material:Material = null):void {
		var body:Body = new Body(BodyType.STATIC);
		body.shapes.add(new Polygon(Polygon.rect(p_rect.x-p_size, p_rect.bottom, p_rect.width+p_size*2, p_size), p_material));
		body.shapes.add(new Polygon(Polygon.rect(p_rect.x-p_size, p_rect.y-p_size, p_rect.width+p_size*2, p_size), p_material));
		body.shapes.add(new Polygon(Polygon.rect(p_rect.x-p_size, p_rect.y-p_size, p_size, p_rect.height+p_size*2), p_material));
		body.shapes.add(new Polygon(Polygon.rect(p_rect.right, p_rect.y-p_size, p_size, p_rect.height+p_size*2), p_material));
		body.space = _physics.space;
	}

	private function createBall(p_x:Number, p_y:Number):void
	{
		var ball:GNapeDynamicBody = GNodeFactory.createNodeWithComponent(GNapeDynamicBody) as GNapeDynamicBody;
		ball.shape = new Circle(16);
		var sprite:GSprite = ball.node.addComponent(GSprite) as GSprite;
		ball.body.setShapeMaterials(Material.rubber());
		sprite.texture = GAtlasManager.mainAtlas.getSubTexture("ballTexture");
		sprite.texture.g2d_filteringType = GTextureFilteringType.LINEAR;
		ball.x = p_x;
		ball.y = p_y;
		_genome.root.addChild(ball.node);
		_balls.push(ball.body);

		_ballBody = ball.body;

		_ballSprite = ball.node;
	}

	private function onClick(event:MouseEvent):void {
		createBall(event.stageX,event.stageY);
	}

}
}
