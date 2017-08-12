package gamelib2d;

import flash.display.Sprite;
import gamelib2d.Def;
import gamelib2d.Obj;

class Actor extends Obj
{

	public var lastXPos: Float;
	public var lastYPos: Float;

	public var lastXV1: Float;
	public var lastYV1: Float;
	public var lastXV2: Float;
	public var lastYV2: Float;

	var stoppedX: Bool;
	var stoppedY: Bool;
	var stopped: Bool;
	
	var savePointX: Float;
	var savePointY: Float;
	var savePointDirLeft: Bool;
	
	var stopMovingSpeedX: Float;
	var stopMovingSpeedY: Float;
	
	var startScrollingH: Float;
	var startScrollingV: Float;
	var maxScrollXV: Float;
	var maxScrollYV: Float;

	var prioAnim: Int;
	var prioAnimTime: Int;
	
	
	override public function new (spr: Sprite)
	{
		super (spr);
		
		stopMovingSpeedX = 0.001;
		stopMovingSpeedY = 0.5;
		
		startScrollingH = Std.int (4 * Def.STAGE_W / 9);
		startScrollingV = Std.int (4 * Def.STAGE_H / 10);
		maxScrollXV = 4;
		maxScrollYV = 8;
	}
	
	override public function init (name: String, code: Int, par: Int, mapx: Int, mapy: Int, xp: Float, yp: Float, ts: TileSet,
									anim: Int, animflags: Int, ?lyr: Layer, ?flags: ObjectFlags)
	{
		super.init (name, code, par, mapx, mapy, xp, yp, ts, anim, animflags, lyr, flags);
		
		useKeyboard = true;
		
		saveLocation ();
		reset ();
	}
	
	override public function onFrame ()
	{
		lastXV2 = lastXV1;
		lastYV2 = lastYV1;
		lastXV1 = x - lastXPos;
		lastYV1 = y - lastYPos;

		lastXPos = x;
		lastYPos = y;

		stoppedX = (Math.abs (lastXV1) < stopMovingSpeedX);
		stoppedY = (Math.abs (lastYV1) < stopMovingSpeedY);
		stopped = (stoppedX && stoppedY);
	}
		
	public function saveLocation ()
	{
		savePointX = x;
		savePointY = y;
		savePointDirLeft = lastDirectionLeft;
	}
	
	public function restoreLocation ()
	{
		x = savePointX;
		y = savePointY;
		lastDirectionLeft = savePointDirLeft;
		reset ();
	}
	
	public function reset ()
	{
		lastXV1 = 0;
		lastYV1 = 0;
		lastXV2 = 0;
		lastYV2 = 0;

		lastXPos = x;
		lastYPos = y;
		
		speedX = 0;
		speedY = 0;
		
		createObjectFocus (startScrollingV, startScrollingH, startScrollingH, startScrollingV, maxScrollXV, maxScrollYV, true);
		
		prioAnim = -1;
		
		objFlags.autoMirrorLeftRight = true;
		objFlags.autoMirrorUpDown = false;
		objFlags.ignoreLevelBounds = false;
		levelBounds = { top: false, left: true, right: true, bottom: false };
	}
	
	override public function draw ()
	{
		if (prioAnim > -1)
		{
			if (--prioAnimTime >= 0)
				animation = prioAnim;
			else
				prioAnim = -1;
		}
		super.draw ();
	}
	
}