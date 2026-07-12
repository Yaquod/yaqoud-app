import 'package:yaqood/Models/trip_history_model.dart';
import 'package:yaqood/Services/trip_api_service.dart';

class TripHistoryController {
  final TripApiService _apiService = TripApiService();

  List<TripItem> allTrips = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  int currentPage = 0;
  final int pageSize = 10; 
  String? errorMessage;

  List<TripItem> get completedTrips => allTrips.where((trip) => trip.status == "COMPLETED").toList();
  List<TripItem> get cancelledTrips => allTrips.where((trip) => trip.status.contains("CANCELLED")).toList();

  Future<void> fetchFirstPage({required Function onUpdate}) async {
    isLoading = true;
    errorMessage = null;
    currentPage = 0;
    hasMoreData = true;
    allTrips.clear();
    onUpdate(); 

    await _loadTrips();

    isLoading = false;
    onUpdate();
  }

  Future<void> fetchNextPage({required Function onUpdate}) async {
    if (isLoadingMore || !hasMoreData) return;

    isLoadingMore = true;
    currentPage++;
    onUpdate(); 
    await _loadTrips();

    isLoadingMore = false;
    onUpdate(); 
  }

  Future<void> _loadTrips() async {
    final responseMap = await _apiService.getLastTrips(page: currentPage, size: pageSize);

    if (responseMap == null || responseMap.containsKey('error_type')) {
      errorMessage = responseMap?['error_type'] ?? "Failed to load rides";
      hasMoreData = false;
      return;
    }

    final historyResponse = TripHistoryResponse.fromJson(responseMap);

    if (historyResponse.success && historyResponse.data != null) {
      final newTrips = historyResponse.data!.content;
      
      if (newTrips.isEmpty) {
        hasMoreData = false;
      } else {
        allTrips.addAll(newTrips);
        
        if (historyResponse.data!.page != null) {
          final pageInfo = historyResponse.data!.page!;
          if (pageInfo.number >= pageInfo.totalPages - 1) {
            hasMoreData = false;
          }
        }
      }
    } else {
      errorMessage = historyResponse.message ?? "Something went wrong";
    }
  }
}