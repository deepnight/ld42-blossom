import dn.Process;

class Main extends dn.Process {
	public static var ME : Main;

	public function new() {
		super();
		ME = this;
		createRoot(Boot.ME.s2d);
        root.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		Assets.init();
		new Console();
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.font);
		delayer.addF(startGame,1);
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

		Const.SCALE = M.floor( w() / (25*Const.GRID) );
		root.scaleX = root.scaleY = Const.SCALE;

		// cached.width = M.ceil(Boot.ME.s2d.width/cached.scaleX);
		// cached.height = M.ceil(Boot.ME.s2d.height/cached.scaleY);
	}

	override public function update() {
		super.update();
	}
}

