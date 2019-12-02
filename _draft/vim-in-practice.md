[*VIM Cheat Sheet*](https://vim.rtorr.com/)

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




## edit (CRUD)

### Create

To create character, you need enter the `INSERT` mode
`i` - `insert`, enter `INSERT` mode, before current character under the cursor
`I` - `Insert`, enter `INSERT` mode, before current line
`a` - `append`, enter `INSERT` mode, after current character under the cursor
`A` - `Append`, enter `INSERT` mode, after current line
`o` - `open`, open a new line below current line then enter `INSERT` mode
`O` - `Open`, open a new line above current line then enter `INSERT` mode


`c` - `change`, can enter `INSERT` mode as well, but with motion, see Update.
`s` - `substitute`, can enter `INSERT` mode as well, with delete current character.

### Read

`<C-g>` - show the line location in the current file, but not works in IdeaVIM
kk

### Update


### Delete
`d` -  
`x` 
`c`


