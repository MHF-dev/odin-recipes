{{flutter_js}}
{{flutter_build_config}}

// Use the CanvasKit files bundled with the app instead of a CDN so the web
// preview also works offline.
_flutter.loader.load({
  config: { canvasKitBaseUrl: "canvaskit/" },
});
