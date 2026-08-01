# Koreader-Highlights-to-Obsidian
This R script enables capturing of highlights from your books into notes in obsidian

- This finds all of the .lua files (created by KOreader) in a folder you set and gathers all of the text you have highlighted in a book from it.
- It makes a new .md file (Obsidian note) for each book it finds, labels them with the author and how many total pages.
- The highlights are each on a new line, separated by chapter and labelled page number, colour and timestamped. Any notes in the book will also be imported.
- This does not do automatic syncing, but you manually run this code whenever you want.

**SetUp:**
If you are new to this, you will have to install R and RStudio to run this code.
_Required R Packages:_
- stringr
run the line ``install.packages("stringr")`` when running the script for the first time. This line is not required after that
_Steps:_
1. Set your books folder. This is wherever you are storing your books. You can plug your eReader into your computer and set it to ``books_folder  <- "D:/Books"`` for example
2. Set your Obsidian notes folder. This is wherever you want these notes to show up. For example, my Obsidian Vault is called Obsidian Vault and I have a subfolder for all of these notes called Books ``obsidian_books <- "C:/Users/Admin/OneDrive/Documents/Obsidian Vault/Books"``
3. Check what book formats you use. The line ``pattern = "metadata\\.(epub|pdf|mobi)\\.lua$",`` sets which book file types it searches for.
4. Run the entire script of code
