# Public Midum entrypoint.
#
# The public API stays renderer-neutral. Today, screen() is implemented by the
# internal DOM renderer.

import /HTML/
import /Midum/Config/palette as current_palette
import /Midum/Config/style as current_style
import /Midum/Internal/DOM/Button/base_css as button_base_css
import /Midum/Internal/DOM/Button/role_css as button_role_css
import /Midum/Internal/DOM/Button/style_css as button_style_css
import /Midum/Internal/DOM/Card/base_css as card_base_css
import /Midum/Internal/DOM/Card/role_css as card_role_css
import /Midum/Internal/DOM/Card/surface_script_0 as card_surface_script_0
import /Midum/Internal/DOM/Card/surface_script_1 as card_surface_script_1
import /Midum/Internal/DOM/Card/surface_script_2 as card_surface_script_2
import /Midum/Internal/DOM/Card/surface_script_3 as card_surface_script_3
import /Midum/Internal/DOM/Card/style_css as card_style_css
import /Midum/Internal/DOM/Image/base_css as image_css
import /Midum/Internal/DOM/Layout/css as layout_css
import /Midum/Internal/DOM/Text/css as text_css
import /Midum/Internal/DOM/Theme/base_css as theme_base_css
import /Midum/Internal/DOM/Theme/orange_css as theme_orange_css
import /Midum/Internal/DOM/Theme/olive_css as theme_olive_css
import /Midum/Internal/DOM/Theme/root_class as root_class

def screen(Event: Type, body: HTML(Event)) -> HTML(Event):
  <main class={"bc-font-ui " ++ root_class(current_palette(), current_style())}>
    <style>{text{theme_base_css()}}</style>
    <style>{text{theme_orange_css()}}</style>
    <style>{text{theme_olive_css()}}</style>
    <style>{text{layout_css()}}</style>
    <style>{text{image_css()}}</style>
    <style>{text{card_base_css()}}</style>
    <style>{text{card_role_css()}}</style>
    <style>{text{card_style_css()}}</style>
    <script>
      {text{card_surface_script_0()}}
      {text{card_surface_script_1()}}
      {text{card_surface_script_2()}}
      {text{card_surface_script_3()}}
    </script>
    <style>{text{button_base_css()}}</style>
    <style>{text{button_role_css()}}</style>
    <style>{text{button_style_css()}}</style>
    <style>{text{text_css()}}</style>
    {body}
  </main>
