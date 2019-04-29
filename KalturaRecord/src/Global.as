package {

	import com.vidiun.VidiunClient;
	import com.vidiun.recording.controller.IRecordControl;
	import com.vidiun.recording.view.VRecordViewParams;
	import com.vidiun.recording.view.Theme;
	import com.vidiun.utils.Locale;


	public class Global {

		static public var PRELOADER:PreloaderSkin;
		static public var VIEW_PARAMS:VRecordViewParams;
		static public var THEME:Theme;
		static public var LOCALE:Locale;
		static public var RECORD_CONTROL:IRecordControl;
		static public var VIDIUN_CLIENT:VidiunClient;
		static public var DISABLE_GLOBAL_CLICK:Boolean = false;
		
		/**
		 * hide ui controls of the preview player 
		 */
		static public var REMOVE_PLAYER:Boolean = false;
		
		/**
		 * show timer during preview 
		 */
		static public var SHOW_PREVIEW_TIMER:Boolean = false;
		
		/**
		 * delay before initial camera test (allowing hardware to activate).
		 * the delay after a failed test is double.
		 */
		static public var DETECTION_DELAY:uint;
		
		/**
		 * show additional debug traces 
		 */
		static public var DEBUG_MODE:Boolean = false;
	}
}