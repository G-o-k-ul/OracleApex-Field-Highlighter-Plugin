# 🎨 Field Highlighter – Oracle APEX Dynamic Action Plugin

> **Plugin Type:** Dynamic Action  
> **Internal Name:** `COM.ORACLE.ACE.FIELD.HIGHLIGHTER`  
> **APEX Version:** 22.1+  
> **Author:** GOKUL – Oracle ACE Apprentice  
> **Version:** 1.0.0  

---

## 📌 Overview

**Field Highlighter** is a Dynamic Action plugin for Oracle APEX that programmatically highlights one or more page items with a colored border, background tint, and optional pulsing animation.

Use it to direct user attention to fields that need review, have validation issues, or are required under certain conditional logic — without forcing a full page submit.

---

## ✨ Features

| Feature | Details |
|---|---|
| **Multiple Items** | Highlight any number of items at once (comma-separated) |
| **4 Built-in Styles** | Error, Warning, Success, Info |
| **Custom Colors** | Define your own background + border hex colors |
| **Pulse Animation** | CSS keyframe pulse draws attention on trigger |
| **3 Modes** | `highlight`, `clear`, `toggle` |
| **Auto-Clear** | Field automatically un-highlights when user interacts |
| **Container Tint** | Subtly tints the entire form field wrapper |
| **Accessible** | Visual-only, doesn't affect tabbing or semantics |

---

## 📁 File Structure

```
Field-highlighter/
├── src/
│   ├── dynamic_action_plugin_com_oracle_ace_field_highlighter.sql  ← Plugin definition
│   └── pkg_highlighter_plugin.sql                                  ← PL/SQL Package
└── README.md
```

---

## 🚀 Installation

### Step 1 – Install PL/SQL Package
```sql
@src/pkg_highlighter_plugin.sql
```

### Step 2 – Import Plugin into APEX
1. **Shared Components → Plug-ins → Import**
2. Upload: `src/dynamic_action_plugin_com_oracle_ace_field_highlighter.sql`
3. Click **Next → Install Plugin**

---

## ⚙️ Plugin Attributes

| Attribute | Type | Default | Description |
|---|---|---|---|
| **Items to Highlight** | Text | *(required)* | Comma-separated item names: `P1_NAME,P1_EMAIL` |
| **Mode** | Select List | `highlight` | `highlight`, `clear`, or `toggle` |
| **Style** | Select List | `warning` | `error`, `warning`, `success`, `info`, `custom` |
| **Pulse Animation** | Yes/No | `Y` | Animate a pulsing ring when highlighting |
| **Auto-Clear on Change** | Yes/No | `Y` | Remove highlight when user edits the field |
| **Custom Background** | Text | `#fffbcc` | Hex color (only when Style = `custom`) |
| **Custom Border** | Text | `#f0c040` | Hex color (only when Style = `custom`) |

---

## 🔧 Usage Examples

### Example 1 – Highlight missing required fields before submit
```
Event: Button Click (Submit)
Condition: P1_NAME is null OR P1_EMAIL is null  
True Action → Field Highlighter [ACE]
  Items: P1_NAME,P1_EMAIL
  Mode: highlight
  Style: error
  Pulse: Y
```

### Example 2 – Clear highlights after fixing fields
```
Event: Change (on P1_NAME)
True Action → Field Highlighter [ACE]
  Items: P1_NAME
  Mode: clear
```

### Example 3 – Toggle highlight to show "under review" state
```
Event: Button Click (Flag for Review)
True Action → Field Highlighter [ACE]
  Items: P1_NOTES,P1_STATUS
  Mode: toggle
  Style: info
  Pulse: N
```

---

## 🎨 Style Preview

| Style | Background | Border | Use For |
|---|---|---|---|
| `error` | Light red | Red | Validation errors, missing required fields |
| `warning` | Light yellow | Orange | Caution, fields needing review |
| `success` | Light green | Green | Confirmed/validated fields |
| `info` | Light blue | Blue | Informational callout |
| `custom` | Your hex | Your hex | Brand-specific styling |

---

## 💡 Use Cases

- 🔴 **Client-side validation** – highlight empty required fields before AJAX submit
- 🟡 **Workflow review** – flag fields that need manager approval
- 🟢 **Form completion** – mark fields as verified/complete
- 🔵 **Onboarding tours** – highlight fields user should fill next

---

## 📄 License

MIT License – free to use, modify, and distribute. Attribution appreciated.

---


## 👤 Author

**GOKUL**  
Oracle ACE Apprentice  
GitHub: https://github.com/G-o-k-ul
Blog: https://codewithgokul.blogspot.com/
LinkedIn: https://www.linkedin.com/in/gokul-b-ab86a6229/
