import mt.Process;
import mt.MLib;

class Main extends mt.Process {
	public static var ME : Main;

	public var cached : h2d.CachedBitmap;

	public function new() {
		super();
		ME = this;
		createRoot(Boot.ME.s2d);
		Assets.init();
		new Console();
		cached = new h2d.CachedBitmap(root, 1,1);
		cached.blendMode = None;
		new Game( new h2d.Sprite(cached) );
		onResize();
	}

	override public function onResize() {
		super.onResize();

		Const.SCALE = MLib.floor( w() / (30*Const.GRID) );
		cached.scaleX = cached.scaleY = Const.SCALE;

		cached.width = MLib.ceil(Boot.ME.s2d.width/cached.scaleX);
		cached.height = MLib.ceil(Boot.ME.s2d.height/cached.scaleY);
	}

	override public function update() {
		super.update();
	}
}

