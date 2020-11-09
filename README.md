# midityper-fcb1010

This Ruby script lets you control your computer using the Behringer FCB1010 MIDI foot pedals. The FCB1010 has 12 pedals, rather than the 2 or 3 that most USB foot pedals have. Depending on location it costs $100-$200, making it rather affordable for what you get.

This script currently only supports Linux, but it should be pretty easy to port. It's also specific for the FBC1010 pedals, not other MIDI pedals. If you want to use it, you'll probably want to customize things, so just copy the code and modify to your liking.

## Demo

[![](http://img.youtube.com/vi/6KQyI_LWHXA/0.jpg)](http://www.youtube.com/watch?v=6KQyI_LWHXA "Demo video on Youtube")

## Why?

With these pedals you can do a lot of simple tasks, strongly reducing the amount of talking/typing required to get through the day. It's useful when you have bad RSI and want to type less. When using speech recognition it's also useful, to avoid voice strain. It currently supports:

- Switching between programs.
- Navigating the Thunderbird e-mail client.
- Page up, page down, arrow keys, pressing enter, next/previous browser tab, closing browser tabs.
- Clicking links and going back to the previous page (requires the Vimium extension for Chrome, or Tridactyl for Firefox).
- Navigating code in the Vim editor.

But it's easily customized. Anything you can do with a keyboard, you can do with these pedals, thanks to xdotool. It also includes a rudimentary interactive menu system, for storing a large amount of less often used commands.

## Getting started

Run `gem install unimidi`, clone this repository, run `./start.sh`and you're good to go. Assuming your MIDI interface calls itself USB2MIDI like mine (Alesis USB-MIDI link interface), the script will automatically stop and start when you connect/disconnect the USB cable.

You will likely end up customizing everything for your own workflow anyway, so I didn't bother splitting this up in configuration and code. Copy the code, read it, and modify to your liking.

If you start using this daily, make sure to read the disclaimer at the bottom of this page.

## Tips

Due to the layout of the foot pedals, it's easier when you take your shoes off. Less risk of accidentally hitting the wrong pedal. Also if let's you feel around to find the right pedal without needing to look, which lets you work a lot faster.

The FCB1010 sometimes sends multiple events for the same pedal. Therefore, the script ignores repeat events within a very short timeframe. Except for a few pedals like page up and page down, which are on a allow list of sorts.

If you use the FCB1010 many hours a day, every day, eventually the pedals will stop responding properly. I go through about one set of pedals every 2-3 years. But if you're handy with a soldering iron, according to this video (https://www.youtube.com/watch?v=R9CcfRYkGjY&) you can solder in sturdier buttons.

For the menu system, I usually have a terminal open on the side that's tailing the "choices" log output file. Hacky, but works well enough in a tiling window manager.

The FCB1010 is pretty bulky. For a more portable approach you may want to consider the Soleman pedals. It only has four pedals, but it can send separate MIDI events for key_down/key_up, so you can configure it to behave differently depending on how long you press the pedal. Justin Koningsberger wrote a [port](https://github.com/Justin-Koningsberger/midi_bank_controller), but Covid happened before we could test it, so it might not be 100% finished.

## Disclaimer

I'm not a doctor or ergonomics specialist. You can get RSI anywhere if you overdo it. I've had some lower back issues causing tingling feet. I'm not sure if using these pedals was also a cause, but just to be safe I'm not using it as much at the moment. On the other hand, I've used it extensively for several years before that, without issues. In general it's probably good advice to take frequent breaks and stop at the first sign of trouble.
