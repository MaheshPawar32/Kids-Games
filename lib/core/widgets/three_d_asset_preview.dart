import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// Displays one bundled GLB in a Flutter Scene viewport.
///
/// Keep this widget lazy: create it only when the 3D preview is visible.
class ThreeDAssetPreview extends StatefulWidget {
  const ThreeDAssetPreview({
    required this.assetPath,
    this.scale = 1.0,
    this.semanticsLabel = '3D model preview',
    super.key,
  });

  final String assetPath;
  final double scale;
  final String semanticsLabel;

  @override
  State<ThreeDAssetPreview> createState() => _ThreeDAssetPreviewState();
}

class _ThreeDAssetPreviewState extends State<ThreeDAssetPreview> {
  final Scene _scene = Scene();
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await Scene.initializeStaticResources();
      final model = await Node.fromGlbAsset(widget.assetPath);
      if (!mounted) return;

      model.scale = vm.Vector3.all(widget.scale);
      _scene.add(model);
      setState(() => _isReady = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _scene.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Icon(
          Icons.view_in_ar_rounded,
          size: 44,
          color: Color(0xFF8792A8),
          semanticLabel: '3D preview unavailable',
        ),
      );
    }

    if (!_isReady) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    return Semantics(
      image: true,
      label: widget.semanticsLabel,
      child: SceneView(
        _scene,
        camera: PerspectiveCamera(
          position: vm.Vector3(0, 0, -3.6),
          target: vm.Vector3.zero(),
        ),
        pixelRatio: 1.5,
        warmUp: true,
      ),
    );
  }
}
