package en;

import mt.heaps.slib.*;
import mt.MLib;
import mt.deepnight.Lib;

class Bonus extends Entity {
	public static var ALL : Array<Bonus> = [];

	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		gravity*=0.4;

		game.scroller.add(spr, Const.DP_FRONT);
		spr.setRandom("bonus",Std.random);
		spr.setCenterRatio(0.5, 0.89);
	}


	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override public function postUpdate() {
		super.postUpdate();
		//sprScaleX+=(1-sprScaleX)*0.1;
		//sprScaleY+=(1-sprScaleY)*0.1;
	}

	override function onLand() {
		super.onLand();
		dy = 0;
		//sprScaleX = 1.4;
		//sprScaleY = 0.6;
	}


	function pickUp() {
		var r = 12;
		for(e in en.Obstacle.ALL)
			if( distCase(e)<=r ) {
				fx.cleanedUp(e.centerX,e.centerY,0x0080FF);
				e.destroy();
			}
		game.addEnergy(Const.BUY*4);

		fx.cleanUp(centerX, centerY, Const.GRID*r, 0x159AEA);
		destroy();
	}

	override public function update() {
		super.update();

		if( onGround )
			dy = -rnd(0.20,0.25);

		if( !cd.hasSetS("check",0.15) ) {
			for(e in en.Branch.ALL)
				if( /*!level.hasPollution(e.cx,e.cy) &&*/ distCase(e)<=2 && sightCheckCase(e.cx,e.cy) ) {
					pickUp();
					break;
				}
		}
	}
}

