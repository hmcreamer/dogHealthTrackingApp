![alt text](https://github.com/hmcreamer/dogHealthTrackingApp/blob/main/DogHealthTracker/IMG_9451.JPG?raw=true)



# Description

I created this app to help track our dogs' medical history. It is pretty easy to forget when we last gave the dogs their flea preventative medicine and heartworm treatment. We also found that the vet does not consistently send reminders for when the dogs need to renew their vaccines or come in for checkups. This app aims to provide an easy way to track the dogs' medical history so we never miss a treatment or vaccine again!

---

# User Guide

## Dog Profiles
When the app opens, you will see a list of your current dog profiles. To add a new dog profile, select the **'plus' button**. To remove a dog profile, select the **'Edit' button**. To open a dog profile, simply select the dog profile you would like to view. 

The dog profile will contain:
- Basic information about the dog (birthday, weight, age).
- Treatment information that tells you when to renew the dog's flea treatment, heartworm treatment, and vaccines.

This dog profile aims to give you a quick way to view important information to keep your dog's health on track.

## Medical History
To view a more extensive history of the dog's health, select the **'View Medical History' button**. This will bring you to a list of medical events that have occurred for the dog. 
- To add a new medical event, select the **'plus' button**.
- To remove a medical event, select the **'Edit' button**.
- To view more details about the medical event, simply select the medical event.

## Medical Events
There are 5 types of medical events:
1. **Vaccine**
2. **Heartworm Treatment**
3. **Flea Treatment**
4. **Vet Visit**
5. **Other**

For each medical event, you can:
- Select the date it occurred.
- Add an expiration date.
- Set a reminder date.
- Include a description with additional details about the event.

---

# Instructions for Downloading on Your iPhone

1. **Connect Your iPhone to Your Mac**:
   - Use a Lightning cable to connect your iPhone to your Mac.
   - If prompted on your iPhone, tap **Trust This Computer** and enter your passcode.

2. **Enable Developer Mode on Your iPhone (iOS 16+)**:
   - On your iPhone, go to **Settings > Privacy & Security > Developer Mode** and enable it.
   - Restart your phone if necessary.

3. **Open Your Project in Xcode**:
   - Open your `.xcodeproj` or `.xcworkspace` file in Xcode.

4. **Select Your iPhone as the Build Target**:
   - In Xcode, click the **Device Selector** dropdown in the toolbar near the "Run" button.
   - Select your connected iPhone from the list of available devices.

5. **Set a Team in Signing & Capabilities**:
   - Click your project name in the **Project Navigator** (left panel).
   - Select your **app target** under the "Targets" section.
   - Go to the **Signing & Capabilities** tab.
   - Under the **Team** dropdown, select your Apple ID. 
     - If your Apple ID isn’t listed, click **Add an Account...**, sign in, and select it.

6. **Resolve Provisioning Profile Errors**:
   - Xcode will automatically create a free provisioning profile for you.
   - If an error appears, click **Fix Issue** to let Xcode resolve it.

7. **Build and Run the App**:
   - Press the **Run** button (the play triangle in the toolbar) or use the shortcut `Cmd + R`.
   - Xcode will build the app, sign it, and install it on your connected iPhone.

8. **Trust the Developer Certificate on Your iPhone**:
   - On your iPhone, go to **Settings > General > VPN & Device Management**.
   - Under **Developer App**, tap your Apple ID and select **Trust [Your Name]**.

9. **Run Your App**:
   - The app will appear on your iPhone’s home screen. Tap the icon to launch it.
