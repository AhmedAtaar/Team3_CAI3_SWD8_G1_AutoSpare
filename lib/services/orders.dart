import 'package:auto_spare/services/orders_repository.dart';
import 'package:auto_spare/services/orders_repo_memory.dart';

/// واجهة موحّدة للطلبات عبر التطبيق كله
final OrdersRepository ordersRepo = OrdersRepoMemory();
