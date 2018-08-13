package en;

import mt.heaps.slib.*;
import mt.MLib;
import mt.deepnight.Lib;

class Fruit extends Entity {
	public static var ALL : Array<Fruit> = [];

	public var parent : Branch;
	var power : Float = 0.1;

	public function new(p:Branch) {
		super(p.cx,p.cy);
		ALL.push(this);
		hasGravity = false;
		hasColl = false;
		parent = p;

		game.scroller.add(spr, Const.DP_TREE);
		spr.setRandom("fruitRaw",Std.random);
		spr.setCenterRatio(0.5, 0.1);
	}


	override public function dispose() {
		super.dispose();
		ALL.remove(this);
		parent = null;
	}

	override public function postUpdate() {
		super.postUpdate();

		if( parent!=null ) {
			if( power>=1 )
				spr.rotation = 0.25 * Math.cos(game.ftime*0.1);
			spr.setScale(sprScaleX*(0.4+0.6*power));
			spr.set(power>=1?"fruit":"fruitRaw", spr.frame);
		}
	}

	override public function isAlive() {
		return super.isAlive() && !hasGravity;
	}

	override function onLand() {
		super.onLand();
		if( power>=1 && !cd.has("landed") ) {
			fx.plant(centerX, centerY, 0xD75C28);
			new en.Branch(cx,cy, mt.deepnight.Color.makeColorHsl(game.teintHue,0.7,0.6));
			game.teintHue+=0.2;
		}
		cd.setS("landed",Const.INFINITE);
	}

	override public function onClick(bt:Int) {
		super.onClick(bt);
		if( power>=1 && !hasGravity ) {
			dx = rnd(0.09,0.10);
			dy = -0.3;
			parent = null; // fall
		}
	}

	//var fallCpt = 0.;
	override public function update() {
		super.update();

		//if( power>=1 && isAlive() ) {
			//fallCpt+=dt;
			//if( fallCpt>=Const.FPS*3 )
				//parent = null;
		//}

		if( !hasGravity && ( parent==null || !parent.isAlive() || level.hasPollution(cx,cy) ) ) {
			hasGravity = true;
			hasColl = true;
			spr.setCenterRatio(0.5,0.5);
			parent = null;
		}


		if( hasGravity && cd.has("landed") ) {
			sprScaleX*=Math.pow(0.99,dt);
			sprScaleY*=Math.pow(0.97,dt);
			if( sprScaleX<=0.03 )
				destroy();
		}

		if( isAlive() ) {
			if( !level.hasPollution(cx,cy) && power>0 )
				power+=0.006*dt;
			power = MLib.fclamp(power, 0, 1);
		}
	}
}

