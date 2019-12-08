
# Introduce

```
Vim 是一个方便快捷的编辑器。
曾经也学习过一次 VIM，但是命令行版本的 VIM 用来开发 Java 不太顺手，还需要使用 IDEA 这样的集成开发环境才行。
体验到 VIM 的便捷和快速之后，就很难再回到日常的编码习惯中，所以这次准备重新学习练习 VIM 在 IDEA 这个平台上。
所以写此文章记录重新学习 VIM， 以及一些平时开发中遇到的 VIM 最佳解决方案。
用于 VIM 进行快速编码
作为一个 Java 开发者来说，有一个优秀的
```
Vim is a convenient and quick text editor.

This is a vim 
1. vim tutor
2. make your idea to text-editor
3. select your best vim editor, like macvim, evil mode in emacs, and whatever you are using 

requirement:
1. all default vim settings
2. a comfortable Idea, which I highly recommend Intellij Idea Community Edition
(What? It is an IDE not and editor, see my post how to set to an elegant editor)
3. A keyboard without <ESC> and <Backspace> key
4. you can use the course on the idea

# change some word

## move

### Basic
```
  h          ↑
j   k      ←   →
  l          ↓
```

### Navigation

`G` - go to bottom
`gg` - go to top
`{number} G / gg` - jump to the given {number} of line
`%` - move to the matching `() [] {}` in that block 
`n` / `N` in search - jump to the search result
`<C-]>` - jump to the declaration / tag
`<C-t>` - jump back from tag
`<C-o>` - jump back from a jump (see details below)
`<C-i>` - jump forward to `<C-o>`

`<C-o>` can jump back from following command
* `<C-]>`
* `gg`
* `G`
* `number G / gg`
* `n` / `N` in search

## edit (CRUD)

### Create

To create character, you need enter the `INSERT` mode
`i` - `insert`, enter `INSERT` mode, before current character under the cursor
`I` - `Insert`, enter `INSERT` mode, before current line
`a` - `append`, enter `INSERT` mode, after current character under the cursor
`A` - `Append`, enter `INSERT` mode, after current line
`o` - `open`, open a new line below current line then enter `INSERT` mode
`O` - `Open`, open a new line above current line then enter `INSERT` mode


`c` - `change`, enter `INSERT` mode as well, need motion, see Update.
`s` - `substitute`, enter `INSERT` mode as well, will delete current character.

### Read

`<C-g>` - show the line location in the current file, but not works in IdeaVIM
`/{word}` <ENTER> - search {word} forward
`n` - jump to next word
`N` - jump to previous word
`?{word}` <ENTER> - search {word} backward

`:set ic` - ignore case when searching 
`:set hls` - hlsearch
`:set is` - incsearch
`:set ic hls is` - combine all this set
`:set noxx` -- switch off the set, `noic`
`/{word}\c` - ignore case when searching {word} this time


### Update

`u` - undo
`U` - undo all the changes on a line
`<C-r>` - redo, to undo the undoes

`p` - put the previously deleted after the cursor
`r{x}` - replace the character at the cursor with x
`ce` - dw + i
`c$` - C 
`R` - enter replacing mode

substitute
```
substitute {new} for {old}, differnt params with different scope
:s/{old}/{new}    -- first in current line
:s/{old}/{new}/g  -- all in current line
:{from},{to}s/{old}/{new}/g -- all in range of from and to 
:%s/{old}/{new}/g -- all in the whole file
:%s/{old}/{new}/gc -- all in the whole file with a confirm prompt
```


### Delete
`d` -  
`x` - delete the character under the cursor
`c`
`<C-w>` - delete a word in insert mode
`<C-u>` - delete all the characters in current line on once insert mode
`dw` - delete a word
`d$` - delete to the end of the line
`D` - d$
`dd` - delete a whole line


## advance

### motion
> e.g: this is word.

w - until the start of the next word
    `is ` including the space
e - to the end of the current word
    `is`
$ - to the end of the line
    `is word.` including .
    
### counter  
0 - move to the start of the line
number - repeat command {number} times


```
counter command
command [number] motion
```


<C-d> - show the hint in command mode
:help - visit help doc

### command

`:!{command}` - execute external command
:w{filename} - save to another file

v - visual mode
v + :w{filename} -> `:'<,'>w{filename}` - save selection to another file
:r{filename} - read the content of the file
:r + !{command} - read the command output  

y - yank(copy)
p - past
yw - yank a word


## not working
`<C-g>`

# References
* [*VIM Cheat Sheet*](https://vim.rtorr.com/)


# Practice 

## delete a word in insert mode

`<C-w>` - delete back a word
`<C-u>` - delete back a line in current insert

```
1. This is a whole sentence.
C-w -> This is a whole  
C-u -> 

2. This is 
-> This is a whole sentence.
C-w -> This is a whole
C-w -> This is 
```

## multi cursor 
`<C-v>` - start multi cursor visual mode
then 
* `I` - enter insert mode, then `<ESC>`, all lines will be inserted
* `A` - enter insert mode, same as `I`
```
this is
this is
this is

this is showing how mulit cursor works.
this is showing how mulit cursor works.
this is showing how mulit cursor works.
```

## batch process
```
given:
1, 2, 3 
expect:
1,
2,
3

solve:
<S-v> -> : -> s/, /,\r/g
```

```
given:
User(id=1),
User(id=23),
User(id=456)
exepct:
1,
23,
456

solve:
<S-v> -> 2j -> : -> s/
User(id=1),
User(id=23),
User(id=456)
```
