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
	private static extern int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);
	
	
	[DllImport("user32.dll", EntryPoint = "SetLayeredWindowAttributes")]
	static extern int SetLayeredWindowAttributes(IntPtr hwnd, int crKey, byte bAlpha, uint dwFlags);
	
	// This is the index of the property we want to modify
	private const int GwlExStyle = -20;
	
	// The flags we want to set
	private const uint WsExLayered = 0x00080000;			// Makes the window "layered"
	private const uint WsExTransparent = 0x00000020;		// Makes the window "clickable through"
	
	private const uint WS_EX_NOACTIVATE = 0x08000000;   // A top-level window created with this style does not become the foreground window when the user clicks it.
	private const uint LWA_ALPHA = 2;

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
		SetWindowLong(_hWnd, GwlExStyle, WsExLayered | WsExTransparent | WS_EX_NOACTIVATE);
		SetLayeredWindowAttributes(_hWnd, 0, 255, LWA_ALPHA);
		// WDA_EXCLUDEFROMCAPTURE = 0x00000011
		SetWindowDisplayAffinity(_hWnd, 0x00000011);
	}
}
