# Plan S feedback files
The R function below allows you to automatically download all Plan S feedback files from [Zenodo](https://zenodo.org/record/3250081/) at once. 

### How to download the files

### Requirements

Before executing the code you have to create a new R project and manually create an empty folder called 'files' within the project directory. Alternatively, you can simply change the destination paths to match a directory of your choice.

### Create URLs and destination paths

```{r}
# Create URLs
seq <- sprintf("%03.0f", 44:607)
urls <- paste0("https://zenodo.org/record/3250081/files/", seq, "_Plan S.pdf")

# Create destination paths
MAIN_DIR <- rprojroot::find_rstudio_root_file()
destinations <- paste0(MAIN_DIR, "/files/", seq, ".pdf")
```

### Download feedback files into 'files' folder

Please note that the numbering of the feedback files isn't consecutive, i.e. not all of the URLs created above exist. Hence, `tryCatch()` checks whether each individual URL exists first and `download.file()` then downloads only the existing ones.   

```{r}
# Download files
Map(function(url, destfile) tryCatch(download.file(url, destfile, mode = "wb"), error = function(e) 1), urls, destinations)
```
