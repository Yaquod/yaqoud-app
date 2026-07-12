import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:yaqood/Controllers/trip_history_controller.dart';
import 'package:yaqood/Models/trip_history_model.dart';
import 'package:yaqood/Widgets/Primary_color.dart';
import 'package:yaqood/Widgets/trip_history_card.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key}); 

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final TripHistoryController _controller = TripHistoryController();
  final ScrollController _scrollController = ScrollController();
  
  int _activeFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.fetchFirstPage(onUpdate: () {
      if (mounted) setState(() {});
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.fetchNextPage(onUpdate: () {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<TripItem> _getFilteredTrips() {
    switch (_activeFilterIndex) {
      case 1:
        return _controller.completedTrips;
      case 2:
        return _controller.cancelledTrips;
      case 0:
      default:
        return _controller.allTrips;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<TripItem> currentTrips = _getFilteredTrips();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD9ECFF), Color(0xFFCFE5FF), Color(0xFFE9E3FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Your Rides',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 48), 
                  ],
                ),
              ),
              
              const Gap(12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5), 
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip(index: 0, label: 'All'),
                      const Gap(8),
                      _buildFilterChip(index: 1, label: "Completed"),
                      const Gap(8),
                      _buildFilterChip(index: 2, label: "Cancelled"),
                    ],
                  ),
                ),
              ),

              const Gap(16),

              Expanded(
                child: _buildTripList(currentTrips),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({required int index, required String  label}) {
    final bool isSelected = _activeFilterIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeFilterIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? PrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: PrimaryColor.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripList(List<TripItem> trips) {
    if (_controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: PrimaryColor),
      );
    }

    if (_controller.errorMessage != null && trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Error: ${_controller.errorMessage}",
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
            const Gap(12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: PrimaryColor),
              onPressed: () => _controller.fetchFirstPage(onUpdate: () => setState(() {})),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (trips.isEmpty) {
      return const Center(
        child: Text(
          "No autonomous rides found.",
          style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return RefreshIndicator(
      color: PrimaryColor,
      onRefresh: () => _controller.fetchFirstPage(onUpdate: () => setState(() {})),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 24), 
        itemCount: trips.length + (_controller.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == trips.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: PrimaryColor),
                ),
              ),
            );
          }

          return TripHistoryCard(
            trip: trips[index],
            currentUserLocation: null,
          );
        },
      ),
    );
  }
}