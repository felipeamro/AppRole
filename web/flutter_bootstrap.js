{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  config: {
    // Serve o CanvasKit localmente (build/web/canvaskit) em vez de buscar em
    // www.gstatic.com, evitando depender de um CDN externo em tempo de execucao.
    canvasKitBaseUrl: "/canvaskit/",
  },
});
