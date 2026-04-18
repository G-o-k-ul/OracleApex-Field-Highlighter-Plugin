CREATE PACKAGE ace_field_highlighter AS
-- =============================================================================
-- Package: ACE_FIELD_HIGHLIGHTER
-- Plugin Type: Dynamic Action Plugin
-- Internal Name: COM.ORACLE.ACE.FIELD.HIGHLIGHTER
-- Description: Highlights one or more APEX page items with a color and
--              optional pulsing border animation to draw user attention.
--              Useful for directing focus to required fields, validation
--              errors, or fields that require review.
-- Author: [Your Name] - Oracle ACE Apprentice
-- Version: 1.0.0
-- Compatible: Oracle APEX 22.1+
-- =============================================================================

  FUNCTION render (
    p_dynamic_action IN apex_plugin.t_dynamic_action,
    p_plugin         IN apex_plugin.t_plugin
  ) RETURN apex_plugin.t_dynamic_action_render_result;

END ace_field_highlighter;
/

CREATE PACKAGE BODY ace_field_highlighter AS

  -- ---------------------------------------------------------------------------
  -- FUNCTION: render
  -- Highlights specified APEX items with color, border and optional animation.
  -- ---------------------------------------------------------------------------
  FUNCTION render (
    p_dynamic_action IN apex_plugin.t_dynamic_action,
    p_plugin         IN apex_plugin.t_plugin
  ) RETURN apex_plugin.t_dynamic_action_render_result AS

    l_result           apex_plugin.t_dynamic_action_render_result;

    -- Attribute 1: Comma-separated list of page item names to highlight
    l_items            VARCHAR2(4000) := NVL(p_dynamic_action.attribute_01, '');
    -- Attribute 2: Highlight Mode  (highlight | clear | toggle)
    l_mode             VARCHAR2(10)   := NVL(p_dynamic_action.attribute_02, 'highlight');
    -- Attribute 3: Highlight Style (error | warning | success | info | custom)
    l_style            VARCHAR2(10)   := NVL(p_dynamic_action.attribute_03, 'warning');
    -- Attribute 4: Pulse Animation (Y/N)
    l_pulse            VARCHAR2(1)    := NVL(p_dynamic_action.attribute_04, 'Y');
    -- Attribute 5: Auto-clear on item change (Y/N)
    l_auto_clear       VARCHAR2(1)    := NVL(p_dynamic_action.attribute_05, 'Y');
    -- Attribute 6: Custom background color (hex, used when style = 'custom')
    l_custom_bg        VARCHAR2(20)   := NVL(p_dynamic_action.attribute_06, '#fffbcc');
    -- Attribute 7: Custom border color (hex)
    l_custom_border    VARCHAR2(20)   := NVL(p_dynamic_action.attribute_07, '#f0c040');

  BEGIN

    -- Inject CSS styles once per page
    apex_css.add(
      p_css =>
        -- Color definitions per style
        '.ace-hl-error   { background:#fff5f5 !important; border:2px solid #e74c3c !important; border-radius:4px; }' ||
        '.ace-hl-warning { background:#fffdf0 !important; border:2px solid #f39c12 !important; border-radius:4px; }' ||
        '.ace-hl-success { background:#f0fff4 !important; border:2px solid #27ae60 !important; border-radius:4px; }' ||
        '.ace-hl-info    { background:#f0f8ff !important; border:2px solid #3498db !important; border-radius:4px; }' ||
        '.ace-hl-custom  { border-radius:4px !important; }' ||

        -- Container highlight (wraps label + item)
        '.ace-hl-container { border-radius:6px; padding:4px; transition: background 0.3s; }' ||
        '.ace-hl-container.ace-hl-error   { background: rgba(231,76,60,0.08); }' ||
        '.ace-hl-container.ace-hl-warning { background: rgba(243,156,18,0.08); }' ||
        '.ace-hl-container.ace-hl-success { background: rgba(39,174,96,0.08); }' ||
        '.ace-hl-container.ace-hl-info    { background: rgba(52,152,219,0.08); }' ||

        -- Pulse animation
        '@keyframes acePulse {' ||
          '0%   { box-shadow: 0 0 0 0   rgba(243,156,18,0.5); }' ||
          '70%  { box-shadow: 0 0 0 8px rgba(243,156,18,0);   }' ||
          '100% { box-shadow: 0 0 0 0   rgba(243,156,18,0);   }' ||
        '}' ||
        '@keyframes acePulseError {' ||
          '0%   { box-shadow: 0 0 0 0   rgba(231,76,60,0.5); }' ||
          '70%  { box-shadow: 0 0 0 8px rgba(231,76,60,0);   }' ||
          '100% { box-shadow: 0 0 0 0   rgba(231,76,60,0);   }' ||
        '}' ||
        '.ace-hl-pulse-warning { animation: acePulse      1.5s ease-in-out 2; }' ||
        '.ace-hl-pulse-error   { animation: acePulseError 1.5s ease-in-out 2; }' ||
        '.ace-hl-pulse-success { animation: acePulse      1.5s ease-in-out 2; }' ||
        '.ace-hl-pulse-info    { animation: acePulse      1.5s ease-in-out 2; }',
      p_key => 'ace-field-highlighter-css'
    );

    -- Build the JavaScript function
    l_result.javascript_function :=
      'function() {' ||
      '  var itemList  = ' || apex_javascript.add_value(l_items) || '.split(",");' ||
      '  var mode      = ' || apex_javascript.add_value(l_mode)  || ';' ||
      '  var style     = ' || apex_javascript.add_value(l_style) || ';' ||
      '  var doPulse   = ' || apex_javascript.add_value(l_pulse) || ' === "Y";' ||
      '  var autoClear = ' || apex_javascript.add_value(l_auto_clear) || ' === "Y";' ||
      '  var customBg  = ' || apex_javascript.add_value(l_custom_bg) || ';' ||
      '  var customBrd = ' || apex_javascript.add_value(l_custom_border) || ';' ||
      '  var hlClass   = "ace-hl-" + style;' ||
      '  var pulseClass= "ace-hl-pulse-" + style;' ||

      '  itemList.forEach(function(itemName) {' ||
      '    itemName = itemName.trim();' ||
      '    if (!itemName) return;' ||
      '    var el = document.getElementById(itemName);' ||
      '    if (!el) { apex.debug.warn("ACE Highlighter: item not found:", itemName); return; }' ||

      '    if (mode === "clear" || (mode === "toggle" && el.classList.contains(hlClass))) {' ||
      '      // CLEAR mode: remove all highlights' ||
      '      el.classList.remove(hlClass, pulseClass, "ace-hl-custom");' ||
      '      el.style.background = "";' ||
      '      el.style.border     = "";' ||
      '      var container = el.closest(".t-Form-inputContainer, .apex-item-wrapper, .t-Form-fieldContainer");' ||
      '      if (container) container.classList.remove("ace-hl-container", hlClass);' ||

      '    } else {' ||
      '      // HIGHLIGHT mode: apply styles' ||
      '      el.classList.add(hlClass);' ||
      '      if (style === "custom") {' ||
      '        el.style.background   = customBg;' ||
      '        el.style.border       = "2px solid " + customBrd;' ||
      '        el.style.borderRadius = "4px";' ||
      '      }' ||
      '      // Wrap container for subtle background tint' ||
      '      var container = el.closest(".t-Form-inputContainer, .apex-item-wrapper, .t-Form-fieldContainer");' ||
      '      if (container) container.classList.add("ace-hl-container", hlClass);' ||

      '      // Pulse animation: re-trigger by removing + re-adding class' ||
      '      if (doPulse) {' ||
      '        el.classList.remove(pulseClass);' ||
      '        void el.offsetWidth;  /* force reflow */' ||
      '        el.classList.add(pulseClass);' ||
      '      }' ||

      '      // Auto-clear on user interaction' ||
      '      if (autoClear) {' ||
      '        var clearFn = function() {' ||
      '          el.classList.remove(hlClass, pulseClass, "ace-hl-custom");' ||
      '          el.style.background = ""; el.style.border = "";' ||
      '          if (container) container.classList.remove("ace-hl-container", hlClass);' ||
      '          el.removeEventListener("input",  clearFn);' ||
      '          el.removeEventListener("change", clearFn);' ||
      '          el.removeEventListener("click",  clearFn);' ||
      '        };' ||
      '        el.addEventListener("input",  clearFn);' ||
      '        el.addEventListener("change", clearFn);' ||
      '        el.addEventListener("click",  clearFn);' ||
      '      }' ||
      '    }' ||
      '  });' ||
      '}';

    RETURN l_result;

  EXCEPTION
    WHEN OTHERS THEN
      apex_debug.error('ACE Field Highlighter Plugin Error: %s', SQLERRM);
      RAISE;
  END render;

END ace_field_highlighter;
/