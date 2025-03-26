# VideoCollage
### **📽 Video Collage Maker**  

A SwiftUI-based iOS application that allows users to create a video collage from multiple selected videos. The app leverages **AVFoundation** to merge videos, provides export functionality, and ensures a clean UI with minimal controls.  

---

## **🚀 Features**  
✅ **Multi-Video Picker** – Select multiple videos from the gallery.  
✅ **Playback Controls** – Play/Pause videos using a single button.  
✅ **Hidden Media Controls** – Provides an immersive playback experience.  
✅ **Collage Creation** – Merges selected videos into a single collage.  
✅ **Video Export** – Saves the final collage with the shortest video’s duration.  
✅ **Export Progress Tracking** – Displays progress and success messages.  
✅ **MVVM Architecture** – Ensures clean and maintainable code.  

---

## **🛠 Tech Stack**  
- **Language:** Swift  
- **Framework:** SwiftUI  
- **Media Processing:** AVFoundation  
- **IDE:** Xcode  

---

## **📦 Installation**  
1. Clone the repository:  
   ```bash
   git clone https://github.com/your-username/VideoCollageMaker.git
   cd VideoCollageMaker
   ```
2. Open `VideoCollageMaker.xcodeproj` in Xcode.  
3. Run the project on a simulator or a real device.  

---

## **📌 Notes**  
- The export feature currently sets the final video duration based on the **shortest** selected video.  
- The app hides all video controls to provide a clean viewing experience.  

---

## **📝 Future Improvements**  
- Customizable collage layouts.  
- Option to set a fixed export duration.  
- Improved export quality and performance.  

---

### **📜 License**  
This project is open-source and available under the [MIT License](LICENSE).  

Feel free to contribute, report issues, or suggest improvements! 🚀
