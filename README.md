# zunder-prompt

Simple and fast zsh prompt based on [gitstatus](https://github.com/romkatv/gitstatus),
built for using it in [zunder-zsh](https://github.com/Warbacon/zunder-prompt)
but compatible with any configuration.

![preview](./assets/preview.webp)

## Why?

I found myself oscillating between Starship and Powerlevel10k for
my preferred zsh prompt. Starship is very attractive, but it has
too many features for my needs. On the other hand, Powerlevel10k is fast
and its git information is very helpful, but it has too many features
that I don't use and it's difficult to configure for colors.

So I built my own prompt with the colors of Starship and git information from gitstatus,
which uses Powerlevel10k.

Because of that, this prompt is faster than Starship but easier to modify than Powerlevel10k.
However, Powerlevel10k can be even faster if you use the instant-prompt functionality.

## Installation

### Manual

1. Clone this repository wherever you want.

    ```sh
    git clone --recursive https://github.com/Warbacon/zunder-prompt.git
    ```

2. Source `zunder-prompt.zsh` in your `.zshrc`.

    ```sh
    source /wherever/you/cloned/this/repo/zunder-prompt.zsh
    ```

### Zinit

```sh
zi ice compile'./gitstatus/(install|*.zsh)'
zi light "Warbacon/zunder-prompt"
```

## Customization

As zunder-prompt is built with simplicity and speed in mind, there isn't too
much customization available. However, you can change the prompt's character
symbol and its color by modifying the following environment variables:

```sh
ZUNDER_PROMPT_CHAR=""              # default value: "❯"
ZUNDER_PROMPT_CHAR_COLOR="yellow"   # default value: "green"
```

`ZUNDER_PROMPT_CHAR_COLOR` does accept any color between 0 and 255
or a color name.

## Thanks to

- [gitsatus](https://github.com/romkatv/gitstatus)
- [Starship](https://starship.rs)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
