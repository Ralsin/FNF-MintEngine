package mint;

import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.FlxG;
import mint.helpers.Point;

/**
 * Extension to flixel.FlxCamera
 * Adds parallax (`parallaxActive`) and improves shake effect (use `screenshake()`).
 */
class Camera extends flixel.FlxCamera {
	/**
	 * Position of the Top-Left corner of the camera in the world.
	 */
	public var position:Point = new Point();

	/**
	 * Moves camera to this point with `moveFunction`.
	 */
	public var focusPoint:Point;

	/**
	 * Function which is used to move the camera to the focus point.
	 * Default is `return end`.
	 */
	dynamic public function moveFunction(start:Float, end:Float, time:Float):Float {
		return end;
	}

	/**
	 * Function which is used to control how force value behaves.
	 * `progress` - value from 0 to 1.
	 * `return force` - no fade, default value.
	 */
	dynamic public function shakeForceFade(force:Float, elapsed:Float, progress:Float):Float {
		return force;
	}

	var _shakeOffset:Point = new Point();
	var _shakeFullDuration:Float;
	var _shakeDuration:Float;
	var _shakeForce:Float;
	var _shakeInterval:Float;
	var _shakeIntervalPoint:Float;
	var _shakeAxes:FlxAxes;
	var _shakeType:ShakeType;
	var _shakeStepped:Bool = false;
	var _shakeCallback:() -> Void;

	var _parallaxOffset:Point = new Point();

	public var parallaxActive:Bool = false;
	public var parallaxMultiplier:Float = 10.;
	public var mouseWorldPos(default, null):FlxPoint = FlxPoint.get();

	public function new(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0, zoom:Float = 0) {
		super(x, y, width, height, zoom);
	}

	override function update(t:Float) {
		if (focusPoint != null) {
			position.x = moveFunction(position.x, focusPoint.x, t);
			position.y = moveFunction(position.y, focusPoint.y, t);
		}
		if (parallaxActive) {
			mouseWorldPos = FlxG.mouse.getWorldPosition();
			_parallaxOffset.x = (mouseWorldPos.x / FlxG.width - .5) * parallaxMultiplier;
			_parallaxOffset.y = (mouseWorldPos.y / FlxG.height - .5) * parallaxMultiplier;
		}
		updateShakeThing(t);
		scroll.set(position.x + _shakeOffset.x + _parallaxOffset.x, position.y + _shakeOffset.y + _parallaxOffset.y);
		super.update(t);
	}

	public function resetParallax(disable:Bool = true):Void {
		if (disable)
			parallaxActive = false;
		_parallaxOffset.x = 0.;
		_parallaxOffset.y = 0.;
	}

	public function screenshake(duration:Float = 1., force:Float = .05, interval:Float = 0., callback:() -> Void, type:ShakeType = Random,
			axes:FlxAxes = XY):Camera {
		_shakeDuration = _shakeFullDuration = duration;
		_shakeForce = force;
		_shakeInterval = interval;
		_shakeIntervalPoint = 0.;
		_shakeAxes = axes;
		_shakeType = type;
		_shakeStepped = FlxG.random.bool();
		_shakeCallback = callback;
		return this;
	}

	function updateShakeThing(t:Float):Void { // cat brain mrrp mrrp meow mrrp meow
		if (_shakeDuration > 0.) {
			_shakeDuration -= t;
			if (_shakeDuration <= 0) {
				_shakeOffset.x = 0.;
				_shakeOffset.y = 0.;
				if (_shakeCallback != null)
					_shakeCallback();
			}
			if (_shakeInterval != 0.) {
				if (_shakeIntervalPoint > _shakeInterval) {
					_shakeIntervalPoint = 0.;
					shakeThing();
				} else
					_shakeIntervalPoint += t;
			} else
				shakeThing();
			_shakeForce = shakeForceFade(_shakeForce, t, 1. - _shakeDuration / _shakeFullDuration);
		}
	}

	inline function shakeThing() {
		switch _shakeType {
			case Random:
				if (_shakeAxes.x)
					_shakeOffset.x = FlxG.random.float(-_shakeForce * width, _shakeForce * width) * zoom * FlxG.scaleMode.scale.x;
				if (_shakeAxes.y)
					_shakeOffset.y = FlxG.random.float(-_shakeForce * height, _shakeForce * height) * zoom * FlxG.scaleMode.scale.y;

			case Step:
				if (_shakeAxes.x)
					_shakeOffset.x = (_shakeStepped ? -_shakeForce : _shakeForce) * width * zoom * FlxG.scaleMode.scale.x;
				if (_shakeAxes.y)
					_shakeOffset.y = (_shakeStepped ? -_shakeForce : _shakeForce) * height * zoom * FlxG.scaleMode.scale.y;
				_shakeStepped = !_shakeStepped;
		}
	}
}

enum ShakeType {
	Random;
	Step;
}
