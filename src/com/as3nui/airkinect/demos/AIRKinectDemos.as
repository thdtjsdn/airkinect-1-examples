/**
 *
 * User: rgerbasi
 * Date: 12/19/11
 * Time: 3:31 PM
 */
package com.as3nui.airkinect.demos {
	import com.as3nui.airkinect.demos.away3d.ElevationDemo;
	import com.as3nui.airkinect.demos.composite.CompositeDemo;
	import com.as3nui.airkinect.demos.composite.ThresholdDemo;
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.airkinect.demos.mapping.SpaceMappingDemo;
	import com.as3nui.airkinect.demos.pointcloud.PointCloudDemo;
	import com.as3nui.airkinect.demos.sound.ThereminDemo;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;

	public class AIRKinectDemos extends Sprite {
			private var _devMode:Boolean = true;
			private var _currentDemoIndex:int;

			private var _demos:Vector.<Class>;
			private var _demoText:TextField;

			public function AIRKinectDemos() {
				this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage)
			}

			private function onAddedToStage(event:Event):void {
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;

				if(_devMode) {
					loadDemo()
				}else{
					initDemos();
					_currentDemoIndex = 0;
					loadNextDemo();
				}
			}

			private function initDemos():void {
				_demoText = new TextField();
				_demoText.autoSize = TextFieldAutoSize.LEFT;
				_demoText.textColor = 0x000000;

				_demos = new <Class>[];

				_demos.push(ElevationDemo);
				_demos.push(SpaceMappingDemo);
				_demos.push(PointCloudDemo);
				_demos.push(ThereminDemo);

				stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp)
			}

			private function onKeyUp(event:KeyboardEvent):void {
				if(event.keyCode != Keyboard.RIGHT && event.keyCode != Keyboard.LEFT && (event.keyCode < 48 || event.keyCode >57)) return;

				if(event.keyCode == Keyboard.RIGHT){
					_currentDemoIndex++;
				}else if(event.keyCode == Keyboard.LEFT){
					_currentDemoIndex--;
				//Number Keys
				}else if(event.keyCode >= 48 && event.keyCode <= 57){

					_currentDemoIndex = event.keyCode - 48;
					if(_currentDemoIndex == 0) _currentDemoIndex = 10;
					_currentDemoIndex--;
					if(event.shiftKey) _currentDemoIndex += 10;
				}

				if(_currentDemoIndex < 0) _currentDemoIndex = _demos.length -1;
				if(_currentDemoIndex >= _demos.length) _currentDemoIndex = 0;

				loadNextDemo();
			}

			private function loadDemo():void {
				// Pointcloud Demo
//				this.addChild(new CompositeDemo());
				this.addChild(new ThresholdDemo());
				//this.addChild(new ElevationDemo());
				//this.addChild(new SpaceMappingDemo());
				//this.addChild(new PointCloudDemo());
				//this.addChild(new ThereminDemo());
			}

			private function loadNextDemo():void {
				this.removeChildren();
				var currentDemo:BaseDemo = new _demos[_currentDemoIndex]();
				currentDemo.y = 20;
				this.addChild(currentDemo);

				this.addChild(_demoText);
				_demoText.text = currentDemo.demoName;
			}
		}
	}