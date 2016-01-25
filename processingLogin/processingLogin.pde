import processing.net.*;
import controlP5.*;
ControlP5 cp5;

JSONObject json;

String encodedAuth = "";
Client client;
String data;

boolean isLoggedIn = false;
boolean isWrongPassword = false;
String currentUser = "";
String currentPassword = "";
Textfield username;
Textfield password;

final static int TIMER = 100;
static boolean isEnabled = true;

String host;
int port;
String address;

void setup() {
  size(700,400);
  noStroke();
  textSize(12);
  
  json = loadJSONObject("config.json");
  host = json.getString("host");
  port = json.getInt("port");
  address = json.getString("address");
  
  cp5 = new ControlP5(this);
     
  cp5.getTab("default")
     .activateEvent(true)
     .setLabel("home")
     .setId(1)
     ;
  
  cp5.addTab("login");
  cp5.getTab("login")
     .activateEvent(true)
     .setId(2)
     ;

  cp5.addTab("success");
  cp5.getTab("success")
     .activateEvent(true)
     .setId(3)
     ;
  
  username = cp5.addTextfield("username")
     .setPosition(width/2 - 100, height/2 - 40)
     .setSize(200, 20)
     .setLabel("username")
     .setFocus(true)
     ;
  username.setAutoClear(true);
  cp5.getController("username").moveTo("login");
  
  password = cp5.addTextfield("password")
     .setPosition(width/2 - 100, height/2)
     .setSize(200, 20)
     .setPasswordMode(true)
     .setLabel("password")
     ;
  password.setAutoClear(true);
  cp5.getController("password").moveTo("login");
  
  cp5.addButton("submit")
     .setBroadcast(false)
     .setLabel("login")
     .setPosition(width/2 - 100, height/2 + 40)
     .setSize(200,40)
     .setValue(1)
     .setBroadcast(true)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
  cp5.getController("submit").moveTo("login");
  
  cp5.addButton("loginBt")
     .setBroadcast(false)
     .setPosition(width/2 - 75, height/2 - 40)
     .setLabel("Login")
     .setSize(150,80)
     .setValue(1)
     .setBroadcast(true)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
  cp5.getController("loginBt").moveTo("default");
  
  cp5.addButton("logoutBt")
     .setBroadcast(false)
     .setPosition(width - 80, 10)
     .setLabel("Logout")
     .setSize(70,20)
     .setValue(1)
     .setBroadcast(true)
     .getCaptionLabel().align(CENTER,CENTER)
     ;
  cp5.getController("logoutBt").moveTo("global");
  cp5.getController("logoutBt").hide();
}

void draw() {
  background(170);
  fill(0);
  
  if(isLoggedIn){
    textAlign(RIGHT);
    text("Hello, " + currentUser, width - 10, 50);
    
    textAlign(CENTER);
    text("Login successful \\o/", width/2, height/2 - 10);
  }
  
  if(isWrongPassword){
    textAlign(CENTER);
    text("You shall not pass! \n(with a wrong password)", width/2, height/2 - 70);
  }
  
}

void controlEvent(ControlEvent theControlEvent) {
  if (theControlEvent.isTab()) {
    println("got an event from tab : "+theControlEvent.getTab().getName()+" with id "+theControlEvent.getTab().getId());
  }
  
  if(theControlEvent.getLabel() == "Logout"){
    cp5.getController("logoutBt").hide();
    isLoggedIn = false;
    cp5.getTab("default").bringToFront();
  }
  
  if (theControlEvent.isAssignableFrom(Textfield.class)) {
    Textfield t = (Textfield)theControlEvent.getController();
    
    if(t.getName() == "username"){
      currentUser = t.getStringValue();
    }
    if(t.getName() == "password"){
      currentPassword = t.getStringValue();
    }
    
    client = new Client(this, host, port);
    client.write("POST "+address+" HTTP/1.0\r\n");
    client.write("Accept: application/xml\r\n");
    client.write("Accept-Charset: utf-8;q=0.7,*;q=0.7\r\n");
    client.write("Content-Type: application/x-www-form-urlencoded\r\n");
    String contentLength = nf(23+currentUser.length()+currentPassword.length()); 
    client.write("Content-Length: "+contentLength+"\r\n\r\n");
    
    client.write("username="+currentUser+"&password="+currentPassword+"&\r\n");
    client.write("\r\n");

    println("controlEvent: accessing a string from controller '"
      +t.getName()+"': "+t.getStringValue()
    );
    
    print("controlEvent: trying to setText, ");

    t.setText("controlEvent: changing text.");
    if (t.isAutoClear()==false) {
      println(" success!");
    } 
    else {
      println(" but Textfield.isAutoClear() is false, could not setText here.");
    }
  }
}

public void loginBt(int theValue) {
  cp5.getTab("login").bringToFront();
}

void submit(int theValue) {
  isEnabled = true;
  username.submit();
  password.submit();
  thread("timer"); // from forum.processing.org/two/discussion/110/trigger-an-event
}

void loginCheck(){
  if (client.available() > 0) {
    data = client.readString();
    String[] m = match(data, "<logintest>(.*?)</logintest>");
    if(m[1].equals("success")){
      println("success");
      cp5.getTab("success").bringToFront();
      isLoggedIn = true;
      isWrongPassword = false;
      cp5.getController("logoutBt").show();
    } else {
      println("wrong password");
      isLoggedIn = false;
      isWrongPassword = true;
    }
  }
}

void timer() {
  while (isEnabled) {
    delay(TIMER);
    isEnabled = false;
    loginCheck();
  }
}