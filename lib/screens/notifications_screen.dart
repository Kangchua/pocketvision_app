import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/exception_handler.dart';
import '../utils/theme_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    
    try {
      await context.read<NotificationProvider>().fetchNotifications(user.id);
      final error = context.read<NotificationProvider>().error;
      if (error != null && mounted) {
        ExceptionHandler.showErrorSnackBar(context, error);
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await context.read<NotificationProvider>().markAsRead(id);
      if (mounted) {
        ExceptionHandler.showSuccessSnackBar(context, 'Đã đánh dấu đã đọc');
      }
    } catch (e) {
      if (mounted) {
        ExceptionHandler.showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final provider = context.read<NotificationProvider>();
    if (provider.unreadCount == 0) {
      ExceptionHandler.showInfoSnackBar(context, 'Không có thông báo chưa đọc');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh dấu tất cả đã đọc?'),
        content: Text('Bạn có muốn đánh dấu ${provider.unreadCount} thông báo là đã đọc?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Đồng ý', style: TextStyle(color: ThemeColors.getPrimary(context))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final user = context.read<AuthProvider>().user;
      if (user == null) return;
      
      try {
        await provider.markAllAsRead(user.id);
        if (mounted) {
          ExceptionHandler.showSuccessSnackBar(context, 'Đã đánh dấu tất cả đã đọc');
        }
      } catch (e) {
        if (mounted) {
          ExceptionHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  Future<void> _deleteNotification(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thông báo?'),
        content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: ThemeColors.getDanger(context))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<NotificationProvider>().deleteNotification(id);
        if (mounted) {
          ExceptionHandler.showSuccessSnackBar(context, 'Đã xóa thông báo');
        }
      } catch (e) {
        if (mounted) {
          ExceptionHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  Future<void> _deleteAllNotifications() async {
    final provider = context.read<NotificationProvider>();
    if (provider.notifications.isEmpty) {
      ExceptionHandler.showInfoSnackBar(context, 'Không có thông báo để xóa');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả thông báo?'),
        content: Text('Bạn có chắc chắn muốn xóa tất cả ${provider.notifications.length} thông báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa tất cả', style: TextStyle(color: ThemeColors.getDanger(context))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await provider.deleteAllNotifications();
        if (mounted) {
          ExceptionHandler.showSuccessSnackBar(context, 'Đã xóa tất cả thông báo');
        }
      } catch (e) {
        if (mounted) {
          ExceptionHandler.showErrorSnackBar(context, e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackground(context),
      appBar: AppBar(
        title: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            final unreadCount = provider.unreadCount;
            return Row(
              children: [
                const Text('Thông báo'),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeColors.getDanger(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        elevation: 0,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (provider.unreadCount > 0) {
                return IconButton(
                  icon: Icon(Icons.done_all, color: ThemeColors.getPrimary(context)),
                  tooltip: 'Đánh dấu tất cả đã đọc',
                  onPressed: _markAllAsRead,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: ThemeColors.getTextPrimary(context)),
            onSelected: (value) {
              switch (value) {
                case 'mark_all_read':
                  _markAllAsRead();
                  break;
                case 'delete_all':
                  _deleteAllNotifications();
                  break;
                case 'refresh':
                  _loadNotifications();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20, color: ThemeColors.getPrimary(context)),
                    SizedBox(width: 12),
                    Text('Đánh dấu tất cả đã đọc'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: ThemeColors.getDanger(context)),
                    SizedBox(width: 12),
                    Text('Xóa tất cả'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20, color: ThemeColors.getTextPrimary(context)),
                    SizedBox(width: 12),
                    Text('Làm mới'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.error != null && 
              notificationProvider.error!.contains('403')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: ThemeColors.getDanger(context)),
                  const SizedBox(height: 16),
                  Text(
                    'Không có quyền truy cập',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ThemeColors.getDanger(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn không có quyền xem thông báo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ThemeColors.getTextTertiary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (notificationProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: ThemeColors.getTextLight(context)),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có thông báo nào',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ThemeColors.getTextTertiary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thông báo về ngân sách và hóa đơn sẽ xuất hiện ở đây',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ThemeColors.getTextTertiary(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final unreadNotifications = notificationProvider.unreadNotifications;
          final readNotifications = notificationProvider.readNotifications;

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: CustomScrollView(
              slivers: [
                // Unread Notifications Section
                if (unreadNotifications.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active, 
                              color: ThemeColors.getPrimary(context), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Chưa đọc (${unreadNotifications.length})',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.getPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notification = unreadNotifications[index];
                        return _buildNotificationCard(context, notification, false);
                      },
                      childCount: unreadNotifications.length,
                    ),
                  ),
                ],

                // Read Notifications Section
                if (readNotifications.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_none, 
                              color: ThemeColors.getTextSecondary(context), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Đã đọc (${readNotifications.length})',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.getTextSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notification = readNotifications[index];
                        return _buildNotificationCard(context, notification, true);
                      },
                      childCount: readNotifications.length,
                    ),
                  ),
                ],

                // Empty state (should not reach here, but just in case)
                if (notificationProvider.notifications.isEmpty)
                  const SliverFillRemaining(
                    child: SizedBox.shrink(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, notification, bool isRead) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ThemeColors.getDanger(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xóa thông báo?'),
            content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Xóa', style: TextStyle(color: ThemeColors.getDanger(context))),
              ),
            ],
          ),
        );
        return confirm == true;
      },
      onDismissed: (direction) {
        _deleteNotification(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isRead ? ThemeColors.getSurface(context) : ThemeColors.getSurfaceLight(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead ? ThemeColors.getBorder(context) : ThemeColors.getPrimary(context).withOpacity(0.3),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: isRead ? null : [
            BoxShadow(
              color: ThemeColors.getPrimary(context).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (!isRead) {
                _markAsRead(notification.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isRead 
                          ? ThemeColors.getTextSecondary(context).withOpacity(0.1)
                          : ThemeColors.getPrimary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: isRead 
                          ? ThemeColors.getTextSecondary(context)
                          : ThemeColors.getPrimary(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                                  color: ThemeColors.getTextPrimary(context),
                                ),
                              ),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: ThemeColors.getPrimary(context),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(notification.createdAt ?? DateTime.now()),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ThemeColors.getTextTertiary(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, 
                        color: ThemeColors.getTextSecondary(context), size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_read':
                          if (!isRead) {
                            _markAsRead(notification.id);
                          }
                          break;
                        case 'delete':
                          _deleteNotification(notification.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!isRead)
                        PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.done, size: 18, color: ThemeColors.getPrimary(context)),
                              SizedBox(width: 12),
                              Text('Đánh dấu đã đọc'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: ThemeColors.getDanger(context)),
                            SizedBox(width: 12),
                            Text('Xóa'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BUDGET_WARNING':
        return Icons.warning;
      case 'NEW_INVOICE':
        return Icons.receipt_long;
      case 'PAYMENT_REMINDER':
        return Icons.payment;
      case 'GENERAL':
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}