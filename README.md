# Practicals

## Special character, badge, and code

This is the code for the following badge:  
<img alt="Task Results badge" src="https://img.shields.io/badge/Task-Results-green">

```html
<img alt="Task Results badge" src="https://img.shields.io/badge/Task-Results-green">
```

The `_extension` folder contains a timer that can be called in Quarto as:
```markdown
:::{.timer #taks1 seconds=300 starton=interaction}
:::
```
This requires:
- a unique ID (e.g. #task1),
- the number of seconds (e.g. seconds=300),
- and the starton argument (e.g. starton=interaction).

## Colors
These are the color used by the university
`#ededed` `#70789a` `#7ab51d` `#006e89` `#003866`

| Color | Hex |
|-------|------|
| <span style="display:inline-block;width:20px;height:20px;background:#ededed;border:1px solid #ccc;"></span> | `#ededed` |
| <span style="display:inline-block;width:20px;height:20px;background:#70789a;border:1px solid #ccc;"></span> | `#70789a` |
| <span style="display:inline-block;width:20px;height:20px;background:#7ab51d;border:1px solid #ccc;"></span> | `#7ab51d` |
| <span style="display:inline-block;width:20px;height:20px;background:#006e89;border:1px solid #ccc;"></span> | `#006e89` |
| <span style="display:inline-block;width:20px;height:20px;background:#003866;border:1px solid #ccc;"></span> | `#003866` |

<table>
  <tr>
    <th>Color</th>
    <th>Hex</th>
  </tr>
  <tr>
    <td><div style="width:20px;height:20px;background:#ededed;border:1px solid #ccc;"></div></td>
    <td>#ededed</td>
  </tr>
  <tr>
    <td><div style="width:20px;height:20px;background:#70789a;border:1px solid #ccc;"></div></td>
    <td>#70789a</td>
  </tr>
  <tr>
    <td><div style="width:20px;height:20px;background:#7ab51d;border:1px solid #ccc;"></div></td>
    <td>#7ab51d</td>
  </tr>
  <tr>
    <td><div style="width:20px;height:20px;background:#006e89;border:1px solid #ccc;"></div></td>
    <td>#006e89</td>
  </tr>
  <tr>
    <td><div style="width:20px;height:20px;background:#003866;border:1px solid #ccc;"></div></td>
    <td>#003866</td>
  </tr>
</table>


## Rendering the Quarto project

This repository contains two YAML profiles that need to be rendered.
You can run the commands directly in the terminal, or run the R script named  `render.r`,which contains:

```r
system("quarto render --profile english")
system("quarto render --profile german")
system("quarto preview")
```
# Styling
The styling is set in tge `style.scss` documents

# Docs
The `docs` folder contains the HTML files used to deploy the site (for example, via GitHub Pages).
