# Canvas

Hacking on the remains of [Canvas](https://github.com/usecanvas). Here’s a [video demo](https://www.youtube.com/watch?v=3RHQd4b1iPA) of what it was. Nothing to see yet though. I’m currently removing all of the stuff that depends on the server and updating to Swift 4.

## Goals

Here’s the steps I have in mind for this new version. I’ve been calling it "Canvas 2.0" which is kinda misleading since it will have less features than 1.0. Anyway, here’s my ideas for it sorta in order.

* **Local only.** Removing all of the sign in, sign up, account, realtime editing, presence, organizations, etc. to make the editor local only.
* **More sharing.** I had to remove all of the sharing options since the server did those before. It would be faily easy to add sharing as Markdown back. To HTML, shouldn't be too bad either.
* **iCloud Sync.** Once things are local only, let’s get syncing with iCloud setup.
* **macOS app.** After iOS is stripped down and working with iCloud, let’s add the macOS app. (Unless Apple does that crazy cross platform thing.)

There’s a lot of other things I’d like to do outside of the iOS & macOS apps. This is a good start though. The main thing that needs to be done at some point is reworking Canvas Native (the underlying format) to something more sane since we don’t have to support the old OT wire format.

## Building

You’ll need Xcode, [XcodeGen](https://github.com/yonaskolb/XcodeGen) to build Canvas. Simply run the following command for instructions:

    $ rake bootstrap

After this completes, simple open Canvas.xcodeproj and click ▶️

Enjoy.
