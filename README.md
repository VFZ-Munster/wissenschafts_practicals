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
These are the colors used to match the university’s official palette.

![#ededed](https://img.shields.io/badge/-e5e5e5-ededed?style=flat-square) 
![#70789a](https://img.shields.io/badge/-70789a-70789a?style=flat-square)
![#7ab51d](https://img.shields.io/badge/-7ab51d-7ab51d?style=flat-square)
![#006e89](https://img.shields.io/badge/-006e89-006e89?style=flat-square)
![#003866](https://img.shields.io/badge/-003866-003866?style=flat-square)


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
