// Confidence Tracker Animation
// This program visualizes how user confidence changes when educational tools are updated
// Author: MS

// Global variables to track confidence and animation state
ConfidenceBar confidenceBar;        // The main confidence visualization bar
UpdateSimulator updateSystem;       // Handles simulated system updates
MessageDisplay messageDisplay;      // Shows messages to the user
int updateCounter = 0;              // Counts how many updates have occurred
boolean autoMode = true;            // Whether updates happen automatically
int lastUpdateTime = 0;             // Tracks when the last update happened
int updateInterval = 5000;          // Time between auto updates (5 seconds)

// Setup runs once at the beginning
void setup() {
  size(800, 600);                   // Create a window 800 pixels wide, 600 pixels tall
  
  // Create instances of our main objects
  confidenceBar = new ConfidenceBar(150, 200, 500, 60);
  updateSystem = new UpdateSimulator();
  messageDisplay = new MessageDisplay(400, 460);
  
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
}

// Trigger a successful use of the system (increases confidence)
void triggerSuccess() {
  // Using the system successfully builds confidence gradually
  confidenceBar.changeConfidence(8);
  messageDisplay.showMessage("Successfully completed a task - confidence building!", color(50, 180, 80));
}

// Trigger finding help or tutorial (increases confidence)
void triggerHelp() {
  // Finding help resources boosts confidence
  confidenceBar.changeConfidence(12);
  messageDisplay.showMessage("Found helpful tutorial - understanding improved!", color(50, 150, 200));
}

// Draw the title at the top of the screen
void drawTitle() {
  fill(50);                         // Dark gray text
  textAlign(CENTER);
  textSize(24);
  text("Confidence Tracker: Educational Tool Updates", width/2, 40);
  
  textSize(14);
  fill(100);
  text("Visualizing how frequent system changes affect user confidence", width/2, 65);
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
      rectMode(CENTER);
      rect(x, y, 700, 60, 10);
      rectMode(CORNER);
      
      // Draw the message text
      fill(messageColor);
      textAlign(CENTER);
      textSize(16);
      text(currentMessage, x, y + 5);
    }
  }
}
