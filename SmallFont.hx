package gamelib2d;

import openfl.utils.ByteArray;
import gamelib2d.SmallFontData;
import openfl.display.BitmapData;

class SmallFont
{
	public static var baFON: ByteArray = null;
	
	
	public static function init ()
	{
		baFON = new ByteArray ();
		for (d in SmallFontData.data)
			baFON.writeByte (d);
	}
	
	public static function getCharBitmap (ascii: Int): ByteArray
	{
		if (baFON == null)
			init ();
		baFON.position = 3;
		var count: Int = baFON.readByte ();
		var n: Int = -1;
		for (i in 0...count)
		{
			if (baFON.readByte () == ascii)
			{
				n = i;
				break;
			}
		}
		if (n == -1)
			return null;
		else
		{
			var p: Int = 4 + count + (2 * n);
			baFON.position = p;
			p = 4 + count + (baFON.readByte () & 0xFF) + ((baFON.readByte () & 0xFF) << 8);
			baFON.position = p;
			count = baFON.readByte () * baFON.readByte ();
			var ba: ByteArray = new ByteArray ();
			baFON.position = 0;
			ba.writeBytes (baFON, p, 2 + count);
			ba.position = 0;
			return ba;
			
		}
	}
	
	public static function getStrWidth (msg: String, ?narrow: Int = 0): Int
	{
		var w: Int = 0;
		for (i in 0...msg.length)
		{
			var c: Int = msg.charCodeAt (i);
			w += getCharBitmap (c).readByte ();
			if (c == 32)
				w -= narrow;
		}
		return w;
	}
	
	
	public static function drawCharBitmap (surface: BitmapData, x: Int, y: Int, ba: ByteArray, c: Int): Int
	{
		ba.position = 0;
		var w: Int = ba.readByte ();
		var h: Int = ba.readByte ();
		for (j in 0...h)
			for (i in 0...w)
			{
				if (ba.readByte () != 0)
					surface.setPixel (x + i, y + j, c);
			}
		return w;
	}
	

	public static function writeStr (surface: BitmapData, x: Int, y: Int, s: String, color: Int, ?narrow: Int = 0)
	{
		for (i in 0...s.length)
		{
			var c: Int = s.charCodeAt (i);
			x += drawCharBitmap (surface, x, y, getCharBitmap (c), color);
			if (c == 32)
				x -= narrow;
		}
	}	
}
