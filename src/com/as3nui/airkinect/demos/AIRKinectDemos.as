/*
 * Copyright (c) 2012 AS3NUI
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is furnished to
 * do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies
 * or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 * OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

package com.as3nui.airkinect.demos {
	import com.as3nui.airkinect.demos.away3d.ElevationDemo;
	import com.as3nui.airkinect.demos.basic.BasicDemo;
	import com.as3nui.airkinect.demos.core.BaseDemo;
	import com.as3nui.airkinect.demos.mapping.SpaceMappingDemo;
	import com.as3nui.airkinect.demos.mask.MaskDemo;
	import com.as3nui.airkinect.demos.mask.MaskMappingDemo;
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
			private var _devMode:Boolean = false;
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

				_demos.push(BasicDemo);
				_demos.push(ElevationDemo);
				_demos.push(SpaceMappingDemo);
				_demos.push(PointCloudDemo);
				_demos.push(ThereminDemo);
				_demos.push(MaskDemo);
				_demos.push(MaskMappingDemo);

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
//				this.addChild(new BasicDemo());
//				this.addChild(new CompositeDemo());
//				this.addChild(new ThresholdDemo());
				//this.addChild(new ElevationDemo());
//				this.addChild(new SpaceMappingDemo());
//				this.addChild(new PointCloudDemo());
				//this.addChild(new ThereminDemo());
//				this.addChild(new MaskDemo());
//				this.addChild(new MaskMappingDemo());
//				this.addChild(new CorrectionProblemDemo());
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