import mt.Process;
import mt.MLib;

class Main extends mt.Process {
	public static var ME : Main;

	public function new() {
		super();
		ME = this;
		createRoot(Boot.ME.s2d);
        root.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		Assets.init();
		new Console();
		startGame();
		new mt.deepnight.GameFocusHelper(root, Assets.font);
	}

	public function startGame() {
		if( Game.ME!=null )
			Game.ME.destroy();
		createChildProcess(function(p) {
			if( Game.ME==null ) {
				new Game( new h2d.Object(root) );
				onResize();
				p.destroy();
			}
		});
	}

	override public function onResize() {
		super.onResize();

		Const.SCALE = MLib.floor( w() / (25*Const.GRID) );
		root.scaleX = root.scaleY = Const.SCALE;

		// cached.width = MLib.ceil(Boot.ME.s2d.width/cached.scaleX);
		// cached.height = MLib.ceil(Boot.ME.s2d.height/cached.scaleY);
	}

	override public function update() {
		super.update();
	}
}

