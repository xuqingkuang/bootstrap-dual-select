# Bootstrap Dual Select

## Demo

[Click here for demo](http://xuqingkuang.github.io/bootstrap-dual-select/index.html)

## Synopsis

Bootstrap Dual Select is a dual select implementation especially designed for 
Bootstrap and jQuery.

It focus to use the jQuery total features and writen in Coffee scripts.

## Usage

At first you should create a simple `<select>` tag. After which you can
initialize the dual select as a jQuery plugin just like: 

`$('select').dualSelect();`

If you wish to restore the original select element, just use

`$('select').dualSelect('destory');`

## Options / API

There are currently two ways to use this component. First up is by using html5
`data-*` attributes embedded in the select tag, but you can also provide a 
Javascript Object. The variable names are the same all around and can be even
mixed and matched within the select or Javascript. The current options are: 

| Option       | Type    | Default    | Description |
| ------------ | ------- | ---------- | ----------- |
| `title`      | String  | Item       | The title of the control. |
| `timeout`    | UInt    | 300        | Timeout of searching with the filter. |
| `filter`     | Boolean | true       | Filter display. |

Bootstrap Dual Select could set default templates, language translations, and
default options with `$.dualSelect`, all of options are opened for customization.


## Installation


Bootstrap Dual Select could be install with bower or npm, just to use

`$ bower install bootstrap-dual-select`

`$ npm install bootstrap-dual-select`

Also, copy the js file in `dist` folder to your project and reference it
direclty could work too.

`<script src="./dist/bootstrap-dual-select.js"></script>`

## How to contribute

Bootstrap Dual Select was writen in Coffeescript, so it should be installed at
first, just use following command:

`npm install -g coffee-script`

And then clone the project:

`git clone https://github.com/xuqingkuang/bootstrap-dual-select`

Enter into the project and start build:

`npm run-script compile`

**Issues and patches are welcome. ;-)**


```
The MIT License (MIT)

Copyright (c) 2014 Geodan B.V. (Alex van den Hoogen)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```