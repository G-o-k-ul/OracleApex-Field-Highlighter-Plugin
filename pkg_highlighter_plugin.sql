CREATE PACKAGE ace_field_highlighter AS
-- =============================================================================
-- Package: ACE_FIELD_HIGHLIGHTER
-- Plugin Type: Dynamic Action Plugin
-- Internal Name: COM.ORACLE.ACE.FIELD.HIGHLIGHTER
-- Description: Highlights one or more APEX page items with a color and
--              optional pulsing border animation to draw user attention.
--              Useful for directing focus to required fields, validation
--              errors, or fields that require review.
-- Author: Gokul - Oracle ACE Apprentice
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
) RETURN apex_plugin.t_dynamic_action_render_result
AS
  l_result        apex_plugin.t_dynamic_action_render_result;
  l_items         VARCHAR2(4000) := NVL(p_dynamic_action.attribute_01, '');
  l_mode          VARCHAR2(10)   := NVL(p_dynamic_action.attribute_02, 'highlight');
  l_style         VARCHAR2(10)   := NVL(p_dynamic_action.attribute_03, 'warning');
  l_pulse         VARCHAR2(1)    := NVL(p_dynamic_action.attribute_04, 'Y');
  l_auto_clear    VARCHAR2(1)    := NVL(p_dynamic_action.attribute_05, 'Y');
  l_custom_bg     VARCHAR2(20)   := NVL(p_dynamic_action.attribute_06, '#fffbcc');
  l_custom_border VARCHAR2(20)   := NVL(p_dynamic_action.attribute_07, '#f0c040');
BEGIN

  apex_css.add(
    p_css =>
      '.ace-hl-error   { background:#fff5f5 !important; border:2px solid #e74c3c !important; border-radius:4px; box-sizing:border-box; }' ||
      '.ace-hl-warning { background:#fffdf0 !important; border:2px solid #f39c12 !important; border-radius:4px; box-sizing:border-box; }' ||
      '.ace-hl-success { background:#f0fff4 !important; border:2px solid #27ae60 !important; border-radius:4px; box-sizing:border-box; }' ||
      '.ace-hl-info    { background:#f0f8ff !important; border:2px solid #3498db !important; border-radius:4px; box-sizing:border-box; }' ||
      '.ace-hl-custom  { border-radius:4px !important; box-sizing:border-box; }' ||
      '@keyframes acePulseWarning { 0%{box-shadow:0 0 0 0 rgba(243,156,18,0.6)} 70%{box-shadow:0 0 0 8px rgba(243,156,18,0)} 100%{box-shadow:0 0 0 0 rgba(243,156,18,0)} }' ||
      '@keyframes acePulseError   { 0%{box-shadow:0 0 0 0 rgba(231,76,60,0.6)}  70%{box-shadow:0 0 0 8px rgba(231,76,60,0)}  100%{box-shadow:0 0 0 0 rgba(231,76,60,0)} }'  ||
      '@keyframes acePulseSuccess { 0%{box-shadow:0 0 0 0 rgba(39,174,96,0.6)}  70%{box-shadow:0 0 0 8px rgba(39,174,96,0)}  100%{box-shadow:0 0 0 0 rgba(39,174,96,0)} }'  ||
      '@keyframes acePulseInfo    { 0%{box-shadow:0 0 0 0 rgba(52,152,219,0.6)} 70%{box-shadow:0 0 0 8px rgba(52,152,219,0)} 100%{box-shadow:0 0 0 0 rgba(52,152,219,0)} }'  ||
      '.ace-pulse-warning { animation: acePulseWarning 1.2s ease-in-out 2; }' ||
      '.ace-pulse-error   { animation: acePulseError   1.2s ease-in-out 2; }' ||
      '.ace-pulse-success { animation: acePulseSuccess 1.2s ease-in-out 2; }' ||
      '.ace-pulse-info    { animation: acePulseInfo    1.2s ease-in-out 2; }',
    p_key => 'ace-field-highlighter-css'
  );

  l_result.javascript_function :=
    'function() {' ||
    '  var items      = "' || REPLACE(l_items, '"', '') || '".split(",");' ||
    '  var mode       = "' || l_mode   || '";' ||
    '  var style      = "' || l_style  || '";' ||
    '  var doPulse    = "' || l_pulse  || '" === "Y";' ||
    '  var autoClear  = "' || l_auto_clear || '" === "Y";' ||
    '  var customBg   = "' || l_custom_bg     || '";' ||
    '  var customBrd  = "' || l_custom_border || '";' ||
    '  var hlClass    = "ace-hl-"    + style;' ||
    '  var pulseClass = "ace-pulse-" + style;' ||

    '  items.forEach(function(itemName) {' ||
    '    itemName = itemName.trim();' ||
    '    if (!itemName) return;' ||
    '    var el = document.getElementById(itemName);' ||
    '    if (!el) { apex.debug.warn("ACE Field Highlighter: item not found ->", itemName); return; }' ||

    '    var isClear = (mode === "clear") || (mode === "toggle" && el.classList.contains(hlClass));' ||

    '    if (isClear) {' ||
    '      el.classList.remove(hlClass, pulseClass, "ace-hl-custom");' ||
    '      el.style.background  = "";' ||
    '      el.style.border      = "";' ||
    '      el.style.borderRadius= "";' ||

    '    } else {' ||
    '      el.classList.add(hlClass);' ||

    '      if (style === "custom") {' ||
    '        el.classList.add("ace-hl-custom");' ||
    '        el.style.background   = customBg;' ||
    '        el.style.border       = "2px solid " + customBrd;' ||
    '        el.style.borderRadius = "4px";' ||
    '      }' ||

    '      if (doPulse) {' ||
    '        el.classList.remove(pulseClass);' ||
    '        void el.offsetWidth;' ||
    '        el.classList.add(pulseClass);' ||
    '      }' ||

    '      if (autoClear) {' ||
    '        var clearFn = function() {' ||
    '          el.classList.remove(hlClass, pulseClass, "ace-hl-custom");' ||
    '          el.style.background   = "";' ||
    '          el.style.border       = "";' ||
    '          el.style.borderRadius = "";' ||
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
    apex_debug.error('ACE Field Highlighter Error: %s', SQLERRM);
    RAISE;
END;

END ace_field_highlighter;
/
