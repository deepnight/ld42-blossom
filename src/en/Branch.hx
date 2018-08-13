package en;

import mt.heaps.slib.*;
import mt.MLib;
import mt.deepnight.Lib;

class Branch extends Entity {
	public static var ALL : Array<Branch> = [];

	public var parent : Branch;
	var parts : Array<HSprite> = [];
	var invalidate = true;

	public function new(x,y,?p:Branch) {
		super(x,y);
		ALL.push(this);
		hasGravity = false;
		hasColl = false;
		parent = p;

		game.scroller.add(spr, Const.DP_TREE);
		spr.setRandom("branchCore",Std.random);
		spr.setCenterRatio(0.5, 0.5);
		if( parent!=null )
			parent.invalidate = true;
	}


	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function onClick(bt:Int) {
		super.onClick(bt);
		if( bt==1 && !isRoot() )
			kill();
	}

	public function getChildren() : Array<Branch> {
		var children = [];
		for(e in ALL)
			if( e.parent==this )
				children.push(e);
		return children;
	}

	override public function postUpdate() {
		super.postUpdate();

		if( invalidate ) {
			invalidate = false;
			for( e in parts )
				e.remove();
			parts = [];

			if( parent!=null ) {
				var s = Assets.tiles.h_getRandom("branch", spr);
				parts.push(s);
				s.setCenterRatio(0.5,0.5);
				var a = Math.atan2(parent.centerY-centerY, parent.centerX-centerX);
				s.setPos(Math.cos(a)*Const.GRID*0.5, Math.sin(a)*Const.GRID*0.5);
				s.rotation = a + rnd(0,0.2,true);
			}

			if( isRoot() ) {
				var s = Assets.tiles.h_getRandom("branch", spr);
				parts.push(s);
				s.setCenterRatio(0.5,0.5);
				s.rotation = -1.57+rnd(0,0.2,true);
			}

			var children = getChildren();
			if( children.length==0 ) {
				var s = Assets.tiles.h_getRandom("branch", spr);
				parts.push(s);
				s.setCenterRatio(0.5,0.5);
				s.scaleX = rnd(0.3,0.5);
				s.scaleY = rnd(0.4,0.6);
				s.y = -5;
				s.rotation = -1.57+rnd(0.2,0.5,true);
			}
		}
	}

	public inline function isRoot() return this==game.treeRoot;

	public function kill() {
		dx = rnd(0,0.1,true);
		dy = -rnd(0.1,0.3);
		hasGravity = true;
		hasColl = true;
		parent = null;
		spr.rotation = 0;
	}

	override public function isAlive() {
		return super.isAlive() && !hasGravity;
	}

	override function onLand() {
		super.onLand();
		dy *= -1;
		spr.rotation*=0.7;
		cd.setS("landed", Const.INFINITE);
	}

	override public function update() {
		super.update();

		if( isAlive() && ( parent==null || !parent.isAlive() ) && !isRoot() )
			kill();

		if( hasGravity && !cd.has("landed") )
			spr.rotation*=Math.pow(0.96,dt);

		if( hasGravity && cd.has("landed") ) {
			sprScaleX*=Math.pow(0.99,dt);
			sprScaleY*=Math.pow(0.99,dt);
			if( sprScaleX<=0.03 )
				destroy();
		}
	}
}

