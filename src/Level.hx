package;

import mt.MLib;
import mt.deepnight.Color;
import mt.heaps.slib.*;

class Level extends mt.Process {
	public var wid : Int;
	public var hei : Int;
	public var bg : h2d.Object;
	var collMap : haxe.ds.Vector<Bool>;
	public var pollMap : haxe.ds.Vector<Bool>;

	public var debug : h2d.Graphics;
	var pixels : Map<UInt, Array<CPoint>>;

	public function new() {
		super(Game.ME);

		var bd = hxd.Res.level.toBitmap();
		wid = bd.width;
		hei = bd.height;
		collMap = new haxe.ds.Vector(wid*hei);
		pollMap = new haxe.ds.Vector(wid*hei);

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		bg = new h2d.Object();
		Game.ME.root.add(bg, Const.DP_SKY);
		//var mask = new h2d.Bitmap(h2d.Tile.fromColor(0x1D2045,1,1), bg);
		//mask.scaleX = wid*Const.GRID;
		//mask.scaleY = wid*Const.GRID;

		//var mask = new h2d.Graphics(root);
		//mask.beginFill(0x2B2F68,1);
		//mask.drawRect(0,0,wid*Const.GRID,hei*Const.GRID);

		pixels = new Map();
		for(cy in 0...hei)
		for(cx in 0...wid) {
			var c = mt.deepnight.Color.removeAlpha( bd.getPixel(cx,cy) );
			if( !pixels.exists(c) )
				pixels.set(c, []);
			pixels.get(c).push( new CPoint(cx,cy) );
			if( c==0xffffff || c==0xd02dff )
				setColl(cx,cy,true);
		}

		render();
	}

	function render() {
		if( debug!=null ) {
			debug.remove();
			root.removeChildren();
			bg.removeChildren();
		}
		var game = Game.ME;

		var e = Assets.tiles.h_getRandom("skyGradient", bg);
		e.scaleX = wid*Const.GRID / e.tile.width;
		e.scaleY = hei*Const.GRID / e.tile.height;

		for(cx in 0...wid)
		for(cy in 0...hei) {
			var x = cx*Const.GRID;
			var y = cy*Const.GRID;
			if( hasColl(cx,cy) ) {
				if( !hasColl(cx,cy-1) ) {
					var e = Assets.tiles.h_getRandom("surface", root);
					e.setPosition(x,y-Const.GRID);
				}
				else if( !hasColl(cx,cy+1) ) {
					var e = Assets.tiles.h_getRandom("ceil", root);
					e.setPosition(x,y);
				}
				else {
					var e = Assets.tiles.h_getRandom("dirt", root);
					e.setPosition(x,y);
				}
			}
			else {
				if( Std.random(100)<10 ) {
					var e = Assets.tiles.h_getRandom("skyStar", bg);
					e.setPos(x,y);
				}

			}
		}

		debug = new h2d.Graphics(root);
	}

	override function onDispose() {
		super.onDispose();
	}

	public function iteratePixels(c:UInt, cb:Int->Int->Void) {
		if( !pixels.exists(c) )
			return;

		for(pt in pixels.get(c))
			cb(pt.cx, pt.cy);
	}

	public inline function getPixel(c:UInt) : Null<CPoint> {
		return pixels.exists(c) ? pixels.get(c)[0] : null;
	}

	public function getPixels(c:UInt) : Array<CPoint> {
		return pixels.exists(c) ? pixels.get(c) : [];
	}

	public function hasPixel(c:UInt, cx:Int, cy:Int) {
		for(pt in getPixels(c))
			if( pt.cx==cx && pt.cy==cy )
				return true;
		return false;
	}

	public function isValid(cx:Float,cy:Float) {
		return cx>=0 && cx<wid && cy>=0 && cy<hei;
	}

	public function coordId(x,y) return x+y*wid;

	public function hasColl(x:Int, y:Int) {
		return !isValid(x,y) ? true : collMap.get(coordId(x,y));
	}

	public function setColl(x,y,v:Bool) {
		collMap.set(coordId(x,y), v);
	}

	public function hasPollution(x:Int,y:Int) : Bool {
		return !isValid(x,y) ? true : pollMap.get(coordId(x,y))==true;
	}

	public function setPollution(x,y,v:Bool) {
		pollMap.set(coordId(x,y), v);
	}

	override public function update() {
		super.update();
	}
}