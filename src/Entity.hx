import dn.heaps.slib.*;
import dn.Lib;

class Entity {
	public static var ALL : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var level(get,never) : Level; inline function get_level() return Game.ME.level;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var destroyed(default,null) = false;
	public var cd : dn.Cooldown;
	public var tmod(get,never) : Float; inline function get_tmod() return Game.ME.tmod;

	public var spr : HSprite;
	public var debug : Null<h2d.Graphics>;
	public var label : Null<h2d.Text>;
	var cAdd : h3d.Vector;

	public var uid : Int;
	public var cx = 0;
	public var cy = 0;
	public var xr = 0.;
	public var yr = 0.;
	public var dx = 0.;
	public var dy = 0.;
	public var frict = 0.9;
	public var gravity = 0.02;
	public var hasColl = true;
	public var hasGravity = true;
	public var sprScaleX = 1.0;
	public var sprScaleY = 1.0;

	public var onGround(get,never) : Bool; inline function get_onGround() return level.hasColl(cx,cy+1) && yr>=0.5 && dy==0;
	public var centerX(get,never) : Float; inline function get_centerX() return (cx+xr)*Const.GRID;
	public var centerY(get,never) : Float; inline function get_centerY() return (cy+yr)*Const.GRID;

	private function new(x,y) {
		uid = Const.UNIQ++;
		ALL.push(this);

		cd = new dn.Cooldown(Const.FPS);
		setPosCase(x,y);

		spr = new dn.heaps.slib.HSprite(Assets.tiles);
		//spr = new dn.heaps.slib.HSprite(Assets.gameElements);
		game.scroller.add(spr, Const.DP_BG);
		spr.setCenterRatio(0.5,0.5);
		cAdd = new h3d.Vector();
		spr.colorAdd = cAdd;
	}

	public function isAlive() {
		return !destroyed;
	}

	public function toString() {
		return Type.getClassName(Type.getClass(this))+"#"+uid;
	}

	public function setPosCase(x:Int, y:Int) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 0.5;
	}

	public function setPosPixel(x:Float, y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x-cx*Const.GRID)/Const.GRID;
		yr = (y-cy*Const.GRID)/Const.GRID;
	}

	//public function say(str:String, ?c=0xFFFFFF) {
		//var i = 0;
		//var t = game.tw.createS(i, str.length, str.length*0.03);
		//t.onUpdate = function() {
			//setLabel(str.substr(0,i), c);
		//}
		//t.onEnd = function() {
			//var tf = label;
			//game.cm.signal("say");
			//game.tw.createS(tf.alpha, 0.5|0, 1).end( function() setLabel() );
		//}
	//}

	public function setLabel(?str:String, ?c=0xFFFFFF) {
		if( str==null && label!=null ) {
			label.remove();
			label = null;
		}
		if( str!=null ) {
			if( label==null ) {
				label = new h2d.Text(Assets.font);
				game.scroller.add(label, Const.DP_UI);
			}
			label.text = str;
			label.textColor = c;
		}
	}


	public inline function rnd(min,max,?sign) return Lib.rnd(min,max,sign);
	public inline function irnd(min,max,?sign) return Lib.irnd(min,max,sign);
	public inline function pretty(v,?p=1) return Lib.prettyFloat(v,p);

	public function sightCheckCase(x:Int,y:Int) {
		return dn.Bresenham.checkThinLine(cx,cy,x,y, function(x,y) return !level.hasColl(x,y));
	}

	public inline function distCase(e:Entity) {
		return Lib.distance(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr);
	}

	public inline function distPx(e:Entity) {
		return Lib.distance(centerX, centerY, e.centerX, e.centerY);
	}

	public inline function distPxFree(x:Float, y:Float) {
		return Lib.distance(centerX, centerY, x, y);
	}

	public inline function angTo(e:Entity) return Math.atan2(e.centerY-centerY, e.centerX-centerX);
	public inline function dirTo(e:Entity) return e.centerX<=centerX ? -1 : 1;

	public inline function destroy() {
		destroyed = true;
	}

	public function is<T:Entity>(c:Class<T>) return Std.is(this, c);
	public function as<T:Entity>(c:Class<T>) : T return Std.instance(this, c);

	public function dispose() {
		ALL.remove(this);
		cd.destroy();
		spr.remove();
		if( label!=null )
			label.remove();
		if( debug!=null )
			debug.remove();
	}

	public function preUpdate() {
		cd.update(tmod);
	}

	public function postUpdate() {
		spr.x = (cx+xr)*Const.GRID;
		spr.y = (cy+yr)*Const.GRID;
		spr.scaleX = sprScaleX;
		spr.scaleY = sprScaleY;

		if( label!=null )
			label.setPosition( Std.int(centerX-label.textWidth*0.5), Std.int(centerY-label.textHeight-Const.GRID*0.5));

		if( Console.ME.has("bounds") ) {
			if( debug==null ) {
				debug = new h2d.Graphics();
				game.scroller.add(debug, Const.DP_UI);
			}
			debug.setPosition(centerX, centerY);
			debug.clear();

			debug.beginFill(0xE8DDB3,0.2);
			debug.lineStyle(1,0xE8DDB3,0.7);
			debug.drawRect(-1,-1,2,2);
			debug.drawCircle(0,0,5);

			//for(a in Area.ALL)
				//if( a.owner==this ) {
					//debug.beginFill(a.color,0.2); debug.lineStyle(1,a.color,0.4);
					//debug.drawCircle(a.centerX-footX, a.centerY-footY, a.radius);
				//}
		}
		if( !Console.ME.has("bounds") && debug!=null ) {
			debug.remove();
			debug = null;
		}

		cAdd.r*=Math.pow(0.8,tmod);
		cAdd.g*=Math.pow(0.7,tmod);
		cAdd.b*=Math.pow(0.7,tmod);
	}

	public function onClick(bt:Int) {
	}

	function onLand() {}
	function onTouchWall(dir:Int) {}
	function onTouchCeiling() {}

	public function blink() {
		cAdd.r = 1;
		cAdd.g = 1;
		cAdd.b = 1;
	}

	public function update() {
		// X
		var steps = M.ceil( M.fabs(dx*tmod) );
		var step = dx*tmod / steps;
		while( steps>0 ) {
			xr+=step;
			if( hasColl ) {
				if( xr>0.7 && level.hasColl(cx+1,cy) ) {
					xr = 0.7;
					onTouchWall(1);
					steps = 0;
				}
				if( xr<0.3 && level.hasColl(cx-1,cy) ) {
					xr = 0.3;
					onTouchWall(-1);
					steps = 0;
				}
			}
			while( xr>1 ) { xr--; cx++; }
			while( xr<0 ) { xr++; cx--; }
			steps--;
		}
		dx*=Math.pow(frict,tmod);

		// Gravity
		if( !onGround && hasGravity )
			dy += gravity*tmod;

		// Y
		var steps = M.ceil( M.fabs(dy*tmod) );
		var step = dy*tmod / steps;
		while( steps>0 ) {
			yr+=step;
			if( hasColl ) {
				if( yr>1 && level.hasColl(cx,cy+1) ) {
					yr = 1;
					onLand();
					steps = 0;
				}
				if( yr<0.3 && level.hasColl(cx,cy-1) ) {
					yr = 0.3;
					onTouchCeiling();
					steps = 0;
				}
			}
			while( yr>1 ) { yr--; cy++; }
			while( yr<0 ) { yr++; cy--; }
			steps--;
		}
		dy*=Math.pow(frict,tmod);
	}
}