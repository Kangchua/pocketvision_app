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
  /// - 192.168.x.x: Dùng cho device thật (iPhone/Android)
  /// 
  /// Có thể thay đổi giữa các IP:
  /// - '192.168.100.194' (IP hiện tại)
  /// - '192.168.2.8' (IP dự phòng - nếu máy khác host)
  /// 
  /// Ví dụ: '192.168.1.100' hoặc '192.168.0.5'
  static const String serverIp = '192.168.100.194';
  
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
}

