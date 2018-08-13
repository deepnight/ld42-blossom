package en;

import mt.heaps.slib.*;
import mt.MLib;
import mt.deepnight.Lib;

class Branch extends Entity {
	public static var ALL : Array<Branch> = [];

	public var parent : Branch;
	var branchesWrapper : h2d.Sprite;
	var leavesWrapper : h2d.Sprite;
	var parts : Array<HSprite> = [];
	var invalidate = true;
	var power : Float = 0;

	public function new(x,y,?p:Branch) {
		super(x,y);
		ALL.push(this);
		hasGravity = false;
		hasColl = false;
		parent = p;

		game.scroller.add(spr, Const.DP_TREE);
		spr.setRandom("empty",Std.random);
		spr.setCenterRatio(0.5, 0.5);
		if( parent!=null )
			parent.invalidate = true;

		leavesWrapper = new h2d.Sprite();
		game.scroller.add(leavesWrapper, Const.DP_BG);

		branchesWrapper = new h2d.Sprite();
		game.scroller.add(branchesWrapper, Const.DP_TREE);
	}


	override public function dispose() {
		super.dispose();
		leavesWrapper.remove();
		branchesWrapper.remove();
		ALL.remove(this);
	}

	var killClicks = 0;
	override public function onClick(bt:Int) {
		super.onClick(bt);
		if( bt==1 && !isRoot() ) {
			killClicks++;
			blinkChildren(0xFF0000,true);
			cd.setS("recentKillClick",3);
			if( killClicks>=6 )
				kill();
		}
	}

	function blinkChildren(c:UInt,shake:Bool) {
		cAdd.setColor(c);
		if( shake )
			cd.setS("shaking", 1);
		for(e in getChildren())
			e.blinkChildren(c,shake);
	}

	public function getChildren() : Array<Branch> {
		var children = [];
		for(e in ALL)
			if( e.parent==this )
				children.push(e);
		return children;
	}

	public function isBranchEnd() : Bool {
		for(e in ALL)
			if( e.parent==this )
				return false;
		return true;
	}

	public function getTreeDepth() {
		var d = 0;
		var b = parent;
		while( b!=null ) {
			d++;
			b = b.parent;
		}
		return d;
	}

	function render() {
		for( e in parts ) e.remove();
		parts = [];

		var children = getChildren();

		if( !isRoot() && children.length==0 ) {
			var s = Assets.tiles.h_getRandom("backLeaves", leavesWrapper);
			parts.push(s);
			s.setCenterRatio(0.5,0.5);
			s.rotation = rnd(0,1,true);
		}

		if( parent!=null ) {
			var s = Assets.tiles.h_getRandom("branch", branchesWrapper);
			parts.push(s);
			s.setCenterRatio(0.5,0.5);
			var a = Math.atan2(parent.centerY-centerY, parent.centerX-centerX);
			s.setPos(Math.cos(a)*Const.GRID*0.5, Math.sin(a)*Const.GRID*0.5);
			s.scaleX = -distPx(parent) / Const.GRID;
			s.scaleY = 1.6*getThickness();
			s.rotation = a;
		}

		if( isRoot() ) {
			var s = Assets.tiles.h_getRandom("branch", branchesWrapper);
			parts.push(s);
			s.setCenterRatio(0.5,0.5);
			s.rotation = -1.57+rnd(0,0.2,true);
			s.scaleX = 1;
			s.scaleY = 1.4*getThickness();
		}

		if( !isRoot() && children.length>0 ) {
			var s = Assets.tiles.h_getRandom("smallLeaves", leavesWrapper);
			parts.push(s);
			s.setCenterRatio(0.5,0.5);
			s.rotation = rnd(0,1,true);
		}

		if( children.length==0 ) {
			var s = Assets.tiles.h_getRandom("leaves", leavesWrapper);
			parts.push(s);
			s.setCenterRatio(0.5,0.5);
			s.rotation = rnd(0,1,true);
		}
	}

	override public function postUpdate() {
		super.postUpdate();

		var sh = cd.has("shaking") ? cd.getRatio("shaking") : 0;

		if( invalidate ) {
			invalidate = false;
			render();
		}

		for(e in parts)
			e.colorAdd = cAdd;

		branchesWrapper.x = spr.x;
		branchesWrapper.y = spr.y;
		branchesWrapper.scaleX = spr.scaleX;
		branchesWrapper.scaleY = spr.scaleY;
		branchesWrapper.x+=rnd(0.5,1,true)*sh;
		branchesWrapper.y+=rnd(0.5,1,true)*sh;

		leavesWrapper.x = spr.x + Math.cos(game.ftime*0.020+uid*0.1)*2;
		leavesWrapper.y = spr.y + Math.cos(game.ftime*0.011+uid*0.5)*2 + (isRoot()?-8 : 0);
		leavesWrapper.scaleX = spr.scaleX * power;
		leavesWrapper.scaleY = spr.scaleY * power;
	}

	function getThickness() {
		return 1.0 - 0.7 * MLib.fclamp(getTreeDepth()/5, 0, 1);
	}

	public inline function isRoot() return this==game.treeRoot;

	public function kill() {
		if( parent!=null ) {
			parent.power*=0.5;
			parent.invalidate = true;
		}
		dx = rnd(0,0.1,true);
		dy = -rnd(0.1,0.3);
		hasGravity = true;
		hasColl = true;
		parent = null;
		game.energy+=25;
	}

	override public function isAlive() {
		return super.isAlive() && !hasGravity;
	}

	override function onLand() {
		super.onLand();
		dy *= -1;
		cd.setS("landed", Const.INFINITE);
	}

	override public function update() {
		super.update();

		if( isAlive() && ( parent==null || !parent.isAlive() ) && !isRoot() )
			kill();

		//if( hasGravity && !cd.has("landed") )
			//spr.rotation*=Math.pow(0.96,dt);

		if( hasGravity && cd.has("landed") ) {
			sprScaleX*=Math.pow(0.99,dt);
			sprScaleY*=Math.pow(0.99,dt);
			if( sprScaleX<=0.03 )
				destroy();
		}

		if( isAlive() && power<1 )
			power+=0.003*dt;

		if( !cd.hasSetS("energyTick", 1) )  {
			if( isRoot() )
				game.energy+=2;
			if( isBranchEnd() )
				game.energy+=2*power;
			else
				game.energy-=1.5;
		}

		if( !cd.has("recentKillClick") )
			killClicks = 0;

		if( isRoot() )
			setLabel(""+pretty(game.energy));
	}
}

