import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final Function(File)? onImageCaptured;
  
  const CameraScreen({
    super.key,
    this.onImageCaptured,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _initializeCameraController(_selectedCameraIndex);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy camera')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khởi tạo camera: ${e.toString()}')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _initializeCameraController(int cameraIndex) async {
    if (_cameras == null || cameraIndex >= _cameras!.length) return;

    final camera = _cameras![cameraIndex];
    
    // Dispose controller cũ nếu có
    await _controller?.dispose();
    
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg, // Đảm bảo format JPEG cho tất cả platform
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khởi tạo camera: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
        // Quay lại màn hình trước nếu không khởi tạo được
        Navigator.pop(context);
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _isInitialized = false;
    });

    await _controller?.dispose();
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _initializeCameraController(_selectedCameraIndex);
  }

  Future<void> _takePicture() async {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera chưa sẵn sàng. Vui lòng đợi...')),
        );
      }
      return;
    }

    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Chụp ảnh
      final XFile capturedImage = await _controller!.takePicture();
      
      // Trên iOS, file path có thể gây lỗi "_Namespace"
      // Sử dụng trực tiếp path từ XFile, nếu lỗi thì đọc bytes
      File imageFile;
      
      try {
        // Thử sử dụng file path trực tiếp
        imageFile = File(capturedImage.path);
        
        // Kiểm tra file có tồn tại và có thể đọc được không
        if (await imageFile.exists()) {
          final bytes = await imageFile.readAsBytes();
          if (bytes.isEmpty) {
            throw Exception('File ảnh rỗng');
          }
          // File hợp lệ, sử dụng trực tiếp
        } else {
          throw Exception('File không tồn tại');
        }
      } catch (e) {
        // Nếu không thể truy cập file path trực tiếp (iOS _Namespace error)
        // Đọc bytes từ XFile và tạo file tạm
        try {
          final bytes = await capturedImage.readAsBytes();
          if (bytes.isEmpty) {
            throw Exception('Không thể đọc dữ liệu ảnh');
          }
          
          // Tạo file tạm từ bytes
          // Trên mobile, sử dụng path từ XFile làm fallback
          // Tạo tên file unique
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final tempPath = '${capturedImage.path}_temp_$timestamp.jpg';
          imageFile = File(tempPath);
          
          // Ghi bytes vào file
          await imageFile.writeAsBytes(bytes);
        } catch (readError) {
          // Nếu vẫn lỗi, thử dùng path gốc
          imageFile = File(capturedImage.path);
        }
      }
      
      setState(() {
        _isCapturing = false;
      });

      // Trả về ảnh đã chụp qua callback nếu có
      if (widget.onImageCaptured != null) {
        widget.onImageCaptured!(imageFile);
      }
      
      // Tự động quay lại màn hình trước với file ảnh
      if (mounted) {
        Navigator.pop(context, imageFile);
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chụp ảnh: ${e.toString()}'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            if (_isInitialized && _controller != null && _controller!.value.isInitialized)
              Positioned.fill(
                child: CameraPreview(_controller!),
              )
            else
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (_cameras != null && _cameras!.length > 1)
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
                        onPressed: _switchCamera,
                        tooltip: 'Đổi camera',
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Capture Button
                    GestureDetector(
                      onTap: _isCapturing ? null : _takePicture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: _isCapturing ? Colors.grey : Colors.white,
                            width: 4,
                          ),
                        ),
                        child: _isCapturing
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              )
                            : Container(
                                margin: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Hint Text
                    Text(
                      'Chạm để chụp ảnh',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

