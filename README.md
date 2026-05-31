A lot of mouse software is lacking or buggy. I want some looping macro functionality, and consistently applied window-based profiles. After trying many brands' gaming mice, it seems I really have to do it myself...

## Design

### Main

- Each OS key may have up to one KeyManager managing it. We use a map to track our OS keys' KeyManagers. When defining a key's behaviours, we either create a new KeyManager or reuse its existing one
- We hook into a Windows DLL to listen for when the focused window changes. KeyManagers can subscribe to get notified when needed

### KeyManager

- Each KeyManager hooks its corresponding down and up events just once for its OS key. It does not matter whether that key is a physical keyboard key, or comes from some virtual mouse macro, only that we can perform health checks on its real pressed state, since AHK up events do not trigger consistently
- Each KeyManager may have one or more Workers, which each define a custom behaviour. The goal of allowing multiple workers is to define different behaviours based on the focused window. Thus, a KeyManager either ties a Worker to specific window classes, or uses it as the default Worker
- KeyManagers are in charge of tracking pressed state and suppressing the looping key down events from the OS. They interpret their hooked events, alongside getting notified of window focus switches, to start/stop Workers
- When switching to a window with a different Worker, we need to decide how to manage the old and new Workers. If we imagine that our keys existed physically and think about how we'd press them when switching windows, then it makes sense to:
  - Treat any down keys as lifted (i.e. stop any old workers)
  - Not treat any down keys as freshly pressed in the new window (i.e. not start new workers)
  - The OS key would stay in its pressed state. Later, the new Worker would only get ended (without the start)
- KeyManager events:
  - Down: Handles a fired down event from the OS key
  - Up: Handles a fired up event from the OS key
  - Switch: While down, handles a fired window focus switch event
  - Heartbeat: While down, this is the callback to poll the real pressed state of the OS key, to manually fire the up event if needed

### Worker

- Workers can be simple, just proxying down and up events of a different key. Or, workers can be more complex, performing looping presses while active. The world is your oyster
- Worker events:
  - Start: An instruction to begin the Worker's behaviour
  - End: An instruction to kill the Worker's behaviour

### Sender

- Senders are used by Workers to both perform an initial key down *and* schedule (or later force) a subsequent automatic key up
- Senders are single-use, fire-and-forget runnables that abstract away their internal timeout
- Sender events:
  - Init: The instruction to begin the Sender's behaviour
  - Kill: The instruction to kill the Sender's behaviour, which may be called early
