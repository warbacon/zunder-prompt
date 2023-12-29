# zunder-prompt

Simple and fast zsh prompt based on [gitstatus](https://github.com/romkatv/gitstatus).

![preview](./assets/preview.webp)

## Why? 🤔

I found myself oscillating between **Starship** and **Powerlevel10k** for my preferred
zsh prompt. Starship is very customizable and attractive by default,
but it has too many features that I don't use and that makes it slower than
I would like. Powerlevel10k on the other hand is extremely fast but the
configuration file is extremely complex.

My goal then was to create a prompt with the **basic functionality needed**.
After mulling this over, I came to the conclusion that simply seeing if
the previous command had failed and the information from the git repository
I was in was enough.

I also decided to **dispense with too many advanced customization options**,
as that would complicate the code and would not be necessary
if it was already pretty enough by default.

Zunder-prompt is inspired by Starship for its look and feel and uses
gitstatus to display git information. Normally the latter should slow down
the prompt quite a bit, however, this project is the same one that Powerlevel10k
uses for it and is extremely optimized, so the prompt has **no lag**
at all and **works instantly**.

## Installation ⚙️

### Zinit

```sh
zinit light-mode depth"1" for \
  make"zwc" romkatv/gitstatus \
  warbacon/zunder-prompt
```

## Customization 🎨

As zunder-prompt is built with simplicity and speed in mind, there isn't too
much customization available. However, you can change the prompt's character
symbol.

```sh
ZUNDER_PROMPT_CHAR="➜"              # default value: "❯"
```

## Thanks to

- [romkatv](https://github.com/romkatv) for gitsatus.
- [Starship](https://starship.rs/).
