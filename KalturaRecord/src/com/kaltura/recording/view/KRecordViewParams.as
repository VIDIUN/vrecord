package com.vidiun.recording.view
{
	public class VRecordViewParams
	{
		public var themeUrl:String;
		public var localeUrl:String;
		public var autoPreview:Boolean;
		
		public function VRecordViewParams(themeUrl:String, localeUrl:String, autoPreview:String)
		{
			this.themeUrl = themeUrl;
			this.localeUrl = localeUrl;
			this.autoPreview = (autoPreview == '1') || autoPreview == "true";
		}

	}
}