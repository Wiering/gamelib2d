package gamelib2d;

import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Sprite;
import gamelib2d.TileSet;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse; 

class QuickIcon
{
	static var iconlist: List<QuickIcon> = new List ();
	static var sprScreen: Sprite;
	
	public var name: String;
	public var checked: Bool;
	public var selected: Bool;
	var ts: TileSet;
	var posX: Int;
	var posY: Int;
	var tileUnchecked: Int;
	var tileChecked: Int;
	var bmp: Bitmap;
	var bd: BitmapData;
	
	
	public static function initClass (screen: Sprite)
	{
		screen.stage.addEventListener (Event.MOUSE_LEAVE, mouseLeave);
		screen.stage.addEventListener (MouseEvent.MOUSE_MOVE, mouseMove);
		
	}
	
	static function mouseLeave (ev: Event)
	{
		for (qi in QuickIcon)
			qi.hide ();
	}
	
	static function mouseMove (ev: Event)
	{
		for (qi in QuickIcon)
			qi.show ();
	}
	
	
	public function new (screen: Sprite)
	{
		sprScreen = screen;
		iconlist.add (this);
	}
	
	public function init (strName: String, x: Int, y: Int, tileset: TileSet, uncheckedTile: Int, checkedTile: Int, defaultChecked: Bool)
	{
		name = strName;
		posX = x;
		posY = y;
		ts = tileset;
		tileUnchecked = uncheckedTile;
		tileChecked = checkedTile;
		checked = defaultChecked;
		bd = new BitmapData (ts.tileW, ts.tileH, true, 0);
		redraw ();
		bmp = new Bitmap (bd);
		bmp.x = x;
		bmp.y = y;
		hide ();
		sprScreen.addChild (bmp);
	}
	
	public function redraw ()
	{
		ts.drawTile (bd, 0, 0, checked? tileChecked : tileUnchecked, 0);
	}
	
	public function remove ()
	{
		sprScreen.removeChild (bmp);
		bmp = null;
		bd = null;
		iconlist.remove (this);
	}
	
	public static function removeAll ()
	{
		for (qi in QuickIcon)
			qi.remove ();
	}
	
	public function hide ()
	{
		bmp.alpha = 0.25;
	}
	
	public function show ()
	{
		var mx: Int = Std.int (sprScreen.mouseX);
		var my: Int = Std.int (sprScreen.mouseY);
		
		selected = false;
		if (mx < 0 || my < 0 || mx >= Def.STAGE_W || my >= Def.STAGE_H)
			hide ();
		else
		{
			if (mx >= posX && mx < posX + ts.tileW && my >= posY && my < posY + ts.tileH)
			{
				selected = true;
				bmp.alpha = 1.00;
			}
			else
				bmp.alpha = 0.65;
		}
	}
	
	public function run ()
	{
	}
	
	public static function iterator ()
	{
		return iconlist.iterator ();
	}
}