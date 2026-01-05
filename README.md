# Rock-Paper-Scissors-Lizard-Spock

An implementation of the RPSLS game built with Godot v4.5.1.



RPSLS extends the standard Rock–Paper–Scissors ruleset by adding two additional hands, turning the simple cycle into a directed graph where each hand defeats two others.



This project implements RPSLS as a networked multiplayer game with a dedicated server model.



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

## Current State — Version 0.2

### Implemented Features

* Full RPSLS game logic
* Turn-based input handling
* Authoritative server model multiplayer using ENet
* Server-side round resolution
* Result synchronization to clients
* Basic UI feedback for round outcome



(Tested via headless server + multiple clients)



### Planned Features

* Choice confirmation and locking
* Clear indication of local and opponent choice state
* UI feedback and visual polish



### Notes

* One instance runs as the server (can be headless)
* Clients submit choices; the server resolves outcomes
* The server is the single source of truth (authoritative)
