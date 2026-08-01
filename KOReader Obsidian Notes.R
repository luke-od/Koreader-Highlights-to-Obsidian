### SYNC_KOREADER.R
### 1/8/26
### Lucas O'Dowd - https://github.com/luke-od 

####
#### NAVIGATE THIS SHORT SCRIPT WITH THE OUTLINE, THE LINES ON THE TOP RIGHT or Ctrl+Shift+O ####
####
#### FIRST TIME RUN, TAKE THE # AWAY FROM THE install.packages LINE TO RUN IT (ONLY REQUIRED ONCE)
# install.packages("stringr")
library(stringr)

####
#### CHANGE THESE 2 FILE PATHS: ####
####
#### THE FOLDER THAT HAS THE BOOKS YOU WANT TO SYNC - e.g. PLUG IN YOUR KINDLE
books_folder  <- "D:/Books"

#### THE FOLDER THAT CONTAINS YOUR OBSIDIAN NOTE FILES - e.g. IN A FOLDER CALLED Books
obsidian_books <- "C:/Users/Admin/OneDrive/Documents/Obsidian Vault/Books"
dir.create(obsidian_books, recursive=TRUE, showWarnings=FALSE)



extract_first <- function(x,p){
 m<-str_match(x,p)
 if(is.na(m[1,2])) "" else gsub('\\"','"',m[1,2],fixed=TRUE)
}

parse_annotations <- function(lines){
  starts <- grep("^\\s*\\[[0-9]+\\]\\s*=\\s*\\{$", lines)
  out <- list()
  for(i in starts){
    block <- character()
    depth <- 0
    j <- i
    repeat{
      ln <- lines[j]
      block <- c(block,ln)
      depth <- depth + str_count(ln,"\\{") - str_count(ln,"\\}")
      j <- j+1
      if(depth<=0 || j>length(lines)) break
    }
    b <- paste(block,collapse="\n")
    if(!grepl('\\["text"\\]',b)) next
    out[[length(out)+1]] <- list(
      chapter=extract_first(b,'\\["chapter"\\]\\s*=\\s*"([^"]*)"'),
      page=extract_first(b,'\\["pageno"\\]\\s*=\\s*([0-9]+)'),
      text=extract_first(b,'(?s)\\["text"\\]\\s*=\\s*"((?:\\\\.|[^"])*)"'),
      colour=extract_first(b,'\\["color"\\]\\s*=\\s*"([^"]*)"'),
      note=extract_first(b,'(?s)\\["note"\\]\\s*=\\s*"((?:\\\\.|[^"])*)"'),
      datetime=extract_first(b,'\\["datetime"\\]\\s*=\\s*"([^"]*)"')
    )
  }
  out
}

parse_file <- function(f){
  lines<-readLines(f,warn=FALSE,encoding="UTF-8")
  txt<-paste(lines,collapse="\n")
  list(
    title=extract_first(txt,'\\["title"\\]\\s*=\\s*"([^"]*)"'),
    author=extract_first(txt,'\\["authors"\\]\\s*=\\s*"([^"]*)"'),
    status=extract_first(txt,'\\["status"\\]\\s*=\\s*"([^"]*)"'),
    pages=extract_first(txt,'\\["pages"\\]\\s*=\\s*([0-9]+)'),
    annotations=parse_annotations(lines)
  )
}


####
#### THIS FUNCTION CONFIGURES THE LAYOUT OF THE OBSIDIAN NOTE               ####
####
write_book <- function(book){
 fn <- file.path(obsidian_books,paste0(gsub('[<>:"/\\\\|?*]','_',book$title),".md"))
 user_notes<-"## My Notes\n"
 if(file.exists(fn)){
   old<-paste(readLines(fn,warn=FALSE),collapse="\n")
   if(grepl("## My Notes",old,fixed=TRUE))
     user_notes<-sub("(?s).*?(## My Notes.*)$","\\1",old,perl=TRUE)
 }
 con<-file(fn,"w",encoding="UTF-8")
 writeLines(c(
"---",
paste0("title: ",book$title),
paste0("author: ",book$author),
paste0("status: ",book$status),
paste0("pages: ",book$pages),
"---","","# ",book$title,"",
"## Highlights",""),con)

 anns <- book$annotations
 chaps<-unique(vapply(anns,`[[`,"", "chapter"))
 for(ch in chaps){
   writeLines(c(paste0("### ",ifelse(ch=="","Unknown chapter",ch)),""),con)
   for(a in anns[vapply(anns,`[[`,"","chapter")==ch]){
     writeLines(paste0("> ",a$text),con)
     meta<-paste(c(
       if(a$page!="") paste0("p.",a$page),
       if(a$colour!="") paste0("colour: ",a$colour),
       if(a$datetime!="") a$datetime
     ),collapse=" • ")
     writeLines(c(paste0("*",meta,"*")),con)
     if(a$note!="") writeLines(c("","> **Note:** ",a$note),con)
     writeLines("",con)
   }
 }
 writeLines(c("",user_notes),con)
 close(con)
}


####
#### IF YOU HAVE OTHER BOOK FILE TYPES, ADD THEM INTO THE LINE BELOW WITH A | IN BETWEEN - e.g. (epub|pdf|mobi) ####
####
files <- list.files(books_folder,
                    pattern = "metadata\\.(epub|pdf|mobi)\\.lua$",
                    recursive = TRUE, full.names=TRUE)
# for(f in files){
#  b<-parse_file(f)
#  out<-file.path(obsidian_books,paste0(gsub('[<>:"/\\\\|?*]','_',b$title),".md"))
#  newtxt<-paste(capture.output(write_book),collapse="")
#  try(write_book(b),silent=TRUE)
# }

for(f in files){
  b <- parse_file(f)
  
  # Skip books with no highlights or notes
  if(length(b$annotations) == 0) next
  
  out <- file.path(obsidian_books,paste0(gsub('[<>:"/\\\\|?*]','_',b$title),".md"))
  newtxt <- paste(capture.output(write_book),collapse="")
  try(write_book(b),silent=TRUE)
}
cat("Notes created. Open Obsidian :)\n")