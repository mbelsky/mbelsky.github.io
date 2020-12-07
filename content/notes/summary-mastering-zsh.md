([source](https://github.com/rothgar/mastering-zsh/blob/master))

## history

### Modifying the Last Command

```
$ systemctl status service-name

# replace status with restart
$ ^status^restart # systemctl restart service-name

# global
$ echo foo foo
$ ^foo^bar^:G # echo bar bar

# also there is fc command
```

## aliases

### Automatically Expand Aliases

🤯 https://github.com/rothgar/mastering-zsh/blob/master/docs/helpers/aliases.md#automatically-expand-aliases

```
# Search through your command history and print the top 10 commands
alias history-stat='history 0 | awk ''{print $2}'' | sort | uniq -c | sort -n -r | head'
```

## variables

Keyword to search: `Parameter Substitution`
