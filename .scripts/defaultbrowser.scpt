(*
  This script sets Firefox as the default browser. You can replace "firefox" with any browser name.
  https://www.felixparadis.com/posts/how-to-set-the-default-browser-from-the-command-line-on-a-mac/
*)

on run argv
	do shell script "/opt/homebrew/bin/defaultbrowser firefox"
	try
		tell application "System Events"
			tell application process "CoreServicesUIAgent"
				tell window 1
					tell (first button whose name starts with "use")
						perform action "AXPress"
					end tell
				end tell
			end tell
		end tell
	end try
end run
