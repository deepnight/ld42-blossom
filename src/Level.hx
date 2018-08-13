package;

import mt.MLib;
import mt.deepnight.Color;
import mt.heaps.slib.*;

class Level extends mt.Process {
	public var wid : Int;
	public var hei : Int;
	var collMap : haxe.ds.Vector<Bool>;

	public var debug : h2d.Graphics;
	var pixels : Map<UInt, Array<CPoint>>;

	public function new() {
		super(Game.ME);

		wid = 48;
		hei = 48;
		collMap = new haxe.ds.Vector(wid*hei);

		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		var mask = new h2d.Graphics(root);
		mask.beginFill(0x212550,1);
		mask.drawRect(0,0,wid*Const.GRID,hei*Const.GRID);

		var bd = hxd.Res.level.toBitmap();
		pixels = new Map();
		for(cy in 0...hei)
		for(cx in 0...wid) {
			var c = mt.deepnight.Color.removeAlpha( bd.getPixel(cx,cy) );
			if( !pixels.exists(c) )
				pixels.set(c, []);
			pixels.get(c).push( new CPoint(cx,cy) );
			if( c==0xffffff )
				setColl(cx,cy,true);
		}

		render();
	}

	function render() {
		if( debug!=null ) {
			debug.remove();
			root.removeChildren();
		}
		var game = Game.ME;

		for(cx in 0...wid)
		for(cy in 0...hei) {
			var x = cx*Const.GRID;
			var y = cy*Const.GRID;
			if( hasPixel(0xffffff, cx,cy) ) {
				var e = Assets.tiles.h_getRandom("dirt", root);
				e.setPos(x,y);
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

	override public function update() {
		super.update();
	}
}