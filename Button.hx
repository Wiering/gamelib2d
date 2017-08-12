package gamelib2d;

import flash.Lib;
import flash.events.Event;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.ui.Multitouch;
import flash.events.TouchEvent;

class Button 
{
	var spr: Sprite;
	var key: Int;
	public var pressed: Bool;
	var oppositeButton: Button;
	var lastId: Int;
	public var visible: Bool;
	
	
	public static var actionFunction: Int -> Bool -> Void;
	
	static var buttonList: List<Button> = new List ();
	
	static inline var RELEASED_ALPHA = 0.2;
	static inline var PRESSED_ALPHA = (1.0 + RELEASED_ALPHA) / 2;
	
	
	
	
	public static function init ()
	{
		flash.ui.Multitouch.inputMode = flash.ui.MultitouchInputMode.TOUCH_POINT;
		
		Lib.current.addEventListener (TouchEvent.TOUCH_BEGIN, touchBegin);
		Lib.current.addEventListener (TouchEvent.TOUCH_MOVE, touchMove);
		Lib.current.addEventListener (TouchEvent.TOUCH_END, touchEnd);
		
	}
	
	public static function done ()
	{
		Lib.current.removeEventListener (TouchEvent.TOUCH_BEGIN, touchBegin);
		Lib.current.removeEventListener (TouchEvent.TOUCH_MOVE, touchMove);
		Lib.current.removeEventListener (TouchEvent.TOUCH_END, touchEnd);
	}
	
	private static function touchBegin (e: TouchEvent)
	{
		touchPoint (e.touchPointID, Std.int (e.stageX), Std.int (e.stageY), true);
	}
	
	private static function touchMove (e: TouchEvent)
	{
		touchPoint (e.touchPointID, Std.int (e.stageX), Std.int (e.stageY), true);
	}
	
	private static function touchEnd (e: TouchEvent)
	{
		touchPoint (e.touchPointID, Std.int (e.stageX), Std.int (e.stageY), false);
	}
	
	
	private static function touchPoint (id: Int, x: Int, y: Int, v: Bool)
	{
		for (b in buttonList)
			if (b.contains (x, y))
			{
				if (v)
					b.press ();
				else
					b.release ();
				b.lastId = id;
				return;
			}
		if (!v)
			for (b in buttonList)
				if (id == b.lastId)
					b.release ();
	}
	
	
	

	
	public function new ()
	{
		buttonList.add (this);
	}
	
	public function destroy ()
	{
		if (spr != null)
		{
			//spr.removeEventListener (TouchEvent.TOUCH_BEGIN, onTouchBegin);
			//spr.removeEventListener (TouchEvent.TOUCH_MOVE, onTouchMove);
			//spr.removeEventListener (TouchEvent.TOUCH_END, onTouchEnd);
			
			flash.Lib.current.removeChild (spr);
			spr = null;
		}
		buttonList.remove (this);
	}
	
	
	public function create (x: Int, y: Int, sx: Float, sy: Float, bd: BitmapData, k: Int, ?opposite: Button)
	{
		spr = new Sprite ();
		spr.addChild (new Bitmap (bd));
		spr.x = x;
		spr.y = y;
		spr.scaleX = sx;
		spr.scaleY = sy;
		
		oppositeButton = opposite;
		
		key = k;
		
		flash.Lib.current.addChild (spr);
		
		//spr.addEventListener (TouchEvent.TOUCH_BEGIN, onTouchBegin);
		//spr.addEventListener (TouchEvent.TOUCH_MOVE, onTouchMove);
		//spr.addEventListener (TouchEvent.TOUCH_END, onTouchEnd);
		
		spr.alpha = RELEASED_ALPHA;
		pressed = false;
		visible = true;
	}
	
	
	public function contains (x: Int, y: Int): Bool
	{
		return (x >= spr.x && x < spr.x + spr.width && y >= spr.y && y < spr.y + spr.height);
	}
	
	
	public function press ()
	{
		if (! pressed)
		{
			if (oppositeButton != null)
				if (oppositeButton.pressed)
					oppositeButton.release ();
			
			pressed = true;
			actionFunction (key, pressed);
			Keys.setKeyStatus (key, pressed);
		}
		show (visible);
	}
	
	public function release ()
	{
		if (pressed)
		{
			pressed = false;
			actionFunction (key, pressed);
			Keys.setKeyStatus (key, pressed);
		}
		show (visible);
	}
	
	
	/*
	private function onTouchBegin (e: TouchEvent)
	{
		press ();
	}
	
	private function onTouchMove (e: TouchEvent)
	{
		if (oppositeButton != null)
			if (e.stageX > oppositeButton.spr.x && e.stageX < oppositeButton.spr.x + oppositeButton.spr.width &&
				e.stageY > oppositeButton.spr.y && e.stageY < oppositeButton.spr.y + oppositeButton.spr.height)
			{
				onTouchEnd (e);
				oppositeButton.onTouchBegin (e);
			}
			
		//if (e.stageX < 0 || e.stageY < 0 || e.stageX > spr.width * spr.scaleX || e.stageY > spr.height * spr.scaleY)
		//	onTouchEnd (e);
	}
	
	private function onTouchEnd (e: TouchEvent)
	{
		release ();
	}
	*/
	
	public function show (b: Bool)
	{
		visible = b;
		if (visible)
		{
			if (pressed)
				spr.alpha = PRESSED_ALPHA;
			else
				spr.alpha = RELEASED_ALPHA;
		}
		else
			spr.alpha = 0;
	}
	
}