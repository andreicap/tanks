# Tanks

## Protocol

### Messages from client

* join
* ready
* start_move(orientation) - start movement in the specified direction
* stop_move - stop movement
* shoot - shoot a projectile

### Messages from server

* joined(who)
* is_ready(who)
* started_move(who, orientation) - someone started to move in the specified direction
* stoped_move(who) - someone stopped
* has_shot(who) - someone has shoot a projectile
* killed(who, by_whom) - someone was destroyed
* full_resync(world) - perform a full resynchronization of game state


## Usage

TODO: Write usage instructions here


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

