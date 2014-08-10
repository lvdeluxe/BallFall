package
{
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.AccelerometerEvent;
import flash.sensors.Accelerometer;

public class AccelerometerTest extends Sprite
{
	private var ball:Sprite;
	private var accelerometer:Accelerometer;
	private var xSpeed:Number = 0;
	private var ySpeed:Number = 0;
	private const RADIUS = 20;

	public final function AccelerometerTest()
	{
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;

		createBall();

		if (Accelerometer.isSupported)
		{
			accelerometer = new Accelerometer();
			accelerometer.addEventListener(AccelerometerEvent.UPDATE, accUpdateHandler);
			stage.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
	}

	private final function createBall():void
	{
		ball = new Sprite();
		ball.graphics.beginFill(0xFF0000);
		ball.graphics.drawCircle(0, 0, RADIUS);
		ball.cacheAsBitmap = true;
		ball.x = stage.stageWidth / 2;
		ball.y = stage.stageHeight / 2;
		addChild(ball);
	}

	private final function enterFrameHandler(event:Event):void
	{
		event.stopPropagation();
		moveBall();
	}
	private final function moveBall():void
	{
		var newX:Number = ball.x + xSpeed;
		var newY:Number = ball.y + ySpeed;
		if (newX < 20)
		{
			ball.x = RADIUS;
			xSpeed = 0;
		}
		else if (newX > stage.stageWidth - RADIUS)
		{
			ball.x = stage.stageWidth - RADIUS;
			xSpeed = 0;
		}
		else
		{
			ball.x += xSpeed;
		}

		if (newY < RADIUS)
		{
			ball.y = RADIUS;
			ySpeed = 0;
		}
		else if (newY > stage.stageHeight - RADIUS)
		{
			ball.y = stage.stageHeight - RADIUS;
			ySpeed = 0;
		}
		else
		{
			ball.y += ySpeed;
		}
	}

	private final function accUpdateHandler(event:AccelerometerEvent):void
	{
		xSpeed -= event.accelerationX * 2;
		ySpeed += event.accelerationY * 2;
	}
}
}