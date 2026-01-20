# Rock-Paper-Scissors-Lizard-Spock

An implementation of the RPSLS game built with Godot v4.5.1.



RPSLS extends the standard Rock–Paper–Scissors ruleset by adding two additional hands, turning the simple cycle into a directed graph where each hand defeats two others.



This project implements RPSLS as a synchronous, turn-based multiplayer game over ENet.



## Rules

* Scissors cut Paper
* Paper covers Rock
* Rock crushes Lizard
* Lizard poisons Spock
* Spock smashes Scissors
* Scissors decapitate Lizard
* Lizard eats Paper
* Paper disproves Spock
* Spock vaporizes Rock
* Rock crushes Scissors



## Current State — Version 0.3

### Implemented Features

* Full RPSLS game logic
* Turn-based input handling
* Authoritative server model multiplayer using ENet
* Server-side round resolution
* Result synchronization to clients
* Explicit Host / Join flow via UI
* Turn-based input with client-side submission
* Choice confirmation via submit action
* Input locking after submission until round resolution
* Result synchronization to all clients
* Automatic scene transition on successful connection
* In-game display of host IP address
* Copy-to-clipboard support for host address
* UI feedback for:
* \- selected choice
* \- waiting-for-opponent state
* \- round outcome (win / lose / draw)



(Requires further testing with external machines due to institution adversarial private network)



### Planned Features

* UI feedback and visual polish



### Notes

* One instance runs as the host and server
* Clients submit choices; the server resolves outcomes
* The server is the single source of truth (authoritative)
  

### How to Run

Godot version required: 4.5.1



##### Running a game

1\. Open Godot 4.5.1

2\. Click **Import**

3\. Select the repository root containing `project.godot`

4\. Open the project



##### Hosting a Game

1\. Run the project

2\. On the main menu, click **Host**

3\. This instance becomes the authoritative server and enters the game

4\. The host’s local IP address is displayed in-game and can be copied



##### Joining a Game

1\. Run the project in a separate instance or on another machine

2\. On the main menu, click **Join**

3\. Enter the host address:

&nbsp;  - IP or IP:PORT

&nbsp;  - Default port is 8910

4\. Submit the address to connect



Clients automatically transition to the game scene once connected.

