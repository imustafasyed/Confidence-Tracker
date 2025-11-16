// Confidence Tracker Animation v2.0
// This program visualizes how user confidence changes when educational tools are updated
// Author: Mustafa Syed

import processing.sound.*;          // Import Sound library (must be installed first)

// Global variables to track confidence and animation state
ConfidenceBar confidenceBar;        // The main confidence visualization bar
UpdateSimulator updateSystem;       // Handles simulated system updates
MessageDisplay messageDisplay;      // Shows messages to the user
UpdateLog updateLog;                // Displays history of all updates
AudioFeedback audioFeedback;        // Handles psychological audio feedback
int updateCounter = 0;              // Counts how many updates have occurred
boolean autoMode = true;            // Whether updates happen automatically
int lastUpdateTime = 0;             // Tracks when the last update happened
int updateInterval = 5000;          // Time between auto updates (5 seconds)

// Setup runs once at the beginning
void setup() {
  size(1000, 600);                  // Create a window 1000 pixels wide, 600 pixels tall
  smooth();                         // Enable anti-aliasing for smoother graphics
  
  // Create instances of our main objects
  confidenceBar = new ConfidenceBar(125, 220, 500, 70);  // Adjusted for better proportions
  updateSystem = new UpdateSimulator();
  messageDisplay = new MessageDisplay(375, 420);         // Repositioned
  updateLog = new UpdateLog(800, 74, 220, 420);         // Adjusted dimensions
  audioFeedback = new AudioFeedback(this);               // Pass 'this' to access sound
  
  // Start with a welcome message
  messageDisplay.showMessage("Welcome! Watch how confidence changes with system updates.", color(100, 100, 255));
}

// Draw runs continuously (about 60 times per second)
void draw() {
  background(245);                  // Light gray background
  
  // Draw title at the top
  drawTitle();
  
  // Update and display the confidence bar
  confidenceBar.update();
  confidenceBar.display();
  
  // Display the current message
  messageDisplay.display();
  
  // Display the update log
  updateLog.display();
  
  // Draw instructions at the bottom
  drawInstructions();
  
  // Draw update counter
  drawUpdateCounter();
  
  // Handle automatic updates if auto mode is on
  if (autoMode) {
    // Check if enough time has passed since last update
    if (millis() - lastUpdateTime > updateInterval) {
      triggerUpdate();              // Trigger a new update
      lastUpdateTime = millis();    // Record the current time
    }
  }
}

// This function runs when the user clicks the mouse
void mousePressed() {
  // Check if click is on the trigger update button (negative)
  if (mouseX > 50 && mouseX < 230 && mouseY > 520 && mouseY < 560) {
    triggerUpdate();                // Trigger an update manually
  }
  
  // Check if click is on the success button (positive)
  if (mouseX > 250 && mouseX < 430 && mouseY > 520 && mouseY < 560) {
    triggerSuccess();               // User successfully completed a task
  }
  
  // Check if click is on the help button (positive)
  if (mouseX > 450 && mouseX < 630 && mouseY > 520 && mouseY < 560) {
    triggerHelp();                  // User found helpful resources
  }
  
  // Check if click is on the toggle mode button
  if (mouseX > 650 && mouseX < 780 && mouseY > 520 && mouseY < 560) {
    autoMode = !autoMode;           // Switch between auto and manual mode
    if (autoMode) {
      lastUpdateTime = millis();    // Reset timer when switching to auto
    }
  }
  
  // Handle scrollbar clicks
  updateLog.handleMousePressed();
}

// This function runs when the user releases the mouse
void mouseReleased() {
  updateLog.handleMouseReleased();
}

// This function runs when the user drags the mouse
void mouseDragged() {
  updateLog.handleMouseDragged();
}

// This function runs when the user scrolls the mouse wheel
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  updateLog.handleMouseWheel(e);
}

// Trigger a simulated system update
void triggerUpdate() {
  updateCounter++;                  // Increase the update count
  
  // Get a random update event from our system
  UpdateEvent event = updateSystem.generateUpdate();
  
  // Apply the confidence change
  confidenceBar.changeConfidence(event.confidenceChange);
  
  // Show the message with appropriate color
  color messageColor = event.confidenceChange < 0 ? color(200, 50, 50) : color(50, 150, 50);
  messageDisplay.showMessage(event.message, messageColor);
  
  // Add to the update log
  updateLog.addEntry(event.type, event.confidenceChange);
  
  // Play psychological audio feedback
  audioFeedback.playNegativeSound();
}

// Trigger a successful use of the system (increases confidence)
void triggerSuccess() {
  // Using the system successfully builds confidence gradually
  confidenceBar.changeConfidence(8);
  messageDisplay.showMessage("Successfully completed a task - confidence building!", color(50, 180, 80));
  
  // Add to the update log
  updateLog.addEntry("Task Completed", 8);
  
  // Play psychological audio feedback
  audioFeedback.playPositiveSound();
}

// Trigger finding help or tutorial (increases confidence)
void triggerHelp() {
  // Finding help resources boosts confidence
  confidenceBar.changeConfidence(12);
  messageDisplay.showMessage("Found helpful tutorial - understanding improved!", color(50, 150, 200));
  
  // Add to the update log
  updateLog.addEntry("Help Found", 12);
  
  // Play psychological audio feedback
  audioFeedback.playHelpSound();
}

// Draw the title at the top of the screen
void drawTitle() {
  fill(50);                         // Dark gray text
  textAlign(CENTER);
  textSize(24);
  text("Confidence Tracker: Educational Tool Updates", 325, 40);
  
  textSize(14);
  fill(100);
  text("Visualizing how frequent system changes affect user confidence", 325, 65);
}

// Draw instructions at the bottom
void drawInstructions() {
  // Manual update button (negative change)
  fill(200, 100, 100);
  rect(50, 520, 180, 40, 5);
  fill(255);
  textAlign(CENTER);
  textSize(14);
  text("Trigger Update", 140, 545);
  
  // Success button (positive change)
  fill(100, 200, 120);
  rect(250, 520, 180, 40, 5);
  fill(255);
  text("Use Successfully", 340, 545);
  
  // Help button (positive change)
  fill(100, 180, 200);
  rect(450, 520, 180, 40, 5);
  fill(255);
  text("Find Help/Tutorial", 540, 545);
  
  // Toggle mode button
  fill(150, 100, 200);
  rect(650, 520, 130, 40, 5);
  fill(255);
  String modeText = autoMode ? "AUTO" : "MANUAL";
  text(modeText, 715, 545);
}

// Draw the update counter
void drawUpdateCounter() {
  fill(80);
  textAlign(LEFT);
  textSize(16);
  text("Total Updates: " + updateCounter, 50, 150);
}

// ============================================
// CLASS: ConfidenceBar
// This class represents the visual confidence bar
// ============================================
class ConfidenceBar {
  float x, y;                       // Position on screen
  float maxWidth, height;           // Size of the bar
  float currentConfidence;          // Current confidence level (0-100)
  float targetConfidence;           // Where confidence is moving toward
  float barWidth;                   // Current width of the bar
  
  // Constructor - sets up the confidence bar
  ConfidenceBar(float x, float y, float maxWidth, float height) {
    this.x = x;
    this.y = y;
    this.maxWidth = maxWidth;
    this.height = height;
    this.currentConfidence = 75;    // Start at 75% confidence
    this.targetConfidence = 75;
    this.barWidth = maxWidth * 0.75;
  }
  
  // Update the bar's animation
  void update() {
    // Smoothly move current confidence toward target
    currentConfidence += (targetConfidence - currentConfidence) * 0.05;
    
    // Calculate bar width based on confidence percentage
    barWidth = maxWidth * (currentConfidence / 100.0);
  }
  
  // Change the confidence level
  void changeConfidence(float change) {
    targetConfidence += change;
    
    // Keep confidence between 0 and 100
    targetConfidence = constrain(targetConfidence, 0, 100);
  }
  
  // Draw the confidence bar on screen
  void display() {
    // Draw background bar (gray)
    fill(220);
    rect(x, y, maxWidth, height, 5);
    
    // Calculate color based on confidence level
    // Green when high, yellow when medium, red when low
    color barColor = getConfidenceColor(currentConfidence);
    
    // Draw the actual confidence bar
    fill(barColor);
    rect(x, y, barWidth, height, 5);
    
    // Draw border
    noFill();
    stroke(100);
    strokeWeight(2);
    rect(x, y, maxWidth, height, 5);
    noStroke();
    
    // Draw label
    fill(50);
    textAlign(CENTER);
    textSize(18);
    text("User Confidence Level", x + maxWidth/2, y - 20);
    
    // Draw percentage
    textSize(24);
    text(int(currentConfidence) + "%", x + maxWidth/2, y + height/2 + 8);
    
    // Draw confidence markers
    drawMarkers();
  }
  
  // Get color based on confidence level
  color getConfidenceColor(float confidence) {
    if (confidence > 70) {
      // Green for high confidence
      return color(80, 200, 120);
    } else if (confidence > 40) {
      // Yellow for medium confidence
      return color(240, 200, 80);
    } else {
      // Red for low confidence
      return color(230, 80, 80);
    }
  }
  
  // Draw scale markers on the bar
  void drawMarkers() {
    textSize(10);
    fill(100);
    textAlign(CENTER);
    
    // 0% marker
    text("0%", x, y + height + 15);
    
    // 50% marker
    text("50%", x + maxWidth/2, y + height + 15);
    
    // 100% marker
    text("100%", x + maxWidth, y + height + 15);
  }
}

// ============================================
// CLASS: UpdateSimulator
// This class generates different types of updates
// ============================================
class UpdateSimulator {
  String[] updateTypes;             // Array of possible update types
  String[] updateMessages;          // Messages for each update type
  float[] confidenceChanges;        // How much each update affects confidence
  
  // Constructor - sets up the different update scenarios
  UpdateSimulator() {
    // Define different types of updates
    updateTypes = new String[] {
      "Interface Redesign",
      "Menu Relocation",
      "New Feature Added",
      "Minor Bug Fix",
      "Complete Layout Change",
      "Settings Menu Moved",
      "Helpful Tutorial Added",
      "Color Scheme Changed"
    };
    
    // Messages explaining each update
    updateMessages = new String[] {
      "Major interface redesign - navigation changed entirely",
      "Menu items moved to different locations - confusing",
      "New feature added without explanation - uncertain",
      "Small bug fix - system feels more stable",
      "Complete layout overhaul - need to relearn everything",
      "Settings hidden in new location - frustrating",
      "Helpful tutorial provided - understanding improved",
      "Visual changes only - minor adjustment needed"
    };
    
    // How much each update changes confidence (-20 to +10)
    confidenceChanges = new float[] {
      -15,  // Interface Redesign
      -12,  // Menu Relocation
      -8,   // New Feature
      +5,   // Bug Fix
      -20,  // Complete Layout Change
      -10,  // Settings Moved
      +10,  // Tutorial Added
      -5    // Color Scheme
    };
  }
  
  // Generate a random update event
  UpdateEvent generateUpdate() {
    // Pick a random update type
    int index = int(random(updateTypes.length));
    
    // Create and return a new update event
    return new UpdateEvent(
      updateTypes[index],
      updateMessages[index],
      confidenceChanges[index]
    );
  }
}

// ============================================
// CLASS: UpdateEvent
// Represents a single system update event
// ============================================
class UpdateEvent {
  String type;                      // Type of update
  String message;                   // Message to display
  float confidenceChange;           // How much confidence changes
  
  // Constructor
  UpdateEvent(String type, String message, float confidenceChange) {
    this.type = type;
    this.message = message;
    this.confidenceChange = confidenceChange;
  }
}

// ============================================
// CLASS: MessageDisplay
// Shows messages to the user about what's happening
// ============================================
class MessageDisplay {
  float x, y;                       // Position on screen
  String currentMessage;            // The message to display
  color messageColor;               // Color of the message
  int displayTime;                  // How long to show message
  int startTime;                    // When message started showing
  
  // Constructor
  MessageDisplay(float x, float y) {
    this.x = x;
    this.y = y;
    this.currentMessage = "";
    this.messageColor = color(100);
    this.displayTime = 4000;        // Show messages for 4 seconds
    this.startTime = 0;
  }
  
  // Show a new message
  void showMessage(String message, color msgColor) {
    this.currentMessage = message;
    this.messageColor = msgColor;
    this.startTime = millis();      // Record when message started
  }
  
  // Display the message on screen
  void display() {
    // Only show if message is recent
    if (millis() - startTime < displayTime) {
      // Draw background box for message
      fill(255, 255, 255, 200);
      stroke(100);
      strokeWeight(0.2);
      rectMode(CENTER);
      rect(x, y, 600, 60, 10);
      rectMode(CORNER); // add stroke here
      
      // Draw the message text
      fill(messageColor);
      textAlign(CENTER);
      textSize(16);
      text(currentMessage, x, y + 5);
    }
  }
}

// ============================================
// CLASS: UpdateLog
// Shows a scrolling history of all updates
// ============================================
class UpdateLog {
  float x, y;                       // Position on screen
  float w, h;                       // Width and height of log panel
  String[] events;                  // Array of event names
  float[] changes;                  // Array of confidence changes
  String[] times;                   // Array of timestamps
  int maxEntries = 50;              // Maximum number of entries to store
  int visibleEntries = 10;          // Number of entries visible at once
  int count = 0;                    // Current number of entries
  int scrollOffset = 0;             // Current scroll position
  boolean draggingScrollbar = false;// Is user dragging the scrollbar
  
  // Constructor - sets up the update log
  UpdateLog(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    // Initialize arrays to hold log entries
    events = new String[maxEntries];
    changes = new float[maxEntries];
    times = new String[maxEntries];
  }
  
  // Add a new entry to the log
  void addEntry(String event, float change) {
    // Shift all entries down to make room at the top
    for (int i = maxEntries - 1; i > 0; i--) {
      events[i] = events[i - 1];
      changes[i] = changes[i - 1];
      times[i] = times[i - 1];
    }
    
    // Add new entry at the top
    events[0] = event;
    changes[0] = change;
    times[0] = getTimeStamp();
    
    // Increase count up to maximum
    if (count < maxEntries) {
      count++;
    }
    
    // Reset scroll to top when new entry is added
    scrollOffset = 0;
  }
  
  // Get a formatted timestamp
  String getTimeStamp() {
    int totalSeconds = millis() / 1000;
    int minutes = totalSeconds / 60;
    int seconds = totalSeconds % 60;
    return nf(minutes, 2) + ":" + nf(seconds, 2);
  }
  
  // Handle mouse wheel scrolling
  void handleMouseWheel(float e) {
    // Check if mouse is over the log panel
    if (mouseX > x - w/2 && mouseX < x + w/2 && mouseY > y && mouseY < y + h) {
      // Scroll up or down
      scrollOffset -= int(e);
      // Keep scroll within bounds
      scrollOffset = constrain(scrollOffset, 0, max(0, count - visibleEntries));
    }
  }
  
  // Handle scrollbar dragging
  void handleMousePressed() {
    // Check if clicking on scrollbar
    if (count > visibleEntries) {
      float scrollbarX = x + w/2 - 12;
      float scrollbarY = y + 40 + getScrollbarY();
      float scrollbarHeight = getScrollbarHeight();
      
      // Made the clickable area wider for easier grabbing
      if (mouseX > scrollbarX - 2 && mouseX < scrollbarX + 8 && 
          mouseY > scrollbarY && mouseY < scrollbarY + scrollbarHeight) {
        draggingScrollbar = true;
      }
    }
  }
  
  // Handle scrollbar release
  void handleMouseReleased() {
    draggingScrollbar = false;
  }
  
  // Handle scrollbar dragging motion
  void handleMouseDragged() {
    if (draggingScrollbar && count > visibleEntries) {
      float scrollAreaHeight = h - 90;
      float scrollbarHeight = getScrollbarHeight();
      float maxScrollY = scrollAreaHeight - scrollbarHeight;
      
      // Calculate new scroll position based on mouse Y
      float relativeY = mouseY - (y + 40);
      float scrollPercent = relativeY / maxScrollY;
      scrollOffset = int(scrollPercent * (count - visibleEntries));
      scrollOffset = constrain(scrollOffset, 0, count - visibleEntries);
    }
  }
  
  // Calculate scrollbar height based on content
  float getScrollbarHeight() {
    float scrollAreaHeight = h - 90;
    float ratio = float(visibleEntries) / float(count);
    return max(20, scrollAreaHeight * ratio);
  }
  
  // Calculate scrollbar Y position
  float getScrollbarY() {
    if (count <= visibleEntries) return 0;
    float scrollAreaHeight = h - 90;
    float scrollbarHeight = getScrollbarHeight();
    float maxScrollY = scrollAreaHeight - scrollbarHeight;
    float scrollPercent = float(scrollOffset) / float(count - visibleEntries);
    return scrollPercent * maxScrollY;
  }
  
  // Display the log panel
  void display() {
    // Draw background panel
    fill(255);
    stroke(100);
    strokeWeight(1);
    rect(x - w/2, y, w, h, 10);
    noStroke();
    
    // Draw header
    fill(70);
    textAlign(CENTER);
    textSize(14);
    text("Update History", x, y + 20);
    
    // Draw a dividing line
    stroke(200);
    strokeWeight(1);
    line(x - w/2 + 10, y + 30, x + w/2 - 10, y + 30);
    noStroke();
    
    // Create clipping area for entries
    clip(x - w/2 + 5, y + 10, w - 20, h - 20);
    
    // Draw each log entry (only visible ones based on scroll)
    float entryY = y + 45 - (scrollOffset * 35);
    float entryHeight = 35;
    
    for (int i = 0; i < count; i++) {
      // Only draw if entry is within visible area
      if (entryY + entryHeight > y + 40 && entryY < y + h) {
        // Draw entry background (alternate colors)
        if (i % 2 == 0) {
          fill(248);
        } else {
          fill(255);
        }
        rect(x - w/2 + 5, entryY, w - 20, entryHeight);
        
        // Draw timestamp
        fill(120);
        textAlign(LEFT);
        textSize(9);
        text(times[i], x - w/2 + 10, entryY + 12);
        
        // Draw event name
        fill(50);
        textSize(10);
        text(events[i], x - w/2 + 10, entryY + 25);
        
        // Draw confidence change with color coding
        textAlign(RIGHT);
        if (changes[i] > 0) {
          fill(50, 180, 80);
          text("+" + int(changes[i]), x + w/2 - 15, entryY + 25);
        } else {
          fill(200, 50, 50);
          text(int(changes[i]), x + w/2 - 15, entryY + 25);
        }
      }
      
      // Move to next entry position
      entryY += entryHeight;
    }
    
    // Remove clipping
    noClip();
    
    // Draw scrollbar if needed
    if (count > visibleEntries) {
      // Draw scrollbar track (lighter gray)
      fill(220);
      rect(x + w/2 - 12, y + 40, 8, h - 50, 4);
      
      // Draw scrollbar thumb (darker, more visible)
      float scrollbarY = y + 40 + getScrollbarY();
      float scrollbarHeight = getScrollbarHeight();
      
      // Change color if being dragged
      if (draggingScrollbar) {
        fill(100);  // Darker when dragging
      } else {
        fill(140);  // Medium gray normally
      }
      rect(x + w/2 - 12, scrollbarY, 8, scrollbarHeight, 4);
    }
    
    // If no entries yet, show a message
    if (count == 0) {
      fill(150);
      textAlign(CENTER);
      textSize(11);
      text("No events yet.", x, y + h/2 - 5);
      text("Start interacting!", x, y + h/2 + 10);
    }
  }
}

// ============================================
// CLASS: AudioFeedback
// Provides psychological audio feedback using Processing Sound library
// Focus: "Not by adding engineering, but by adding psychology"
// ============================================
class AudioFeedback {
  TriOsc negativeOsc;               // Triangle wave for harsh negative sounds
  SinOsc positiveOsc;               // Sine wave for pleasant positive sounds
  SinOsc helpOsc;                   // Sine wave for warm help sounds
  
  // Constructor - sets up audio oscillators
  AudioFeedback(PApplet parent) {
    negativeOsc = new TriOsc(parent);   // Triangle wave = harsher tone
    positiveOsc = new SinOsc(parent);   // Sine wave = smooth tone
    helpOsc = new SinOsc(parent);       // Sine wave = gentle tone
  }
  
  // Play sound for NEGATIVE events (system updates)
  // Psychology: Descending, harsh tone = disruption, confusion, frustration
  void playNegativeSound() {
    negativeOsc.play();
    negativeOsc.freq(600);          // Start at 600Hz
    negativeOsc.amp(0.3);           // Moderate volume
    
    // Descend to create psychological discomfort
    for (int i = 0; i < 10; i++) {
      negativeOsc.freq(600 - i * 30);  // Drop 300Hz total
      delay(15);                       // Quick descent
    }
    
    negativeOsc.stop();             // Abrupt stop = jarring
  }
  
  // Play sound for POSITIVE events (task completion)
  // Psychology: Ascending, smooth tone = achievement, satisfaction, reward
  void playPositiveSound() {
    positiveOsc.play();
    positiveOsc.freq(400);          // Start at 400Hz
    positiveOsc.amp(0.25);          // Gentle volume
    
    // Ascend to create sense of accomplishment
    for (int i = 0; i < 10; i++) {
      positiveOsc.freq(400 + i * 30);  // Rise 300Hz total
      delay(20);                       // Pleasant pace
    }
    
    positiveOsc.stop();
  }
  
  // Play sound for HELP events (finding support)
  // Psychology: Steady, warm tone = reassurance, guidance, comfort
  void playHelpSound() {
    helpOsc.play();
    helpOsc.freq(500);              // Steady 500Hz (calming)
    helpOsc.amp(0.2);               // Soft volume
    
    // Slight upward drift = hope and direction
    for (int i = 0; i < 10; i++) {
      helpOsc.freq(500 + i * 5);    // Gentle rise
      delay(25);                    // Longer = more reassuring
    }
    
    helpOsc.stop();
  }
}
