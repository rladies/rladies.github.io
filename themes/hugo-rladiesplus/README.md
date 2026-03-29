# Adapted Initio theme for Hugo
 
 [Hugo-Initio](https://miguelsimoni.github.io/hugo-initio-site/) is ported from the [Initio](http://www.gettemplate.com/info/initio/) template by [GetTemplate.com](http://www.gettemplate.com/) for [Hugo](https://gohugo.io/).

## License

This port is released under the MIT License. Check the [original theme license](http://www.gettemplate.com/info/initio/) for additional licensing information.

## Thanks

Thanks to [Steve Francia](https://github.com/spf13) for creating Hugo and the awesome community around the project. And also thanks to [Sergey Pozhilov](http://www.gettemplate.com/) for creating this awesome theme.

---

## JS bundling (theme-specific)

This theme includes a lightweight workflow to bundle vendor JavaScript into `assets/` so Hugo Pipes can fingerprint and minify it. The system is designed so that repository clones continue to work without running npm; maintainers can build and commit the bundle when they update libraries.

What was added

- `package.json` — npm scripts and dependencies used for bundling.
- `assets/js/vendor.js` — entry point that imports vendor libraries and exposes globals expected by legacy scripts.

How it works

- The bundler writes `assets/js/vendor.bundle.js`. When present, Hugo Pipes will minify and fingerprint it and the theme will include the fingerprinted file.
- If the bundled asset is not present, the theme falls back to loading individual `assets/js/*.js` files so clones don't need to run npm.

Quick commands for maintainers

1. Install dev dependencies (only required if you're updating or rebuilding the bundle):

```bash
cd themes/hugo-rladies
npm install
```

2. Build the bundle into `assets/`:

```bash
npm run build:js
```

3. Optionally commit the built `assets/js/vendor.bundle.js` so clones don't need to build.

4. To update libraries to their latest matching versions:

```bash
npm run update:libs
npm run build:js
```

Notes and alternatives

- The build pipeline uses `esbuild` for speed. If you need more features (code-splitting, plugins), consider webpack or rollup.
- If you'd prefer to keep a committed static bundle in `static/js/` instead of using `assets/`, adjust the `build:js` script in `package.json` to write into `static/js/`.
- I can add an optional CI step to rebuild the bundle on release and commit it automatically.
# Adapted Initio theme for Hugo

[Hugo-Initio](https://miguelsimoni.github.io/hugo-initio-site/) is ported from the [Initio](http://www.gettemplate.com/info/initio/) template by [GetTemplate.com](http://www.gettemplate.com/) for [Hugo](https://gohugo.io/).



### Original Template Info

**Licensing:** Creative Commons (for more options, go to the [original template site](http://www.gettemplate.com/info/initio/))  
**Released:** Feb 21, 2014  
**Last Updated:** Feb 21, 2014  
**Version:** 1.0  
**Bootstrap:** 3.3.4 or higher  
**Libraries:** jQuery  
**Designer:** Sergey Pozhilov  


## License

This port is released under the MIT License. Check the [original theme license](http://www.gettemplate.com/info/initio/) for additional licensing information.

## Thanks

Thanks to [Steve Francia](https://github.com/spf13) for creating Hugo and the awesome community around the project. And also thanks to [Sergey Pozhilov](http://www.gettemplate.com/) for creating this awesome theme.
