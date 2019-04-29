package com.vidiun.recording.view 
{

	import com.vidiun.net.streaming.events.RecordNetStreamEvent;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.text.TextField;


	/**
	 * user interface for preview; buttons and handlers.
	 * button skins are taken from the loaded skin file according to instance names.
	 */
	public class PreviewPlayer extends UIComponent {

		public static const PREVIEW_UPDATE_PLAYHEAD:String = "previewUpdatePlayhead"
		public static const PREVIEW_DONE:String = "previewDone"
		public static const PREVIEW_STOPPED:String = "previewStopped"
			
		// ui elements:
		public var buttonSave:Button;
		public var buttonReRecord:Button;
		public var buttonPlay:Button;
		public var buttonPause:Button;
		public var buttonStop:Button;
		public var progressBar:ProgressBar;
		public var textProgress:TextField;

		private var _playheadTime:String;
		
		/**
		 * formatted representation of current playhead time 
		 */		
		public function get playheadTime():String {
			return _playheadTime;
		}

		/**
		 * C'tor 
		 * @param skin
		 */
		public function PreviewPlayer(skin:MovieClip) {
			super(skin);
		}


		override protected function redraw():void {
			super.redraw();
			buttonSave = new Button(_skin["buttonSave"]);
			buttonSave.name = "buttonSave";
			if (!Global.REMOVE_PLAYER)
				_skin.addChild(buttonSave);

			buttonReRecord = new Button(_skin["buttonReRecord"]);
			buttonReRecord.name = "buttonReRecord";
			if (!Global.REMOVE_PLAYER)
				_skin.addChild(buttonReRecord);

			buttonPlay = new Button(_skin["buttonPlay"]);
			buttonPlay.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
			buttonPlay.name = "buttonPlay";
			buttonPlay.visible = true;
			if (!Global.REMOVE_PLAYER)
				_skin.addChild(buttonPlay);

			buttonPause = new Button(_skin["buttonPause"]);
			//		buttonPause.addEventListener( MouseEvent.CLICK, onMouseClick, false, 0, true );
			buttonPause.name = "buttonPause";
			buttonPause.visible = false;
			if (!Global.REMOVE_PLAYER)
				_skin.addChild(buttonPause);

			buttonStop = new Button(_skin["buttonStop"]);
			buttonStop.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
			buttonStop.name = "buttonStop";
			buttonStop.visible = false;
			if (!Global.REMOVE_PLAYER)
				_skin.addChild(buttonStop)

			progressBar = new ProgressBar(_skin["progressBar"]);
//			progressBar.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
			progressBar.name = "progressBar";
			if (!Global.REMOVE_PLAYER)
				_skin.addChild(progressBar);

			textProgress = _skin["textProgress"];
		}


		private function onMouseClick(evt:MouseEvent):void {
			if (evt.target == buttonPlay)
				play(evt);
			if (evt.target == buttonStop)
				stop();
			if (evt.target == progressBar)
				seek(getSeekSeconds());
		}

		
		/**
		 * updates the total recorded time on screen 
		 */
		public function updateTotalTime():void {
			updateProgress();
		}

		
		public function play(evt:MouseEvent = null):void {
			if (!playing) {
				buttonPlay.visible = false;
				buttonStop.visible = true;
				//			buttonPause.visible = true;

				if (_state == "pause") {
					Global.RECORD_CONTROL.resume();
				}
				else {
					this.addEventListener(Event.ENTER_FRAME, onProgress, false, 0, true);
					Global.RECORD_CONTROL.addEventListener(RecordNetStreamEvent.NETSTREAM_PLAY_COMPLETE, onPreviewComplete, false, 0, true);

					if (evt) //if it is a click do preview (before this preview was called twice
						Global.RECORD_CONTROL.previewRecording();
				}
				_state = "play";
			}
		}


		// p = 0 -> 1
		private function getSeekSeconds():Number {
			var ms:Number = progressBar.getProgress() * Global.RECORD_CONTROL.recordedTime;
			var s:Number = Math.floor(ms / 1000);

			return (s);
		}


		public function seek(offset:Number):void {
			pause();
			Global.RECORD_CONTROL.seek(offset);
			play();
		}


		public function pause():void {
			if (!paused) {
				buttonPlay.visible = true;
				buttonStop.visible = false;
				Global.RECORD_CONTROL.pausePreviewRecording();
				_state = "pause";
			}
		}


		public function stop():void {
			if (!stopped) {
				buttonPlay.visible = true;
				buttonStop.visible = false;
				this.removeEventListener(Event.ENTER_FRAME, onProgress);
				Global.RECORD_CONTROL.removeEventListener(RecordNetStreamEvent.NETSTREAM_PLAY_COMPLETE, onPreviewComplete);
				Global.RECORD_CONTROL.stopPreviewRecording();
				Global.RECORD_CONTROL.clearVideoAndSetCamera();
				updateProgress(0);
				_state = "stop";
				dispatchEvent(new Event(PREVIEW_STOPPED));
			}
		}


		public function get playing():Boolean {
			return (_state == "play");
		}


		public function get paused():Boolean {
			return (_state == "pause");
		}


		public function get stopped():Boolean {
			return (_state == "stop");
		}


		private function onProgress(evt:Event):void {
			updateProgress();
		}


		private function updateProgress(p:Number = -1):void {
			_playheadTime = "00:00:00";

			if (p < 0) {
				p = Global.RECORD_CONTROL.playheadTime * 1000 / Global.RECORD_CONTROL.recordedTime;
				_playheadTime = (formatTime(Global.RECORD_CONTROL.playheadTime * 1000));
			}

			var recordedTime:String = formatTime(Global.RECORD_CONTROL.recordedTime);
			progressBar.setProgress(p);
			if (_playheadTime <= recordedTime)
				textProgress.text = _playheadTime + " / " + recordedTime;
			else
				trace("_playheadTime: " + _playheadTime);

			dispatchEvent(new Event(PREVIEW_UPDATE_PLAYHEAD));
		}


		private function onPreviewComplete(evt:Event):void {
			stop();
			dispatchEvent(new Event(PREVIEW_DONE));
		}


		private function formatTime(ms:Number):String {
			var formatted:String;
			var sec:Number = Math.floor(ms / 1000);
			var min:Number = Math.floor(sec / 60);
			var hour:Number = Math.floor(min / 60);

			sec = sec - (min * 60);
			if (min >= 60)
				min = min - (hour * 60);

			var secString:String = String(sec);
			var hourString:String = String(hour);

			var minString:String = String(min);

			secString = (secString.length == 1) ? "0" + secString : secString;
			minString = (minString.length == 1) ? "0" + minString : minString;
			hourString = (hourString.length == 1) ? "0" + hourString : hourString;

			formatted = hourString + ":" + minString + ":" + secString;

			return (formatted);
		}


		override protected function validateSkin(skin:MovieClip):Boolean {
			if (skin["buttonSave"] && skin["buttonReRecord"] && skin["buttonPlay"] && skin["textProgress"] && skin["progressBar"])
				return (true);
			else
				return (false);
		}
	}
}
