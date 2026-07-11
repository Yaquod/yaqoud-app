import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart' hide Route;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yaqood/Constants/constants.dart';
import 'package:yaqood/Enums/ride_step.dart';
import 'package:yaqood/Services/location_service.dart';
import 'package:yaqood/Services/map_helper.dart';
import 'package:yaqood/Services/map_routing_service.dart';
import 'package:yaqood/Services/profile_api_service.dart';
import 'package:yaqood/Services/trip_api_service.dart';
import 'package:yaqood/Widgets/App_Drawer.dart';
import 'package:yaqood/Widgets/Custom_SnackBar.dart';
import 'package:yaqood/Widgets/Map/map_buttons.dart';
import 'package:yaqood/Widgets/Map/map_center_pin.dart';
import 'package:yaqood/Widgets/Map/map_info_window.dart';
import 'package:yaqood/Widgets/Primary_color.dart';
import 'package:google_places_autocomplete_text_field/google_places_autocomplete_text_field.dart';
import 'package:yaqood/Widgets/confirm_trip_widget.dart';
import 'package:yaqood/Widgets/en_route_widget.dart';
import 'package:yaqood/Widgets/location_search_widget.dart';
import 'package:yaqood/Widgets/payment_widget.dart';
import 'package:yaqood/Widgets/picking_up_widget.dart';
import 'package:yaqood/Widgets/safety_check_widget.dart';
import 'package:yaqood/Widgets/searching_vehicle_widget.dart';
import 'package:yaqood/Widgets/trip_checkout_widget.dart';
import 'package:yaqood/Widgets/trip_complete_widget.dart';
import 'package:yaqood/Widgets/trip_offer_widget.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.initialTripId});
  final String? initialTripId;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  GoogleMapController? mapController;
  DraggableScrollableController sheetController =
      DraggableScrollableController();

  bool hasPermission = false;
  bool isMapMoving = false;
  bool isFirstTime = true;
  bool isSelectedFromSearch = false;
  bool showInfoWindow = true;
  bool hasRoute = false;
  bool isFirstVehicleLocationLoaded = false;
  bool isLoadingProfile = true;

  LatLng? startLocation;
  LatLng? currentLocation;
  LatLng? destinationLocation;
  LatLng? vehicleLiveLocation;

  String? startStreetName;
  String? destinationStreetName;
  String? currentTripStatus;
  String? tripRequestId;

  CameraPosition? lastCameraPosition;
  StreamSubscription<Position>? positionStream;
  StreamSubscription<Map<String, dynamic>>? sseTripSubscription;

  TextEditingController startController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  double sheetSize = 0.2;
  double? tripDistance;
  double? tripDuration;
  double? offerFare;
  double? offerTime;
  double vehicleBearing = 0.0;

  FocusNode startFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();

  GoogleApiConfig googleApiConfig = GoogleApiConfig(
    apiKey: dotenv.env["GOOGLE_MAPS_API_KEY"]!,
    fetchPlaceDetailsWithCoordinates: true,
  );

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};

  late VoidCallback _startFocusListener;
  late VoidCallback _destinationFocusListener;

  Timer? tripPollingTimer;

  RideStep currentStep = RideStep.initial;

  final LocationService _locationService = LocationService();
  final MapRoutingService _mapRoutingService = MapRoutingService();
  final TripApiService _tripApiService = TripApiService();
  final ProfileApiService _profileApiService = ProfileApiService();

  BitmapDescriptor? carMarkerIcon;

  Map<String, dynamic>? profileResponseData;

  // assign start Location to it`s textField
  void updatesStartFieldWithStartLocation() async {
    if (currentLocation == null) return;

    String street = await _locationService.getStreetName(startLocation!);

    setState(() {
      startController.text = street;
    });
  }

  // Location Stream
  void currentLocationStream() async {
    hasPermission = await _locationService.checkLocationPermission();

    if (!hasPermission) return;

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,

            distanceFilter: 10,
          ),
        ).listen((Position position) async {
          if (!mounted) return;

          LatLng newLatLng = LatLng(position.latitude, position.longitude);
          currentLocation = newLatLng;

          if (startLocation == null &&
              !isSelectedFromSearch &&
              !isMapMoving &&
              currentStep == RideStep.initial) {
            String street = await _locationService.getStreetName(newLatLng);

            if (!mounted) return;

            setState(() {
              startLocation = newLatLng;
              startStreetName = street;
              startController.text = street;
            });

            mapController?.animateCamera(CameraUpdate.newLatLng(newLatLng));
          }

          if (currentStep == RideStep.enRoute) {
            setState(() {
              vehicleLiveLocation = newLatLng;
            });

            followLiveCamera(newLatLng, bearing: position.heading);

            if (destinationLocation != null) {
              double distanceToTarget = Geolocator.distanceBetween(
                newLatLng.latitude,
                newLatLng.longitude,
                destinationLocation!.latitude,
                destinationLocation!.longitude,
              );

              if (distanceToTarget < 8) {
                tripPollingTimer?.cancel();
                setState(() {
                  currentStep = RideStep.completed;
                });
                openSheet(Constants.maxSheetSize);
              }
            }
          }
        });
  }

  //  Location Markers
  Set<Marker> getMarkers() {
    Set<Marker> markersSet = {};

    if (startLocation != null && currentStep != RideStep.enRoute) {
      markersSet.add(
        Marker(
          markerId: MarkerId("start"),
          position: startLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    if (destinationLocation != null) {
      markersSet.add(
        Marker(
          markerId: MarkerId("end"),
          position: destinationLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    if (vehicleLiveLocation != null && currentStep == RideStep.pickingUp) {
      markersSet.add(
        Marker(
          markerId: const MarkerId("yaqood_car_live"),
          position: vehicleLiveLocation!,
          icon:
              carMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
          rotation: vehicleBearing,
          flat: true,
          anchor: Offset(0.5, 0.5),
          infoWindow: const InfoWindow(
            title: "Yaqood Autonomous Vehicle",
            snippet: "Live Tracking",
          ),
        ),
      );
    }

    return markersSet;
  }

  // Update Route
  Future<void> updateRoute(
    LatLng start,
    LatLng destination, {
    bool focus = false,
  }) async {
    if (!mounted) return;
    setState(() {
      showInfoWindow = false;
      hasRoute = true;
    });

    try {
      final routeData = await _mapRoutingService.getRouteData(
        start: start,
        destination: destination,
      );

      List<LatLng> points = (routeData['coordinates'] as List).cast<LatLng>();
      Set<Polyline> computedPolylines = (routeData['polylines'] as Set)
          .cast<Polyline>();

      if (!mounted) return;

      if (points.isNotEmpty) {
        setState(() {
          polylineCoordinates = points;
          polylines = computedPolylines;
          tripDistance = (routeData['distance'] ?? 0) as double?;
          tripDuration = (routeData['duration'] ?? 0) as double?;
        });

        if (focus && polylineCoordinates.isNotEmpty) {
          focusOnRoute();
        }
      }
    } catch (e) {
      print("Error updating route: $e");
    }
  }

  // Follow live Location
  void followLiveCamera(LatLng location, {double bearing = 0.0}) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 17, tilt: 35, bearing: bearing),
      ),
    );
  }

  // FocusOnRoute
  void focusOnRoute() async {
    MapHelper.animateToRoute(mapController, polylineCoordinates);

    if (sheetController.isAttached) {
      double targetSize =
          (currentStep == RideStep.pickingUp || currentStep == RideStep.enRoute)
          ? Constants.pickingUpSize
          : currentStep == RideStep.confirmTrip
          ? Constants.tripSummary
          : Constants.minSheetSize;

      openSheet(targetSize);
    }
  }

  // clear Route
  void clearRoute() {
    setState(() {
      hasRoute = false;
      showInfoWindow = true;
      polylineCoordinates.clear();
      polylines.clear();
      tripDistance = 0;
      tripDuration = 0;
    });
  }

  // Clear Destination;
  void clearDestinaton() {
    setState(() {
      destinationController.clear();
      destinationLocation = null;
      destinationStreetName = null;
    });
  }

  // Bottom sheet animation
  void openSheet(double size) {
    if (!sheetController.isAttached) return;

    if ((sheetController.size - size).abs() < 0.02) return;

    sheetController.animateTo(
      size,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Start Trip Flow
  Future<void> startTripFlow() async {
    if (startLocation == null || destinationLocation == null) return;

    final result = await _tripApiService.requestTrip(
      start: LatLng(startLocation!.latitude, startLocation!.longitude),
      destination: LatLng(
        destinationLocation!.latitude,
        destinationLocation!.longitude,
      ),
    );

    if (result == null) return;

    if (result["error_type"] == "auth_error") {
      showSnackBar(context: context, message: "Login expired");
      return;
    }

    if (result["error_type"] == "network_error") {
      showSnackBar(context: context, message: "Network error");
      return;
    }

    if (result["success"] == true && result["data"]["status"] == "PENDING") {
      tripRequestId = result["data"]["id"].toString();

      setState(() {
        currentStep = RideStep.searchingVehicle;
      });

      startRequestPolling();
      openSheet(Constants.searchingSheetSize);
    }
  }

  // start Requst HTTP Polling
  void startRequestPolling() {
    tripPollingTimer?.cancel();

    if (tripRequestId == null) return;

    tripPollingTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final result = await _tripApiService.getRequestStatus(tripRequestId!);

      if (result == null) return;

      final data = result["data"];
      if (data == null) {
        print("Warning: result['data'] is null, skipping this polling tick");
        return;
      }

      final status = data['status'] as String?;
      final estimatedTimeValue = data['estimatedTime'];
      final estimatedFareValue = data['estimatedFare'];

      if (status == null) {
        print("Warning: status is null, skipping this polling tick");
        return;
      }

      final estimatedTime = estimatedTimeValue != null
          ? (estimatedTimeValue as num).toDouble()
          : 0.0;
      final estimatedFare = estimatedFareValue != null
          ? (estimatedFareValue as num).toDouble()
          : 0.0;

      currentTripStatus = status;

      handleRequestStatus(status, estimatedTime, estimatedFare);
    });
  }

  // Handle Request Status
  void handleRequestStatus(
    String status,
    double estimatedTime,
    double estimatedFare,
  ) {
    if (!mounted) return;

    if (status == "COMPLETED") {
      tripPollingTimer?.cancel();

      setState(() {
        offerTime = estimatedTime;
        offerFare = estimatedFare;
        currentStep = RideStep.offer;
      });

      openSheet(Constants.tripSummary);
    }
  }

  // start Trip HTTP Polling
  void startTripPolling() {
    tripPollingTimer?.cancel();

    if (tripRequestId == null) return;

    tripPollingTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      final result = await _tripApiService.getTripStatus(tripRequestId!);

      if (result == null) return;

      final data = result["data"];
      if (data == null) {
        print("Warning: result['data'] is null, skipping this polling tick");
        return;
      }

      final status = data['status'] as String?;

      if (status == null) {
        print("Warning: status is null, skipping this polling tick");
        return;
      }

      currentTripStatus = status;

      handleTripStatus(status);
    });
  }

  // Handle Trip Status
  void handleTripStatus(String status) {
    if (!mounted) return;

    if (status == "VEHICLE_ON_WAY") {
      if (currentStep != RideStep.pickingUp) {
        setState(() {
          currentStep = RideStep.pickingUp;
        });
        openSheet(Constants.pickingUpSize);
      }
    } else if (status == "ARRIVED_AT_PICKUP") {
      if (currentStep == RideStep.enRoute) return;

      if (currentStep != RideStep.safetyCheck) {
        setState(() {
          currentStep = RideStep.safetyCheck;
        });
        openSheet(Constants.pickingUpSize);
      }

      if (vehicleLiveLocation != null && destinationLocation != null) {
        updateRoute(vehicleLiveLocation!, destinationLocation!, focus: false);
        followLiveCamera(vehicleLiveLocation!, bearing: vehicleBearing);
      }
    } else if (status == "IN_PROGRESS" || status == "ARRIVED_AT_DESTINATION") {
      if (currentStep != RideStep.enRoute) {
        setState(() {
          currentStep = RideStep.enRoute;
        });
      }

      if (currentLocation != null && destinationLocation != null) {
        updateRoute(currentLocation!, destinationLocation!, focus: false);
        followLiveCamera(currentLocation!, bearing: vehicleBearing);
      }
    } else if (status == "COMPLETED") {
      tripPollingTimer?.cancel();

      if (currentStep != RideStep.checkout) {
        setState(() {
          currentStep = RideStep.checkout;
        });
        openSheet(Constants.pickingUpSize);
      }
    }
  }

  // cancel trip request
  Future<void> handleCancelTrip() async {
    if (tripRequestId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    bool isCancelled = await _tripApiService.cancelTripRequest(tripRequestId!);

    if (mounted) Navigator.pop(context);

    if (isCancelled) {
      tripPollingTimer?.cancel();

      if (mounted) {
        setState(() {
          currentStep = RideStep.confirmTrip;
        });
        openSheet(Constants.tripSummary);

        showSnackBar(
          context: context,
          message: "Trip request cancelled successfully",
          isError: false,
        );
      }
    } else {
      if (mounted) {
        showSnackBar(
          context: context,
          message: "Failed to cancel trip. Please try again.",
          isError: true,
        );
      }
    }
  }

  // Decline Offer
  Future<Map<String, dynamic>?> handleDeclineOffer() async {
    if (tripRequestId == null) return null;

    final result = await _tripApiService.declineOffer(tripRequestId!);

    if (result != null && result["success"] == true) {
      showSnackBar(context: context, message: "Offer Declined", isError: true);

      if (mounted) {
        setState(() {
          currentStep = RideStep.confirmTrip;
        });
        openSheet(Constants.tripSummary);
      }
    } else {
      showSnackBar(context: context, message: "Network error");
    }

    return result;
  }

  // Accept Offer
  Future<bool> handleAcceptOffer() async {
    if (tripRequestId == null) return false;

    try {
      final result = await _tripApiService.acceptOffer(tripRequestId!);

      if (result != null && result["success"] == true) {
        final data = result["data"];
        if (data != null && data["status"] == "ACCEPTED") {
          if (!mounted) return false;

          showSnackBar(
            context: context,
            message: "Your vehicle is on the way and paid successfully!",
            isError: false,
          );

          openSheet(Constants.minSheetSize);
          return true;
        } else {
          showSnackBar(context: context, message: "Something went wrong");
        }
      } else {
        showSnackBar(context: context, message: "Network error");
      }
    } catch (e) {
      print("Error in handleAcceptOffer: $e");
      if (mounted) {
        showSnackBar(context: context, message: "Error accepting offer");
      }
    }
    return false;
  }

  // handle Start Trip
  Future<void> handleStartTrip() async {
    if (tripRequestId == null) return;

    tripPollingTimer?.cancel();

    final result = await _tripApiService.startTrip(tripRequestId!);

    if (result != null && result["success"] == true) {
      if (mounted) {
        setState(() {
          currentStep = RideStep.enRoute;
        });

        if (currentLocation != null) {
          followLiveCamera(currentLocation!, bearing: vehicleBearing);
        }

        showSnackBar(
          context: context,
          message:
              "Trip started successfully! Enjoy your safe autonomous journey.",
          isError: false,
        );
      }

      startTripPolling();
    } else {
      if (mounted) {
        if (result != null && result["error_type"] == "auth_error") {
          showSnackBar(context: context, message: "Login expired");
        } else {
          showSnackBar(
            context: context,
            message: "Failed to start trip. Please try again.",
          );
        }
        startTripPolling();
      }
    }
  }

  // handle complete Trip
  Future<void> handleCompleteTrip() async {
    if (tripRequestId == null) return;

    final result = await _tripApiService.completeTrip(tripRequestId!);

    if (result != null && result["success"] == true) {
      if (mounted) {
        setState(() {
          currentStep = RideStep.completed;
        });
        openSheet(Constants.maxSheetSize);
      }
    } else {
      if (mounted) {
        if (result != null && result["error_type"] == "auth_error") {
          showSnackBar(context: context, message: "Login expired");
        } else {
          showSnackBar(
            context: context,
            message: "Failed to confirm leave. Please try again.",
          );
        }
      }
    }
  }

  void _onStartLocationChanged(LatLng location, Prediction prediction) {
    setState(() {
      isSelectedFromSearch = true;
      startLocation = location;
      final streetName = prediction.description?.split('،')[0] ?? "";
      startController.text = prediction.description!;
      startStreetName = streetName;
    });

    if (startLocation != null && destinationLocation != null) {
      _initializeTrip();
    }
  }

  void _clearStartLocationSearch() {
    setState(() {
      startController.clear();
      startLocation = null;
      startStreetName = null;
      clearRoute();
    });
  }

  void _onDestinationChanged(LatLng location, Prediction prediction) {
    setState(() {
      isSelectedFromSearch = true;
      destinationLocation = location;
      destinationStreetName = prediction.description?.split('،')[0] ?? "";
      destinationController.text = prediction.description!;
    });

    if (startLocation != null && destinationLocation != null) {
      _initializeTrip();
    }
  }

  void _clearDestinationLocationSearch() {
    setState(() {
      destinationController.clear();
      destinationLocation = null;
      destinationStreetName = null;
      clearRoute();
    });
  }

  void _initializeTrip() {
    startFocusNode.unfocus();
    destinationFocusNode.unfocus();
    FocusScope.of(context).unfocus();

    openSheet(Constants.minSheetSize);

    if (startLocation != null && destinationLocation != null) {
      updateRoute(startLocation!, destinationLocation!, focus: true);
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        currentStep = RideStep.confirmTrip;
      });

      openSheet(Constants.tripSummary);
    });
  }

  void _handleLocationGPSPressed() {
    if (currentLocation == null) return;

    if (hasRoute && startLocation != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(startLocation!, 16),
      );
    } else {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation!, 16),
      );
    }
  }

  // listen To Trip Updates
  void listenToTripUpdates() {
    sseTripSubscription?.cancel();
    isFirstVehicleLocationLoaded = false;

    if (tripRequestId == null) return;

    sseTripSubscription = _tripApiService
        .streamTripLiveUpdates(tripRequestId!)
        .listen(
          (payload) {
            if (!mounted) return;

            final double? lat = payload['lat'] != null
                ? (payload['lat'] as num).toDouble()
                : null;
            final double? lng = payload['lon'] != null
                ? (payload['lon'] as num).toDouble()
                : null;

            if (lat != null &&
                lng != null &&
                currentStep == RideStep.pickingUp) {
              LatLng newVehicleLocation = LatLng(lat, lng);

              setState(() {
                if (vehicleLiveLocation != null) {
                  double rawCalculatedBearing = Geolocator.bearingBetween(
                    vehicleLiveLocation!.latitude,
                    vehicleLiveLocation!.longitude,
                    newVehicleLocation.latitude,
                    newVehicleLocation.longitude,
                  );

                  double diff = rawCalculatedBearing - vehicleBearing;
                  if (diff > 180) diff -= 360;
                  if (diff < -180) diff += 360;

                  vehicleBearing = (vehicleBearing + 0.3 * diff) % 360;
                } else {
                  vehicleBearing = 0.0;
                }
                vehicleLiveLocation = newVehicleLocation;
              });

              if (startLocation != null) {
                updateRoute(newVehicleLocation, startLocation!, focus: false);
              }

              if (!isFirstVehicleLocationLoaded) {
                isFirstVehicleLocationLoaded = true;
                openSheet(Constants.pickingUpSize);

                followLiveCamera(newVehicleLocation, bearing: vehicleBearing);
              } else if (!isMapMoving) {
                followLiveCamera(newVehicleLocation, bearing: vehicleBearing);
              }
            }
          },
          onError: (error) {
            print("SSE Error in Home: $error");
          },
        );
  }

  void _loadCustomMarker() async {
    carMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/autonomous-car.png',
    );
    if (mounted) setState(() {});
  }

  Set<Circle> getCircles() {
    Set<Circle> circlesSet = {};
    if (startLocation != null && currentStep == RideStep.pickingUp) {
      circlesSet.add(
        Circle(
          circleId: const CircleId("pickup_ripple"),
          center: startLocation!,
          radius: 40,
          fillColor: PrimaryColor.withValues(alpha: 0.15),
          strokeColor: PrimaryColor.withValues(alpha: 0.4),
          strokeWidth: 2,
        ),
      );
    }
    return circlesSet;
  }

  void _resetToHomeScreen() {
    tripPollingTimer?.cancel();
    sseTripSubscription?.cancel();
    positionStream?.cancel();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
      (route) => false,
    );
  }

  Future<void> _fetchUserProfileData() async {
    final data = await _profileApiService.getUserProfile();

    if (data != null && data["error_type"] == null) {
      setState(() {
        profileResponseData = data;
        isLoadingProfile = false;
      });
    } else {
      setState(() {
        isLoadingProfile = false;
      });
      if (data?["error_type"] == "auth_error") {
        print("Session expired, user needs to login again.");
      }
    }
  }

  // init State
  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    _fetchUserProfileData();

    currentLocationStream();

    sheetController.addListener(() {
      if (!mounted) return;

      final newSize = sheetController.size;
      if ((sheetSize - newSize).abs() > 0.01) {
        setState(() {
          sheetSize = newSize;
        });
      }
    });

    _startFocusListener = () {
      if (startFocusNode.hasFocus) {
        openSheet(Constants.maxSheetSize);
      }
    };
    startFocusNode.addListener(_startFocusListener);

    _destinationFocusListener = () {
      if (destinationFocusNode.hasFocus) {
        openSheet(Constants.maxSheetSize);
      }
    };
    destinationFocusNode.addListener(_destinationFocusListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      openSheet(Constants.collapseSheetSize);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // String? status = message.data['status'];
      String title = message.notification?.title ?? "";
      String body = message.notification?.body ?? "";
      print("----------------------------------");
      print("title: $title");
      print("body: $body");
      print("----------------------------------");

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: title,
        desc: body,
        btnOkOnPress: () {},
      ).show();
    });
  }

  // dispose
  @override
  void dispose() {
    startController.dispose();
    destinationController.dispose();

    startFocusNode.removeListener(_startFocusListener);
    destinationFocusNode.removeListener(_destinationFocusListener);

    sheetController.dispose();
    mapController?.dispose();
    positionStream?.cancel();

    tripPollingTimer?.cancel();

    sseTripSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      drawer: AppDrawer(
        userData: profileResponseData,
        onProfileUpdated: (updatedData) {
          setState(() {
            profileResponseData = updatedData;
          });
        },
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator(color: PrimaryColor))
          : Stack(
              children: [
                // Google map
                Positioned.fill(
                  child: GoogleMap(
                    mapType: MapType.normal,

                    markers: getMarkers(),

                    polylines: polylines,

                    circles: getCircles(),

                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,

                    initialCameraPosition: CameraPosition(
                      target: currentLocation!,
                      zoom: 16,
                    ),

                    onTap: (_) {
                      openSheet(Constants.collapseSheetSize);
                    },

                    onCameraMove: (position) {
                      lastCameraPosition = position;

                      if (!isMapMoving) {
                        setState(() => isMapMoving = true);

                        if (isFirstTime) {
                          isFirstTime = false;
                        } else if (currentStep == RideStep.initial) {
                          openSheet(Constants.minSheetSize);
                        }
                      }
                    },

                    onCameraIdle: () async {
                      if (!mounted || lastCameraPosition == null) return;

                      if (currentStep == RideStep.searchingVehicle ||
                          currentStep == RideStep.offer) {
                        setState(() {
                          isMapMoving = false;
                        });
                        return;
                      }

                      if (isSelectedFromSearch) {
                        setState(() {
                          isSelectedFromSearch = false;
                          isMapMoving = false;
                          if (!hasRoute) {
                            openSheet(Constants.collapseSheetSize);
                          } else {
                            openSheet(Constants.minSheetSize);
                          }
                        });

                        return;
                      }

                      LatLng targetLocation = lastCameraPosition!.target;

                      setState(() {
                        isMapMoving = false;
                      });

                      String street = await _locationService.getStreetName(
                        targetLocation,
                      );

                      if (!mounted) return;

                      if (!hasRoute) {
                        setState(() {
                          startLocation = targetLocation;
                          startStreetName = street;
                          startController.text = street;
                        });

                        openSheet(Constants.collapseSheetSize);
                      }
                    },

                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  ),
                ),

                if (!hasRoute) MapCenterPin(isMapMoving: isMapMoving),

                // info window
                MapInfoWindow(
                  startStreetName: startStreetName,
                  isMapMoving: isMapMoving,
                  sheetSize: sheetSize,
                  showInfoWindow: showInfoWindow,
                  onTap: () {
                    setState(() {
                      currentStep = RideStep.search;
                    });
                    openSheet(Constants.maxSheetSize);
                  },
                ),

                MapDrawerButton(
                  isMapMoving: isMapMoving,
                  sheetSize: sheetSize,
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),

                MapLocationButton(
                  isMapMoving: isMapMoving,
                  sheetSize: sheetSize,
                  hasRoute: hasRoute,
                  onPressed: _handleLocationGPSPressed,
                ),

                MapFocusRouteButton(
                  hasRoute: hasRoute,
                  polylineCoordinates: polylineCoordinates,
                  isMapMoving: isMapMoving,
                  sheetSize: sheetSize,
                  onPressed: focusOnRoute,
                ),

                // Bottom Sheet
                DraggableScrollableSheet(
                  controller: sheetController,

                  initialChildSize: Constants.collapseSheetSize,
                  minChildSize: Constants.minSheetSize,
                  maxChildSize: Constants.maxSheetSize,

                  builder: (context, scrollController) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),

                      child: ListView(
                        controller: scrollController,

                        children: [
                          Icon(Icons.drag_handle),

                          Gap(10),

                          Visibility(
                            visible: currentStep.index <= 1,
                            maintainState: true,
                            child: currentStep == RideStep.initial
                                ? GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();

                                      setState(() {
                                        currentStep = RideStep.search;
                                      });
                                      openSheet(Constants.maxSheetSize);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: PrimaryColor,
                                          ),
                                          const Gap(12),
                                          const Text(
                                            "Where to?",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : LocationSearch(
                                    startController: startController,
                                    destinationController:
                                        destinationController,
                                    startFocusNode: startFocusNode,
                                    destinationFocusNode: destinationFocusNode,
                                    mapController: mapController,
                                    googleApiConfig: googleApiConfig,
                                    onStartLocationChanged:
                                        _onStartLocationChanged,
                                    onDestinationChanged: _onDestinationChanged,
                                    clearStartLocationSearch:
                                        _clearStartLocationSearch,
                                    clearDestinationLocationSearch:
                                        _clearDestinationLocationSearch,
                                  ),
                          ),

                          if (currentStep == RideStep.confirmTrip)
                            ConfirmTripWidget(
                              startStreetName:
                                  startStreetName ?? "Current Location",
                              destinationStreetName: destinationStreetName!,
                              onRequestPressed: () async {
                                await startTripFlow();
                              },
                              onEditPressed: () {
                                startFocusNode.unfocus();
                                destinationFocusNode.unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();

                                setState(() {
                                  currentStep = RideStep.search;
                                });

                                openSheet(Constants.maxSheetSize);
                              },
                              distance: tripDistance,
                              duration: tripDuration,
                            ),

                          if (currentStep == RideStep.searchingVehicle)
                            SearchingVehicleWidget(
                              onCancelSearch: () async {
                                await handleCancelTrip();
                              },
                            ),

                          if (currentStep == RideStep.offer)
                            TripOfferWidget(
                              startStreetName:
                                  startStreetName ?? "Current Location",
                              destinationStreetName: destinationStreetName!,
                              estimatedTime: offerTime ?? 0,
                              estimatedFare: offerFare ?? 0,
                              distance: tripDistance ?? 0,
                              acceptOffer: () async {
                                setState(() {
                                  currentStep = RideStep.payment;
                                });
                                openSheet(Constants.maxSheetSize);

                                startTripPolling();
                              },
                              declineOffer: handleDeclineOffer,
                            ),

                          if (currentStep == RideStep.payment)
                            PaymentWidget(
                              estimatedFare: offerFare ?? 0.0,
                              onPaymentSuccess: () async {
                                bool isTripActivated =
                                    await handleAcceptOffer();

                                if (isTripActivated && mounted) {
                                  setState(() {
                                    currentStep = RideStep.pickingUp;
                                  });

                                  openSheet(Constants.minSheetSize);

                                  listenToTripUpdates();
                                }
                              },
                              tripRequestId: tripRequestId!,
                            ),

                          if (currentStep == RideStep.pickingUp)
                            PickingUpWidget(
                              startStreetName:
                                  startStreetName ?? "Current Location",
                              distance: tripDistance,
                              duration: tripDuration,
                            ),

                          if (currentStep == RideStep.safetyCheck)
                            SafetyCheckWidget(
                              onStartRidePressed: () async {
                                await handleStartTrip();
                              },
                            ),

                          if (currentStep == RideStep.enRoute)
                            EnRouteWidget(
                              destinationStreetName:
                                  destinationStreetName ?? "Destination",
                              distance: tripDistance,
                              duration: tripDuration,
                            ),

                          if (currentStep == RideStep.checkout)
                            TripCheckoutWidget(
                              onEndTripPressed: () async {
                                await handleCompleteTrip();
                              },
                            ),

                          if (currentStep == RideStep.completed)
                            TripCompleteWidget(
                              onSubmitRating: (rating, comment) {
                                _resetToHomeScreen();
                              },
                              onSkipRating: () {
                                _resetToHomeScreen();
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
