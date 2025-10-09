The keypad interaction system uses **relative positioning** through `Marker3D` nodes. This allows you to place multiple keypads throughout your scene, and each will position the player correctly when interacted with.

## How It Works

1. When the player presses **E** while looking at a keypad, the system finds the keypad's `InteractionMarker` child
2. The player is teleported to the marker's **global position and rotation**
3. This gives you precise visual control over where the player stands when using each keypad

4. **Position the marker:**
   - Select the `InteractionMarker` node
   - Use the 3D viewport gizmos to move it to where you want the player to stand
   - The marker's **position** determines where the player's feet will be
   - The marker's **rotation** determines which direction the player will face
