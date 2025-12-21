/// Cấu hình API
/// 
/// HƯỚNG DẪN:
/// 1. Để chạy trên iPhone, thay đổi [serverIp] thành IP của máy tính chạy backend
/// 2. Lấy IP: Trên Mac chạy `ifconfig | grep "inet "`, trên Windows chạy `ipconfig`
/// 3. Đảm bảo iPhone và máy tính cùng một mạng WiFi
/// 4. Port mặc định là 8081 (theo application.properties của backend)
class ApiConfig {
  // ============================================
  // CẤU HÌNH QUAN TRỌNG - ĐỌC KỸ TRƯỚC KHI THAY ĐỔI
  // ============================================
  
  /// IP của máy tính chạy backend server
  /// 
  /// - localhost: Dùng cho emulator/simulator
  /// - 192.168.x.x: Dùng cho device thật (iPhone/Android) - local network
  /// - 18.138.243.153: AWS EC2 public IP (production)
  /// 
  /// Có thể thay đổi giữa các IP:
  /// - '18.138.243.153' (AWS EC2 - production)
  /// - '192.168.100.194' (Local development)
  /// - '192.168.2.8' (IP dự phòng - nếu máy khác host)
  /// 
  /// Ví dụ: '192.168.1.100' hoặc '192.168.0.5'
  static const String serverIp = '18.138.243.153';
  
  /// Port của backend server (theo application.properties)
  static const int serverPort = 8081;
  
  /// Base URL của API
  static String get baseUrl => 'http://$serverIp:$serverPort/api';
  
  // ============================================
  // CÁC CẤU HÌNH KHÁC
  // ============================================
  
  /// Timeout cho kết nối (giây)
  static const int connectTimeout = 30;
  
  /// Timeout cho nhận dữ liệu (giây)
  static const int receiveTimeout = 30;
  
  /// Debug mode - hiển thị log API requests/responses
  static const bool debugMode = true;
  
  /// Base URL của server (không có /api)
  static String get serverBaseUrl => 'http://$serverIp:$serverPort';
  
  // ============================================
  // CẤU HÌNH AI SERVER
  // ============================================
  
  /// URL của AI server để phân tích hóa đơn
  /// Cập nhật URL này khi ngrok URL thay đổi
  static const String aiServerUrl = 'https://unominously-hexangular-corrinne.ngrok-free.dev/extract_invoice';
  
  /// Build full URL cho avatar/image từ relative path
  /// Ví dụ: "uploads/avatars/avatar_1_abc.jpg" -> "http://192.168.100.194:8081/uploads/avatars/avatar_1_abc.jpg"
  static String buildImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    // Nếu đã là full URL thì trả về luôn
    if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
      return relativePath;
    }
    // Nếu là relative path thì build full URL
    return '$serverBaseUrl/$relativePath';
  }
}

