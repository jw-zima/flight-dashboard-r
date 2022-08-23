#  flight-dashboard-r

# Shiny dashboard with stast on flight arrivals and delays in US in 2019
<p align="left">
    <a alt="Data Analysis">
        <img src="https://img.shields.io/badge/%20-Data%20Analysis%20-orange" /></a>
    <a alt="Visualisation">
        <img src="https://img.shields.io/badge/%20-Visualisation%20-orange" /></a>
    <a alt="Dashboard">
        <img src="https://img.shields.io/badge/%20-Dashboard%20-orange" /></a>
</p>

## General info

#### Problem Statement
TO BE DONE

## Notes
TO BE DONE

## Technologies

<p align="left">
    <a alt="R">
        <img src="https://img.shields.io/badge/%20-R%20-blue" /></a>
    <a alt="Shiny">
        <img src="https://img.shields.io/badge/%20-Shiny%20-blue" /></a>
    <a alt="bash">
        <img src="https://img.shields.io/badge/%20-bash%20-blue" /></a>
</p>


## References

Datasets are were downloaded from the kaggle platform using the official [Kaggle API](https://github.com/Kaggle/kaggle-api)
* [Airline Database](https://www.kaggle.com/datasets/open-flights/airline-database)
* [Airports, Train Stations, and Ferry Terminals](https://www.kaggle.com/datasets/open-flights/airports-train-stations-and-ferry-terminals)
* [Airline Delay Analysis](https://www.kaggle.com/datasets/sherrytp/airline-delay-analysis)

--------
## Usage
ALL BELOW TO BE DONE
## Project Organization
See the [filestructure]
TO BE ADDED

## How to run it
TO BE DONE


## Install developer requirements

1. [Install R](https://cran.r-project.org/mirrors.html)

Alternatively, you can install using [Docker](https://hub.docker.com/_/r-base) or [Ansible](https://github.com/Oefenweb/ansible-r) on Ubuntu.

Homebrew is great, but I currently avoid using it to install R, because of a number of bugs.

2. Edit the `setup.R` file to include any packages you need

3. In terminal, run:

```zsh
$ Rscript ./setup.R
```

If you have install problems with R 4.02, try running:

```{r}
echo '.libPaths("/renv/lib/x86_64-apple-darwin17.0/4.0.2")' >> /usr/local/lib/R/etc/Rprofile.site
```
## Lint

```zsh
$ devtools::install_github("REditorSupport/languageserver")
$ Rscript functions/lint.R
```

________________

## Captions (aka Citations)

Include the following code block at the beginning of your Rmarkdown Notebook

```{r}
library(captioner) # This is optional, as it's included in requirements

fig_nums <- captioner()
citef <- partial(fig_nums, display = 'cite')

table_nums <- captioner(prefix = 'Table')
citet <- partial(table_nums, display = 'cite')
```

### Figures / Plots

```{r figure_cap, fig.cap=figure_cap}
code here...
figure_cap <- fig_nums("figure_cap", "ipsum lorem")
```
use (`r citef('figure_cap')`) to cite the Figure

### Tables

```{r table_cite, fig.cap=table_cite}
code here...
table_cite <- table_nums("table_cite", "ipsum lorem")
```

use (`r citet('table_cite')`) to cite the Table

## Referencing

harvard style: https://www.lib.rmit.edu.au/easy-cite/

@MISC {tag,
    TITLE = {Title},
    AUTHOR = {Author Name},
    NOTE = {NOTE)},
    URL = {https://botbotdot.com}
}

Reference in Rmarkdown with [@tag]

https://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html

Website: direct quote:
between single quotes, add page number / para or heading
Eg. The tables are intended 'to aid technical ... schedule' (World Health Organization 2014, para. 8).

Website paraphrasing:
Eg. For immunization program ... (World Health Organization 2014).
Bibleography:
World Health Organization 2014, WHO recommendations for routine immunization - summary tables, World Health Organization, viewed 1 May 2014, <http://www.who.int/immunization/policy/immunization_tables/en/>.


________________


## Run models and R code from the command line

```zsh
Rscript src/models/ flight-dashboard-r.R
```

## Exporting as PDF or HTML (aka Knitting)

### Install Latex

For pdf drivers on Mac [Bookdown recommends] tinytex

```r
tinytex::install_tinytex()
```

As an alternative, consider mactex or basictex

```zsh
$ brew install pandoc pandoc-citeproc mactex # or basictex
```

### Knit Rmarkdown file

To export/knit Rmarkdown files, and display a notification on Mac when it's done

```zsh
Rscript -e 'rmarkdown::render("notebooks/ flight-dashboard-r.Rmd")'; osascript -e 'display notification "rmarkdown is knitted" with title "Done"'
```

[filestructure]:  flight-dashboard-r/FILESTRUCTURE.md
[Bookdown recommends]: https://bookdown.org/yihui/rmarkdown-cookbook/install-latex.html

### Tests

In R:

```r
testthat::test_dir('tests')
```

How to write tests: https://kbroman.org/pkg_primer/pages/tests.html

<p><small>Project based on the <a target="_blank" href="https://drivendata.github.io/cookiecutter-data-science/">cookiecutter data science project template</a>. #cookiecutterdatascience</small></p>

## Contributors

jw-zima

--------
<p><small>Project based on the <a target="_blank" href="https://github.com/tgrrr/cookiecutter-data-science-r">cookiecutter data science for r project template</a>. #cookiecutterdatascience</small></p>
