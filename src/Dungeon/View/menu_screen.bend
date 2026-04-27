import /HTML/
import /Dungeon/DungeonEvent as DungeonEvent

def _menu_screen_frame(header: HTML(DungeonEvent), body: HTML(DungeonEvent), footer: HTML(DungeonEvent)) -> HTML(DungeonEvent):
  <section class="menu-screen">
    <div class="menu-screen__header">
      {header}
    </div>
    <div class="menu-screen__body">
      {body}
    </div>
    <div class="menu-screen__footer">
      {footer}
    </div>
  </section>
