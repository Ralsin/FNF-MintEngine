package funkin.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import funkin.api.AudioManager;
import funkin.api.FileManager;

class MainMenu extends funkin.templates.Menu {
	public static var curSelected:Int = 0;

	var selectedSomethin:Bool = false;

	var menuItems:Array<FlxSprite>;
	var menuItemsList:Array<String> = ['freeplay', 'options', 'awards', 'credits'];

	override function create() {
		menuItems = [];
		for (i in 0...menuItemsList.length) {
			var menuItem:FlxSprite = new FlxSprite(2280.);
			menuItem.frames = FileManager.getFrames('mainmenu/menu_' + menuItemsList[i]);
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

		AudioManager.playMusic('freakyMenu', 102, 0, .1);
		Game.camState.moveFunction = (start, end, time) -> {
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
			// spr.x = lerp(spr.x, FlxG.width - spr.frameWidth + 250. * Math.abs(thing), e8);
			spr.y = lerp(spr.y, FlxG.height * .5 - spr.frameHeight * .5 + thing * 270., e8);
			spr.x = lerp(spr.x, 150 - 250 * Math.abs(thing), e8);
		};

		Game.camBG.zoom = camera.zoom = lerp(camera.zoom, 1., e8);
		super.update(elapsed);
	}

	override function onKeybindDown(justPressed:Bool, keybind:String) {
		// trace('Just Pressed: $justPressed; Keybind: $keybind');
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
						open(new funkin.menus.PlayState('gayfreaker', 'hard'));
					case 'options':
						selectedSomethin = false;
					case 'credits':
						selectedSomethin = false;
				}
		}
	}
	override function onKeyDown(justPressed:Bool, key:String) {
		// trace('Just Pressed: $justPressed; Key: $key');
		if (key == 'M') {
			selectedSomethin = true;
			// open(new Metronome());
		}
	}

	override function onBeatHit(beat:Int) {
		if (beat % 4 == 0) {
			Game.StateManager.gradient.alpha = .8;
			camera.zoom += .01;
		}
		camera.zoom += .01;
	}

	function changeSelection(huh:Int = 0, silent:Bool = false) {
		final prev:Int = cast curSelected;
		curSelected = Math.floor(Math.min(Math.max(curSelected + huh, 0), menuItems.length - 1));
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
