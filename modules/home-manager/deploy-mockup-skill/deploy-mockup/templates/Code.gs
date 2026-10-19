/**
 * Web app entry point. Serves the single-file build (index.html) produced by
 * scripts/build-gas.mjs. BUILD is filled in at build time with the page title
 * and the branch and commit it was built from.
 */
var BUILD = __BUILD__;

function doGet() {
  return HtmlService.createHtmlOutputFromFile('index')
    .setTitle(BUILD.title + (BUILD.production ? '' : ' · ' + BUILD.branch))
    // HtmlService ignores <meta name="viewport"> inside the page; it must be added here.
    .addMetaTag('viewport', 'width=device-width, initial-scale=1');
}
