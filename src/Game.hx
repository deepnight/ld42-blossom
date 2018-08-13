import mt.Process;
import mt.deepnight.Tweenie;
import mt.deepnight.Lib;
import mt.heaps.slib.*;
import mt.MLib;
import hxd.Key;
import Entity;

class Game extends mt.Process {
	public static var ME : Game;

	public var scroller : h2d.Layers;
	public var vp : Viewport;
	//public var fx : Fx;
	public var level : Level;
	//public var hero : en.Hero;
	var clickTrap : h2d.Interactive;
	var mask : h2d.Graphics;

	public var energy : Float;

	public var hud : h2d.Flow;
	public var treeRoot : en.Branch;
	//public var cm : mt.deepnight.Cinematic;

	public function new(ctx:h2d.Sprite) {
		super(Main.ME);

		ME = this;
		createRoot(ctx);
		//Console.ME.runCommand("+ bounds");

		//cm = new mt.deepnight.Cinematic(Const.FPS);

		scroller = new h2d.Layers(root);
		vp = new Viewport();
		//fx = new Fx();

		clickTrap = new h2d.Interactive(1,1,Main.ME.root);
		clickTrap.onPush = onMouseDown;
		clickTrap.enableRightButton = true;

		mask = new h2d.Graphics(Main.ME.root);
		mask.visible = false;
		mask.beginFill(0x0,1);
		mask.drawRect(0,0, 1, 1);
		energy = 100;

		hud = new h2d.Flow();
		root.add(hud, Const.DP_UI);
		hud.horizontalSpacing = 1;

		level = new Level();
		var pt = level.getPixel(0x00FF00);
		treeRoot = new en.Branch(pt.cx,pt.cy);

		onResize();
	}

	public function updateHud() cd.setS("invalidateHud",Const.INFINITE);
	function _updateHud() {
		if( !cd.has("invalidateHud") )
			return;

		hud.removeChildren();
		cd.unset("invalidateHud");

		// TODO render HUD

		onResize();

	}

	function onMouseDown(ev:hxd.Event) {
		var m = getMouse();

		var none = true;
		for(e in Entity.ALL)
			if( e.isAlive() && m.cx==e.cx && m.cy==e.cy ) {
				none = false;
				e.onClick(ev.button);
			}

		if( none && ev.button==0 && energy>50 ) {
			var dh = new DecisionHelper(en.Branch.ALL);
			dh.keepOnly( function(e) return e.isAlive() && MLib.fabs(e.cx-m.cx)<=1 && MLib.fabs(e.cy-m.cy)<=1 );
			dh.score( function(e) return -e.distPxFree(m.x,m.y)*0.1 );
			dh.score( function(e) return -e.getTreeDepth()*2);
			dh.score( function(e) return e.isBranchEnd() ? -3 : 0);
			var best = dh.getBest();
			if( best!=null ) {
				energy-=50;
				new en.Branch(m.cx, m.cy, best);
			}
		}
	}

	override public function onResize() {
		super.onResize();
		clickTrap.width = w();
		clickTrap.height = h();

		hud.x = Std.int( w()*0.5/Const.SCALE - hud.outerWidth*0.5 );
		hud.y = 4;

		mask.scaleX = w();
		mask.scaleY = h();
	}

	override public function onDispose() {
		super.onDispose();

		mask.remove();
		clickTrap.remove();

		//for(e in Entity.ALL)
			//e.destroy();
		//gc();

		if( ME==this )
			ME = null;
	}

	function gc() {
		var i = 0;
		while( i<Entity.ALL.length )
			if( Entity.ALL[i].destroyed )
				Entity.ALL[i].dispose();
			else
				i++;
	}

	override function postUpdate() {
		super.postUpdate();
		_updateHud();
	}

	public function getMouse() {
		var gx = hxd.Stage.getInstance().mouseX;
		var gy = hxd.Stage.getInstance().mouseY;
		var x = Std.int( gx/Const.SCALE-scroller.x );
		var y = Std.int( gy/Const.SCALE-scroller.y );
		return {
			x : x,
			y : y,
			cx : Std.int(x/Const.GRID),
			cy : Std.int(y/Const.GRID),
		}
	}

	//public function hasCinematic() {
		//return !cm.isEmpty();
	//}

	public function controlsLocked() {
		return Console.ME.isActive();
	}

	override public function update() {
		//cm.update(dt);

		super.update();

		// Updates
		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate(dt);
		for(e in Entity.ALL) if( !e.destroyed ) e.update();
		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();
		gc();

		if( Key.isPressed(hxd.Key.ESCAPE) ) {
		}
	}
}
