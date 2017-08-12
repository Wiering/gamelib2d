package gamelib2d;

import openfl.display.Bitmap;

class TileSetData
{
	public var name: String;
	public var tileW: Int;
	public var tileH: Int;
	public var numTilesX: Int;
	public var numTilesY: Int;
	public var numTiles: Int;
	public var numSequences: Int;

	public function getBitmap (): Bitmap
	{
		return null;
	}

	public function seq (): Array<Array<Int>>
	{
		return [[0]];
	}

}
