package en;

import dn.heaps.slib.*;
import dn.Lib;

class Obstacle extends Entity {
	public static var ALL : Array<Obstacle> = [];

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		hasGravity = false;
		hasColl = false;

		game.scroller.add(spr, Const.DP_SMOKE);
		spr.setRandom("stripes",Std.random);
		spr.setCenterRatio(0.5, 0.5);
		spr.alpha = 0;
		spr.colorize(0xFF0000);

		game.level.setPollution(cx,cy,true);
		cd.setS("expand", rnd(10,20));
	}


	override public function dispose() {
		super.dispose();
		ALL.remove(this);
		game.level.setPollution(cx,cy,false);
	}

	override public function postUpdate() {
		super.postUpdate();
		//spr.rotation+=0.002;
		if( !level.hasPollution(cx-1,cy) || !level.hasPollution(cx+1,cy) || !level.hasPollution(cx,cy-1) || !level.hasPollution(cx,cy+1) ) {
			if( !cd.hasSetS("fx",0.3) )
				fx.smoke(centerX,centerY,0x992828);
			spr.alpha += (0.20-spr.alpha)*0.03;
		}
		else
			spr.alpha += (0.30-spr.alpha)*0.03;

	}

	override public function update() {
		super.update();
	}
}

