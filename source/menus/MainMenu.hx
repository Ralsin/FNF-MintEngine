package menus;

import flixel.FlxG;
import flixel.FlxSprite;
import backend.AudioManager;
import backend.Controls;
import backend.MintFileManager;

class MainMenu extends extendable.Menu {
	public static var curSelected:Int = 0;

	var selectedSomethin:Bool = false;

	var menuItems:Array<FlxSprite>;
	var menuItemsList:Array<String> = ['freeplay', 'options', 'awards', 'credits'];

	override function create() {
		menuItems = [];
		for (i in 0...menuItemsList.length) {
			var menuItem:FlxSprite = new FlxSprite(2280.);
			menuItem.frames = MintFileManager.getFrames('mainmenu/menu_' + menuItemsList[i]);
			menuItem.animation.addByPrefix('idle', menuItemsList[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', menuItemsList[i] + " white", 24);
			menuItem.animation.play('selected');
			menuItem.drawFrame();
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.push(menuItem);
			add(menuItem);
			menuItem.updateHitbox();
		}
		changeSelection(0);
		menuItems[0].animation.play('selected');

		AudioManager.playMusic('freakyMenu', 102);
		MainState.instance.camState.moveFunction = (start, end, time) -> {
			return end;
		};
		AudioManager.loadSound('menuScroll', 'menu-scroll', true);
		AudioManager.loadSound('menuConfirm', 'menu-confirm', true);
	}

	override function update(elapsed:Float) {
		final e8:Float = elapsed * 8.;
		for (i => spr in menuItems) {
			final thing = spr.ID - curSelected;
			final ass:Float = lerp(spr.scale.x, thing == 0 ? .85 : .65, e8);
			spr.scale.set(ass, ass);
			spr.x = lerp(spr.x, FlxG.width - spr.frameWidth + 250. * Math.abs(thing), e8);
			spr.y = lerp(spr.y, FlxG.height * .5 - spr.frameHeight * .5 + thing * 270., e8);
		};
		super.update(elapsed);
	}

	override function onKeyDown(repeated:Bool, keybind:String, key:String) {
		if (selectedSomethin)
			return;

		switch keybind {
			case 'UI_Up':
				changeSelection(-1);
			case 'UI_Down':
				changeSelection(1);
			case 'Accept':
				selectedSomethin = true;
				AudioManager.playSound('menuConfirm');
				switch (menuItemsList[curSelected]) {
					case 'freeplay':
						selectedSomethin = false;
						// MainState.instance.open(new menus.SongPicker());
					case 'options':
						selectedSomethin = false;
					case 'credits':
						selectedSomethin = false;
				}
		}
		
		selectedSomethin = false; // cuz no other menus yet
	}

	override function onBeatHit(curBeat:Int) {
		if (curBeat % 4 == 0) {
			MainState.instance.gradientAlpha = .8;
			camera.zoom += .01;
		}
		camera.zoom += .01;
	}

	function changeSelection(huh:Int = 0, silent:Bool = false) {
		final prev:Int = cast curSelected;
		curSelected = Std.int(Math.min(Math.max(curSelected + huh, 0), menuItems.length - 1));
		if (curSelected != prev) {
			menuItems[prev].animation.play('idle');
			menuItems[curSelected].animation.play('selected');
			if (!silent)
				AudioManager.playSound('menuScroll');
		}
	}

	function lerp(s:Float, e:Float, t:Float) {
		return s + (e - s) * Math.min(t, 1);
	}
}
