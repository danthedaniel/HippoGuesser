import EctoEnum

# user   - can participate in guessing rounds
# mod    - can start/stop rounds and pick winners
# admin  - can add/remove mods
# banned - can't do anything
defenum PermLevel, user: 0, mod: 1, admin: 2, banned: 3

# in_progress - currently collecting guesses
# completed   - guessing has ended
# closed      - guessing has ended and winners (if any) have been picked
defenum RoundState, in_progress: 0, completed: 1, closed: 2
