import h2d.Object;
import dn.heaps.HParticle;


class Fx extends dn.Process {
	public var pool : ParticlePool;

	public var bgAddSb    : h2d.SpriteBatch;
	public var bgNormalSb    : h2d.SpriteBatch;
	public var topAddSb       : h2d.SpriteBatch;
	public var topNormalSb    : h2d.SpriteBatch;

	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.level;

	public function new() {
		super(Game.ME);

		pool = new ParticlePool(Assets.tiles.tile, 3000, Const.FPS);

		bgAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgAddSb, Const.DP_FX_BG);
		bgAddSb.blendMode = Add;
		bgAddSb.hasRotationScale = true;

		bgNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgNormalSb, Const.DP_FX_BG);
		bgNormalSb.hasRotationScale = true;

		topNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topNormalSb, Const.DP_FX_FRONT);
		topNormalSb.hasRotationScale = true;

		topAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topAddSb, Const.DP_FX_FRONT);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();

		bgAddSb.remove();
		bgNormalSb.remove();
		topAddSb.remove();
		topNormalSb.remove();
	}

	public function clear() {
		pool.killAll();
	}

	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function allocTopNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topNormalSb, t,x,y);
	}

	public inline function allocBgAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgAddSb, t,x,y);
	}

	public inline function allocBgNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgNormalSb, t,x,y);
	}

	public inline function getTile(id:String) : h2d.Tile {
		return Assets.tiles.getTileRandom(id);
	}

	public function killAll() {
		pool.killAll();
	}

	public function markerEntity(e:Entity, ?c=0xFF00FF, ?short=false) {
		#if debug
		if( e==null )
			return;

		markerCase(e.cx, e.cy, c, short);
		#end
	}

	public function markerCase(cx:Int, cy:Int, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;

		var p = allocTopAdd(getTile("dot"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerFree(x:Float, y:Float, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("dot"), x,y);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.dr = 0.3;
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerText(cx:Int, cy:Int, txt:String, ?t=1.0) {
		var tf = new h2d.Text(Assets.font, topNormalSb);
		tf.text = txt;

		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.frict = 0.92;
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPosition(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
	}

	public function flashBangS(c:UInt, a:Float, ?t=0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
		game.root.add(e, Const.DP_FX_FRONT);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end( function() {
			e.remove();
		});
	}

	function collGround(p:HParticle) {
		return
			!level.hasColl( Std.int(p.x/Const.GRID), Std.int((p.y-2)/Const.GRID) ) &&
			level.hasColl( Std.int(p.x/Const.GRID), Std.int((p.y+1)/Const.GRID) );
	}

	function hasColl(p:HParticle) {
		return level.hasColl( Std.int(p.x/Const.GRID), Std.int((p.y+1)/Const.GRID) );
	}

	function _hardPhysics(p:HParticle) {
		if( collGround(p) && Math.isNaN(p.data0) ) {
			p.data0 = 1;
			p.gy = 0;
			p.dx*=0.5;
			p.dy = 0;
			p.dr = 0;
			p.frict = 0.8;
			p.rotation *= 0.03;
		}
	}



	public function woodCover(x:Float, y:Float, dir:Int) {
		var c = 0x7e593e;

		// Dots
		var n = 100;
		for( i in 0...n) {
			var p = allocTopNormal(getTile("dot"), x+rnd(0,3,true), y+rnd(0,4,true));
			p.colorize( Color.interpolateInt(c,0x0,rnd(0,0.1)) );
			p.scaleX = rnd(1,3);
			p.dx = dir * (i<=n*0.2 ? rnd(3,12) : rnd(-2,5) );
			p.dy = rnd(-3,1);
			p.gy = rnd(0.1,0.2);
			p.frict = rnd(0.85,0.96);
			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.3,true);
			p.lifeS = rnd(5,10);
			p.setFadeS(rnd(0.7,1), 0, rnd(3,7));
			p.onUpdate = _hardPhysics;
			p.delayS = i>20 ? rnd(0,0.1) : 0;
		}

		// Planks
		var n = 20;
		for( i in 0...n) {
			var p = allocTopNormal(getTile("dot"), x+rnd(0,3,true), y+rnd(0,4,true));
			p.colorize( Color.interpolateInt(c,0x0,rnd(0,0.1)) );
			p.setFadeS(rnd(0.7,1), 0, rnd(3,7));

			p.scaleX = rnd(3,5);
			p.scaleY = 2;
			p.scaleMul = rnd(0.992,0.995);

			p.dx = dir * (i<=n*0.2 ? rnd(2,8) : rnd(-2,5) );
			p.dy = rnd(-5,0);
			p.gy = rnd(0.1,0.2);
			p.frict = rnd(0.85,0.96);

			p.rotation = rnd(0,6.28);
			p.dr = rnd(0,0.3,true);

			p.lifeS = rnd(5,10);
			p.onUpdate = _hardPhysics;
			p.delayS = i>20 ? rnd(0,0.1) : 0;
		}
	}


	public function cleanUp(x:Float, y:Float, r:Float, c:UInt) {
		var p = allocTopAdd(getTile("radius"), x,y);
		p.colorize(c);
		p.setFadeS(0.5, 0.1, 1);
		p.setScale( 2*r/p.t.width );
		//p.ds = 0.01;
		//p.dsFrict = 0.8;
		p.lifeS = 0.5;
		p.delayS = 0.1;

		//var n = 20;
		//for(i in 0...n) {
			//var a = 6.28 * i/n;
			//var p = allocTopAdd(getTile("star"), x+Math.cos(a)*10, y+Math.sin(a)*10);
			//p.colorize(c);
			//p.moveAwayFrom(x,y, 2);
			//p.frict = 0.9;
			//p.rotation = a+1.57;
			//p.dr = 0.1;
			//p.lifeS = 0.5;
		//}

		var n = 400;
		for(i in 0...n) {
			var a = 4*6.28 * i/n + rnd(0,0.1,true);
			var d = r*(1-i/n) + rnd(0,5,true);
			var p = allocTopAdd(getTile("star"), x+Math.cos(a)*d, y+Math.sin(a)*d);
			p.colorize(c);
			//p.moveAwayFrom(x,y, rnd(0.5,1));
			p.rotation = a+1.57;
			p.moveAng(a,1);
			p.frict = 0.8;
			p.lifeS = rnd(0.4,0.6);
			//p.alphaFlicker = 0.5;
			p.delayS = 0.8 * i/n;
		}

	}



	public function cleanedUp(x:Float, y:Float, c:UInt) {
		var n = 30;
		for(i in 0...n) {
			var a = 6.28 * i/n;
			var d = rnd(1,10);
			var p = allocTopAdd(getTile("dot"), x+Math.cos(a)*d, y+Math.sin(a)*d);
			p.colorize(c);
			p.moveAwayFrom(x,y, rnd(0.5,1));
			p.frict = 0.8;
			p.lifeS = rnd(1,3);
			p.alphaFlicker = 0.5;
		}
	}


	public function blossom(x:Float, y:Float, c:UInt) {
		var n = 30;
		for(i in 0...n) {
			var a = 6.28 * i/n;
			var p = allocTopAdd(getTile("dot"), x+Math.cos(a)*10, y+Math.sin(a)*10);
			p.colorize(c);
			p.moveAwayFrom(x,y, 1);
			p.frict = 0.9;
			p.lifeS = 0.5;
		}
	}




	public function plant(x:Float, y:Float, c:UInt) {
		var n = 30;
		for(i in 0...n) {
			var a = 6.28 * i/n;
			var p = allocTopAdd(getTile("star"), x+Math.cos(a)*10, y+Math.sin(a)*10);
			p.colorize(c);
			p.moveAwayFrom(x,y, 2);
			p.rotation = p.getMoveAng();
			p.frict = 0.9;
			p.lifeS = 0.5;
		}
		var n = 40;
		for(i in 0...n) {
			var a = 6.28 * i/n;
			var p = allocTopAdd(getTile("dot"), x+Math.cos(a)*30, y+Math.sin(a)*30);
			p.colorize(c);
			p.moveTo(x,y, 2);
			p.frict = 0.9;
			p.lifeS = 0.5;
		}
	}


	function _followAng(p:HParticle) {
		p.rotation = p.getMoveAng();
	}


	public function envDust() {
		var n = 6;
		for(i in 0...n) {
			var p = allocTopAdd(getTile("dot"), rnd(0,game.vp.wid), rnd(0,game.vp.hei));
			//var p = allocTopAdd(getTile("dot"), rnd(0,game.vp.wid), rnd(-30,0));
			p.setFadeS(rnd(0.07,0.12), rnd(0.6,1), rnd(2,3));
			p.scaleX = rnd(5,10);
			p.scaleXMul = rnd(0.97,0.99);
			p.dx = rnd(0,2);
			p.dy = rnd(-1,2);
			p.frict = rnd(0.94,0.97);
			p.gx = rnd(0.01,0.03);
			p.gy = rnd(0.01,0.02);
			p.lifeS = rnd(2,3);
			p.onUpdate = _followAng;
		}
	}

	public function envRain() {
		var n = 6;
		for(i in 0...n) {
			var xr = rnd(0,1);
			var p = allocTopAdd(getTile("dot"), xr*game.vp.wid, rnd(0,game.vp.hei));
			//var p = allocTopAdd(getTile("dot"), rnd(0,game.vp.wid), rnd(-30,0));
			p.setFadeS(rnd(0.07,0.12), rnd(0.6,1), rnd(2,3));
			p.scaleX = rnd(9,16);
			p.scaleXMul = rnd(0.97,0.99);
			p.dx = rnd(0,2);
			p.dy = rnd(-1,2);
			p.frict = rnd(0.94,0.97);
			p.gx = rnd(0.01,0.03);
			p.gy = rnd(0.04,0.08);
			p.lifeS = rnd(2,3);
			p.onUpdate = _followAng;
		}
	}

	public function envSmoke() {
		var n = 6;
		for(i in 0...n) {
			var xr = rnd(0,1);
			var p = allocTopAdd(getTile("smoke"), xr*game.vp.wid, game.level.hei*Const.GRID*rnd(0.6, 1));
			p.colorize(Color.interpolateInt(0x236CC7,0xBC2E38,xr) );
			p.setFadeS(rnd(0.05,0.08), rnd(0.6,1), rnd(2,3));
			p.setScale(rnd(0.9,1.7));
			p.rotation = rnd(0,6.28);
			p.scaleMul = rnd(0.995,0.998);
			p.dy = rnd(-1,2);
			p.frict = rnd(0.94,0.97);
			p.dr = rnd(0,0.003,true);
			p.gx = rnd(0.01,0.02);
			p.gy = rnd(0.003,0.004);
			p.lifeS = rnd(2,3);
		}
	}

	public function smoke(x:Float,y:Float,c:UInt) {
		var n = 1;
		for(i in 0...n) {
			var p = (i==0?allocTopNormal:allocBgNormal)(getTile("smoke"), x+rnd(0,9,true), y+rnd(0,9,true));
			p.colorize(c);
			p.setFadeS(rnd(0.2,0.3), rnd(0.3,0.5), rnd(1,1.5));
			p.setScale(rnd(0.6,0.75));
			p.rotation = rnd(0,6.28);
			p.scaleMul = rnd(0.995,0.998);
			p.frict = rnd(0.94,0.97);
			p.dr = rnd(0,0.003,true);
			p.gx = rnd(0.001,0.002);
			p.gy = rnd(0.0003,0.0004);
			p.lifeS = rnd(0.4,0.8);
			p.delayS = rnd(0,0.3);
		}
	}

	public function largeSmoke(x:Float,y:Float,c:UInt) {
		var n = 1;
		for(i in 0...n) {
			var p = (i==0?allocTopNormal:allocBgNormal)(getTile("smoke"), x+rnd(0,9,true), y+rnd(0,9,true));
			p.colorize(c);
			p.setFadeS(rnd(0.05,0.10), rnd(0.3,0.5), rnd(1.5,2.5));
			p.setScale(rnd(0.8,1.1));
			p.rotation = rnd(0,6.28);
			p.scaleMul = rnd(0.995,0.998);
			p.frict = rnd(0.94,0.97);
			p.dr = rnd(0,0.003,true);
			p.gx = rnd(0.001,0.002);
			p.gy = rnd(0.0003,0.0004);
			p.lifeS = rnd(0.6,0.8);
			p.delayS = rnd(0,1);
		}
	}

	override function update() {
		super.update();

		pool.update( game.dt );
	}
}