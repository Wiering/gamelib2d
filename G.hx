package gamelib2d;

import flash.Lib;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.display.StageQuality;
#if flash
import flash.ui.GameInput;
import flash.ui.GameInputDevice;
import flash.events.GameInputEvent;
//import flash.ui.GameInputControl;
//import flash.system.Capabilities;
#else
import openfl.events.GameInputEvent;
#end

/*
class State
{
	public function onCreate ()
	{
		
	}
	
	public function onFrame ()
	{
		
	}
	
	public function onDraw ()
	{
		
	}
	
	public function onDestroy ()
	{
		
	}
	

	public static var curState: State = null;
	
	public static function setState (newState: State)
	{
		if (curState != null)
			curState.onDestroy ();
		Utils.gc ();
		curState = newState;
		if (curState != null)
			curState.onCreate ();
	}
	
	static function runState ()
	{
		if (curState != null)
			curState.onFrame ();
	}
	
	static function drawState ()
	{
		if (curState != null)
			curState.onDraw ();
	}
}
*/

class G
{
	public static var instance: G = null;
	
	public var screen: Sprite;
	private var firstTime: Bool;
	
	public var pause: Bool;
	public var ready: Bool;
	
	public static var maxFrames = 5;
	
#if flash
	//public static var gameInput: GameInput = new GameInput();
#end
	
	public function new ()
	{
		ready = false;
		firstTime = true;
		screen = new Sprite ();
		
		//screen.addEventListener (Event.ENTER_FRAME, onEnterFrame);
		Lib.current.addEventListener (Event.ENTER_FRAME, onEnterFrame);
		
		//nme.Lib.current.addChild ();
	/*
		var spr = new Sprite ();
		spr.addChild (new nme.display.Bitmap (nme.Assets.getBitmapData ("assets/gfx/Title.png")));
		spr.cacheAsBitmap = true;
		spr.x = -1;
		Lib.current.addChild (spr);
	*/
		//Lib.current.stage.quality = StageQuality.HIGH;
			
		instance = this;
	}
	
	
	public function initGame ()
	{
		// override this
	}
	
	
	public function initLevel ()
	{
		
		// override this
	}
	
	public function cleanUpLevel ()
	{
#if USE_TILESHEET
		TileSet.clearTileSheet ();
#end
		Utils.gc ();  
	}
	
	
	public function runGameLogic ()
	{
#if USE_TILESHEET
		Obj.sort ();
#end
	}
	
	public function drawGame ()
	{
		// override this
	}
	
	function onEnterFrame (e: Dynamic)
	{
		if (firstTime)
		{
			pause = false;
			
			flash.Lib.current.addChild (screen);
			
			
			Def.STAGE_W = screen.stage.stageWidth;
			Def.STAGE_H = screen.stage.stageHeight;
			screen.stage.scaleMode = flash.display.StageScaleMode.EXACT_FIT;
			
			Keys.init ();
			Lib.current.stage.addEventListener (KeyboardEvent.KEY_DOWN, onKeyDown);
			Lib.current.stage.addEventListener (KeyboardEvent.KEY_UP, onKeyUp);
			
			Lib.current.stage.addEventListener (MouseEvent.CLICK, onClick);
		
		#if flash
		//	if (gamepadDevice != null)
			{
		//		trace(gamepadDevice.name);
			}
		#else
			//Lib.current.stage.addEventListener (JoystickEvent.BUTTON_DOWN, onJoystickButtonDown);
		#end
			
			Timing.init (100);
			
			initGame ();
			
			firstTime = false;
		}
		
	//#if flash
		for (i in 0...Timing.logicFrames (maxFrames))
			if (!pause)
			{
			//	if (State.curState != null)
			//		State.curState.onFrame ();
			//	else
					runGameLogic ();  
			} 
	//#else
	//	if (!pause)
	//		runGameLogic();
	//#end
		
		//if (State.curState != null)
		//	State.curState.onDraw ();
		//else
			drawGame ();
	}

	function onKeyDown (event: KeyboardEvent)
	{
		var repeat: Bool = Keys.keyIsDown (event.keyCode);
		
		for (obj in Obj)
			if (obj.useKeyboard)
				if ((!repeat) || obj.objFlags.allowKeyboardRepeat)
					obj.onKeyDown (event.keyCode);
					
		Keys.setKeyStatus (event.keyCode, true);
	}
	
	function onKeyUp (event: KeyboardEvent)
	{
		Keys.setKeyStatus (event.keyCode, false);
		for (obj in Obj)
			if (obj.useKeyboard)
				obj.onKeyUp (event.keyCode);
	}
	
	function onClick (event: MouseEvent)
	{
		for (obj in Obj)
			if (obj.useMouse)
				if (obj.lastMouseOver)
					obj.onClick ();
	}
	
#if !(flash || js)
	function onJoystickButtonDown (event: GameInputEvent)
	{
		//trace (event.device + " " + event.id);
		trace (event.toString());
	}
#end
	
}
