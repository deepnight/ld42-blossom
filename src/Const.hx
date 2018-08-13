class Const {
	public static var FPS = 60;
	public static var GRID = 16;
	public static var SCALE = 1.0;

	public static var UNIQ = 0;
	public static var INFINITE = 999999;

	static var _inc=0;
	public static var DP_BG = _inc++;
	public static var DP_FX_BG = _inc++;
	public static var DP_SMOKE = _inc++;
	public static var DP_TREE = _inc++;
	public static var DP_FRONT = _inc++;
	public static var DP_FX_FRONT = _inc++;
	public static var DP_UI = _inc++;
	public static var DP_TOP = _inc++;

	public static var BUY = 50;
	public static var SELL = Std.int(BUY*0.75);
	public static var BLOSSOM = 500;
}
