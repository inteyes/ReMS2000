## Re:MS2000
Here it is - free and open source Korg MS2000 MIDI editor and librarian panel.
### What is implemented
- [X] Program management
  - Save / load single programs and patch banks to / from disk
  - Transmit / receive single programs and patch banks to / from the MS2000
- [X] Access to all "Edit (LCD) Mode" parameters
- [X] Sequence editor
- [X] Recalling parameters on project load (must be activated in the panel settings first)
- [X] Vocoder mode
### What is in development
- [ ] Transferring data between timbres
- [ ] Interface tuning
### Beta version
This is a beta version and may contain bugs. Feel free to report if you found any. Details of what happened and under what circumstances are highly appreciated. 
### Quick start
- Synthesizer side
  - Global options - 2A Memory Protect - Off
  - Global options - 3A MIDI Ch - your choice
  - Global options - 4D MIDI Filter SystemEx - Enable
- Panel side:
  - Open panel
  - Set MIDI Input, MIDI Output, MIDI Channel (which you set above)

I also suggest you to change synthesizer clock mode to "External" before transmitting / receiving bulk dump data to avoid data errors.

At this point the panel is ready to work!
### Afterword
This panel was created using great [Ctrlr software](https://github.com/RomanKubiak/ctrlr) by Roman Kubiak. While you are able to run Ctrlr on your system - you are able to run this panel. Release will be packed with source .panel file.

Exported instances (standalone, vst32, vst64) will be provided only for single platform - Windows.

Have fun using your MS2000!
