package gamelib2d;

import openfl.geom.ColorTransform;
import openfl.Lib;
import gamelib2d.Utils;
import gamelib2d.Def;
import openfl.geom.Matrix;

import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import openfl.display.Loader; 
import openfl.net.URLRequest;
import openfl.events.Event;

#if USE_TILESHEET
import openfl.display.Tilesheet;
#end

class TileSet
{
	static var tilesets: List<TileSet> = new List ();
	
	public static var gameUpScaleX: Int = 1;
	public static var gameUpScaleY: Int = 1;
	
	public var upScaleX: Int = 1;
	public var upScaleY: Int = 1;
	public var downScaleX: Float = 1.0;
	public var downScaleY: Float = 1.0;
	
	public static function scaledFillRect (bd: BitmapData, r: Rectangle, rgba: Int)
	{
		r.x *= gameUpScaleX;
		r.y *= gameUpScaleY;
		r.width *= gameUpScaleX;
		r.height *= gameUpScaleY;
		bd.fillRect (r, rgba);
	}
	
	public static function scaledSetPixel32 (bd: BitmapData, x: Int, y: Int, rgba: Int)
	{
		if (gameUpScaleX == 1 && gameUpScaleY == 1)
		{
			bd.setPixel32 (x, y, rgba);
		}
		else
		{
			var r: Rectangle = new Rectangle (x * gameUpScaleX, y * gameUpScaleY, gameUpScaleX, gameUpScaleY);
			bd.fillRect (r, rgba);
		}
	}
	
	private var mcContainer: Sprite;
	//private var mcLoader: Bitmap;

	private var bitmap: Array<BitmapData>;
	
	public var tsdata: TileSetData;

	public var name: String;
	public var tileW: Int;
	public var tileH: Int;
	public var scaledTileW: Int;
	public var scaledTileH: Int;
	public var numTilesX: Int;
	public var numTilesY: Int;
	public var numTiles: Int;

	public var seq: Array<Array<Int>>;
	public var seqCurFrame: Array<Int>;
	public var seqCurFrameCounter: Array<Int>;
	public var seqTotalFrames: Array<Int>;
	public var numSequences: Int;
	
	public var hasTransparency: Array<Bool>;
	
	public var ready: Bool;
	
	
#if USE_TILESHEET
	public var useDrawTiles: Bool;
	public static var tileSheet: Tilesheet;
	public static var megaTileSet: BitmapData;
	public static var megaTilePosX: Int;
	public static var megaTilePosY: Int;
	public static var megaTilePosNextY: Int;
	public static var megaTileCounter: Int;
	
	public static function clearTileSheet ()
	{
		megaTileSet = null;
		tileSheet = null;
	}
	
	public static function initMegaTileSet (sizeX: Int, sizeY: Int)
	{
		megaTileSet = new BitmapData (sizeX, sizeY, true, 0);
		megaTilePosX = 0;
		megaTilePosY = 0;
		megaTilePosNextY = 0;
		megaTileCounter = 0;
		
		tileSheet = new Tilesheet (megaTileSet);
	}
	
	private function addTileToMegaTileSet (tile: Int, m: Int): Rectangle
	{
		if (megaTilePosY + scaledTileH + 1 > megaTilePosNextY)
			megaTilePosNextY = megaTilePosY + scaledTileH + 1;
		if (megaTilePosX + scaledTileW + 1 > megaTileSet.width)
		{
			megaTilePosX = 0;
			megaTilePosY = megaTilePosNextY;
			megaTilePosNextY = megaTilePosY + scaledTileH;
			
			//trace(megaTilePosY);
		}
		var r: Rectangle = new Rectangle (megaTilePosX + 1, megaTilePosY + 1, scaledTileW, scaledTileH);
		megaTileSet.copyPixels (bitmap[m], getTileRect (tile), new Point (r.x, r.y));
		megaTilePosX += scaledTileW + 1;
		return r;
	}
	
	public var megaTileRect: Array<Array<Rectangle>>;
	public var megaTileNumber: Array<Array<Int>>;
	
	public function addToMegaTileSet ()
	{
		megaTileRect = new Array ();
		megaTileNumber = new Array ();
		for (m in 0...4)
			if (bitmap[m] != null)
			{
				megaTileRect[m] = new Array ();
				megaTileNumber[m] = new Array ();
				for (k in 0...numTiles)
				{
					var r: Rectangle = addTileToMegaTileSet (k, m);
					
					//tileSheet.addTileRect (r, new Point (r.x + r.width / 2, r.y + r.height / 2));
					tileSheet.addTileRect (r);
					
					megaTileRect[m].push (r);
					megaTileNumber[m].push (megaTileCounter++);
				}
			}
		useDrawTiles = true;
	}
	
	public static function addTileToDraw (l: Layer, s: Sprite, x: Float, y: Float, tile: Int, alpha: Float, size: Float)
	{
		if (l == null) return;
		if (l.spriteOrder == null) return;
		var n = -1;
		for (i in 0...l.spriteOrder.length)
		{
			if (l.spriteOrder[i] == s)
				n = i;
		}
		if (n == -1) 
		{
			//trace (s);
			//Def.debugStr = "" + s;
			return;
		}
		if (l.tileSheetData[n] == null) l.tileSheetData[n] = new Array ();
		l.tileSheetData[n].push (x);
		l.tileSheetData[n].push (y);
		l.tileSheetData[n].push (tile);
		l.tileSheetData[n].push (size);
		l.tileSheetData[n].push (alpha);
	}
	
	public static function drawTiles (layer: Layer)
	{
		layer.lyr.graphics.clear ();
		
		var af: Array<Float> = new Array ();
		for (a in layer.tileSheetData)
		{
			if (a != null)
				for (f in a)
					af.push (f);
		}
		
		tileSheet.drawTiles (layer.lyr.graphics, af, false, Tilesheet.TILE_SCALE + Tilesheet.TILE_ALPHA);  //  + Tilesheet.TILE_BLEND_ADD
	}
#end

	public function new (mc)
	{
		mcContainer = mc;
		tilesets.add (this);
		ready = false;
	}

	public function clear ()
	{
		tilesets.remove (this);
		
		//if (mcContainer != null && mcLoader != null) 
		//	mcContainer.removeChild (mcLoader);
		//mcLoader = null;
		
		if (bitmap != null)
		{
			if (bitmap[0] != null) bitmap[0].dispose ();
			if (bitmap[1] != null) bitmap[1].dispose ();
			if (bitmap[2] != null) bitmap[2].dispose ();
			if (bitmap[3] != null) bitmap[3].dispose ();
		}
		bitmap = null;
		seq = null;
		seqCurFrame = null;
		seqCurFrameCounter = null;
		seqTotalFrames = null;
		ready = false;
	#if USE_TILESHEET
		megaTileRect = null;
	#end
	}

	
	public function createFromBitmapData (bd: BitmapData, ?tileWidth: Int = 0, ?tileHeight: Int = 0)
	{
		
		if (tileWidth * tileHeight == 0)
		{
			tileW = bd.width;
			tileH = bd.height;
			numTilesX = 1;
			numTilesY = 1;
			numTiles = 1;
		}
		else
		{
			tileW = tileWidth;
			tileH = tileHeight;
			numTilesX = Std.int ((bd.width + tileW - 1) / tileW);
			numTilesY = Std.int ((bd.height + tileH - 1) / tileH);
			numTiles = numTilesX * numTilesY;
		}
		bitmap = new Array ();
		bitmap[0] = bd;
		bitmap[1] = bd;
		bitmap[2] = bd;
		bitmap[3] = bd;
		
		numSequences = 0;
		seq = [];
		//seqCurFrame = new Array ();
		//seqCurFrameCounter = new Array ();
		//seqTotalFrames = new Array ();
		
		scaledTileW = tileW * upScaleX;
		scaledTileH = tileH * upScaleY;
		
		ready = true;
	}
	
	
	public function createSequences (seqData: Array<Array<Int>>)
	{
		numSequences = seqData.length;
		seq = seqData;
		
		seqCurFrame = new Array ();
		seqCurFrameCounter = new Array ();
		seqTotalFrames = new Array ();

		for (i in 0...numSequences)
		{
			seqCurFrame[i] = -1;
			seqCurFrameCounter[i] = 0;
			seqTotalFrames[i] = 0;
			for (j in 0...seq[i].length)
				if (j % 3 == 1)
					seqTotalFrames[i] += seq[i][j] + 1;
		}
	}
	
	
	private function createFlippedBitmaps ()
	{
		for (k in 0...numTiles)
		{
			var r = getTileRect (k);
			if (bitmap[1] != null)
				for (i in 0...scaledTileW)
					bitmap[1].copyPixels (bitmap[0], new Rectangle (r.x + scaledTileW - 1 - i, r.y, 1, scaledTileH), new Point (r.x + i, r.y));
			if (bitmap[2] != null)
				for (j in 0...scaledTileH)
					bitmap[2].copyPixels (bitmap[0], new Rectangle (r.x, r.y + scaledTileH - 1 - j, scaledTileW, 1), new Point (r.x, r.y + j));
			if (bitmap[3] != null)
				for (i in 0...scaledTileW)
					bitmap[3].copyPixels (bitmap[2], new Rectangle (r.x + scaledTileW - 1 - i, r.y, 1, scaledTileH), new Point (r.x + i, r.y));
		}
	}
	
	
	public function reloadBitmap ()
	{
		var bmp = tsdata.getBitmap ();
		if (bmp != null)
			if (downScaleX != 1.0 || downScaleY != 1.0)
			{
				var r: Rectangle = bitmap[0].rect;
				var m: Matrix = new Matrix();
				m.scale (downScaleX, downScaleY);
				bitmap[0].fillRect (r, 0);
				bitmap[0].draw (bmp.bitmapData, m);
			}
			else
				if (upScaleX == 1 && upScaleY == 1)
					bitmap[0].copyPixels (bmp.bitmapData, new Rectangle (0, 0, Std.int (bmp.width), Std.int (bmp.height)), new Point (0, 0));
				else
				{
					var r: Rectangle = new Rectangle (0, 0, upScaleX, upScaleY);
					for (y in 0...Std.int (bmp.height))
					{
						r.y = y * upScaleY;
						for (x in 0...Std.int (bmp.width))
						{
							r.x = x * upScaleX;
							var rgba = bmp.bitmapData.getPixel32 (x, y);
							bitmap[0].fillRect (r, rgba);
							//for (j in 0...upScaleY)
							//	for (i in 0...upScaleX)
							//		bitmap[0].setPixel32 (x * upScaleX + i, y * upScaleY + j, rgba);
						}
					}
				}
	}
	
	
	public function init (data: TileSetData, ?fh: Bool = true, ?fv: Bool = true)
	{
		ready = false;
		
		name = data.name;
		
		tileW = data.tileW;
		tileH = data.tileH;
		
		numTilesX = data.numTilesX;
		numTilesY = data.numTilesY;
		numTiles = data.numTiles;

		if (downScaleX != 1.0 || downScaleY != 1.0)
		{
			tileW = Std.int (tileW * downScaleX);
			tileH = Std.int (tileH * downScaleY);
		}
		scaledTileW = tileW * upScaleX;
		scaledTileH = tileH * upScaleY;

		bitmap = new Array ();
		
		hasTransparency = new Array ();

		numSequences = 0;
		
		tsdata = data;

//#if js
//		var loader: Loader = new Loader();
//		loader.contentLoaderInfo.addEventListener (Event.COMPLETE, loadComplete);
//		loader.load (new URLRequest(".\\gfx\\" + tsdata.name + ".png"));
//#end

//#if flash
		//mcLoader = data.getBitmap ();
//		loadComplete (null);
//#end
//	}
	
//	private function loadComplete (e: Event)
//	{
//#if js
//		mcLoader = new Bitmap (e.target.loader.contentLoaderInfo.content.bitmapData);
//#end
		
		var w = data.numTilesX * scaledTileW;
		var h = data.numTilesY * scaledTileH;
		
		// these are for mirrored and upsidedown copies of the tileset
		//bitmap[0] = new BitmapData (Std.int (mcLoader.width), Std.int (mcLoader.height), true, 0x0);
		//bitmap[1] = new BitmapData (Std.int (mcLoader.width), Std.int (mcLoader.height), true, 0x0);
		//bitmap[2] = new BitmapData (Std.int (mcLoader.width), Std.int (mcLoader.height), true, 0x0);
		//bitmap[3] = new BitmapData (Std.int (mcLoader.width), Std.int (mcLoader.height), true, 0x0);
		
		bitmap[0] = new BitmapData (w, h, true, 0x0);
		if (fh) bitmap[1] = new BitmapData (w, h, true, 0x0);
		if (fv) bitmap[2] = new BitmapData (w, h, true, 0x0);
		if (fh && fv) bitmap[3] = new BitmapData (w, h, true, 0x0);
		
		//if (mcLoader != null)
		//	bitmap[0].copyPixels (mcLoader.bitmapData, new Rectangle (0, 0, Std.int (mcLoader.width), Std.int (mcLoader.height)), new Point (0, 0));
		reloadBitmap ();
		
		createFlippedBitmaps ();
		
		for (k in 0...numTiles)
		{
			var r = getTileRect (k);
			hasTransparency[k] = false;
			for (i in 0...scaledTileW)
			{
				if (! hasTransparency[k])
					for (j in 0...scaledTileH)
						if (Std.int (bitmap[0].getPixel32 (Std.int (r.x) + i, Std.int (r.y) + j) & 0xFF000000) != Std.int (0xFF000000))    // fixed, was:  == 0
							hasTransparency[k] = true;
			}
		}
		
		//mcLoader = null;

		createSequences (tsdata.seq ());
		
		//bmp = new nme.display.Bitmap (nme.Assets.getBitmapData ("assets/gfx/WideTest.png"));
		//bmp.scaleX = 2.0;
		//bmp.scaleY = 2.0;
		//bmp.x = -1;
		//bmp.y = -1;
		//nme.Lib.current.addChild (bmp);
		
	#if USE_TILESHEET
		megaTileRect = null;
		useDrawTiles = false;
	#end		
		
		ready = true;
	}
	public var bmp: Bitmap;
	
	
	// function recolor (bd: BitmapData, r: Rectangle): BitmapData
	// ...
	// ts.editPixels (recolor);
	
	public function editPixels (f: BitmapData -> Rectangle -> BitmapData, ?frame: Int)
	{
		var bd: BitmapData;
		var r: Rectangle;
		if (frame == null) frame = -1;
		for (l in 0...4)
		{
			if (bitmap[l] != null)
				for (k in 0...numTiles)
					if ((k == frame) || (frame == -1))
					{
						r = getTileRect (k);
						bd = new BitmapData (scaledTileW, scaledTileH, true, 0);
						bd.copyPixels (bitmap[l], r, new Point (0, 0));
						bd = f (bd, new Rectangle (0, 0, scaledTileW, scaledTileH));
						bitmap[l].copyPixels (bd, new Rectangle (0, 0, scaledTileW, scaledTileH), new Point (r.x, r.y));
					}
		}
	}
	
	public function slowColorTransform (ct: ColorTransform)
	{
		var bd: BitmapData = bitmap[0];
		
		var rm: Float = (ct.redMultiplier);
		var gm: Float = (ct.greenMultiplier);
		var bm: Float = (ct.blueMultiplier);
		var am: Float = (ct.alphaMultiplier);
		
		var ro: Int = Std.int (ct.redOffset);
		var go: Int = Std.int (ct.greenOffset);
		var bo: Int = Std.int (ct.blueOffset);
		var ao: Int = Std.int (ct.alphaOffset);
		
		for (j in 0...bd.height)
			for (i in 0...bd.width)
			{
				var rgba = bd.getPixel32 (i, j);
				if (rgba & 0xFF000000 != 0)
				{
					var r = Std.int (ro + rm * ((rgba >> 16) & 0xFF));
					var g = Std.int (go + gm * ((rgba >> 8) & 0xFF));
					var b = Std.int (bo + bm * ((rgba) & 0xFF));
					var a = Std.int (ao + am * ((rgba >> 24) & 0xFF));
					
					bd.setPixel32 (i, j, Utils.rgba (r, g, b, a));
				}
			}
		
		createFlippedBitmaps ();
	}
	
	public function getTileRect (n: Int): Rectangle
	{
		var tileX: Int = Utils.safeMod (n, numTilesX);
		var tileY: Int = Std.int (n / numTilesX);
		return new Rectangle (tileX * scaledTileW, tileY * scaledTileH, scaledTileW, scaledTileH);
	}

	public function drawTile (surface: BitmapData, x: Int, y: Int, n: Int, m: Int)
	{
		if (m > 0)
			if (bitmap[m] == null)
				return;
		//surface.fillRect(getTileRect(n), 0xFF5080CC);
		surface.copyPixels (bitmap[m], getTileRect (n), new Point (x, y));
	}
	
	public function getTileBD (n: Int, ?m: Int = 0): BitmapData
	{
		var bd: BitmapData = new BitmapData (scaledTileW, scaledTileH, true, 0);
		if (n < 0) n = getAnimationFrame (( -n) - 1, 0) - 1;
		drawTile (bd, 0, 0, n, m);
		return bd;
	}

	public function runSequences ()
	{
		if (numSequences > 0)
			for (i in 0...numSequences)
#if neko
				if (seqCurFrameCounter[i] != null)
#end
					if (--seqCurFrameCounter[i] < 0)
					{
						seqCurFrame[i]++;
						if (3 * seqCurFrame[i] >= seq[i].length)
							seqCurFrame[i] = 0;
						seqCurFrameCounter[i] = seq[i][3 * seqCurFrame[i] + 1];
					}
	}

	public function GetSequenceFrame (n: Int)
	{
		return seq[n][3 * seqCurFrame[n]];
	}

	public function GetSequenceFrameBounds (n: Int)
	{
		return seq[n][3 * seqCurFrame[n] + 2];
	}

	public function getAnimationFrameCount (n: Int)
	{
		if (n < 0 || n > numSequences - 1)
			return 0;
		else
			return seqTotalFrames[n];
	}
  
	public function getAnimationFrame (n: Int, time: Int)	// n = 0, 1, 2, ...
	{
		var tile: Int = 1;
		
		if (n >= numSequences)
			return n + 1;  // bugfix
			
		var i = time % seqTotalFrames[n];
		while ((i > seq[n][tile]) && (tile + 3 < seq[n].length))
		{
			i -= seq[n][tile] + 1;
			tile += 3;
		}
		// bnds = Seq[n][tile + 1]
		return seq[n][tile - 1];
	}

	public static function iterator ()
	{
		return tilesets.iterator ();
	}
	
}
