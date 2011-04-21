/**
 *
 * - serial2socket-proxy
 * - https://github.com/kalanda/serial2socket-proxy
 *
 * This file is part of serial2socket proxy.
 *
 * serial2socket-proxy is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * serial2socket-proxy is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with serial2socket-proxy.  If not, see <http://www.gnu.org/licenses/>.
 */
 
 public class ServerManager extends Thread {

  //Constants
  final static int DEFAULT_PORT = 8080;  
  
  // Thread control vars 
  private boolean isRunning;          
  private int waitInterval; 
  
  // Parent PApplet   
  private PApplet parent;  

  // Objects for server
  private Server theServer;
  private int serverPortNumber;
  private Client theClient;

  // Constructor
  public ServerManager(PApplet parent) {  
    super();
    this.parent = parent;
    waitInterval = 100;
    isRunning = false;
    serverPortNumber = DEFAULT_PORT;
    start();
  }

  // Create the server
  public void createServer(int portNumber) {

    if(theServer!=null) {
      guiManager.logActivity("Removing server at port "+serverPortNumber);
      if(theClient!=null) theServer.disconnect(theClient);
      theClient = null;
      theServer.stop();
      theServer = null;
      
    }
    serverPortNumber = portNumber;
    
    try {
      theServer = new Server(parent, serverPortNumber);
      guiManager.logActivity("Server is listening port "+serverPortNumber);
    } 
    catch(Exception e) {
      guiManager.logActivity("> Error creating server at port "+serverPortNumber);
      guiManager.logActivity("> "+e.getMessage());
    }
    
  }

  // Sends data to all clients
  void send(String data) {
    if(theServer!=null) {
      theServer.write(data);
    }
  }
  
  // Check if new data from client is available
  public void checkForClientData(){
    if(theClient!=null){
       String whatClientSaid = theClient.readString();
      if (whatClientSaid != null) {
        if(serialManager.send(whatClientSaid)==-1) guiManager.logActivity(">> Client is sending data but not serial port is connected");
      } 
    }
  }

  // 
  public void manageNewClients(Server someServer, Client someClient) {
    
    // Check if the event is from my server
    if(someServer == theServer) {
      // If is the first client, save it
      if(theClient == null) {
        theClient = someClient;
        guiManager.logActivity("New client from "+theClient.ip());
      } 
      // Don't accept more than one client
      else if(theClient != someClient) {
        guiManager.logActivity("> Rejecting client from "+someClient.ip());
        someClient.write("REJECTED: There are too many clients in this server.\n");
        theServer.disconnect(someClient);
      } 
    }
  }
    
  // Start method for thread
  public void start () {
    isRunning = true;
    super.start();
  }
  
  // Run method for thread
  public void run(){
     
    while (isRunning) {
     
      // Method to execute in every run
      checkForClientData();
      
      try {
        sleep((long)(waitInterval));
      } catch (Exception e) {
      }
    }
  }
  
  // Our method that quits the thread
  void quit() {
    isRunning = false;
    interrupt();
  }
} 

