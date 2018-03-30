Hippo Guesser
===

[![MIT License](https://img.shields.io/packagist/l/doctrine/orm.svg)]()

A real-time *Mike Tyson's Punch Out* guess collector for how long it will take
to defeat King Hippo in a speedrun.

## Features
* Uses websockets to communicate the state of a round in real time
* Maintains a leaderboard with the number of correct guesses for the top 20 users
* Dark theme (~~sorry, no light theme is available~~ light themes are for chumps)
* Twitch chat integration

## Tech Used
* [Preact](https://preactjs.com/)
* [React Router v4](https://github.com/ReactTraining/react-router)
* [Bootstrap](https://getbootstrap.com) (with [Bootswatch Lux theme](https://bootswatch.com/lux/))
* [Phoenix Framework](http://phoenixframework.org/)
* [TypeScript](https://www.typescriptlang.org)

## Twitch Chat commands

### Users
* `!guess 0:00.00` or `0:00.00` - Enter a guess for the current round.
* `!leaderboard` - Display the leaderboard
* `!hipposite` - Display the URL for the hippo guesser site.

### Moderators / Broadcaster
* `!start` - Start a new round
* `!stop` - End guessing period
* `!winner 0:00.00` or `!w 0:00.00` - Select winner by the correct time
* `!gg` - Close the round without selecting a winner
