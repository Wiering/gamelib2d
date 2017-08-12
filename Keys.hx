package gamelib2d;

import gamelib2d.Def;

class Keys
{
	private static var keyStatus: Array<Bool>;
	private static var NUM_KEYS: Int = 256;

	public static function init ()
	{
		keyStatus = new Array ();
		for (i in 0...NUM_KEYS)
			keyStatus[i] = false;
	}

	public static function setKeyStatus (key: UInt, status: Bool)
	{
		if (Std.int (key) < NUM_KEYS) 
			keyStatus[key] = status;
	}

	public static function keyIsDown (key: UInt, ?reset: Bool = false): Bool
	{
		if (Std.int (key) < NUM_KEYS)
		{
			var result = keyStatus[key];
			if (reset)
				keyStatus[key] = false;
			return result;
		}
		else
			return false;
	}

}
