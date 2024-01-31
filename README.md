# WinPE BIOS-Settings (Lenovo Thinkpad)

The PowerShell Scripts in this repo will allow you to make changes to the Lenovo BIOS (including **setting an inital password** (if you did some research on this topic you know that this is pretty difficult 😉))

## Setup and requirements

First you need to make a WinPE image with PowerShell.
For this you need the Windows ADK and WinPE-Addon.
I followed [Microsoft's official guide](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install) to set this up

Now you need to create a WinPE image and add the PowerShell to the image. I also followed [Microsoft's official guide](https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-adding-powershell-support-to-windows-pe) with some quirks, which I will describe.

1. Start the Deployment and Imaging Tools Environment as an administrator.
2. Create a working copy of the WinPE files:
    ```cmd
    copype [architecture] [directory]
    ```
3. Now you mount your WinPE image to make neccessary changes:
    ```cmd
    Dism /Mount-Image /ImageFile:"[directory]\media\sources\boot.wim" /Index:1 /    MountDir:"X:\"
    ```