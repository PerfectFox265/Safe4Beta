using Godot;

// Remember to include System and System.Runtime.InteropServices
using System;
using System.Runtime.InteropServices;


public partial class SetupClickThrough : Node
{
	// GetActiveWindow() retrieves the handle of the window. 
	[DllImport("user32.dll")]
	public static extern IntPtr GetActiveWindow();

	// SetWindowLong() modifies a specific flag value associated with a window.
	// We pass the window handle, the index of the property, and the flags the property will have
	[DllImport("user32.dll")]
	private static extern int SetWindowLong(IntPtr hWnd, int nIndex, long dwNewLong);
	[DllImport("user32.dll")]
	private static extern uint GetWindowLong(IntPtr hWnd, int nIndex);
	
	[DllImport("user32.dll", EntryPoint = "SetLayeredWindowAttributes")]
	static extern int SetLayeredWindowAttributes(IntPtr hwnd, UInt32 crKey, byte bAlpha, uint dwFlags);
	
	// This is the index of the property we want to modify
	private const int GwlExStyle = -20;
	
	// The flags we want to set
	private const long WsExLayered = 0x00080000L;			// Makes the window "layered"
	private const long WsExTransparent = 0x00000020L;		// Makes the window "clickable through"
	
	private const long WS_EX_NOACTIVATE = 0x08000000L;   // A top-level window created with this style does not become the foreground window when the user clicks it.
	private const long WS_EX_NOREDIRECTIONBITMAP = 0x00200000L;   


	private const uint LWA_COLORKEY = 1;
	private const uint Background_transparent_color = 0x00000000;


	// check https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles 

	// This is the variable containing the window handle
	private IntPtr _hWnd;
	[DllImport("user32.dll", EntryPoint = "SetWindowDisplayAffinity")]
	private static extern int SetWindowDisplayAffinity(IntPtr hwnd, int dwAffinity);
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// We store the window handle
		_hWnd = GetActiveWindow();
		// We can set the properties already from here
		SetWindowLong(_hWnd, GwlExStyle, 
			GetWindowLong(_hWnd, GwlExStyle) | WsExLayered | WsExTransparent);
		//SetLayeredWindowAttributes(_hWnd, 0, 100, LWA_ALPHA);
		//SetLayeredWindowAttributes(_hWnd, Background_transparent_color, 0, LWA_COLORKEY);
		//int WDA_EXCLUDEFROMCAPTURE = 0x00000011;
		//SetWindowDisplayAffinity(_hWnd, WDA_EXCLUDEFROMCAPTURE);
	}
}
